// ************************************************************************
// TITLE : PERIDOT SDIF ドライバ
//				ファイルサブシステム関数 (NiosII HAL version)
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2019/09/01
//
// ************************************************************************
//
// The MIT License (MIT)
// Copyright (c) 2019 J-7SYSTEM WORKS LIMITED.
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

#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/alt_warning.h>

#include "system.h"
#include "peridot_sdif_ff.h"


/* ファイルデスクリプタテーブル */

static int dev_mmcfs_fd_num;					// ファイルデスクリプタスタック 
static int dev_mmcfs_fd[ ALT_MAX_FD ];
static FIL dev_mmcfs_table[ ALT_MAX_FD ];		// ファイルオブジェクトテーブル 


/* ファイルオープン */

int dev_mmcfs_open(
		alt_fd *fd,
		const char *name,
		int flags,			// ファイルオープンフラグ 
		int mode)			// 使用しない 
{
	FIL fsobj;
	FRESULT fatfs_res;
	BYTE fatfs_mode = 0;
	int fd_num;
	int str_offset;

	str_offset = strlen(fd->dev->name);

	// ファイルデスクリプタの取得 
	if( dev_mmcfs_fd_num == 0 ) return -ENFILE;


	// オープンモードの変換 
	switch( flags & 3 ) {
	default:
		return -EINVAL;

	case O_RDONLY:
		fatfs_mode = FA_OPEN_EXISTING | FA_READ;
		break;

	case O_WRONLY:
		if(flags & O_APPEND) {
			fatfs_mode = FA_OPEN_ALWAYS | FA_WRITE;
		} else {
			fatfs_mode = FA_CREATE_ALWAYS | FA_WRITE;
		}
		break;

	case O_RDWR:
		if(flags & O_APPEND) {
			fatfs_mode = FA_OPEN_ALWAYS | FA_READ | FA_WRITE;
		} else if(flags & O_CREAT) {
			fatfs_mode = FA_CREATE_ALWAYS | FA_READ | FA_WRITE;
		} else {
			fatfs_mode = FA_OPEN_EXISTING | FA_READ | FA_WRITE;
		}
		break;
	}

	// ファイルオープン 
	fatfs_res = f_open(&fsobj, name+str_offset, fatfs_mode);
	if( fatfs_res != FR_OK ) return -ENOENT;

	// ファイルデスクリプタ取得 
	dev_mmcfs_fd_num--;
	fd_num = dev_mmcfs_fd[dev_mmcfs_fd_num];
	dev_mmcfs_table[fd_num] = fsobj;

	fd->priv = (void *)&dev_mmcfs_table[fd_num];
	fd->fd_flags = fd_num;

	return fd_num;
}


/* ファイルクローズ */

int dev_mmcfs_close(
		alt_fd *fd)
{
	FIL *fp = (FIL *)fd->priv;
	FRESULT fatfs_res;
	int fd_num;

	// ファイルクローズ 
	fd_num = fd->fd_flags;

	fatfs_res = f_close(fp);
	if( fatfs_res != FR_OK ) return -EIO;

	// ファイルデスクリプタ返却 
	dev_mmcfs_fd[dev_mmcfs_fd_num] = fd_num;
	dev_mmcfs_fd_num++;

	fd->priv = NULL;
	fd->fd_flags = -1;

	return 0;
}


/* ファイルリード */

int dev_mmcfs_read(
		alt_fd *fd,
		char *ptr,
		int len)
{
	FIL *fp = (FIL *)fd->priv;
	FRESULT fatfs_res;
	UINT readsize;

	fatfs_res = f_read(fp, ptr, len, &readsize);
	if( fatfs_res != FR_OK ) return -EIO;

	return (int)readsize;
}


/* ファイルライト */

int dev_mmcfs_write(
		alt_fd *fd,
		const char *ptr,
		int len)
{
	FIL *fp = (FIL *)fd->priv;
	FRESULT fatfs_res;
	UINT writesize;

	fatfs_res = f_write(fp, ptr, len, &writesize);
	if( fatfs_res != FR_OK ) return -EIO;

	return (int)writesize;
}


/* ファイルシーク */

int dev_mmcfs_lseek(
		alt_fd *fd,
		int ptr,
		int dir)
{
	FIL *fp = (FIL *)fd->priv;
	FRESULT fatfs_res;
	FSIZE_t fpos;

	switch( dir ) {
	default:
		return -EINVAL;

	case SEEK_SET:
		fpos = ptr;
		break;

	case SEEK_CUR:
		fpos = f_tell(fp) + ptr;
		break;

	case SEEK_END:
		fpos = f_size(fp) + ptr;
		break;
	}

	// ファイルシーク実行 
	fatfs_res = f_lseek(fp, fpos);
	if( fatfs_res != FR_OK ) return -EINVAL;

	return (int)fp->fptr;
}


/* ファイルステータス */

int dev_mmcfs_fstat(
		alt_fd *fd,
		struct stat *buf)
{
	FIL *fp = (FIL *)fd->priv;

	buf->st_mode = S_IFREG;
	buf->st_rdev = 0;

	if( fp != NULL) {
		buf->st_size = (off_t)f_size(fp);
	} else {
		buf->st_size = 0;
	}

	return 0;
}


/* 初期化 */

int dev_mmcfs_setup(peridot_sdif_ff_dev *dev)
{
	int ret_code;

	// FatFs初期化 
	f_mount(&(dev->fatfs_work), "", 0);				// FatFSのマウント 

	// ファイルデスクリプタ管理テーブル初期化 
	dev_mmcfs_fd_num = 0;
	do {
		dev_mmcfs_fd[dev_mmcfs_fd_num] = dev_mmcfs_fd_num;
		dev_mmcfs_fd_num++;
	} while( dev_mmcfs_fd_num < ALT_MAX_FD );

	// ファイルシステムデバイス登録 
	ret_code = alt_fs_reg( &(dev->hal_dev) );

	return ret_code;
}


