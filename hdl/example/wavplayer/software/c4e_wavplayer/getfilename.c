/* WAVファイル名を取得                                     */
/*                                                         */
/*   The MIT License (MIT)                                 */
/*   Copyright (c) 2023 J-7SYSTEM WORKS LTD.               */
/*   http://opensource.org/licenses/mit-license.php        */

#include "system.h"
#include <peridot_sdif_pff.h>
#include <string.h>


// ディレクトリオブジェクト 

static DIR fatfs_dir;					// FatFsディレクトリオブジェクト 
static FILINFO fatfs_fno;				// FatFsファイル情報オブジェクト 


// 拡張子が".WAV"かどうか調べる 

static int check_extwav(const char *fn)
{
	int i;

	i = strlen(fn);
	if (i == 0) return 0;

	fn += i-1;		// 一番最後の文字へ移動 

	if ( *fn != 'v' && *fn != 'V') return 0;
	fn--;
	if ( *fn != 'a' && *fn != 'A') return 0;
	fn--;
	if ( *fn != 'w' && *fn != 'W') return 0;
	fn--;
	if ( *fn != '.') return 0;

	return 1;
}


// ディレクトリのオープン 

int open_wavdir(const char *path)
{
	FRESULT res;

	res = pf_opendir(&fatfs_dir, path);
	if (res != FR_OK) return -1;

	return 0;
}


// ディレクトリのWAVファイルを１つ取得 

char *get_wavfilename(void)
{
	FRESULT res;
	char *fn = NULL;

	for(;;) {
		res = pf_readdir(&fatfs_dir, &fatfs_fno);
		if (res != FR_OK || fatfs_fno.fname[0] == 0) {	// エラーまたはもうファイルがない 
			fn = NULL;
			break;
		}

		if (fatfs_fno.fname[0] == '.') continue;		// ドットエントリの場合はリトライ 

		if (fatfs_fno.fattrib & AM_DIR) continue;		// ディレクトリの場合もリトライ 

		fn = fatfs_fno.fname;
		if ( !check_extwav(fn) ) continue;				// .wavファイルでなければリトライ 

		break;
	}

	return fn;
}


