/*
 * system.h - SOPC Builder system and BSP software package information
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

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x0fff0820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1d
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x0f000020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x1c
#define ALT_CPU_NAME "nios2_tiny"
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x0f000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x0fff0820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x1d
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x0f000020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x1c
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x0f000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_TIMER
#define __ALTERA_AVALON_UART
#define __ALTERA_NIOS2_GEN2
#define __PCM_COMPONENT
#define __PERIDOT_SDIF
#define __PERIDOT_VGA_CONTROLLER


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/sysuart"
#define ALT_STDERR_BASE 0x10000060
#define ALT_STDERR_DEV sysuart
#define ALT_STDERR_IS_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_uart"
#define ALT_STDIN "/dev/sysuart"
#define ALT_STDIN_BASE 0x10000060
#define ALT_STDIN_DEV sysuart
#define ALT_STDIN_IS_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_uart"
#define ALT_STDOUT "/dev/sysuart"
#define ALT_STDOUT_BASE 0x10000060
#define ALT_STDOUT_DEV sysuart
#define ALT_STDOUT_IS_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_uart"
#define ALT_SYSTEM_NAME "c4e_pcmplay_core"
#define ALT_SYS_CLK_TICKS_PER_SEC NONE_TICKS_PER_SEC
#define ALT_TIMESTAMP_CLK_TIMER_DEVICE_TYPE NONE_TIMER_DEVICE_TYPE


/*
 * barcolor configuration
 *
 */

#define ALT_MODULE_CLASS_barcolor altera_avalon_pio
#define BARCOLOR_BASE 0x10000120
#define BARCOLOR_BIT_CLEARING_EDGE_REGISTER 0
#define BARCOLOR_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BARCOLOR_CAPTURE 0
#define BARCOLOR_DATA_WIDTH 12
#define BARCOLOR_DO_TEST_BENCH_WIRING 0
#define BARCOLOR_DRIVEN_SIM_VALUE 0
#define BARCOLOR_EDGE_TYPE "NONE"
#define BARCOLOR_FREQ 25000000
#define BARCOLOR_HAS_IN 0
#define BARCOLOR_HAS_OUT 1
#define BARCOLOR_HAS_TRI 0
#define BARCOLOR_IRQ -1
#define BARCOLOR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define BARCOLOR_IRQ_TYPE "NONE"
#define BARCOLOR_NAME "/dev/barcolor"
#define BARCOLOR_RESET_VALUE 0
#define BARCOLOR_SPAN 16
#define BARCOLOR_TYPE "altera_avalon_pio"


/*
 * boot configuration
 *
 */

#define ALT_MODULE_CLASS_boot altera_avalon_onchip_memory2
#define BOOT_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define BOOT_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define BOOT_BASE 0xf000000
#define BOOT_CONTENTS_INFO ""
#define BOOT_DUAL_PORT 0
#define BOOT_GUI_RAM_BLOCK_TYPE "AUTO"
#define BOOT_INIT_CONTENTS_FILE "boot"
#define BOOT_INIT_MEM_CONTENT 1
#define BOOT_INSTANCE_ID "NONE"
#define BOOT_IRQ -1
#define BOOT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define BOOT_NAME "/dev/boot"
#define BOOT_NON_DEFAULT_INIT_FILE_ENABLED 1
#define BOOT_RAM_BLOCK_TYPE "AUTO"
#define BOOT_READ_DURING_WRITE_MODE "DONT_CARE"
#define BOOT_SINGLE_CLOCK_OP 0
#define BOOT_SIZE_MULTIPLE 1
#define BOOT_SIZE_VALUE 16384
#define BOOT_SPAN 16384
#define BOOT_TYPE "altera_avalon_onchip_memory2"
#define BOOT_WRITABLE 1


/*
 * gpio configuration
 *
 */

#define ALT_MODULE_CLASS_gpio altera_avalon_pio
#define GPIO_BASE 0x10000040
#define GPIO_BIT_CLEARING_EDGE_REGISTER 0
#define GPIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define GPIO_CAPTURE 0
#define GPIO_DATA_WIDTH 2
#define GPIO_DO_TEST_BENCH_WIRING 0
#define GPIO_DRIVEN_SIM_VALUE 0
#define GPIO_EDGE_TYPE "NONE"
#define GPIO_FREQ 25000000
#define GPIO_HAS_IN 0
#define GPIO_HAS_OUT 0
#define GPIO_HAS_TRI 1
#define GPIO_IRQ -1
#define GPIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define GPIO_IRQ_TYPE "NONE"
#define GPIO_NAME "/dev/gpio"
#define GPIO_RESET_VALUE 0
#define GPIO_SPAN 16
#define GPIO_TYPE "altera_avalon_pio"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 4
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * pcm configuration
 *
 */

#define ALT_MODULE_CLASS_pcm pcm_component
#define PCM_BASE 0x10001020
#define PCM_IRQ 6
#define PCM_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PCM_NAME "/dev/pcm"
#define PCM_SPAN 16
#define PCM_TYPE "pcm_component"


/*
 * peridot_sdif_0 configuration
 *
 */

#define ALT_MODULE_CLASS_peridot_sdif_0 peridot_sdif
#define PERIDOT_SDIF_0_BASE 0x10001000
#define PERIDOT_SDIF_0_FREQ 100000000
#define PERIDOT_SDIF_0_IRQ 9
#define PERIDOT_SDIF_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PERIDOT_SDIF_0_NAME "/dev/peridot_sdif_0"
#define PERIDOT_SDIF_0_SPAN 16
#define PERIDOT_SDIF_0_TYPE "peridot_sdif"


/*
 * peridot_sdif_pff configuration
 *
 */

#define PERIDOT_SDIF_INST_NAME peridot_sdif_0
#define PF_FS_FAT12 0
#define PF_FS_FAT16 1
#define PF_FS_FAT32 1
#define PF_USE_DIR 1
#define PF_USE_LSEEK 1
#define PF_USE_READ 1
#define PF_USE_WRITE 0


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x0
#define SDRAM_CAS_LATENCY 2
#define SDRAM_CONTENTS_INFO
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 2
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 200.0
#define SDRAM_REFRESH_PERIOD 7.8125
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x18
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 9
#define SDRAM_SDRAM_DATA_WIDTH 16
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 13
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 0
#define SDRAM_SPAN 33554432
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 6.0
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 21.0
#define SDRAM_T_RFC 63.0
#define SDRAM_T_RP 21.0
#define SDRAM_T_WR 14.0


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid_qsys
#define SYSID_BASE 0x10000000
#define SYSID_ID -1608318703
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1673399163
#define SYSID_TYPE "altera_avalon_sysid_qsys"


/*
 * systimer configuration
 *
 */

#define ALT_MODULE_CLASS_systimer altera_avalon_timer
#define SYSTIMER_ALWAYS_RUN 0
#define SYSTIMER_BASE 0x10000020
#define SYSTIMER_COUNTER_SIZE 32
#define SYSTIMER_FIXED_PERIOD 0
#define SYSTIMER_FREQ 25000000
#define SYSTIMER_IRQ 0
#define SYSTIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SYSTIMER_LOAD_VALUE 24999
#define SYSTIMER_MULT 0.001
#define SYSTIMER_NAME "/dev/systimer"
#define SYSTIMER_PERIOD 1
#define SYSTIMER_PERIOD_UNITS "ms"
#define SYSTIMER_RESET_OUTPUT 0
#define SYSTIMER_SNAPSHOT 1
#define SYSTIMER_SPAN 32
#define SYSTIMER_TICKS_PER_SEC 1000
#define SYSTIMER_TIMEOUT_PULSE_OUTPUT 0
#define SYSTIMER_TYPE "altera_avalon_timer"


/*
 * sysuart configuration
 *
 */

#define ALT_MODULE_CLASS_sysuart altera_avalon_uart
#define SYSUART_BASE 0x10000060
#define SYSUART_BAUD 115200
#define SYSUART_DATA_BITS 8
#define SYSUART_FIXED_BAUD 1
#define SYSUART_FREQ 25000000
#define SYSUART_IRQ 1
#define SYSUART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SYSUART_NAME "/dev/sysuart"
#define SYSUART_PARITY 'N'
#define SYSUART_SIM_CHAR_STREAM ""
#define SYSUART_SIM_TRUE_BAUD 0
#define SYSUART_SPAN 32
#define SYSUART_STOP_BITS 1
#define SYSUART_SYNC_REG_DEPTH 2
#define SYSUART_TYPE "altera_avalon_uart"
#define SYSUART_USE_CTS_RTS 0
#define SYSUART_USE_EOP_REGISTER 0


/*
 * vga configuration
 *
 */

#define ALT_MODULE_CLASS_vga peridot_vga_controller
#define VGA_BASE 0x10000100
#define VGA_IRQ 4
#define VGA_IRQ_INTERRUPT_CONTROLLER_ID 0
#define VGA_NAME "/dev/vga"
#define VGA_SPAN 16
#define VGA_TYPE "peridot_vga_controller"
#define VGA_USE_PCMSTREAM 0
#define VGA_VIDEO_CLOCK_HZ 74250000
#define VGA_VIDEO_HACTIVE 1280
#define VGA_VIDEO_HBACKP 220
#define VGA_VIDEO_HSYNC 40
#define VGA_VIDEO_HTOTAL 1650
#define VGA_VIDEO_INTERFACE "PARALLEL"
#define VGA_VIDEO_VACTIVE 720
#define VGA_VIDEO_VBACKP 20
#define VGA_VIDEO_VSYNC 5
#define VGA_VIDEO_VTOTAL 750
#define VGA_VRAM_DATAORDER_BYTE 1
#define VGA_VRAM_LINEBYTES 2560
#define VGA_VRAM_PIXELCOLOR 1
#define VGA_VRAM_PIXELCOLOR_RGB565 1
#define VGA_VRAM_VIEWHEIGHT 720
#define VGA_VRAM_VIEWWIDTH 1280

#endif /* __SYSTEM_H_ */
