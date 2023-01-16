# ===================================================================
# TITLE : PERIDOT-NGS / PERIDOT SDIF Petit FatFs sw package
#
#   DEGISN : S.OSAFUNE (J-7SYSTEM WORKS LIMITED)
#   DATE   : 2019/08/27 -> 2019/09/01
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
# peridot_sdif_pff_sw.tcl
#

# Create a new software package
create_sw_package peridot_sdif_pff

# Associate it with some hardware known as "peridot_sdif"
set_sw_property hw_class_name peridot_sdif

# The version of this driver
set_sw_property version 19.1
set_sw_property min_compatible_hw_version 17.1

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

# This module should be initialized after peridot_sdif driver
set_sw_property alt_sys_init_priority 2000

# Source files
add_sw_property c_source HAL/src/pff3a/pff.c
add_sw_property include_source HAL/src/pff3a/pff.h
add_sw_property include_source HAL/src/pff3a/diskio.h

add_sw_property c_source HAL/src/peridot_sdif_pff_diskio.c
add_sw_property c_source HAL/src/peridot_sdif_boot.c
add_sw_property include_source HAL/inc/pffconf.h
add_sw_property include_source HAL/inc/peridot_sdif_pff.h

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL


# Settings

add_sw_setting unquoted_string system_h_define hw_instance_name PERIDOT_SDIF_INST_NAME peridot_sdif_0 "Instance name of PERIDOT_SDIF hw_class"
add_sw_setting boolean_define_only system_h_define enable_elfboot_function PERIDOT_SDIF_USE_ELFBOOT false "Enable elf-file boot loader function."
#add_sw_setting quoted_string system_h_define boot_elf_filename PERIDOT_SDIF_BOOT_FILENAME /BOOT.ELF "Boot file name (specify in uppercase in 8.3 DOS-format)"

add_sw_setting boolean system_h_define function.use_read_function PF_USE_READ 1 "Use read function. If use elfboot, when need to turn on this option."
add_sw_setting boolean system_h_define function.use_dir_function PF_USE_DIR 0 "Use directory function."
add_sw_setting boolean system_h_define function.use_lseek_function PF_USE_LSEEK 1 "Use seek function. If use elfboot, when need to turn on this option."
add_sw_setting boolean system_h_define function.use_write_function PF_USE_WRITE 0 "Use write function."

add_sw_setting boolean system_h_define fattype.support_fat12 PF_FS_FAT12 0 "Support FAT12 subtype"
add_sw_setting boolean system_h_define fattype.support_fat16 PF_FS_FAT16 1 "Support FAT16 subtype"
add_sw_setting boolean system_h_define fattype.support_fat32 PF_FS_FAT32 1 "Support FAT32 subtype"

# End of file
