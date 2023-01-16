/*
 * alt_sys_init.c - HAL initialization source
 *
 * Machine generated for CPU 'nios2_tiny' in SOPC Builder design 'c4e_pcmplay_core'
 * SOPC Builder design path: C:/PROJECT/temp/hdmi_tx/hw/wavplayer/c4e_pcmplay_core.sopcinfo
 *
 * Generated: Wed Jan 11 10:37:45 JST 2023
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#include "system.h"
#include "sys/alt_irq.h"
#include "sys/alt_sys_init.h"

#include <stddef.h>

/*
 * Device headers
 */

#include "altera_nios2_gen2_irq.h"
#include "altera_avalon_sysid_qsys.h"
#include "altera_avalon_timer.h"
#include "altera_avalon_uart.h"
#include "peridot_sdif.h"
#include "peridot_sdif_pff.h"

/*
 * Allocate the device storage
 */

ALTERA_NIOS2_GEN2_IRQ_INSTANCE ( NIOS2_TINY, nios2_tiny);
ALTERA_AVALON_SYSID_QSYS_INSTANCE ( SYSID, sysid);
ALTERA_AVALON_TIMER_INSTANCE ( SYSTIMER, systimer);
ALTERA_AVALON_UART_INSTANCE ( SYSUART, sysuart);
PERIDOT_SDIF_INSTANCE ( PERIDOT_SDIF_0, peridot_sdif_0);
PERIDOT_SDIF_PFF_INSTANCE ( PERIDOT_SDIF_PFF, peridot_sdif_pff);

/*
 * Initialize the interrupt controller devices
 * and then enable interrupts in the CPU.
 * Called before alt_sys_init().
 * The "base" parameter is ignored and only
 * present for backwards-compatibility.
 */

void alt_irq_init ( const void* base )
{
    ALTERA_NIOS2_GEN2_IRQ_INIT ( NIOS2_TINY, nios2_tiny);
    alt_irq_cpu_enable_interrupts();
}

/*
 * Initialize the non-interrupt controller devices.
 * Called after alt_irq_init().
 */

void alt_sys_init( void )
{
    ALTERA_AVALON_TIMER_INIT ( SYSTIMER, systimer);
    ALTERA_AVALON_SYSID_QSYS_INIT ( SYSID, sysid);
    ALTERA_AVALON_UART_INIT ( SYSUART, sysuart);
    PERIDOT_SDIF_INIT ( PERIDOT_SDIF_0, peridot_sdif_0);
    PERIDOT_SDIF_PFF_INIT ( PERIDOT_SDIF_PFF, peridot_sdif_pff);
}
