-- ===================================================================
-- TITLE : YUV to RGB (Y:fullscale to RGB888)
--
--     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
--     DATE   : 2021/12/02 -> 2022/01/02
--            : 2022/01/02 (FIXED)
--
-- ===================================================================
--
-- The MIT License (MIT)
-- Copyright (c) 2021 J-7SYSTEM WORKS LIMITED.
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

--	R = 1.000*Y                 + 1.402*(V-128)
--	G = 1.000*Y - 0.344*(U-128) - 0.714*(V-128)
--	B = 1.000*Y + 1.772*(U-128)


-- VHDL 1993 / IEEE 1076-1993
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library lpm;
use lpm.lpm_components.all;

entity peridot_vga_yvu2rgb is
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;

		pixelvalid	: in  std_logic;
		y_data		: in  std_logic_vector(7 downto 0);
		uv_data		: in  std_logic_vector(7 downto 0);

		r_data		: out std_logic_vector(7 downto 0);
		g_data		: out std_logic_vector(7 downto 0);
		b_data		: out std_logic_vector(7 downto 0)
	);
end peridot_vga_yvu2rgb;

architecture RTL of peridot_vga_yvu2rgb is
	-- Misc function
	function is_true(S:std_logic) return boolean is begin return(S='1'); end;
	function is_false(S:std_logic) return boolean is begin return(S='0'); end;
	function to_vector(N,W:integer) return std_logic_vector is begin return conv_std_logic_vector(N,W); end;

	-- Signal declare
	signal uv_sel_reg	: std_logic;
	signal y_in_reg		: std_logic_vector(7 downto 0);
	signal u_in_reg		: std_logic_vector(7 downto 0);
	signal v_in_reg		: std_logic_vector(7 downto 0);
	signal y_hold_reg	: std_logic_vector(7 downto 0);
	signal u_hold_reg	: std_logic_vector(7 downto 0);

	signal mul_r_v_sig	: std_logic_vector(16 downto 0);
	signal mul_g_u_sig	: std_logic_vector(16 downto 0);
	signal mul_g_v_sig	: std_logic_vector(16 downto 0);
	signal mul_b_u_sig	: std_logic_vector(16 downto 0);
	signal r_add_sig	: std_logic_vector(16 downto 0);
	signal g_add_sig	: std_logic_vector(16 downto 0);
	signal b_add_sig	: std_logic_vector(16 downto 0);

begin

	-- 入力ラッチとU/Vセレクタ 

	process (clk, reset) begin
		if is_true(reset) then
			uv_sel_reg <= '0';

		elsif rising_edge(clk) then
			if is_true(pixelvalid) then
				uv_sel_reg <= not uv_sel_reg;
			else
				uv_sel_reg <= '0';
			end if;

			y_in_reg <= y_data;
			y_hold_reg <= y_in_reg;

			if is_true(uv_sel_reg) then
				v_in_reg <= uv_data - 128;
			else
				u_in_reg <= uv_data - 128;
			end if;

			u_hold_reg <= u_in_reg;

		end if;
	end process;


	-- R成分計算 

	mul_r_v : lpm_mult
	generic map (
		lpm_type => "LPM_MULT",
		lpm_representation => "SIGNED",
		lpm_widtha => 8,
		lpm_widthb => 9,
		lpm_widthp => 17
	)
	port map (
		dataa => v_in_reg,
		datab => to_vector(179,9),		-- 1.402 * 128
		result => mul_r_v_sig
	);

	r_add_sig <= ("00" & y_hold_reg & "0000000") + mul_r_v_sig;


	-- G成分計算 

	mul_g_u : lpm_mult
	generic map (
		lpm_type => "LPM_MULT",
		lpm_representation => "SIGNED",
		lpm_widtha => 8,
		lpm_widthb => 9,
		lpm_widthp => 17
	)
	port map (
		dataa => u_hold_reg,
		datab => to_vector(44,9),		-- 0.344 * 128
		result => mul_g_u_sig
	);

	mul_g_v : lpm_mult
	generic map (
		lpm_type => "LPM_MULT",
		lpm_representation => "SIGNED",
		lpm_widtha => 8,
		lpm_widthb => 9,
		lpm_widthp => 17
	)
	port map (
		dataa => v_in_reg,
		datab => to_vector(91,9),		-- 0.714 * 128
		result => mul_g_v_sig
	);

	g_add_sig <= ("00" & y_hold_reg & "0000000") - mul_g_u_sig - mul_g_v_sig;


	-- B成分計算 

	mul_b_u : lpm_mult
	generic map (
		lpm_type => "LPM_MULT",
		lpm_representation => "SIGNED",
		lpm_widtha => 8,
		lpm_widthb => 9,
		lpm_widthp => 17
	)
	port map (
		dataa => u_hold_reg,
		datab => to_vector(227,9),		-- 1.772 * 128
		result => mul_b_u_sig
	);

	b_add_sig <= ("00" & y_hold_reg & "0000000") + mul_b_u_sig;


	-- 0～255に飽和して出力 

	r_data <= (others=>'0') when(r_add_sig(16) = '1') else (others=>'1') when(r_add_sig(15) = '1') else r_add_sig(14 downto 7);
	g_data <= (others=>'0') when(g_add_sig(16) = '1') else (others=>'1') when(g_add_sig(15) = '1') else g_add_sig(14 downto 7);
	b_data <= (others=>'0') when(b_add_sig(16) = '1') else (others=>'1') when(b_add_sig(15) = '1') else b_add_sig(14 downto 7);


end RTL;
