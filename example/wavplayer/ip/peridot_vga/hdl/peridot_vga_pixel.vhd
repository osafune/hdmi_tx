-- ===================================================================
-- TITLE : PERIDOT VGA / Pixel fifo
--
--     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
--     DATE   : 2023/01/01 -> 2023/01/05
--            : 2023/01/06 (FIXED)
-- 
-- ===================================================================
--
-- The MIT License (MIT)
-- Copyright (c) 2023 J-7SYSTEM WORKS LIMITED.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

-- VHDL 1993 / IEEE 1076-1993
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity peridot_vga_pixel is
	generic (
		FIFORESETCOUNT		: integer := 4;				-- FIFOの非同期リセット幅(m1clock数) 
		FIFODEPTH_WIDTH		: integer := 9;				-- FIFOの深さ(write側) 
		PIXEL_COLORORDER	: string := "YUV422";		-- "RGB565"   : RGB565 16bit/pixel
														-- "RGB555"   : RGB555 15bit/pixel
														-- "YUV422"   : YUV422 16bit/word
		PIXEL_DATAORDER		: string := "BYTE"			-- "BYTE"     : バイト順(リトルエンディアン) 
														-- "WORD"     : ワード順(16bitビッグエンディアン) 
	);
	port (
		reset			: in  std_logic;
		m1_clk			: in  std_logic;

		fifo_ready		: out std_logic;
		fifo_data		: in  std_logic_vector(31 downto 0);
		fifo_wrena		: in  std_logic;
		fifo_wrfreedw	: out std_logic_vector(FIFODEPTH_WIDTH downto 0);	-- fifoの残量 

		video_clk		: in  std_logic;
		video_vsync		: in  std_logic;
		video_request	: in  std_logic;
		video_rout		: out std_logic_vector(7 downto 0);		-- RGBは2クロック, YUVは4クロック遅延 
		video_gout		: out std_logic_vector(7 downto 0);
		video_bout		: out std_logic_vector(7 downto 0)
	);
end peridot_vga_pixel;

architecture RTL of peridot_vga_pixel is
	-- Misc function
	function is_true(S:std_logic) return boolean is begin return(S='1'); end;

	-- Constant declare
	constant FIFO_WIDTHU	: integer := FIFODEPTH_WIDTH + 1;
	constant FIFO_WIDTHU_R	: integer := FIFODEPTH_WIDTH + 2;

	-- Signal declare
	signal cdb_vsyncin_reg	: std_logic_vector(2 downto 0);		-- [0] input false_path
	signal fiforeset_reg	: std_logic;						-- output false_path
	signal resetcounter		: integer range 0 to FIFORESETCOUNT*2-1;
	
	signal wrusedw_sig		: std_logic_vector(FIFODEPTH_WIDTH downto 0);
	signal q_sig			: std_logic_vector(15 downto 0);
	signal pixeldata_sig	: std_logic_vector(15 downto 0);
	signal pixel_r_sig		: std_logic_vector(7 downto 0);
	signal pixel_g_sig		: std_logic_vector(7 downto 0);
	signal pixel_b_sig		: std_logic_vector(7 downto 0);

	signal validdelay_reg	: std_logic_vector(2 downto 0);
	signal pixellatch_sig	: std_logic;
	signal rout_reg			: std_logic_vector(7 downto 0);
	signal gout_reg			: std_logic_vector(7 downto 0);
	signal bout_reg			: std_logic_vector(7 downto 0);

	-- Component declare
	component peridot_vga_yvu2rgb
	port (
		reset		: in  std_logic;
		clk			: in  std_logic;

		pixelvalid	: in  std_logic;
		y_data		: in  std_logic_vector(7 downto 0);
		uv_data		: in  std_logic_vector(7 downto 0);

		r_data		: out std_logic_vector(7 downto 0);
		g_data		: out std_logic_vector(7 downto 0);
		b_data		: out std_logic_vector(7 downto 0)
	);
	end component;

begin

	-- ピクセルFIFO 

	fifo_ready <= '1' when(resetcounter = 0) else '0';
	fifo_wrfreedw <= 2**FIFODEPTH_WIDTH - wrusedw_sig;

	process (m1_clk, reset) begin
		if is_true(reset) then
			cdb_vsyncin_reg <= (others=>'0');
			fiforeset_reg <= '0';
			resetcounter <= 0;

		elsif rising_edge(m1_clk) then
			cdb_vsyncin_reg <= cdb_vsyncin_reg(1 downto 0) & video_vsync;

			if (cdb_vsyncin_reg(2 downto 1) = "01") then
				fiforeset_reg <= '1';
			elsif (resetcounter = FIFORESETCOUNT) then
				fiforeset_reg <= '0';
			end if;

			if (cdb_vsyncin_reg(2 downto 1) = "01") then
				resetcounter <= FIFORESETCOUNT*2 - 1;
			elsif (resetcounter /= 0) then
				resetcounter <= resetcounter - 1;
			end if;

		end if;
	end process;

	u_fifo : dcfifo_mixed_widths
	generic map (
		lpm_type			=> "dcfifo",
		lpm_numwords		=> 2**FIFODEPTH_WIDTH,
		lpm_width			=> 32,
		lpm_widthu			=> FIFO_WIDTHU,
		lpm_width_r			=> 16,
		lpm_widthu_r		=> FIFO_WIDTHU_R,
		lpm_showahead		=> "OFF",
		add_usedw_msb_bit	=> "ON",
		write_aclr_synch	=> "ON",
		wrsync_delaypipe	=> 4,
		read_aclr_synch		=> "ON",
		rdsync_delaypipe	=> 4,
		use_eab				=> "ON"
	)
	port map (
		aclr	=> fiforeset_reg,
		wrclk	=> m1_clk,
		wrreq	=> fifo_wrena,
		data	=> fifo_data,
		wrusedw	=> wrusedw_sig,
		rdclk	=> video_clk,
		rdreq	=> video_request,
		q		=> q_sig
	);


	-- フォーマット変換 

gen_dataword : if (PIXEL_DATAORDER = "WORD") generate
	pixeldata_sig <= q_sig(7 downto 0) & q_sig(15 downto 8);
end generate;
gen_databyte : if (PIXEL_DATAORDER /= "WORD") generate
	pixeldata_sig <= q_sig;
end generate;

gen_rgb565 : if (PIXEL_COLORORDER = "RGB565") generate
	pixel_r_sig <= pixeldata_sig(15 downto 11) & pixeldata_sig(15 downto 13);
	pixel_g_sig <= pixeldata_sig(10 downto  5) & pixeldata_sig(10 downto  9);
	pixel_b_sig <= pixeldata_sig( 4 downto  0) & pixeldata_sig( 4 downto  2);
	pixellatch_sig <= validdelay_reg(0);
end generate;

gen_rgb555 : if (PIXEL_COLORORDER = "RGB555") generate
	pixel_r_sig <= pixeldata_sig(14 downto 10) & pixeldata_sig(14 downto 12);
	pixel_g_sig <= pixeldata_sig( 9 downto  5) & pixeldata_sig( 9 downto  7);
	pixel_b_sig <= pixeldata_sig( 4 downto  0) & pixeldata_sig( 4 downto  2);
	pixellatch_sig <= validdelay_reg(0);
end generate;

gen_yuv422 : if (PIXEL_COLORORDER = "YUV422") generate
	u_yvu2rgb : peridot_vga_yvu2rgb
	port map (
		reset		=> '0',
		clk			=> video_clk,
		pixelvalid	=> validdelay_reg(0),
		y_data		=> pixeldata_sig(7 downto 0),
		uv_data		=> pixeldata_sig(15 downto 8),
		r_data		=> pixel_r_sig,
		g_data		=> pixel_g_sig,
		b_data		=> pixel_b_sig
	);
	pixellatch_sig <= validdelay_reg(2);
end generate;


	-- 出力データラッチ 

	process (video_clk) begin
		if rising_edge(video_clk) then
			validdelay_reg <= validdelay_reg(1 downto 0) & video_request;

			if is_true(pixellatch_sig) then
				rout_reg <= pixel_r_sig;
				gout_reg <= pixel_g_sig;
				bout_reg <= pixel_b_sig;
			else
				rout_reg <= (others=>'0');
				gout_reg <= (others=>'0');
				bout_reg <= (others=>'0');
			end if;
		end if;
	end process;

	video_rout <= rout_reg;
	video_gout <= gout_reg;
	video_bout <= bout_reg;


end RTL;
