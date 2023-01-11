#ifndef __PERIDOT_SDIF_FF_H__
#define __PERIDOT_SDIF_FF_H__

// ************************************************************************
// TITLE : PERIDOT SDIF FatFs Software package
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2019/08/30
//            : 2022/02/07
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

#include <stddef.h>
#include <alt_types.h>
#include <sys/alt_dev.h>
#include "system.h"
#include "../src/ff13c/ff.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

typedef struct {
	alt_dev hal_dev;
	FATFS fatfs_work;
} peridot_sdif_ff_dev;


/* ファイルオープン */
int dev_mmcfs_open(
		alt_fd *fd,
		const char *name,
		int flags,			// ファイルオープンフラグ 
		int mode);			// 使用しない 

/* ファイルクローズ */
int dev_mmcfs_close(
		alt_fd *fd);

/* ファイルリード */
int dev_mmcfs_read(
		alt_fd *fd,
		char *ptr,
		int len);

/* ファイルライト */
int dev_mmcfs_write(
		alt_fd *fd,
		const char *ptr,
		int len);

/* ファイルシーク */
int dev_mmcfs_lseek(
		alt_fd *fd,
		int ptr,
		int dir);

/* ファイルステータス */
int dev_mmcfs_fstat(
		alt_fd *fd,
		struct stat *buf);

/* 初期化 */
int dev_mmcfs_setup(peridot_sdif_ff_dev *dev);



/* HALインスタンスマクロ */

#define PERIDOT_SDIF_FF_INSTANCE(name, dev) peridot_sdif_ff_dev dev = \
{								\
	{							\
		ALT_LLIST_ENTRY,		\
		SDIF_FF_MOUNT_POINT,	\
		dev_mmcfs_open,			\
		dev_mmcfs_close,		\
		dev_mmcfs_read,			\
		dev_mmcfs_write,		\
		dev_mmcfs_lseek,		\
		dev_mmcfs_fstat,		\
		NULL					\
	},							\
}

#define PERIDOT_SDIF_FF_INIT(name, dev) dev_mmcfs_setup(&dev)



#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __PERIDOT_SDIF_FF_H__ */
