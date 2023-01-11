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

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module peridot_sdif
# 
set_module_property NAME peridot_sdif
set_module_property DISPLAY_NAME "PERIDOT SD Filesystem interface"
set_module_property DESCRIPTION "PERIDOT SD Filesystem interface"
set_module_property GROUP "PERIDOT Peripherals"
set_module_property AUTHOR "J-7SYSTEM WORKS LIMITED"
set_module_property VERSION 19.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property HIDE_FROM_SOPC true
set_module_property HIDE_FROM_QUARTUS true
set_module_property EDITABLE false
set_module_property VALIDATION_CALLBACK validate


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL peridot_sdif
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file peridot_sdif.vhd VHDL PATH hdl/peridot_sdif.vhd TOP_LEVEL_FILE


# 
# parameters
# 
set debugview true

add_parameter CLOCKFREQ integer
set_parameter_property CLOCKFREQ UNITS hertz
set_parameter_property CLOCKFREQ SYSTEM_INFO {CLOCK_RATE clock}
set_parameter_property CLOCKFREQ ENABLED false
set_parameter_property CLOCKFREQ VISIBLE $debugview


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0

add_interface_port clock csi_clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT

add_interface_port reset csi_reset reset Input 1


# 
# connection point s1
# 
add_interface s1 avalon end
set_interface_property s1 addressUnits WORDS
set_interface_property s1 associatedClock clock
set_interface_property s1 associatedReset reset
set_interface_property s1 bitsPerSymbol 8
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 burstcountUnits WORDS
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 0
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 maximumPendingWriteTransactions 0
set_interface_property s1 readLatency 0
set_interface_property s1 readWaitTime 1
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
set_interface_property s1 writeWaitTime 0

add_interface_port s1 avs_address address Input 2
add_interface_port s1 avs_read read Input 1
add_interface_port s1 avs_readdata readdata Output 32
add_interface_port s1 avs_write write Input 1
add_interface_port s1 avs_writedata writedata Input 32
set_interface_assignment s1 embeddedsw.configuration.isFlash 0
set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point irq
# 
add_interface irq interrupt end
set_interface_property irq associatedAddressablePoint s1
set_interface_property irq associatedClock clock
set_interface_property irq associatedReset reset

add_interface_port irq ins_irq irq Output 1


# 
# connection point export
# 
add_interface export conduit end
set_interface_property export associatedClock clock
set_interface_property export associatedReset reset

add_interface_port export coe_sd_clk clk Output 1
add_interface_port export coe_sd_cmd cmd Output 1
add_interface_port export coe_sd_dat0 dat0 Input 1
add_interface_port export coe_sd_dat3 dat3 Output 1
add_interface_port export coe_sd_cd_n cd_n Input 1
add_interface_port export coe_sd_pwr pwr Output 1


#
# Validation callback
#
proc validate {} {

	#
	# Software assignments for system.h
	#
	set_module_assignment embeddedsw.CMacro.FREQ [get_parameter_value CLOCKFREQ]

}
