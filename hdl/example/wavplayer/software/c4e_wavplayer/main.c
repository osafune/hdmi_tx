/* PERIDO-Air基板サンプル：WAVファイルプレイヤー           */
/*                                                         */
/*   The MIT License (MIT)                                 */
/*   Copyright (c) 2023 J-7SYSTEM WORKS LTD.               */
/*   http://opensource.org/licenses/mit-license.php        */

// usage:
//  SDカードの /peridot/wall.bmp を壁紙に表示する。 
//  BMPファイルは1280x720ピクセルの32bppまたは24bppカラーに対応。 
//  SDカードの /peridot フォルダ以下のwavファイルを順に再生する。 
//  WAVファイルは16bitデータ、2チャネルステレオ、44.1kHzサンプリングのみ対応。 

#include "system.h"
#include <io.h>
#include <peridot_sdif_pff.h>

#include "sys/alt_stdio.h"
#include "xprintf.h"
#define printf(...) xprintf(__VA_ARGS__)

#include <stdlib.h>
#include <string.h>

#include "loadbmp.h"
#include "playwav.h"
#include "getfilename.h"


// ファイルが格納されているディレクトリパス 

#define BMPFILE_NAME	"/PERIDOT/WALL.BMP"
#define WAVFILE_DIR		"/PERIDOT"

extern peridot_sdif_pff_dev peridot_sdif_pff;		// pffハンドラ 


// WAVプレイヤー 

static char playfile[13 + sizeof(WAVFILE_DIR) + 1];

int main(void)
{
	const alt_u32 dev_vga = VGA_BASE;

	void *pfb_top;
	alt_u16 *pfb;
	char *fn;

	// システム初期化 

	xdev_out(alt_putchar);

	IOWR(dev_vga, 0, 0);
	play_init();

	printf("\n\n"
		"-----------------------------\n"
		" PERIDOT-Air wav file player\n"
		"-----------------------------\n"
		"sysid : %08x-%08x\n",
		IORD(SYSID_BASE, 0), IORD(SYSID_BASE, 1)
	);


	// SDカード初期化 

	printf("Disk check ... ");

	if (peridot_sdif_pff.init_res != FR_OK) {
		printf("fail(%d)\n", peridot_sdif_pff.init_res);
		while(1) {}
	}
	printf("done.\n");


	// VGA初期化 

	pfb_top = malloc(VGA_VRAM_LINEBYTES * VGA_VRAM_VIEWHEIGHT + 1023);
	if (pfb_top == NULL) {
		printf("[!] Framebuffer allocation failure.\n");
		return -1;
	}
	pfb = (alt_u16 *)(((alt_u32)pfb_top + 1023) & ~0x3ffUL);

	IOWR(dev_vga, 1, (alt_u32)pfb);
	IOWR(dev_vga, 0, 1);


	// 画面初期化 

	if ( loadbmp(BMPFILE_NAME, pfb) ) {
		printf("Failed to load " BMPFILE_NAME "\n");
		while (1) {}
	}


	// wavファイルの連続再生 

	IOWR(BARCOLOR_BASE, 0, 0x222);		// 波形バーの色設定 
	play_setvol(0x2000, 0x2000);

	while(1) {
		fn = get_wavfilename();
		if (fn == NULL) {
			if ( open_wavdir(WAVFILE_DIR) ) {
				printf("[!] Directory open fail.\n");
				break;
			}
			continue;
		}

		strcpy(playfile, WAVFILE_DIR "/");
		strcat(playfile, fn);
		play_wav(playfile);

		while( play_status() ) {
//			if ( !(IORD(PSW_BASE, 0) & (1<<0)) ) {
//				play_stop();
//				while( !(IORD(PSW_BASE, 0) & (1<<0)) ) {}
//			}
		}
	}


	// 終了処理 

	IOWR(dev_vga, 0, 0);
	free(pfb_top);

	return 0;
}

