# ===================================================================
# TITLE : PERIDOT-NGS / "PERIDOT SDIF"
#
#   DEGISN : S.OSAFUNE (J-7SYSTEM WORKS LIMITED)
#   DATE   : 2019/08/27 -> 2019/08/27
#   MODIFY : 2022/02/07 add enhanced_interrupt_api property
#          : 2022/09/25 19.1
#
# ===================================================================
#
# The MIT License (MIT)
# Copyright (c) 2019 J-7SYSTEM WORKS LIMITED.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# peridot_sdif_driver.tcl
#

# Create a new driver
create_driver peridot_sdif_driver

# Associate it with some hardware known as "peridot_sdif"
set_sw_property hw_class_name peridot_sdif

# The version of this driver
set_sw_property version 19.1
set_sw_property min_compatible_hw_version 17.1

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# Interrupt properties: This driver supports enhanced
set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"


#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/peridot_sdif.c

# Include files
add_sw_property include_source HAL/inc/peridot_sdif.h
add_sw_property include_source inc/peridot_sdif_regs.h

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL

# Settings


# End of file
