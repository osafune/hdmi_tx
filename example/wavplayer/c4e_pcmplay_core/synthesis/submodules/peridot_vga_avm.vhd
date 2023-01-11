-- ===================================================================
-- TITLE : PERIDOT VGA / Avalon-MM burst read
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

entity peridot_vga_avm is
	generic (
--		LINENUMBER			: integer := 3;		-- test
--		TRANSCYCLE			: integer := 33;	-- test
		LINENUMBER			: integer := 480;		-- 転送するライン数 
		TRANSCYCLE			: integer := 640/2;		-- 1ライン辺りの転送データワード数 
		LINEOFFSETBYTES		: integer := 1024*2;	-- メモリ上の1ライン分のデータバイト数 
		BURSTCOUNT_WIDTH	: integer := 4			-- バースト長単位 (2^BURSTCOUNT_WIDTH) 
	);
	port (
	--==== Avalon-MM Host信号 ========================================
		reset				: in  std_logic;
		csi_m1_clk			: in  std_logic;

		avm_m1_address		: out std_logic_vector(31 downto 0);
		avm_m1_burstcount	: out std_logic_vector(BURSTCOUNT_WIDTH downto 0);
		avm_m1_waitrequest	: in  std_logic;
		avm_m1_read			: out std_logic;
		avm_m1_readdata		: in  std_logic_vector(31 downto 0);
		avm_m1_readdatavalid: in  std_logic;

	--==== 外部信号 ================================================
		ready				: out std_logic;
		framestart			: in  std_logic;						-- async input (↑エッジで開始)
		framebuff_top		: in  std_logic_vector(31 downto 0);	-- async input (framestart↑エッジ時点で確定していること)

		fifo_ready			: in  std_logic;
		readdata			: out std_logic_vector(31 downto 0);
		readdata_valid		: out std_logic;
		readdata_freedw		: in  std_logic_vector(BURSTCOUNT_WIDTH downto 0)	-- ピクセルFIFOの空いてる数 (0～2^BURSTCOUNT_WIDTH)
	);
end peridot_vga_avm;

architecture RTL of peridot_vga_avm is
	-- Misc function
	function is_true(S:std_logic) return boolean is begin return(S='1'); end;
	function is_false(S:std_logic) return boolean is begin return(S='0'); end;
	function to_vector(N,W:integer) return std_logic_vector is begin return conv_std_logic_vector(N,W); end;

	-- Constant declare
	constant BURSTUNIT		: integer := 2**BURSTCOUNT_WIDTH;
	constant LINEWORDNUM	: integer := LINEOFFSETBYTES/4;

	-- Signal declare
	signal cdb_fstart_reg	: std_logic_vector(2 downto 0);		-- [0] : input false_path
	signal framebegin		: boolean;

	type BUS_STATE is (IDLE, LINE_INIT, READ_SETUP,READ_START,READ_ISSUE,READ_DATA, LINE_LOOP);
	signal avm_state : BUS_STATE;
	signal datacounter		: integer range 0 to BURSTUNIT;
	signal transcounter		: integer range 0 to TRANSCYCLE;
	signal linecounter		: integer range 0 to LINENUMBER-1;
	signal lineaddr_reg		: std_logic_vector(31 downto 2);	-- [*] : from framebuff_top false_path
	signal addr_reg			: std_logic_vector(31 downto 2);
	signal read_reg			: std_logic;

begin

	-- 非同期信号の同期化 

	process (csi_m1_clk, reset) begin
		if is_true(reset) then
			cdb_fstart_reg <= (others=>'0');
		elsif rising_edge(csi_m1_clk) then
			cdb_fstart_reg <= cdb_fstart_reg(1 downto 0) & framestart;
		end if;
	end process;

	framebegin <= (cdb_fstart_reg(2 downto 1) = "01");


	-- AvalonMMバーストリード制御 

	ready <= '1' when(avm_state = IDLE) else '0';

	avm_m1_address    <= addr_reg & "00";
	avm_m1_burstcount <= to_vector(datacounter, avm_m1_burstcount'length);
	avm_m1_read       <= read_reg;

	readdata       <= avm_m1_readdata;
	readdata_valid <= avm_m1_readdatavalid when(avm_state = READ_DATA) else '0';

	process (csi_m1_clk, reset) begin
		if is_true(reset) then
			avm_state <= IDLE;
--			datacounter <= 0;
--			transcounter <= 0;
--			linecounter <= 0;
			read_reg  <= '0';

		elsif rising_edge(csi_m1_clk) then
			case avm_state is
			when IDLE =>
				if framebegin then
					avm_state <= LINE_INIT;
					lineaddr_reg <= framebuff_top(31 downto 2);
					linecounter <= LINENUMBER-1;
				end if;

			when LINE_INIT =>		-- ライン先頭処理 
				if is_true(fifo_ready) then
					avm_state <= READ_SETUP;
					transcounter <= TRANSCYCLE;
					addr_reg <= lineaddr_reg;
					lineaddr_reg <= lineaddr_reg + LINEWORDNUM;
				end if;

			when READ_SETUP =>		-- バーストリードセットアップ 
				avm_state <= READ_START;
				if (transcounter > BURSTUNIT) then
					datacounter <= BURSTUNIT;
				else
					datacounter <= transcounter;
				end if;

			when READ_START =>		-- ピクセルFIFO空き待ち 
				if (readdata_freedw >= datacounter) then
					avm_state <= READ_ISSUE;
					read_reg  <= '1';
				end if;

			when READ_ISSUE =>		-- バーストリードリクエスト発行 
				if is_false(avm_m1_waitrequest) then
					avm_state <= READ_DATA;
					read_reg  <= '0';
				end if;

			when READ_DATA =>		-- バーストリードデータ到着 
				if is_true(avm_m1_readdatavalid) then
					if (datacounter = 1) then
						avm_state <= LINE_LOOP;
					end if;

					datacounter <= datacounter - 1;
					transcounter <= transcounter - 1;
				end if;

			when LINE_LOOP =>		-- ループチェック 
				if (transcounter /= 0) then
					avm_state <= READ_SETUP;
				else
					if (linecounter /= 0) then
						avm_state <= LINE_INIT;
						linecounter <= linecounter - 1;
					else
						avm_state <= IDLE;
					end if;
				end if;

				addr_reg <= addr_reg + BURSTUNIT;

			when others=>
			end case;

		end if;
	end process;


end RTL;
