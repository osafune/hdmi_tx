# ------------------------------------------
# Create generated clocks based on PLLs
# ------------------------------------------

derive_pll_clocks
derive_clock_uncertainty



# ---------------------------------------------
# Original Clock
# ---------------------------------------------

create_clock -period "50.000 MHz" {CLOCK_50}
create_clock -period "96.000 MHz" {DVP_PCLK}



# ---------------------------------------------
# Set SDRAM I/O requirements
# ---------------------------------------------

set sdrclk_nodes	{u0|altpll_component|auto_generated|pll1|clk[0]}
set sdrclk_ports	{SDRCLK_OUT}

set sdrclk_period	10.0
set sdrclk_iodelay	3.154
set sdram_tsu		1.5
set sdram_th		1.0
set sdram_tco_cl3	5.4
set sdram_tco_cl2	6.0
set sdram_tco		$sdram_tco_cl2

create_generated_clock -name sdrclk_out_clock -source $sdrclk_nodes
set_output_delay -clock sdrclk_out_clock 0 $sdrclk_ports

create_generated_clock -name sdram_clock -offset $sdrclk_iodelay -source $sdrclk_nodes
set_output_delay -clock sdram_clock -max $sdram_tsu [get_ports {SDR_*}]
set_output_delay -clock sdram_clock -min $sdram_th [get_ports {SDR_*}]
set_input_delay -clock sdram_clock [expr $sdram_tco - $sdrclk_period] [get_ports {SDR_DQ[*]}]



# ---------------------------------------------
# Set false path
# ---------------------------------------------

set_false_path -from {c4e_pcmplay_core:u2|altera_reset_controller:rst_controller_002|altera_reset_synchronizer:alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}\
				-to [get_registers {c4e_pcmplay_core:u2|pcm_component:pcm|fsdivcount_reg[*]}]
set_false_path -from {c4e_pcmplay_core:u2|pcm_component:pcm|fiforeset_reg}

set_false_path -from [get_registers {c4e_pcmplay_core:u2|pcm_component:pcm|*}]\
				-to {audiobar:u_bar|drive_in_reg[0]}
set_false_path -from [get_registers {c4e_pcmplay_core:u2|c4e_pcmplay_core_barcolor:barcolor|data_out[*]}]\
				-to [get_registers {audiobar:u_bar|alfablend:*|mult_pixa_reg[*]}]
set_false_path -from [get_registers {c4e_pcmplay_core:u2|pcm_component:pcm|*}]\
				-to [get_registers {audiobar:u_bar|lacc_reg[*]}]
set_false_path -from [get_registers {c4e_pcmplay_core:u2|pcm_component:pcm|*}]\
				-to [get_registers {audiobar:u_bar|racc_reg[*]}]
