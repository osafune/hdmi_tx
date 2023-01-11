	c4e_pcmplay_core u0 (
		.clk_100m_clk  (<connected-to-clk_100m_clk>),  // clk_100m.clk
		.clk_25m_clk   (<connected-to-clk_25m_clk>),   //  clk_25m.clk
		.gpio_export   (<connected-to-gpio_export>),   //     gpio.export
		.pcm_clk_128fs (<connected-to-pcm_clk_128fs>), //      pcm.clk_128fs
		.pcm_fs        (<connected-to-pcm_fs>),        //         .fs
		.pcm_ldata     (<connected-to-pcm_ldata>),     //         .ldata
		.pcm_rdata     (<connected-to-pcm_rdata>),     //         .rdata
		.pcm_mute      (<connected-to-pcm_mute>),      //         .mute
		.reset_reset_n (<connected-to-reset_reset_n>), //    reset.reset_n
		.sd_clk        (<connected-to-sd_clk>),        //       sd.clk
		.sd_cmd        (<connected-to-sd_cmd>),        //         .cmd
		.sd_dat0       (<connected-to-sd_dat0>),       //         .dat0
		.sd_dat3       (<connected-to-sd_dat3>),       //         .dat3
		.sd_cd_n       (<connected-to-sd_cd_n>),       //         .cd_n
		.sd_pwr        (<connected-to-sd_pwr>),        //         .pwr
		.sdr_addr      (<connected-to-sdr_addr>),      //      sdr.addr
		.sdr_ba        (<connected-to-sdr_ba>),        //         .ba
		.sdr_cas_n     (<connected-to-sdr_cas_n>),     //         .cas_n
		.sdr_cke       (<connected-to-sdr_cke>),       //         .cke
		.sdr_cs_n      (<connected-to-sdr_cs_n>),      //         .cs_n
		.sdr_dq        (<connected-to-sdr_dq>),        //         .dq
		.sdr_dqm       (<connected-to-sdr_dqm>),       //         .dqm
		.sdr_ras_n     (<connected-to-sdr_ras_n>),     //         .ras_n
		.sdr_we_n      (<connected-to-sdr_we_n>),      //         .we_n
		.uart_rxd      (<connected-to-uart_rxd>),      //     uart.rxd
		.uart_txd      (<connected-to-uart_txd>),      //         .txd
		.vga_videoclk  (<connected-to-vga_videoclk>),  //      vga.videoclk
		.vga_active    (<connected-to-vga_active>),    //         .active
		.vga_rout      (<connected-to-vga_rout>),      //         .rout
		.vga_gout      (<connected-to-vga_gout>),      //         .gout
		.vga_bout      (<connected-to-vga_bout>),      //         .bout
		.vga_hsync_n   (<connected-to-vga_hsync_n>),   //         .hsync_n
		.vga_vsync_n   (<connected-to-vga_vsync_n>),   //         .vsync_n
		.vga_csync_n   (<connected-to-vga_csync_n>),   //         .csync_n
		.bar_export    (<connected-to-bar_export>)     //      bar.export
	);

