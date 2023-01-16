// ===================================================================
// TITLE : PERIDOT-Air / Audio Wave bar (1280x720)
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2023/01/10 -> 2023/01/11
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

// Verilog-2001 / IEEE 1364-2001
`default_nettype none

module audiobar #(
	parameter ALFA_SHIFT	= 0,
	parameter ALFA_OFFSET	= 0
) (
	input wire			reset,
	input wire			clk,

	input wire			mute,
	input wire [23:0]	bar_color,
	input wire [15:0]	pcm_l_in,
	input wire [15:0]	pcm_r_in,

	input wire			active_in,
	input wire [7:0]	r_in,
	input wire [7:0]	g_in,
	input wire [7:0]	b_in,
	input wire			hsyncn_in,
	input wire			vsyncn_in,

	output wire			active_out,
	output wire [7:0]	r_out,
	output wire [7:0]	g_out,
	output wire [7:0]	b_out,
	output wire			hsyncn_out,
	output wire			vsyncn_out
);


/* ===== 外部変更可能パラメータ ========== */



/* ----- 内部パラメータ ------------------ */



/* ※以降のパラメータ宣言は禁止※ */

/* ===== ノード宣言 ====================== */
				/* 内部は全て正論理リセットとする。ここで定義していないノードの使用は禁止 */
	wire			reset_sig = reset;		// モジュール内部駆動非同期リセット 

				/* 内部は全て正エッジ駆動とする。ここで定義していないクロックノードの使用は禁止 */
	wire			clock_sig = clk;		// モジュール内部駆動クロック 

	reg  [1:0]		active_dly_reg, hsync_dly_reg, vsync_dly_reg;
	wire			active_end_sig, hsync_begin_sig;
	reg  [1:0]		drive_in_reg;
	reg  [10:0]		pixcount_reg;
	reg  [1:0]		linecount_reg;

	reg  [1:0]		avgcount_reg;
	reg  [7:0]		lsat_reg, rsat_reg;
	reg  [9:0]		lacc_reg, racc_reg;

	reg  [7:0]		pcm_l_reg, pcm_r_reg;
	wire [7:0]		alfa_sig;


/* ※以降のwire、reg宣言は禁止※ */

/* ===== テスト記述 ============== */



/* ===== モジュール構造記述 ============== */

	// 同期信号ディレイおよびエッジ検出 

	always @(posedge clock_sig or posedge reset_sig) begin
		if (reset_sig) begin
			active_dly_reg <= 2'b00;
			hsync_dly_reg <= 2'b00;
			vsync_dly_reg <= 2'b00;
		end
		else begin
			active_dly_reg <= {active_dly_reg[0], active_in};
			hsync_dly_reg <= {hsync_dly_reg[0], ~hsyncn_in};
			vsync_dly_reg <= {vsync_dly_reg[0], ~vsyncn_in};
		end
	end

	assign active_end_sig = (!active_in && active_dly_reg[0]);
	assign hsync_begin_sig = (!hsyncn_in && !hsync_dly_reg[0]);


	// ビデオアクティブ期間のカウント 

	always @(posedge clock_sig or posedge reset_sig) begin
		if (reset_sig) begin
			drive_in_reg <= 2'b00;
			pixcount_reg <= 1'd0;
			linecount_reg <= 1'd0;
		end
		else begin
			drive_in_reg <= {drive_in_reg[0], ~mute};	// 非同期信号の同期化 

			if (!drive_in_reg[1] || !vsyncn_in) begin
				pixcount_reg <= 1'd0;
				linecount_reg <= 1'd0;
			end
			else begin
				if (hsync_begin_sig) begin
					pixcount_reg <= 1'd0;
				end
				else if (active_in) begin
					pixcount_reg <= pixcount_reg + 1'd1;
				end

				if (active_end_sig) begin
					linecount_reg <= linecount_reg + 1'd1;
				end
			end
		end
	end


	// PCM信号サンプリング(4ライン毎に加算平均) 

	function [7:0] saturation(input [9:0] d);	// 入力を1/2して飽和 
	begin
		saturation = (!d[9] && d[8])? 8'd127 : (d[9] && !d[8])? 8'd128 : d[8:1];
	end
	endfunction

	always @(posedge clock_sig or posedge reset_sig) begin
		if (reset_sig) begin
			avgcount_reg <= 1'd0;
			lsat_reg <= 1'd0;
			rsat_reg <= 1'd0;
			lacc_reg <= 1'd0;
			racc_reg <= 1'd0;
		end
		else begin
			if (hsync_begin_sig) begin
				if (avgcount_reg == 0) begin
					lsat_reg <= saturation(lacc_reg);
					rsat_reg <= saturation(racc_reg);
					lacc_reg <= {{2{pcm_l_in[15]}}, pcm_l_in[15:8]};
					racc_reg <= {{2{pcm_r_in[15]}}, pcm_r_in[15:8]};
				end
				else begin
					lacc_reg <= lacc_reg + {{2{pcm_l_in[15]}}, pcm_l_in[15:8]};
					racc_reg <= racc_reg + {{2{pcm_r_in[15]}}, pcm_r_in[15:8]};
				end

				avgcount_reg <= avgcount_reg + 1'd1;
			end
		end
	end


	// バーグラフパターン合成 

	always @(posedge clock_sig or posedge reset_sig) begin
		if (reset_sig) begin
			pcm_l_reg <= 1'd0;
			pcm_r_reg <= 1'd0;
		end
		else begin
			if (hsync_begin_sig && linecount_reg == 0) begin
				pcm_l_reg <= {~lsat_reg[7], lsat_reg[6:0]};
				pcm_r_reg <= {~rsat_reg[7], rsat_reg[6:0]};
			end
		end
	end

	assign alfa_sig =	(pixcount_reg[10:8] == 3'b000 && pixcount_reg[7:0] <= pcm_l_reg && pixcount_reg[1] && linecount_reg != 0)? (pixcount_reg[7:0] >> ALFA_SHIFT) + ALFA_OFFSET[7:0] :
						(pixcount_reg[10:8] == 3'b100 && (~pixcount_reg[7:0]) <= pcm_r_reg && !pixcount_reg[1] && linecount_reg != 0)? ((~pixcount_reg[7:0]) >> ALFA_SHIFT) + ALFA_OFFSET[7:0] :
						8'd0;

	alfablend
	u_r (
		.clk	(clock_sig),
		.alfa	(alfa_sig),
		.pixa	(bar_color[23:16]),
		.pixb	(r_in),
		.result	(r_out)
	);

	alfablend
	u_g (
		.clk	(clock_sig),
		.alfa	(alfa_sig),
		.pixa	(bar_color[15:8]),
		.pixb	(g_in),
		.result	(g_out)
	);

	alfablend
	u_b (
		.clk	(clock_sig),
		.alfa	(alfa_sig),
		.pixa	(bar_color[7:0]),
		.pixb	(b_in),
		.result	(b_out)
	);

	assign active_out = active_dly_reg[0];
	assign hsyncn_out = ~hsync_dly_reg[0];
	assign vsyncn_out = ~vsync_dly_reg[0];

endmodule


module alfablend (
	input wire			clk,
	input wire [7:0]	alfa,
	input wire [7:0]	pixa,
	input wire [7:0]	pixb,
	output wire [7:0]	result
);

	reg  [8:0]		mult_a_reg, mult_ma_reg;
	reg  [8:0]		mult_pixa_reg, mult_pixb_reg;
	wire [17:0]		mult_a_res_sig, mult_ma_res_sig, result_sig;

	always @(posedge clk) begin
		mult_a_reg  <= {1'b0, alfa};
		mult_ma_reg <= 9'd256 - {1'b0, alfa};
		mult_pixa_reg <= {1'b0, pixa};
		mult_pixb_reg <= {1'b0, pixb};
	end

	lpm_mult #(
		.lpm_type			("lpm_mult"),
		.lpm_representation	("unsigned"),
		.lpm_widtha			(9),
		.lpm_widthb			(9),
		.lpm_widthp			(18)
	)
	u_a (
		.dataa	(mult_a_reg),
		.datab	(mult_pixa_reg),
		.result	(mult_a_res_sig)
	);

	lpm_mult #(
		.lpm_type			("lpm_mult"),
		.lpm_representation	("unsigned"),
		.lpm_widtha			(9),
		.lpm_widthb			(9),
		.lpm_widthp			(18)
	)
	u_ma (
		.dataa	(mult_ma_reg),
		.datab	(mult_pixb_reg),
		.result	(mult_ma_res_sig)
	);

	assign result_sig = mult_a_res_sig + mult_ma_res_sig;
	assign result = result_sig[15:8];

endmodule

`default_nettype wire
