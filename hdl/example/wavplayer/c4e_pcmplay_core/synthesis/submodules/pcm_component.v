// ===================================================================
// TITLE : PCM playback component
//
//     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
//     DATE   : 2015/09/07 -> 2015/09/08
//     MODIFY : 2023/01/08 
//
// ===================================================================
//
// The MIT License (MIT)
// Copyright (c) 2015,2023 J-7SYSTEM WORKS LIMITED.
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


// reg00 STATUS  bit31:IRQENA bit2:PLAY bit1:IRQ bit0:FIFORST
// reg01 VOLUME  bit31:MUTE bit30-16:VOL_R bit14-0:VOL_L
// reg02 FIFOWR  bit31-16:PCMDATA_R bit15-0:PCMDATA_L
// reg03 rsv

// STATUSレジスタ 
//   rw  IRQENA : 0 IRQリクエストをマスク 
//                1 IRQリクエストを許可 
//
//   ro  PLAY   : 0 再生停止 
//                1 再生中 
//
//   ro  IRQ    : 0 FIFOが空いていない 
//                1 FIFOハーフエンプティ(256ワード以上の空きがある)
//
//   rw  FIFORST: 0 FIFO動作をする 
//                1 FIFOをリセットする 
//
// VOLUMEレジスタ 
//   rw  MUTE   : 0 MUTEをオフ 
//                1 MUTE信号オン 
//
//   rw  VOL_R  : 0x0000-0x4000 出力音量(0x0000:最小 - 0x4000:最大)
//   rw  VOL_L  :      〃
//
// FIFOWRレジスタ 
//   wo  PCMDATA_R : 0x8000-0x7FFF  PCMデータ(右チャネル)
//   wo  PCMDATA_L : 0x8000-0x7FFF  PCMデータ(左チャネル)
//
//      このレジスタに書き込むとPCMデータがFIFOにキューイングされる 
//      読み出し値は不定 


// Verilog-2001 / IEEE 1364-2001
`default_nettype none

module pcm_component #(
	parameter PCM_FIFO_DEPTH		= 10,
	parameter PCM_FIFO_AMOSTEMPTY	= 256
) (
	// Interface: clk
	input wire			csi_clk,
	input wire			csi_reset,

	// Interface: Avalon-MM slave
	input wire  [1:0]	avs_address,
	input wire			avs_read,
	output wire [31:0]	avs_readdata,
	input wire			avs_write,
	input wire  [31:0]	avs_writedata,

	// Interface: Avalon-MM Interrupt sender
	output wire			ins_irq,

	// External Interface
	input wire			coe_128fs_clk,
	output wire			coe_pcm_fs,
	output wire [15:0]	coe_pcm_l,
	output wire [15:0]	coe_pcm_r,
	output wire			coe_mute
);


/* ===== 外部変更可能パラメータ ========== */



/* ----- 内部パラメータ ------------------ */

	localparam PCM_FIFO_FREE	= 2**PCM_FIFO_DEPTH - PCM_FIFO_AMOSTEMPTY;


/* ※以降のパラメータ宣言は禁止※ */

/* ===== ノード宣言 ====================== */
				/* 内部は全て正論理リセットとする。ここで定義していないノードの使用は禁止 */
	wire			reset_sig = csi_reset;				// モジュール内部駆動非同期リセット 

				/* 内部は全て正エッジ駆動とする。ここで定義していないクロックノードの使用は禁止 */
	wire			clock_sig = csi_clk;				// モジュール内部駆動クロック 
	wire			audclock_sig = coe_128fs_clk;		// オーディオ駆動クロック(128fs) 

	reg				irqena_reg;
	reg				fiforeset_reg;
	reg				mute_reg;
	reg [14:0]		volume_l_reg, volume_r_reg;

	reg [6:0]		fsdivcount_reg;
	wire			fs_timing_sig;

	wire [31:0]		fifowrdata_sig;
	wire			fifowrreq_sig;
	wire			fifowrfull_sig;
	wire			fifowrempty_sig;
	wire [PCM_FIFO_DEPTH-1:0] fifousedw_sig;
	wire [31:0]		fifoq_sig;
	wire			fifordempty_sig;
	wire			fifoirq_sig;
	wire [15:0]		pcmdata_l_sig, pcmdata_r_sig;
	wire [31:0]		pcmout_l_sig, pcmout_r_sig;


/* ※以降のwire、reg宣言は禁止※ */

/* ===== テスト記述 ============== */


/* ===== モジュール構造記述 ============== */

	// レジスタ

	assign avs_readdata =
			(avs_address == 2'd0)? {irqena_reg, 28'b0, ~fifowrempty_sig, fifoirq_sig, fiforeset_reg} :
			(avs_address == 2'd1)? {mute_reg, volume_r_reg, 1'b0, volume_l_reg} :
			{32{1'bx}};

	assign ins_irq = (irqena_reg)? fifoirq_sig : 1'b0;

	always @(posedge clock_sig or posedge reset_sig) begin
		if (reset_sig) begin
			irqena_reg    <= 1'b0;
			fiforeset_reg <= 1'b1;
			mute_reg     <= 1'b1;
			volume_r_reg <= 1'd0;
			volume_l_reg <= 1'd0;
		end
		else begin
			if (avs_write) begin
				case (avs_address)
					2'd0 : begin
						irqena_reg    <= avs_writedata[31];
						fiforeset_reg <= avs_writedata[0];
					end
					2'd1 : begin
						mute_reg     <= avs_writedata[31];
						volume_r_reg <= avs_writedata[30:16];
						volume_l_reg <= avs_writedata[14:0];
					end
				endcase
			end

		end
	end

	assign fifowrdata_sig = avs_writedata;
	assign fifowrreq_sig  = (avs_write && avs_address == 2'd2)? 1'b1 : 1'b0;

	assign fifoirq_sig = (!fifowrfull_sig && fifousedw_sig < PCM_FIFO_FREE[PCM_FIFO_DEPTH-1:0])? 1'b1 : 1'b0;


	// 再生FIFO 

	dcfifo_mixed_widths #(
		.lpm_type			("dcfifo"),
		.lpm_numwords		(2**PCM_FIFO_DEPTH),
		.lpm_width			(32),
		.lpm_widthu			(PCM_FIFO_DEPTH),
		.lpm_width_r		(32),
		.lpm_widthu_r		(PCM_FIFO_DEPTH),
		.lpm_showahead		("ON"),
		.write_aclr_synch	("OFF"),
		.wrsync_delaypipe	(4),
		.read_aclr_synch	("ON"),
		.rdsync_delaypipe	(4),
		.use_eab			("ON")
	)
	u_fifo (
		.aclr		(fiforeset_reg),
		.wrclk		(clock_sig),
		.wrreq		(fifowrreq_sig),
		.data		(fifowrdata_sig),
		.wrfull		(fifowrfull_sig),
		.wrusedw	(fifousedw_sig),
		.wrempty	(fifowrempty_sig),

		.rdclk		(audclock_sig),
		.rdreq		(fs_timing_sig),
		.q			(fifoq_sig),
		.rdempty	(fifordempty_sig)
	);

	assign pcmdata_l_sig = (fifordempty_sig)? 16'd0 : fifoq_sig[15:0];
	assign pcmdata_r_sig = (fifordempty_sig)? 16'd0 : fifoq_sig[31:16];


	// タイミング生成 

	always @(posedge audclock_sig or posedge reset_sig) begin
		if (reset_sig) begin
			fsdivcount_reg <= 1'd0;
		end
		else begin
			fsdivcount_reg <= fsdivcount_reg + 1'd1;
		end
	end

	assign fs_timing_sig = (fsdivcount_reg == 1'd0);


	// 波形出力 

	lpm_mult #(
		.lpm_type			("lpm_mult"),
		.lpm_representation	("signed"),
		.lpm_widtha			(16),
		.lpm_widthb			(16),
		.lpm_widthp			(32)
	)
	u_vol_l (
		.dataa	(pcmdata_l_sig),
		.datab	({1'b0, volume_l_reg}),
		.result	(pcmout_l_sig)
	);

	lpm_mult #(
		.lpm_type			("lpm_mult"),
		.lpm_representation	("signed"),
		.lpm_widtha			(16),
		.lpm_widthb			(16),
		.lpm_widthp			(32)
	)
	u_vol_r (
		.dataa	(pcmdata_r_sig),
		.datab	({1'b0, volume_r_reg}),
		.result	(pcmout_r_sig)
	);

	assign coe_pcm_fs = fsdivcount_reg[6];
	assign coe_pcm_l = pcmout_l_sig[29:14];
	assign coe_pcm_r = pcmout_r_sig[29:14];
	assign coe_mute = mute_reg;


endmodule

`default_nettype wire
