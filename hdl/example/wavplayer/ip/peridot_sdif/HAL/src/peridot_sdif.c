// ************************************************************************
// TITLE : PERIDOT SDIF ドライバ
//				デバイスサポート関数
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2019/08/29
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

#include <alt_types.h>

#include "peridot_sdif_regs.h"
#include "peridot_sdif.h"


/* フルドライバでのみ使う関数 */
#if !defined(ALT_USE_SMALL_DRIVERS)

/* IRQイネーブル */
void peridot_sdif_irq_enable(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);

	reg |= (PERIDOT_SDIF_IRQ_ENABLE | PERIDOT_SDIF_CDALT_BITMASK | 0xff);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
}

/* IRQディセーブル */
void peridot_sdif_irq_disable(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);

	reg &= ~PERIDOT_SDIF_IRQ_BITMASK;
	reg |= (PERIDOT_SDIF_IRQ_DISABLE | PERIDOT_SDIF_CDALT_BITMASK | 0xff);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
}

/* SDカードへ任意バイト送信 */
void peridot_sdif_send(const peridot_sdif_dev *dev, const alt_u8 *pdata, alt_u32 bytes)
{
	alt_u32 reg;

	do {
		reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);
	} while ( !(reg & PERIDOT_SDIF_READY_BITMASK) );

	reg &= ~0xff;
	reg |= (PERIDOT_SDIF_CDALT_BITMASK | PERIDOT_SDIF_START);

	while(bytes--) {
		IOWR_PERIDOT_SDIF_CONTROL(dev->base, (reg | *pdata++));
		while( !(IORD_PERIDOT_SDIF_CONTROL(dev->base) & PERIDOT_SDIF_READY_BITMASK) ) {}
	}
}

/* SDカードから任意バイト受信 */
void peridot_sdif_recv(const peridot_sdif_dev *dev, alt_u8 *pdata, alt_u32 bytes)
{
	alt_u32 reg, result;

	do {
		reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);
	} while ( !(reg & PERIDOT_SDIF_READY_BITMASK) );

	reg |= (PERIDOT_SDIF_CDALT_BITMASK | PERIDOT_SDIF_START | 0xff);

	while(bytes--) {
		IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
		do {
			result = IORD_PERIDOT_SDIF_CONTROL(dev->base);
		} while ( !(result & PERIDOT_SDIF_READY_BITMASK) );

		*pdata++ = result & 0xff;
	}
}

/* SDカードスロットの状態が変化したかチェック */
int peridot_sdif_card_changed(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);
	alt_u32 result = reg & PERIDOT_SDIF_SD_BITMASK;

	reg &= ~PERIDOT_SDIF_SD_BITMASK;
	reg |= 0xff;

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);

	return (result)? 1 : 0;
}

#endif



/* 初期化 */
void peridot_sdif_init(const peridot_sdif_dev *dev)
{
	while( !(IORD_PERIDOT_SDIF_CONTROL(dev->base) & PERIDOT_SDIF_READY_BITMASK) ) {}

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, 0);
	IOWR_PERIDOT_SDIF_FRC(dev->base, 0);
}

/* SDカードアサート */
void peridot_sdif_assert(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);

	reg |= (PERIDOT_SDIF_CDALT_BITMASK | PERIDOT_SDIF_SD_ASSERT | 0xff);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
}

/* SDカードネゲート */
void peridot_sdif_negate(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);

	reg &= ~PERIDOT_SDIF_SD_BITMASK;
	reg |= (PERIDOT_SDIF_CDALT_BITMASK | PERIDOT_SDIF_SD_NEGATE | 0xff);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
}

/* SDカードへ1バイト送信 */
void peridot_sdif_sendbyte(const peridot_sdif_dev *dev, const alt_u8 data)
{
	alt_u32 reg;

	do {
		reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);
	} while ( !(reg & PERIDOT_SDIF_READY_BITMASK) );

	reg &= ~0xff;
	reg |= (PERIDOT_SDIF_CDALT_BITMASK | PERIDOT_SDIF_START | data);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
}

/* SDカードから1バイト受信 */
alt_u8 peridot_sdif_recvbyte(const peridot_sdif_dev *dev)
{
	alt_u32 reg, result;

	do {
		reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);
	} while ( !(reg & PERIDOT_SDIF_READY_BITMASK) );

	reg |= (PERIDOT_SDIF_CDALT_BITMASK | PERIDOT_SDIF_START | 0xff);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
	do {
		result = IORD_PERIDOT_SDIF_CONTROL(dev->base);
	} while ( !(result & PERIDOT_SDIF_READY_BITMASK) );

	return result & 0xff;
}

/* SDカードスロットの状態を取得 */
int peridot_sdif_card_insert(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);
	alt_u32 result = reg & PERIDOT_SDIF_CD_BITMASK;

	return (result)? 1 : 0;
}

/* SDカードスロット電源ON */
void peridot_sdif_pwr_on(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);

	reg |= (PERIDOT_SDIF_PWR_ON | PERIDOT_SDIF_CDALT_BITMASK | 0xff);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
}

/* SDカードスロット電源OFF */
void peridot_sdif_pwr_off(const peridot_sdif_dev *dev)
{
	alt_u32 reg = IORD_PERIDOT_SDIF_CONTROL(dev->base);

	reg &= ~PERIDOT_SDIF_PWR_BITMASK;
	reg |= (PERIDOT_SDIF_PWR_OFF | PERIDOT_SDIF_CDALT_BITMASK | 0xff);

	IOWR_PERIDOT_SDIF_CONTROL(dev->base, reg);
}

/* 通信クロックを初期化モードに設定 */
void peridot_sdif_setpp(const peridot_sdif_dev *dev)
{
	IOWR_PERIDOT_SDIF_DIVREF(dev->base, dev->pp_count_value);
}

/* 通信クロックをデータモードに設定 */
void peridot_sdif_setdd(const peridot_sdif_dev *dev)
{
	IOWR_PERIDOT_SDIF_DIVREF(dev->base, dev->dd_count_value);
}

/* 任意カウントの間待つ */
void peridot_sdif_wait(const peridot_sdif_dev *dev, const alt_u32 count)
{
	IOWR_PERIDOT_SDIF_FRC(dev->base, count);
	while( IORD_PERIDOT_SDIF_FRC(dev->base) ) {}
}

/* 指定のmsの間待つ */
void peridot_sdif_wait_ms(const peridot_sdif_dev *dev, alt_u32 count)
{
	while(count--) {
		IOWR_PERIDOT_SDIF_FRC(dev->base, dev->timer_1ms_value);
		while( IORD_PERIDOT_SDIF_FRC(dev->base) ) {}
	}
}



/**************************************************************************/
