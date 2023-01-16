// ===================================================================
// TITLE : PERIDOT-Air / VGA component test top
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2023/01/01 -> 2023/01/11
//
//
// ===================================================================
//
// The MIT License (MIT)
// Copyright (c) 2023 J-7SYSTEM WORKS LIMITED.
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

`default_nettype none

module wavplayer_top(
	// clk and system reset
	input wire			CLOCK_50,
	input wire			RESET_N,

	// Interface: EPCS memory controller
	output wire			EPCS_CSO_N,
	output wire			EPCS_DCLK,
	output wire			EPCS_ASDO,
	input wire			EPCS_DATA0,

	// Interface: SD-card controller
	output wire			SD_DAT3,
	output wire			SD_CLK,
	output wire			SD_CMD,
	input wire			SD_DAT0,

	// Interface: SD-card Power enable
	output wire			SD_PWR_N,

	// Interface: SD-card Detect
	input wire			SW_CD_N,

	// Interface: SDRAM
	output wire			SDRCLK_OUT,
	output wire			SDR_CKE,
	output wire			SDR_CS_N,
	output wire			SDR_RAS_N,
	output wire			SDR_CAS_N,
	output wire			SDR_WE_N,
	output wire [12:0]	SDR_A,
	output wire [1:0]	SDR_BA,
	inout wire  [15:0]	SDR_DQ,
	output wire [1:0]	SDR_DQM,

	// Interface: OV-CAM
	output wire			DVP_XCLK,
	input wire			DVP_PCLK,
	input wire [7:0]	DVP_DATA,
	input wire			DVP_HREF,
	input wire			DVP_VSYNC,
	inout wire			DVP_SCCB_C,
	inout wire			DVP_SCCB_D,

	// Interface: TMDS
	output wire [2:0]	TMDS_DATA,
	output wire [2:0]	TMDS_DATA_N,
	output wire			TMDS_CLOCK,
	output wire			TMDS_CLOCK_N,

	// Inteface: Grove
	inout wire [1:0]	GROVE1_D,
	inout wire [1:0]	GROVE2_D,
	output wire			WSLED,

	// OnBoard LED
	output wire [1:0]	USER_LED
);


/* ===== 外部変更可能パラメータ ========== */



/* ----- 内部パラメータ ------------------ */

	localparam VGACLOCK_MHZ	= 74.286;
	localparam FSCLOCK_KHZ	= 44.1;


/* ※以降のパラメータ宣言は禁止※ */

/* ===== ノード宣言 ====================== */
				/* 内部は全て正論理リセットとする。ここで定義していないノードの使用は禁止 */
	wire			reset_sig = ~RESET_N;			// モジュール内部駆動非同期リセット 

				/* 内部は全て正エッジ駆動とする。ここで定義していないクロックノードの使用は禁止 */
	wire			clock_sig = CLOCK_50;			// モジュール内部駆動クロック 

	wire			qsys_reset_n_sig;
	wire			clock_core_sig, clock_peri_sig;
	wire			vpll_locked_sig;
	wire			vga_clk_sig, tx_clk_sig, pcm_clk_sig;

	wire			sd_ssn_sig, sd_pwr_sig;
	wire [1:0]		led_sig;
	wire			uart_rxd_sig, uart_txd_sig;
	wire			vga_active_sig, vga_hsyncn_sig, vga_vsyncn_sig;
	wire [7:0]		vga_rout_sig, vga_gout_sig, vga_bout_sig;
	wire			pcm_fs_sig, mute_sig;
	wire [15:0]		pcm_l_sig, pcm_r_sig;
	wire [11:0]		barcolor_sig;

	wire			bar_active_sig, bar_hsyncn_sig, bar_vsyncn_sig;
	wire [7:0]		bar_r_sig, bar_g_sig, bar_b_sig;


/* ※以降のwire、reg宣言は禁止※ */

/* ===== テスト記述 ============== */



/* ===== モジュール構造記述 ============== */

	///// 未使用ピンの処理 /////

	assign {EPCS_DCLK,EPCS_ASDO,EPCS_CSO_N} = 3'b001;		// コンフィグROMをユーザーモードで使わない場合 
	assign WSLED = 1'b0;



	///// クロックとリセット /////

	syspll		// c0:100.0MHz(-3.25ns), c1:100.0MHz, c2:25.0MHz, c3:5.6452MHz
	u0 (
		.areset		(reset_sig),
		.inclk0		(clock_sig),
		.c0			(SDRCLK_OUT),
		.c1			(clock_core_sig),
		.c2			(clock_peri_sig),
		.c3			(pcm_clk_sig),
		.locked		(qsys_reset_n_sig)
	);

//	vgapll		// c0:25.2MHz, c1:c0x5(126.0MHz)
//	sdpll		// c0:27.0MHz, c1:c0x5(135.0MHz)
	hdpll		// c0:74.286MHz, c1:c0x5(371.43MHz)
	u1 (
		.areset		(reset_sig),
		.inclk0		(clock_sig),
		.c0			(vga_clk_sig),
		.c1			(tx_clk_sig),
		.locked		(vpll_locked_sig)
	);



	///// Platform Designerコンポーネントのインスタンス /////

    c4e_pcmplay_core
	u2 (
        .reset_reset_n		(qsys_reset_n_sig),	//    reset.reset_n
        .clk_100m_clk		(clock_core_sig),	// clk_100m.clk
        .clk_25m_clk		(clock_peri_sig),	//  clk_25m.clk

        .uart_rxd			(uart_rxd_sig),		//     uart.rxd
        .uart_txd			(uart_txd_sig),		//         .txd

        .sdr_addr			(SDR_A),			//      sdr.addr
        .sdr_ba				(SDR_BA),			//         .ba
        .sdr_cs_n			(SDR_CS_N),			//         .cs_n
        .sdr_ras_n			(SDR_RAS_N),		//         .ras_n
        .sdr_cas_n			(SDR_CAS_N),		//         .cas_n
        .sdr_we_n			(SDR_WE_N),			//         .we_n
        .sdr_dq				(SDR_DQ),			//         .dq
        .sdr_dqm			(SDR_DQM),			//         .dqm
        .sdr_cke			(SDR_CKE),			//         .cke

        .sd_clk				(SD_CLK),			//        sd.clk
        .sd_cmd				(SD_CMD),			//          .cmd
        .sd_dat0			(SD_DAT0),			//          .dat0
        .sd_dat3			(sd_ssn_sig),		//          .dat3
        .sd_cd_n			(SW_CD_N),			//          .cd_n
        .sd_pwr				(sd_pwr_sig),		//          .pwr

        .vga_videoclk		(vga_clk_sig),		//      vga.videoclk
        .vga_active			(vga_active_sig),	//         .active
        .vga_rout			(vga_rout_sig),		//         .rout
        .vga_gout			(vga_gout_sig),		//         .gout
        .vga_bout			(vga_bout_sig),		//         .bout
        .vga_hsync_n		(vga_hsyncn_sig),	//         .hsync_n
        .vga_vsync_n		(vga_vsyncn_sig),	//         .vsync_n

        .pcm_clk_128fs		(pcm_clk_sig),		//      pcm.clk_128fs
        .pcm_fs				(pcm_fs_sig),		//         .fs
        .pcm_ldata			(pcm_l_sig),		//         .ldata
        .pcm_rdata			(pcm_r_sig),		//         .rdata
		.pcm_mute			(mute_sig),			//         .mute
        .bar_export			(barcolor_sig),		//      bar.export

        .gpio_export		(GROVE1_D)			//     gpio.export
    );

	assign SD_DAT3 = sd_ssn_sig;
	assign SD_PWR_N = ~sd_pwr_sig;


	// USER_LED : 輝度が高すぎるのでデバイスのWEAK_PULLUPで点灯させる

	assign USER_LED[0] = (~sd_ssn_sig)? 1'bz : 1'b0;
	assign USER_LED[1] = (vpll_locked_sig)? 1'bz : 1'b0;


	// GROVE2 : デバッグ用UARTポート(115.2kbps固定) 

	assign GROVE2_D = {uart_txd_sig, 1'bz};
	assign uart_rxd_sig = GROVE2_D[0];



	///// サウンドバー合成 /////

	audiobar
	u_bar (
		.reset		(reset_sig),
		.clk		(vga_clk_sig),

		.mute		(mute_sig),
		.bar_color	({{2{barcolor_sig[11:8]}}, {2{barcolor_sig[7:4]}}, {2{barcolor_sig[3:0]}}}),
		.pcm_l_in	(pcm_l_sig),
		.pcm_r_in	(pcm_r_sig),

		.active_in	(vga_active_sig),
		.r_in		(vga_rout_sig),
		.g_in		(vga_gout_sig),
		.b_in		(vga_bout_sig),
		.hsyncn_in	(vga_hsyncn_sig),
		.vsyncn_in	(vga_vsyncn_sig),

		.active_out	(bar_active_sig),
		.r_out		(bar_r_sig),
		.g_out		(bar_g_sig),
		.b_out		(bar_b_sig),
		.hsyncn_out	(bar_hsyncn_sig),
		.vsyncn_out	(bar_vsyncn_sig)
	);



	///// HDMI-TX /////

	hdmi_tx #(
		.DEVICE_FAMILY		("Cyclone IV E"),
		.CLOCK_FREQUENCY	(VGACLOCK_MHZ),
		.SCANMODE			("UNDER"),
		.AUDIO_FREQUENCY	(FSCLOCK_KHZ)
	)
	u_tx (
		.reset		(reset_sig),
		.clk		(vga_clk_sig),
		.clk_x5		(tx_clk_sig),

		.active		(bar_active_sig),
		.r_data		(bar_r_sig),
		.g_data		(bar_g_sig),
		.b_data		(bar_b_sig),
		.hsync		(~bar_hsyncn_sig),
		.vsync		(~bar_vsyncn_sig),

		.pcm_fs		(pcm_fs_sig),
		.pcm_l		({pcm_l_sig, 8'd0}),
		.pcm_r		({pcm_r_sig, 8'd0}),

		.data		(TMDS_DATA),
		.data_n		(TMDS_DATA_N),
		.clock		(TMDS_CLOCK),
		.clock_n	(TMDS_CLOCK_N)
	);


endmodule
