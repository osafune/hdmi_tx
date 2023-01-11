#ifndef __PERIDOT_SDIF_REGS_H__
#define __PERIDOT_SDIF_REGS_H__

// ************************************************************************
// TITLE : PERIDOT SDIF ドライバ
//				レジスタ設定
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

#include <io.h>

#define IOADDR_PERIDOT_SDIF_CONTROL(base)		__IO_CALC_ADDRESS_NATIVE(base, 0)
#define IORD_PERIDOT_SDIF_CONTROL(base)			IORD(base, 0) 
#define IOWR_PERIDOT_SDIF_CONTROL(base, data)	IOWR(base, 0, data)

#define IOADDR_PERIDOT_SDIF_DIVREF(base)		__IO_CALC_ADDRESS_NATIVE(base, 1)
#define IORD_PERIDOT_SDIF_DIVREF(base)			IORD(base, 1) 
#define IOWR_PERIDOT_SDIF_DIVREF(base, data)	IOWR(base, 1, data)

#define IOADDR_PERIDOT_SDIF_FRC(base)			__IO_CALC_ADDRESS_NATIVE(base, 2)
#define IORD_PERIDOT_SDIF_FRC(base)				IORD(base, 2) 
#define IOWR_PERIDOT_SDIF_FRC(base, data)		IOWR(base, 2, data)

#define IOADDR_PERIDOT_SDIF_STR(base)			__IO_CALC_ADDRESS_NATIVE(base, 3)
#define IORD_PERIDOT_SDIF_STR(base)				IORD(base, 3) 
#define IOWR_PERIDOT_SDIF_STR(base, data)		IOWR(base, 3, data)

#define PERIDOT_SDIF_IRQ_BITMASK		(1<<15)
#define PERIDOT_SDIF_PWR_BITMASK		(1<<14)
#define PERIDOT_SDIF_CDALT_BITMASK		(1<<13)
#define PERIDOT_SDIF_ZF_BITMASK			(1<<12)
#define PERIDOT_SDIF_CD_BITMASK			(1<<10)
#define PERIDOT_SDIF_READY_BITMASK		(1<<9)
#define PERIDOT_SDIF_SD_BITMASK			(1<<8)

#define PERIDOT_SDIF_IRQ_ENABLE			(1<<15)
#define PERIDOT_SDIF_IRQ_DISABLE		(0<<15)
#define PERIDOT_SDIF_PWR_ON				(1<<14)
#define PERIDOT_SDIF_PWR_OFF			(0<<14)
#define PERIDOT_SDIF_START				(1<<9)
#define PERIDOT_SDIF_SD_ASSERT			(1<<8)
#define PERIDOT_SDIF_SD_NEGATE			(0<<8)


#endif /* __PERIDOT_SDIF_REGS_H__ */
