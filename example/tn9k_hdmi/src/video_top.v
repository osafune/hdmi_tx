// ===================================================================
// TITLE : Tang nano 9K HDMI output test
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2022/12/31 -> 2023/01/07
//
//
// ===================================================================
//
// The MIT License (MIT)
// Copyright (c) 2022 J-7SYSTEM WORKS LIMITED.
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

module video_top
(
	// clk and key
	input wire			CLOCK_27,
	input wire	[1:0]	KEY_n,

	// HDMI-TX
	output wire			TMDS_CLOCK,		// LVCMOS33D
	output wire			TMDS_DATA0,		// LVCMOS33D
	output wire			TMDS_DATA1,		// LVCMOS33D
	output wire			TMDS_DATA2,		// LVCMOS33D

	// OnBoard LED
    output wire [5:0]	LED				// LVCMOS18
);


/* ===== 外部変更可能パラメータ ========== */


/* ----- 内部パラメータ ------------------ */

	localparam VGACLOCK_MHZ	= 74.25;
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

	wire			active_sig, vsync_sig, hsync_sig;
	wire [7:0]		cb_r_sig, cb_g_sig, cb_b_sig;
	wire			de_out_sig, vs_out_sig, hs_out_sig;
	wire [23:0]		pix_out_sig;
	wire			logo_move_sig;
	wire [23:0]		logo_color_sig;


/* ※以降のwire、reg宣言は禁止※ */

/* ===== テスト記述 ============== */



/* ===== モジュール構造記述 ============== */

	assign LED[5:3] = 3'b111;


	///// クロックとリセット /////
wire serial_clk;
wire pll_lock;
wire hdmi4_rst_n;
wire pix_clk;

TMDS_rPLL u_tmds_rpll
(.clkin     (CLOCK_27)     //input clk 
,.clkout    (serial_clk)     //output clk 
,.lock      (pll_lock  )     //output lock
);

assign hdmi4_rst_n = KEY_n[0] & pll_lock;

CLKDIV u_clkdiv
(.RESETN(hdmi4_rst_n)
,.HCLKIN(serial_clk) //clk  x5
,.CLKOUT(pix_clk)    //clk  x1
,.CALIB (1'b1)
);
defparam u_clkdiv.DIV_MODE="5";
defparam u_clkdiv.GSREN="false";


	assign vga_clk_sig = pix_clk;
	assign tx_clk_sig = serial_clk;
	assign reset_sig = ~hdmi4_rst_n;

	assign LED[0] = pll_lock;



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
		.tempo_led	(LED[1]),
		.wave_out	(wav_chime_sig)
	);



	///// ビデオ同期信号・カラーバー生成 /////

	video_syncgen #(
		.BAR_MODE	("WIDE"),
		.COLORSPACE	("BT709"),
		.H_TOTAL	(1650),		// HD720p(1280x720) : 74.25MHz/74.176MHz
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
		.active			(active_sig),
		.hsync			(hsync_sig),
		.vsync			(vsync_sig),
		.cb_rout		(cb_r_sig),
		.cb_gout		(cb_g_sig),
		.cb_bout		(cb_b_sig)
	);

	assign logo_move_sig = 1'b1;
//	assign logo_color_sig = 24'hffffff;		// RGB
	assign logo_color_sig = 24'h80eb80;		// YCbCr

	logo_overlay #(
		.VIEW_X_SIZE	(1280),
		.VIEW_Y_SIZE	(720)
	)
	u_logo (
		.reset			(reset_sig),
		.clock			(vga_clk_sig),
		.logo_color		(logo_color_sig),
		.logo_move		(logo_move_sig),
		.vsync_in		(vsync_sig),
		.hsync_in		(hsync_sig),
		.de_in			(active_sig),
		.pixel_in		({cb_r_sig, cb_g_sig, cb_b_sig}),
		.vsync_out		(vs_out_sig),
		.hsync_out		(hs_out_sig),
		.de_out			(de_out_sig),
		.pixel_out		(pix_out_sig)
	);



	///// HDMI-TX /////

	hdmi_tx #(
		.DEVICE_FAMILY		("Cyclone IV E"),
		.CLOCK_FREQUENCY	(VGACLOCK_MHZ),
		.SCANMODE			("UNDER"),
		.COLORSPACE			("BT709"),
		.AUDIO_FREQUENCY	(FSCLOCK_KHZ)
	)
	u_tx (
		.reset		(reset_sig),
		.clk		(vga_clk_sig),
		.clk_x5		(tx_clk_sig),

		.active		(de_out_sig),
		.r_data		(pix_out_sig[23:16]),
		.g_data		(pix_out_sig[15:8]),
		.b_data		(pix_out_sig[7:0]),
		.hsync		(hs_out_sig),
		.vsync		(vs_out_sig),

		.pcm_fs		(fs_timing_reg),
		.pcm_l		({{2{wav_chime_sig[15]}}, wav_chime_sig, 6'd0}),	// -12dB
		.pcm_r		({{2{wav_chime_sig[15]}}, wav_chime_sig, 6'd0}),	// -12dB

		.data		({TMDS_DATA2,TMDS_DATA1,TMDS_DATA0}),
		.clock		(TMDS_CLOCK)
	);


endmodule
