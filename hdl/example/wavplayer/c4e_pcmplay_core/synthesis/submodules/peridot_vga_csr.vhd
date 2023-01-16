-- ===================================================================
-- TITLE : PERIDOT VGA / Control register
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

entity peridot_vga_csr is
	port (
	--==== Avalon-MM Agent信号 =======================================
		reset				: in  std_logic;
		csi_csr_clk			: in  std_logic;

		avs_csr_address		: in  std_logic_vector(1 downto 0);
		avs_csr_read		: in  std_logic;
		avs_csr_readdata	: out std_logic_vector(31 downto 0);
		avs_csr_write		: in  std_logic;
		avs_csr_writedata	: in  std_logic_vector(31 downto 0);

		ins_csr_irq			: out std_logic;

	--==== 外部信号 ==================================================
		video_vsync			: in  std_logic;	-- async input
		framestart			: out std_logic;
		framebuff_top		: out std_logic_vector(31 downto 0);	-- framestart↑エッジで確定 
		scan_enable			: out std_logic							-- レジスタ書き込みで変化 
	);
end peridot_vga_csr;

architecture RTL of peridot_vga_csr is
	-- Misc function
	function is_true(S:std_logic) return boolean is begin return(S='1'); end;
	function is_false(S:std_logic) return boolean is begin return(S='0'); end;
	function to_vector(N,W:integer) return std_logic_vector is begin return conv_std_logic_vector(N,W); end;
	function repbit(S:std_logic; W:integer) return std_logic_vector is variable a:std_logic_vector(W-1 downto 0); begin a:=(others=>S); return a; end;

	-- signal
	signal framebegin		: boolean;
	signal cdb_vsyncin_reg	: std_logic_vector(2 downto 0);		-- [0] : input false_path
	signal topaddr_out_reg	: std_logic_vector(31 downto 0);	-- [*] : output false_path

	signal readdata_0_sig	: std_logic_vector(31 downto 0);
	signal readdata_1_sig	: std_logic_vector(31 downto 0);
	signal readdata_2_sig	: std_logic_vector(31 downto 0);
	signal vsirq_reg		: std_logic;
	signal vsirqena_reg		: std_logic;
	signal vsflag_reg		: std_logic;
	signal scanena_reg		: std_logic;
	signal framebuff_top_reg: std_logic_vector(31 downto 0);
	signal vsynccounter_reg	: std_logic_vector(7 downto 0);

begin

	-- 非同期信号の同期化 

	framebegin <= (cdb_vsyncin_reg(2 downto 1) = "01");

	process (csi_csr_clk, reset) begin
		if is_true(reset) then
			cdb_vsyncin_reg <= (others=>'0');

		elsif rising_edge(csi_csr_clk) then
			cdb_vsyncin_reg <= cdb_vsyncin_reg(1 downto 0) & video_vsync;

			if framebegin then
				topaddr_out_reg <= framebuff_top_reg;
			end if;
		end if;
	end process;

	framestart <= cdb_vsyncin_reg(2) when is_true(scanena_reg) else '0';
	framebuff_top <= topaddr_out_reg;
	scan_enable <= scanena_reg;


	-- コントロールレジスタ 

	readdata_0_sig <= (
		15 => vsirqena_reg,
		14 => vsirq_reg,
		13 => vsflag_reg,
		 0 => scanena_reg,
		others=>'0'
	);
	readdata_1_sig <= framebuff_top_reg;
	readdata_2_sig <= repbit('0', 24) & vsynccounter_reg;

	with avs_csr_address select avs_csr_readdata <=
		readdata_0_sig when "00",
		readdata_1_sig when "01",
		readdata_2_sig when "10",
		(others=>'X')  when others;

	ins_csr_irq <= vsirq_reg when is_true(vsirqena_reg) else '0';

	process (csi_csr_clk, reset) begin
		if is_true(reset) then
			vsirq_reg    <= '0';
			vsirqena_reg <= '0';
--			vsflag_reg   <= '0';
			scanena_reg  <= '0';
--			vsynccounter_reg <= (others=>'0');

		elsif rising_edge(csi_csr_clk) then

			-- VSYNC割り込みフラグのセットとクリア 

			if framebegin then
				vsirq_reg  <= '1';
				vsflag_reg <= not vsflag_reg;		-- vsflagはVSYNCの度に反転する 
			elsif (is_true(avs_csr_write) and avs_csr_address = "00") then
				vsirq_reg <= vsirq_reg and avs_csr_writedata(14);
			end if;

			-- VSYNCカウンタのセットとデクリメント 

			if (is_true(avs_csr_write) and avs_csr_address = "10") then
				vsynccounter_reg <= avs_csr_writedata(7 downto 0);
			elsif framebegin then
				if (vsynccounter_reg /= 0) then
					vsynccounter_reg <= vsynccounter_reg - '1';
				end if;
			end if;

			-- その他の制御レジスタの書き込み 

			if is_true(avs_csr_write) then
				case avs_csr_address is
				when "00" =>
					vsirqena_reg <= avs_csr_writedata(15);
					scanena_reg  <= avs_csr_writedata(0);

				when "01" =>
					framebuff_top_reg <= avs_csr_writedata;

				when others =>
				end case;
			end if;

		end if;
	end process;


end RTL;
