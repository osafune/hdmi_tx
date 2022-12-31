// ===================================================================
// TITLE : C-02 HDMI output test (DMX-ELボード用)
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2020/04/21 -> 2020/04/21
//     UPDATE : 2022/12/31
//
// ===================================================================
//
// The MIT License (MIT)
// Copyright (c) 2020,2022 J-7SYSTEM WORKS LIMITED.
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


// Verilog-2001 / IEEE 1364-2001
`default_nettype none

module c02_hdmi_test_top(
	output wire			OSC_OE,
	input wire			CLOCK_50,
//	input wire			RESET_N,
	output wire			LED,

	output wire			TMDS_CLOCK_N,	// PIO5
	output wire			TMDS_CLOCK_P,	// PIO4
	output wire			TMDS_DATA0_N,	// PIO6
	output wire			TMDS_DATA0_P,	// PIO7
	output wire			TMDS_DATA1_N,	// PIO8
	output wire			TMDS_DATA1_P,	// PIO9
	output wire			TMDS_DATA2_N,	// PIO10
	output wire			TMDS_DATA2_P	// PIO11
);


/* ===== 外部変更可能パラメータ ========== */



/* ----- 内部パラメータ ------------------ */

//	localparam VGACLOCK_MHZ	= 25.2;
//	localparam FSCLOCK_KHZ	= 48.0;
//	localparam VGACLOCK_MHZ	= 27.0;
//	localparam FSCLOCK_KHZ	= 32.0;
	localparam VGACLOCK_MHZ	= 74.286;
	localparam FSCLOCK_KHZ	= 44.1;
	localparam FSDIVIDER	= $unsigned(VGACLOCK_MHZ * 1000.0 / FSCLOCK_KHZ + 0.5) - 1;
	localparam FSDIVHALF	= FSDIVIDER / 2;

	localparam COUNTER_WIDTH= 11;
	localparam FSDIVNUM		= FSDIVIDER[COUNTER_WIDTH-1:0];
	localparam FSHALFNUM	= FSDIVHALF[COUNTER_WIDTH-1:0];


/* ※以降のパラメータ宣言は禁止※ */

/* ===== ノード宣言 ====================== */
	wire			vga_clk_sig, tx_clk_sig, locked_sig, reset_sig;

	reg  [12:0]		ms_counter_reg;
	reg  [COUNTER_WIDTH-1:0] fs_counter_reg;
	reg				fs_timing_reg;
	wire			timing_1ms_sig;
	wire [15:0]		wav_chime_sig;

	wire [3:0]		hdmicontrol_sig;
	wire			vsync_sig, hsync_sig;
	wire [7:0]		cb_r_sig, cb_g_sig, cb_b_sig;


/* ※以降のwire、reg宣言は禁止※ */

/* ===== テスト記述 ============== */



/* ===== モジュール構造記述 ============== */


	///// クロックとリセット /////

	assign OSC_OE = 1'b1;

//	hdmi_vgapll		// c0:25.2MHz, c1:c0x5(126.0MHz)
//	hdmi_sdpll		// c0:27.0MHz, c1:c0 x5(135.0MHz)
	hdmi_hdpll		// c0:74.286MHz, c1:c0x5(371.43MHz)
	u_pll (
		.areset		(1'b0),
		.inclk0		(CLOCK_50),
		.c0			(vga_clk_sig),
		.c1			(tx_clk_sig),
		.locked		(locked_sig)
	);

	assign reset_sig = ~locked_sig;



	///// サウンド生成 /////

	always @(posedge vga_clk_sig or posedge reset_sig) begin
		if (reset_sig) begin
			ms_counter_reg <= 1'd0;
			fs_counter_reg <= 1'd0;
			fs_timing_reg <= 1'b0;
		end
		else begin
			if (timing_1ms_sig) begin
				ms_counter_reg <= ms_counter_reg + 1'd1;
			end

			if (fs_counter_reg == FSDIVNUM) begin
				fs_counter_reg <= 1'd0;
				fs_timing_reg <= 1'b1;
			end
			else begin
				fs_counter_reg <= fs_counter_reg + 1'd1;

				if (fs_counter_reg == FSHALFNUM) begin
					fs_timing_reg <= 1'b0;
				end
			end

		end
	end

	melodychime #(
		.CLOCK_FREQ_HZ	($unsigned(VGACLOCK_MHZ * 1000000.0))
	)
	u_chime (
		.reset		(reset_sig),
		.clk		(vga_clk_sig),
		.start		(ms_counter_reg[12]),

		.timing_1ms	(timing_1ms_sig),
		.tempo_led	(LED),
		.wave_out	(wav_chime_sig)
	);



	///// ビデオ同期信号・カラーバー生成 /////

	video_syncgen #(
/*		.BAR_MODE	("SD"),		// VGA(640x480) : 25.2MHz
		.COLORSPACE	("RGB"),
		.H_TOTAL	(800),
		.H_SYNC		(96),
		.H_BACKP	(48),
		.H_ACTIVE	(640),
		.V_TOTAL	(525),
		.V_SYNC		(2),
		.V_BACKP	(33),
		.V_ACTIVE	(480)
*/
/*		.BAR_MODE	("SD"),		// SD480p(720x480) : 27.00MHz
		.COLORSPACE	("BT601"),
		.H_TOTAL	(858),
		.H_SYNC		(62),
		.H_BACKP	(60),
		.H_ACTIVE	(720),
		.V_TOTAL	(525),
		.V_SYNC		(6),
		.V_BACKP	(30),
		.V_ACTIVE	(480)
*/
		.BAR_MODE	("WIDE"),	// HD720p(1280x720) : 74.25MHz
		.COLORSPACE	("BT709"),
		.H_TOTAL	(1650),
		.H_SYNC		(40),
		.H_BACKP	(260),
		.H_ACTIVE	(1280),
		.V_TOTAL	(750),
		.V_SYNC		(5),
		.V_BACKP	(20),
		.V_ACTIVE	(720)

	)
	u_vga (
		.reset			(reset_sig),
		.video_clk		(vga_clk_sig),
		.hdmicontrol	(hdmicontrol_sig),
		.hsync			(hsync_sig),
		.vsync			(vsync_sig),
		.cb_rout		(cb_r_sig),
		.cb_gout		(cb_g_sig),
		.cb_bout		(cb_b_sig)
	);



	///// HDMI-TX /////

	hdmi_tx #(
		.DEVICE_FAMILY		("MAX 10"),
		.USE_EXTCONTROL		("ON"),
		.CLOCK_FREQUENCY	(VGACLOCK_MHZ),
		.SCANMODE			("UNDER"),
//		.COLORSPACE			("RGB"),
//		.COLORSPACE			("BT601"),
		.COLORSPACE			("BT709"),
		.AUDIO_FREQUENCY	(FSCLOCK_KHZ)
	)
	u_tx (
		.reset		(reset_sig),
		.clk		(vga_clk_sig),
		.clk_x5		(tx_clk_sig),

		.control	(hdmicontrol_sig),
		.r_data		(cb_r_sig),
		.g_data		(cb_g_sig),
		.b_data		(cb_b_sig),
		.hsync		(hsync_sig),
		.vsync		(vsync_sig),

		.pcm_fs		(fs_timing_reg),
		.pcm_l		({{2{wav_chime_sig[15]}}, wav_chime_sig, 6'd0}),	// -12dB
		.pcm_r		({{2{wav_chime_sig[15]}}, wav_chime_sig, 6'd0}),	// -12dB

		.data		({TMDS_DATA2_P, TMDS_DATA1_P, TMDS_DATA0_P}),
		.data_n		({TMDS_DATA2_N, TMDS_DATA1_N, TMDS_DATA0_N}),
		.clock		(TMDS_CLOCK_P),
		.clock_n	(TMDS_CLOCK_N)
	);


endmodule
