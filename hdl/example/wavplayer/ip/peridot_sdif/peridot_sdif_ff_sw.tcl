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
# peridot_sdif_ff_sw.tcl
#

# Create a new software package
create_sw_package peridot_sdif_ff

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
add_sw_property c_source HAL/src/ff13c/ff.c
#add_sw_property c_source HAL/src/ff13c/ffsystem.c
add_sw_property c_source HAL/src/ff13c/ffunicode.c
add_sw_property include_source HAL/src/ff13c/ff.h
add_sw_property include_source HAL/src/ff13c/diskio.h

add_sw_property c_source HAL/src/peridot_sdif_ff_diskio.c
add_sw_property c_source HAL/src/peridot_sdif_ff.c
add_sw_property include_source HAL/inc/ffconf.h
add_sw_property include_source HAL/inc/peridot_sdif_ff.h

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL


# Settings

add_sw_setting unquoted_string system_h_define hw_instance_name PERIDOT_SDIF_INST_NAME peridot_sdif_0 "Instance name of PERIDOT_SDIF hw_class"
add_sw_setting quoted_string system_h_define mount_point SDIF_FF_MOUNT_POINT /mnt/sd "Mount point"

add_sw_setting boolean_define_only system_h_define locale.support_lfn FF_SUPPORT_LFN true "Support for LFN (long file name)."
add_sw_setting decimal_number system_h_define locale.character_code_page FF_CODE_PAGE 932 "This option specifies the OEM code page to be used on the target system."
add_sw_setting boolean_define_only system_h_define locale.support_utf8 FF_SUPPORT_UTF8 false "This option switches the character encoding UTF-8 on the API when LFN is enabled."
add_sw_setting boolean_define_only system_h_define locale.support_exfat FF_SUPPORT_EXFAT false "This option switches support for exFAT filesystem."

add_sw_setting boolean system_h_define option.readonly_configuration FF_FS_READONLY 0 "This option switches read-only configuration."
add_sw_setting boolean system_h_define option.use_mkfs_function FF_USE_MKFS 0 "Use f_mkfs() function."
add_sw_setting boolean system_h_define option.use_chmod_function FF_USE_CHMOD 0 "Use f_chmod() and f_utime() function."


# End of file
