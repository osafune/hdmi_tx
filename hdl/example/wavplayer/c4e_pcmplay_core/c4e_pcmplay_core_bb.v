
module c4e_pcmplay_core (
	bar_export,
	clk_100m_clk,
	clk_25m_clk,
	gpio_export,
	pcm_clk_128fs,
	pcm_fs,
	pcm_ldata,
	pcm_rdata,
	pcm_mute,
	reset_reset_n,
	sd_clk,
	sd_cmd,
	sd_dat0,
	sd_dat3,
	sd_cd_n,
	sd_pwr,
	sdr_addr,
	sdr_ba,
	sdr_cas_n,
	sdr_cke,
	sdr_cs_n,
	sdr_dq,
	sdr_dqm,
	sdr_ras_n,
	sdr_we_n,
	uart_rxd,
	uart_txd,
	vga_videoclk,
	vga_active,
	vga_rout,
	vga_gout,
	vga_bout,
	vga_hsync_n,
	vga_vsync_n,
	vga_csync_n);	

	output	[11:0]	bar_export;
	input		clk_100m_clk;
	input		clk_25m_clk;
	inout	[1:0]	gpio_export;
	input		pcm_clk_128fs;
	output		pcm_fs;
	output	[15:0]	pcm_ldata;
	output	[15:0]	pcm_rdata;
	output		pcm_mute;
	input		reset_reset_n;
	output		sd_clk;
	output		sd_cmd;
	input		sd_dat0;
	output		sd_dat3;
	input		sd_cd_n;
	output		sd_pwr;
	output	[12:0]	sdr_addr;
	output	[1:0]	sdr_ba;
	output		sdr_cas_n;
	output		sdr_cke;
	output		sdr_cs_n;
	inout	[15:0]	sdr_dq;
	output	[1:0]	sdr_dqm;
	output		sdr_ras_n;
	output		sdr_we_n;
	input		uart_rxd;
	output		uart_txd;
	input		vga_videoclk;
	output		vga_active;
	output	[7:0]	vga_rout;
	output	[7:0]	vga_gout;
	output	[7:0]	vga_bout;
	output		vga_hsync_n;
	output		vga_vsync_n;
	output		vga_csync_n;
endmodule
