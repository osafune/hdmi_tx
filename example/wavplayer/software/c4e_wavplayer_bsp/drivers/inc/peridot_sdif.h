#ifndef __PERIDOT_SDIF_H__
#define __PERIDOT_SDIF_H__

// ************************************************************************
// TITLE : PERIDOT SDIF ドライバ
//				デバイスサポート関数
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2019/09/01
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
#include "peridot_sdif_regs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */


/* デバイス管理構造体 */
typedef struct {
	const alt_u32	base;
	const alt_u32	irq;
	const alt_u32	pp_count_value;
	const alt_u32	dd_count_value;
	const alt_u32	timer_100us_value;
	const alt_u32	timer_1ms_value;
} peridot_sdif_dev;


/* 初期化 */
void peridot_sdif_init(const peridot_sdif_dev *dev);

/* IRQイネーブル */
void peridot_sdif_irq_enable(const peridot_sdif_dev *dev);

/* IRQディセーブル */
void peridot_sdif_irq_disable(const peridot_sdif_dev *dev);

/* SDカードアサート */
void peridot_sdif_assert(const peridot_sdif_dev *dev);

/* SDカードネゲート */
void peridot_sdif_negate(const peridot_sdif_dev *dev);

/* SDカードへ1バイト送信 */
void peridot_sdif_sendbyte(const peridot_sdif_dev *dev, const alt_u8 data);

/* SDカードから1バイト受信 */
alt_u8 peridot_sdif_recvbyte(const peridot_sdif_dev *dev);

/* SDカードへ任意バイト送信 */
void peridot_sdif_send(const peridot_sdif_dev *dev, const alt_u8 *pdata, alt_u32 bytes);

/* SDカードから任意バイト受信 */
void peridot_sdif_recv(const peridot_sdif_dev *dev, alt_u8 *pdata, alt_u32 bytes);

/* SDカードスロットの状態が変化したかチェック */
int peridot_sdif_card_changed(const peridot_sdif_dev *dev);

/* SDカードスロットの状態を取得 */
int peridot_sdif_card_insert(const peridot_sdif_dev *dev);

/* SDカードスロット電源ON */
void peridot_sdif_pwr_on(const peridot_sdif_dev *dev);

/* SDカードスロット電源OFF */
void peridot_sdif_pwr_off(const peridot_sdif_dev *dev);

/* 通信クロックを初期化モードに設定 */
void peridot_sdif_setpp(const peridot_sdif_dev *dev);

/* 通信クロックをデータモードに設定 */
void peridot_sdif_setdd(const peridot_sdif_dev *dev);

/* 任意カウントの間待つ */
void peridot_sdif_wait(const peridot_sdif_dev *dev, const alt_u32 count);

/* 指定のmsの間待つ */
void peridot_sdif_wait_ms(const peridot_sdif_dev *dev, alt_u32 count);


/* HALインスタンスマクロ */

#define PERIDOT_SDIF_INSTANCE(name, dev) peridot_sdif_dev dev = \
{																\
	name##_BASE,												\
	name##_IRQ,													\
	(name##_FREQ - 1) / (400000*2),								\
	(name##_FREQ - 1) / (25000000*2),							\
	(name##_FREQ - 1) / 10000,									\
	(name##_FREQ - 1) / 1000									\
}

#define PERIDOT_SDIF_INIT(name, dev) peridot_sdif_init(&dev)


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __PERIDOT_SDIF_H__ */
