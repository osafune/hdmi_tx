// ************************************************************************
// TITLE : PROCYON IPL - PERIDOT-Air改 Edition
//			アブソリュート実行elfファイルのロード＆実行 
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2011/12/28
//
//     UPDATE : 2013/04/03 NiosII SBT用に変更、内蔵メモリマクロ化 
//              2019/08/29 PERIDOT-Air改, PERIDOT_SDIFペリフェラル専用 
//              2020/10/01 usage修正 
//
// ************************************************************************
//
// The MIT License (MIT)
// Copyright (c) 2011-2020 J-7SYSTEM WORKS LIMITED.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

/*
【　機能　】
	SDカードからelfファイルをメモリにロードして実行する

【必須リソース】
	・NiosIIのリセットベクタとして8kバイトの内蔵メモリマクロまたはUFM
		UFMの場合は別途rwdata,bss,heap,stack領域用に2kバイトのメモリ
	・プログラムを外部RAMに展開して実行できるバス構成 
	・PERIDOT_SDIFペリフェラル 
	・１灯以上のLED(PIOペリフェラルを想定)

【ペリフェラル名】
	・内蔵メモリマクロ : SBTでリセットベクタに指定した8kバイト以上のエリア
	・SDカードI/F      : PERIDOT_SDIFクラスのペリフェラル (名称はBSPでperidot_sdif_pffに設定)
	・LEDペリフェラル  : led またはALTERA_AVALON_PIOクラスのペリフェラル 
	・DE等の7セグLED   : led_7seg (オプション)


【アプリケーション設定】
◆プロジェクトテンプレート
	・Hello World Smallでプロジェクトを生成 
		生成されたhelloworld.cを削除して elfboot.c をコピー
	・NiosII->Propertiesの"NiosII Application Properties"のOptimization levelを"Size"に設定


【BSP設定】
◆Mainタブ
　Hello World Smallで生成した場合はデフォルトでこの値に設定されている。
　下記の項目以外は全てデフォルトのままにしておく。

　● Settings->Commmon->hal
	・sys_clk_timer/timestamp_timer はnone (※必ずnoneにすること)
	・stderr/stdin/stdout はJTAG-UARTまたはnone
	・■ enable_small_c_library (チェック)
	・□ enable_gprof
	・■ enable_reduced_device_drivers (チェック)
	・□ enable_sim_optimize

　● Settings->Commmon->hal.make
	・bsp_cflags_debug は-gオプションのまま
	・bsp_cflags_optimization を'-Os'にする
	・cflags_mgpopt はglobalのまま

　● Settings->Advanced->hal
	・□ enable_instruction_related_exceptions_api
	・log_port はnoneのまま
	・□ enable_exit
	・□ enable_clean_exit
	・□ enable_runtime_stack_checking
	・□ enable_c_plus_plus
	・■ enable_lightweight_device_driver_api (チェック)
	・□ enable_mul_div_emulation (NiosII/eの場合は自動的にチェックが入る)
	・■ enable_sopc_sysid_check (チェック)
	・custom_newlib_flags はnoneのまま
	・log_flags は0のまま

　● Settings->Advanced->hal.linker
	・■ allow_code_at_reset (チェック)
	・■ enable_alt_load (チェック)
	・□ enable_alt_load_copy_rodata
	・■ enable_alt_load_copy_rwdata (チェック)
	・□ enable_alt_load_copy_exceptions


◆Software Packagesタブ
　● peridot_sdif_pff にチェック
  	・instance_name に PERIDOT_SDIFペリフェラルのインスタンス名を記入 (小文字)
	・■ enable_elfboot_function (チェック)
	・■ use_read_function (チェック)
	・□ use_dir_function
	・■ use_lseek_function (チェック)
	・□ use_write_function
	・□ supoort_fat12
	・■ supoort_fat16 (チェック)
	・■ supoort_fat32 (チェック)


◆Linker Scriptタブ
	・全てのセクションのLinker Region Nameを内蔵メモリマクロにする


【メモリ初期化データ生成】
	・ビルド後、elfファイルを右クリック→Make Targets→Buildをクリック
	・mem_init_generateを選択してBuildをクリック
	・プロジェクトのmem_initフォルダに生成されたhexファイルをQuartusプロジェクトに追加してコンパイル


【ロードするアプリケーション側のBSP】

◆Mainタブ
　● Settings->Advanced->hal.linker
	・□ allow_code_at_reset (チェックをはずす)
	・□ enable_alt_load (チェックをはずす)

◆Linker Scriptタブ
	・全てのセクションのLinker Region NameをSDRAM等のメモリリソースにする


*/

#include "system.h"
#include "linker.h"
#include <io.h>
#include <sys/alt_cache.h>
#include <peridot_sdif.h>
#include <peridot_sdif_regs.h>
#include <peridot_sdif_pff.h>

// ブートローダーサポート 
#if defined(PERIDOT_SDIF_USE_ELFBOOT)


// 表示用のLEDペリフェラル 
#if defined(LED_7SEG_BASE)
 #define ELFLOADER_LED_ON(_x)		IOWR(LED_7SEG_BASE, 0, (_x))	// 7セグがあれば表示 
 #define ELFLOADER_LED_OFF()		IOWR(LED_7SEG_BASE, 0, ~0)		// 7セグ消灯 
#elif defined(LED_BASE)
 #define ELFLOADER_LED_ON(_x)		IOWR(LED_BASE, 0, ~0)			// LEDの点灯 
 #define ELFLOADER_LED_OFF()		IOWR(LED_BASE, 0, 0)			// LEDの消灯 
#else
 #define ELFLOADER_LED_ON(_x)
 #define ELFLOADER_LED_OFF()
#endif


// デバッグ用表示スイッチ 
//#define _DEBUG_


/***** ELFファイル型定義 **************************************************/

// ELFファイルの変数型宣言 
typedef void*			ELF32_Addr;
typedef unsigned short	ELF32_Half;
typedef unsigned long	ELF32_Off;
typedef long			ELF32_Sword;
typedef unsigned long	ELF32_Word;
typedef unsigned char	ELF32_Char;

// ELFファイルヘッダ構造体 
typedef struct {
	ELF32_Char		elf_id[16];		// ファイルID 
	ELF32_Half		elf_type;		// オブジェクトファイルタイプ 
	ELF32_Half		elf_machine;	// ターゲットアーキテクチャ 
	ELF32_Word		elf_version;	// ELFファイルバージョン(現在は1) 
	ELF32_Addr		elf_entry;		// エントリアドレス(エントリ無しなら0) 
	ELF32_Off		elf_phoff;		// Programヘッダテーブルのファイル先頭からのオフセット 
	ELF32_Off		elf_shoff;		// 実行時未使用
	ELF32_Word		elf_flags;		// プロセッサ固有のフラグ 
	ELF32_Half		elf_ehsize;		// ELFヘッダのサイズ 
	ELF32_Half		elf_phentsize;	// Programヘッダテーブルの1要素あたりのサイズ 
	ELF32_Half		elf_phnum;		// Programヘッダテーブルの要素数 
	ELF32_Half		elf_shentsize;	// 実行時未使用
	ELF32_Half		elf_shnum;		// 実行時未使用
	ELF32_Half		elf_shstrndx;	// 実行時未使用
} __attribute__ ((packed)) ELF32_HEADER;

// Programヘッダ構造体 
typedef struct {
	ELF32_Word		p_type;			// セグメントのエントリタイプ 
	ELF32_Off		p_offset;		// 対応するセグメントのファイル先頭からのオフセット 
	ELF32_Addr		p_vaddr;		// セグメントの第一バイトを配置する実行時の論理アドレス 
	ELF32_Addr		p_paddr;		// セグメントの第一バイトを配置する物理メモリアドレス
	ELF32_Word		p_filesz;		// 対応するセグメントのファイルでのサイズ(0も可)
	ELF32_Word		p_memsz;		// 対応するセグメントのメモリ上に展開された時のサイズ(0も可)
	ELF32_Word		p_flags;		// 対応するセグメントに適切なフラグ 
	ELF32_Word		p_align;		// アライメント(p_offsetとp_vaddrをこの値で割った余りは等しい)
} __attribute__ ((packed)) ELF32_PHEADER;

// ELFオブジェクトファイルタイプの定数宣言 
#define ELF_ET_EXEC		(2)			// 実行可能なオブジェクトファイル 
#define ELF_EM_NIOS2	(0x0071)	// Altera NiosII Processor
#define ELF_PT_LOAD		(1)			// 実行時にロードされるセグメント 



/**************************************************************************
	アブソリュートelfファイルのロード 
 **************************************************************************/

/* デバッグ用printf */
#ifdef _DEBUG_
 #include <stdio.h>
 #define dgb_printf(...) printf(__VA_ARGS__)
#else
 #define dgb_printf(...)
#endif


/* elfファイルをメモリに展開 */
static ELF32_HEADER eh;		// elfファイルヘッダ	(※メモリ使用領域確認のためstackから外している) 
static ELF32_PHEADER ph;	// elfセクションヘッダ	(※メモリ使用領域確認のためstackから外している) 

static inline int nd_elfload(alt_u32 *entry_addr)
{
	int phnum;
	alt_u32 phy_addr,sec_size;
	UINT res_byte;
	DWORD f_pos;


	/* elfヘッダファイルのチェック */

	if (pf_lseek(0) != FR_OK) return -1;
	if (pf_read(&eh, sizeof(ELF32_HEADER), &res_byte) != FR_OK) return -1;

	if (eh.elf_id[0] != 0x7f ||				// ELFヘッダのチェック 
			eh.elf_id[1] != 'E' ||
			eh.elf_id[2] != 'L' ||
			eh.elf_id[3] != 'F') {
		return -2;
	}
	if (eh.elf_type != ELF_ET_EXEC) {		// オブジェクトタイプのチェック 
		return -2;
	}
	if (eh.elf_machine != ELF_EM_NIOS2) {	// ターゲットCPUのチェック 
		return -2;
	}

	*entry_addr = (alt_u32)eh.elf_entry;	// エントリアドレスの取得 


	/* セクションデータをロード */

	f_pos = (DWORD)eh.elf_ehsize;
	for (phnum=1 ; phnum<=eh.elf_phnum ; phnum++) {

		// Programヘッダを読み込む 
		if (pf_lseek(f_pos) != FR_OK) return -1;
		if (pf_read(&ph, eh.elf_phentsize, &res_byte) != FR_OK) return -1;
		f_pos += eh.elf_phentsize;

		// セクションデータをメモリに展開 
		if(ph.p_type == ELF_PT_LOAD && ph.p_filesz > 0) {
			dgb_printf("- Section %d -----\n",phnum);
			dgb_printf("  Mem address : 0x%08x\n",(unsigned int)ph.p_vaddr);
			dgb_printf("  Phy address : 0x%08x\n",(unsigned int)ph.p_paddr);
			dgb_printf("  Image size  : %d bytes(0x%08x)\n",(int)ph.p_filesz, (unsigned int)ph.p_filesz);
			dgb_printf("  File offset : 0x%08x\n",(unsigned int)ph.p_offset);

			if (pf_lseek(ph.p_offset) != FR_OK) return -1;
			phy_addr = (alt_u32)ph.p_paddr;
			sec_size = ph.p_filesz;

			if (phy_addr == RESET_REGION_BASE || phy_addr == BOOT_REGION_BASE) {
				dgb_printf("  * igonre load section\n");
				break;
			}

			if (pf_read((void*)phy_addr, (UINT)sec_size, &res_byte) != FR_OK) return -1;
		}
	}

	return 0;
}


/* elfファイルのロードと実行 */
extern peridot_sdif_dev PERIDOT_SDIF_INST_NAME;		// peridot_sdifハンドラ 
extern peridot_sdif_pff_dev peridot_sdif_pff;		// pffハンドラ 

inline void pf_boot(const char *boot_filename)
{
	FRESULT res;
	void (*pProc)();
	alt_u32 ledcode=0, entry_addr=0;
	const char *elf_fname;

	dgb_printf("\n*** ELF LOADING ***\n");
	ELFLOADER_LED_OFF();


	/* ELFファイル名の取得 */

	elf_fname = (const char *)IORD_PERIDOT_SDIF_STR( (& PERIDOT_SDIF_INST_NAME)->base );
	if (elf_fname == NULL) elf_fname = boot_filename;


	/* SDカードの初期化確認 */

	dgb_printf("Disk check ... ");

	if (peridot_sdif_pff.init_res != FR_OK) {
		dgb_printf("fail(%d)\n", peridot_sdif_pff.init_res);

		ledcode = ~0x7950d006;					// ディスク初期化エラー Err.1 
		goto BOOT_FAILED;
	}
	dgb_printf("done.\n");

	ELFLOADER_LED_ON(~0x7c5c5c78);				// boot表示 


	/* ファイルを開く */

	dgb_printf("Open \"%s\"\n", elf_fname);

	res = pf_open( elf_fname );
	if (res != FR_OK) {
		dgb_printf("[!] f_open fail(%d)\n", (int)res);

		ledcode = ~0x7950d05b;					// ファイルオープンエラー Err.2 
		goto BOOT_FAILED;
	}


	/* ELFファイルの読み込み */

	if (nd_elfload(&entry_addr) != 0) {
		dgb_printf("[!] elf-file read error.\n");

		ledcode = ~0x7950d04f;					// ファイルリードエラー Err.3 
		goto BOOT_FAILED;
	}


	/* elfファイル実行 */

	dgb_printf("Entry address : 0x%08x\n",(unsigned int)entry_addr);
	dgb_printf("elf file execute.\n\n");

	ELFLOADER_LED_ON(~0x501c5400);				// run表示 

	pProc = (void (*)())entry_addr;

	alt_dcache_flush_all();
	alt_icache_flush_all();
	(*pProc)();


	/* ブート失敗 */

  BOOT_FAILED:
	peridot_sdif_pwr_off(& PERIDOT_SDIF_INST_NAME);

	while(1) {									// エラーコードを点滅表示 
		ELFLOADER_LED_OFF();
		peridot_sdif_wait_ms(& PERIDOT_SDIF_INST_NAME, 200);

		ELFLOADER_LED_ON(ledcode);
		peridot_sdif_wait_ms(& PERIDOT_SDIF_INST_NAME, 300);
	}
}


#endif	// PERIDOT_SDIF_USE_ELFBOOT
