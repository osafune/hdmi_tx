/* WAVファイル再生ライブラリ                               */
/*                                                         */
/*   The MIT License (MIT)                                 */
/*   Copyright (c) 2023 J-7SYSTEM WORKS LTD.               */
/*   http://opensource.org/licenses/mit-license.php        */

#define USE_ISR_PLAYBACK		// 割り込みモードで再生する 

#include "system.h"
#include <io.h>
#include <peridot_sdif_pff.h>

#include "xprintf.h"
#define printf(...) xprintf(__VA_ARGS__)

#ifdef USE_ISR_PLAYBACK
 #include <sys/alt_irq.h>
#endif


// PCM再生ペリフェラル定義 

#define pcm_samplefreq					(44100)
#define pcm_status_irqenable_mask		(1<<31)
#define pcm_status_play_mask			(1<<2)
#define pcm_status_irq_mask				(1<<1)
#define pcm_status_fiforst_mask			(1<<0)
#define pcm_status_irqenable			(1<<31)
#define pcm_status_irqdisable			(0<<31)
#define pcm_status_fiforst				(1<<0)
#define pcm_volume_muteenable			(1<<31)


// 再生FIFO割り込み処理 

static unsigned int g_wavleft = 0;		// 残りのサンプル数 
static alt_u32 g_datbuff[256];			// リードデータバッファ 

static void isr_handle_pcmfifofill(void *context)
{
	const alt_u32 dev_pcm = PCM_BASE;
	FRESULT res;
	UINT readsize;
	int i,n,eof=0;

	// 割り込み要因マスク
	IOWR(dev_pcm, 0, pcm_status_irqdisable);

	// データ読み込み 
	if (g_wavleft <= 256) {		// データファイルの最期 
		n = g_wavleft;
		eof = 1;
	} else {
		n = 256;
	}

	res = pf_read(g_datbuff, (n<<2), &readsize);

	if (res == FR_OK && readsize == (n<<2)) {
		for(i=0 ; i<n ; i++) IOWR(dev_pcm, 2, g_datbuff[i]);
		g_wavleft -= n;
	} else {
		eof = 1;
	}

	// 次回処理 
	if (eof) {
		g_wavleft = 0;			// エラーまたはファイル終了 
	} else {
#ifdef USE_ISR_PLAYBACK
		IOWR(dev_pcm, 0, pcm_status_irqenable);	// 次の割り込みセット 
#endif
	}
}


// ペリフェラル初期化 

int play_init(void)
{
	const alt_u32 dev_pcm = PCM_BASE;

	IOWR(dev_pcm, 1, pcm_volume_muteenable);
	IOWR(dev_pcm, 0, pcm_status_irqdisable | pcm_status_fiforst);

	g_wavleft = 0;

#ifdef USE_ISR_PLAYBACK
	alt_ic_isr_register(PCM_IRQ_INTERRUPT_CONTROLLER_ID, PCM_IRQ, isr_handle_pcmfifofill, NULL, 0);
#endif

	return 0;
}


// 再生ステータス取得 

int play_status(void)
{
	const alt_u32 dev_pcm = PCM_BASE;

	alt_u32 pcm_status = IORD(dev_pcm, 0);

#ifndef USE_ISR_PLAYBACK
	if (g_wavleft && (pcm_status & pcm_status_irq_mask)) {	// FIFOに空きがあればキューする(ポーリングモード) 
		isr_handle_pcmfifofill(NULL);
		return 1;
	}
#endif

	return (pcm_status & pcm_status_play_mask)? 1 : 0;
}

alt_u32 play_getbuffdata(int buffpos)
{
	return g_datbuff[buffpos & 0xff];
}


// 音量設定 

int play_setvol(int vol_l, int vol_r)
{
	const alt_u32 dev_pcm = PCM_BASE;

	if (vol_l > 0x4000) vol_l = 0x4000; else if (vol_l < 0) vol_l = 0;
	if (vol_r > 0x4000) vol_r = 0x4000; else if (vol_r < 0) vol_r = 0;

	IOWR(dev_pcm, 1, (vol_r<<16) | vol_l);

	return 0;
}


// 再生停止 

int play_stop(void)
{
	const alt_u32 dev_pcm = PCM_BASE;

	IOWR(dev_pcm, 0, pcm_status_irqdisable);
	g_wavleft = 0;

	while( play_status() ) {}

	return 0;
}


// WAVファイル再生開始 

int play_wav(const char *wavname)
{
	const alt_u32 dev_pcm = PCM_BASE;

	FRESULT res;
	UINT readsize;
	unsigned char wavbuff[44];
	unsigned int wavfreq,wavsize;
	int i,stmono,samplebit,err;


	// WAVファイルを開く 

	res = pf_open(wavname);

	if(res != FR_OK) {
		printf("[!] file open failure. (code:%d)\n", res);
		return -1;
	}


	// WAVヘッダの解析(簡易版) 

	err = 1;
	res = pf_read(wavbuff, 44, &readsize);		// ヘッダ読み出し 

	if (res == FR_OK && readsize == 44) {
		if (wavbuff[8]=='W' && wavbuff[9]=='A' && wavbuff[10]=='V' && wavbuff[11]=='E' && 	// WAVチャンク 
				wavbuff[20] == 0x01) {	// リニアPCM 

			stmono    =  wavbuff[22];		// モノラル=1,ステレオ=2
			wavfreq   = (wavbuff[25]<< 8)| wavbuff[24];
			samplebit =  wavbuff[34];		// サンプルあたりのビット数 16/8
			wavsize   = (wavbuff[43]<<24)|(wavbuff[42]<<16)|(wavbuff[41]<< 8)| wavbuff[40];

			if (wavbuff[36]=='d' && wavbuff[37]=='a' && wavbuff[38]=='t' && wavbuff[39]=='a' &&
					stmono == 2 && samplebit == 16 && wavfreq == pcm_samplefreq && wavsize>=468) err = 0;
		}
	}
	if (err) {
		printf("[!] '%s' is not supported.\n", wavname);
		return -1;
	}


	// 再生開始 

	printf("wavfile : %s\n   freq %dHz / time %dsec\n",wavname, wavfreq, wavsize/(wavfreq*4));

	play_stop();								// 再生停止とFIFOリセット解除 

	res = pf_read(g_datbuff, 468, &readsize);	// 最初のセクターリード(512バイト境界にあわせる) 
	if (res == FR_OK && readsize == 468) {
		for(i=0 ; i<468/4 ; i++) IOWR(dev_pcm, 2, g_datbuff[i]);
	}
	g_wavleft = (wavsize - 468) / 4;			// 残りのサンプル数 

#ifdef USE_ISR_PLAYBACK
	IOWR(dev_pcm, 0, pcm_status_irqenable);		// 割り込み開始 
#endif

	return wavsize;								// WAVファイルサイズを返す 
}


