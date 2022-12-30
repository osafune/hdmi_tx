-- ===================================================================
-- TITLE : Melody Chime
--
--     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
--     DATE   : 2012/08/17 -> 2012/08/28
--            : 2012/08/28 (FIXED)
--
--     UPDATE : 2018/11/26
--            : 2022/12/28
-- ===================================================================

-- The MIT License (MIT)
-- Copyright (c) 2012,2018 J-7SYSTEM WORKS LIMITED.
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


-- VHDL 1993 / IEEE 1076-1993

----------------------------------------------------------------------
--  シーケンサーサブモジュール 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity melodychime_seq is
	generic(
		TEMPO_TC		: integer := 357		-- テンポカウンタ(357ms/Tempo=84) 
	);
	port(
		reset			: in  std_logic;		-- async reset
		clk				: in  std_logic;		-- system clock
		timing_1ms		: in  std_logic;		-- clock enable (1msタイミング,1パルス幅,1アクティブ) 
		tempo_out		: out std_logic;		-- テンポ信号出力 (1パルス幅,1アクティブ)

		start			: in  std_logic;		-- '1'パルスで再生開始 
		slot_div		: out std_logic_vector(7 downto 0);		-- スロットの音程データ 
		slot_note		: out std_logic;						-- スロットの発音 
		slot0_wrreq		: out std_logic;		-- スロット０への書き込み要求 
		slot1_wrreq		: out std_logic			-- スロット１への書き込み要求 
	);
end melodychime_seq;

architecture RTL of melodychime_seq is
	-- Misc function
	function is_true(S:std_logic) return boolean is begin return(S='1'); end;
	function to_vector(N,W:integer) return std_logic_vector is begin return conv_std_logic_vector(N,W); end;

	-- Constant declare
	constant R		: std_logic_vector(4 downto 0) := "XXXXX";	--	O4G+
	constant O4Gp	: std_logic_vector(4 downto 0) := "00000";	--	O4G+
	constant O4A	: std_logic_vector(4 downto 0) := "00001";	--	O4A
	constant O4Ap	: std_logic_vector(4 downto 0) := "00010";	--	O4A+
	constant O4B	: std_logic_vector(4 downto 0) := "00011";	--	O4B
	constant O5C	: std_logic_vector(4 downto 0) := "00100";	--	O5C
	constant O5Cp	: std_logic_vector(4 downto 0) := "00101";	--	O5C+
	constant O5D	: std_logic_vector(4 downto 0) := "00110";	--	O5D
	constant O5Dp	: std_logic_vector(4 downto 0) := "00111";	--	O5D+
	constant O5E	: std_logic_vector(4 downto 0) := "01000";	--	O5E
	constant O5F	: std_logic_vector(4 downto 0) := "01001";	--	O5F
	constant O5Fp	: std_logic_vector(4 downto 0) := "01010";	--	O5F+
	constant O5G	: std_logic_vector(4 downto 0) := "01011";	--	O5G
	constant O5Gp	: std_logic_vector(4 downto 0) := "01100";	--	O5G+
	constant O5A	: std_logic_vector(4 downto 0) := "01101";	--	O5A
	constant O5Ap	: std_logic_vector(4 downto 0) := "01110";	--	O5A+
	constant O5B	: std_logic_vector(4 downto 0) := "01111";	--	O5B
	constant O6C	: std_logic_vector(4 downto 0) := "10000";	--	O6C
	constant O6Cp	: std_logic_vector(4 downto 0) := "10001";	--	O6C+
	constant O6D	: std_logic_vector(4 downto 0) := "10010";	--	O6D
	constant O6Dp	: std_logic_vector(4 downto 0) := "10011";	--	O6D+
	constant O6E	: std_logic_vector(4 downto 0) := "10100";	--	O6E
	constant O6F	: std_logic_vector(4 downto 0) := "10101";	--	O6F
	constant O6Fp	: std_logic_vector(4 downto 0) := "10110";	--	O6F+
	constant O6G	: std_logic_vector(4 downto 0) := "10111";	--	O6G
	constant O6Gp	: std_logic_vector(4 downto 0) := "11000";	--	O6G+
	constant O6A	: std_logic_vector(4 downto 0) := "11001";	--	O6A
	constant O6Ap	: std_logic_vector(4 downto 0) := "11010";	--	O6A+
	constant O6B	: std_logic_vector(4 downto 0) := "11011";	--	O6B
	constant O7C	: std_logic_vector(4 downto 0) := "11100";	--	O7C
	constant O7Cp	: std_logic_vector(4 downto 0) := "11101";	--	O7C+
	constant O7D	: std_logic_vector(4 downto 0) := "11110";	--	O7D
	constant O7Dp	: std_logic_vector(4 downto 0) := "11111";	--	O7D+

	constant SCORE_WIDTH	: integer := 4;
	constant SCORE_LENGTH	: integer := 2**SCORE_WIDTH;
	constant SLOT_WIDTH		: integer := 1;
	constant SLOT_LENGTH	: integer := 2**SLOT_WIDTH;

	-- signal
	type DEF_SCORE is array(0 to SCORE_LENGTH*SLOT_LENGTH-1) of std_logic_vector(5 downto 0);
	signal score_mem : DEF_SCORE;

	signal tempocount	: integer range 0 to TEMPO_TC-1;
	signal tempo_sig	: std_logic;
	signal start_reg	: std_logic;
	signal scorecount	: integer range 0 to SCORE_LENGTH-1;
	signal play_reg		: std_logic;
	signal tdelay_reg	: std_logic;
	signal slotcount	: integer range 0 to SLOT_LENGTH-1;
	signal slot_reg		: std_logic;

	signal score_reg	: std_logic_vector(5 downto 0);
	signal sqdivref_sig	: integer range 0 to 255;
	signal wrreq_reg	: std_logic_vector(SLOT_LENGTH-1 downto 0);

begin

	-- 楽譜データ 

	score_mem(SCORE_LENGTH*0 + 0)  <= '1' & O6G;
	score_mem(SCORE_LENGTH*0 + 1)  <= '1' & O6Dp;
	score_mem(SCORE_LENGTH*0 + 2)  <= '1' & O5Ap;
	score_mem(SCORE_LENGTH*0 + 3)  <= '1' & O6Dp;
	score_mem(SCORE_LENGTH*0 + 4)  <= '1' & O6F;
	score_mem(SCORE_LENGTH*0 + 5)  <= '1' & O6Ap;
	score_mem(SCORE_LENGTH*0 + 6)  <= '0' & O6Ap;
	score_mem(SCORE_LENGTH*0 + 7)  <= '1' & O5F;
	score_mem(SCORE_LENGTH*0 + 8)  <= '1' & O6F;
	score_mem(SCORE_LENGTH*0 + 9)  <= '1' & O6G;
	score_mem(SCORE_LENGTH*0 + 10) <= '1' & O6F;
	score_mem(SCORE_LENGTH*0 + 11) <= '1' & O5Ap;
	score_mem(SCORE_LENGTH*0 + 12) <= '1' & O6Dp;
	score_mem(SCORE_LENGTH*0 + 13) <= '0' & O6Dp;
	score_mem(SCORE_LENGTH*0 + 14) <= '0' & O6Dp;
	score_mem(SCORE_LENGTH*0 + 15) <= '0' & O6Dp;

	score_mem(SCORE_LENGTH*1 + 0)  <= '0' & R;
	score_mem(SCORE_LENGTH*1 + 1)  <= '0' & R;
	score_mem(SCORE_LENGTH*1 + 2)  <= '1' & O5G;
	score_mem(SCORE_LENGTH*1 + 3)  <= '0' & O5G;
	score_mem(SCORE_LENGTH*1 + 4)  <= '1' & O6D;
	score_mem(SCORE_LENGTH*1 + 5)  <= '0' & O6D;
	score_mem(SCORE_LENGTH*1 + 6)  <= '0' & R;
	score_mem(SCORE_LENGTH*1 + 7)  <= '0' & R;
	score_mem(SCORE_LENGTH*1 + 8)  <= '1' & O5Ap;
	score_mem(SCORE_LENGTH*1 + 9)  <= '0' & O5Ap;
	score_mem(SCORE_LENGTH*1 + 10) <= '1' & O5Ap;
	score_mem(SCORE_LENGTH*1 + 11) <= '0' & O5Ap;
	score_mem(SCORE_LENGTH*1 + 12) <= '1' & O5G;
	score_mem(SCORE_LENGTH*1 + 13) <= '0' & O5G;
	score_mem(SCORE_LENGTH*1 + 14) <= '0' & O5G;
	score_mem(SCORE_LENGTH*1 + 15) <= '0' & O5G;


	-- テンポタイミングおよびスタート信号発生 

	process (clk, reset) begin
		if is_true(reset) then
			tempocount  <= 0;
			start_reg <= '0';

		elsif rising_edge(clk) then
			if is_true(timing_1ms) then
				if (tempocount = 0) then
					tempocount <= TEMPO_TC-1;
				else
					tempocount <= tempocount - 1;
				end if;
			end if;

			if is_true(start) then
				start_reg <= '1';
			elsif is_true(tempo_sig) then
				start_reg <= '0';
			end if;

		end if;
	end process;

	tempo_sig <= '1' when(is_true(timing_1ms) and tempocount = 0) else '0';
	tempo_out <= tempo_sig;


	-- スコアシーケンサ 

	process (clk, reset) begin
		if (reset = '1') then
			play_reg   <= '0';
			scorecount <= 0;
			tdelay_reg <= '0';
			slot_reg   <= '0';
			slotcount  <= 0;

		elsif rising_edge(clk) then
			if is_true(tempo_sig) then
				if is_true(start_reg) then
					play_reg <= '1';
					scorecount <= 0;
				elsif (scorecount = SCORE_LENGTH-1) then
					play_reg <= '0';
				elsif is_true(play_reg) then
					scorecount <= scorecount + 1;
				end if;
			end if;

			tdelay_reg <= tempo_sig;

			if is_true(tdelay_reg) then
				slot_reg <= play_reg;
				slotcount <= 0;
			elsif (slotcount = SLOT_LENGTH-1) then
				slot_reg  <= '0';
			else
				slotcount <= slotcount + 1;
			end if;

		end if;
	end process;


	-- 楽譜読み出し 

	process (clk, reset) begin
		if is_true(reset) then
			wrreq_reg <= (others=>'0');

		elsif rising_edge(clk) then
			score_reg <= score_mem( slotcount*SCORE_LENGTH + scorecount );

			for i in 0 to SLOT_LENGTH-1 loop
				if (i = slotcount) then
					wrreq_reg(i) <= slot_reg;
				else
					wrreq_reg(i) <= '0';
				end if;
			end loop;

		end if;
	end process;


	-- 音階データ→分周値変換 

	with score_reg(4 downto 0) select sqdivref_sig <=
		241-1	when O4Gp,	--	O4G+	207.652Hz
		227-1	when O4A,	--	O4A		220.000Hz
		215-1	when O4Ap,	--	O4A+	233.082Hz
		202-1	when O4B,	--	O4B		246.942Hz
		191-1	when O5C,	--	O5C		261.626Hz
		180-1	when O5Cp,	--	O5C+	277.183Hz
		170-1	when O5D,	--	O5D		293.665Hz
		161-1	when O5Dp,	--	O5D+	311.127Hz
		152-1	when O5E,	--	O5E		329.628Hz
		143-1	when O5F,	--	O5F		349.228Hz
		135-1	when O5Fp,	--	O5F+	369.994Hz
		128-1	when O5G,	--	O5G		391.995Hz
		120-1	when O5Gp,	--	O5G+	415.305Hz
		114-1	when O5A,	--	O5A		440.000Hz
		107-1	when O5Ap,	--	O5A+	466.164Hz
		101-1	when O5B,	--	O5B		493.883Hz
		96-1	when O6C,	--	O6C		523.251Hz
		90-1	when O6Cp,	--	O6C+	554.365Hz
		85-1	when O6D,	--	O6D		587.330Hz
		80-1	when O6Dp,	--	O6D+	622.254Hz
		76-1	when O6E,	--	O6E		659.255Hz
		72-1	when O6F,	--	O6F		698.456Hz
		68-1	when O6Fp,	--	O6F+	739.989Hz
		64-1	when O6G,	--	O6G		783.991Hz
		60-1	when O6Gp,	--	O6G+	830.609Hz
		57-1	when O6A,	--	O6A		880.000Hz
		54-1	when O6Ap,	--	O6A+	932.328Hz
		51-1	when O6B,	--	O6B		987.767Hz
		48-1	when O7C,	--	O7C		1046.502Hz
		45-1	when O7Cp,	--	O7C+	1108.731Hz
		43-1	when O7D,	--	O7D		1174.659Hz
		40-1	when O7Dp;	--	O7D+	1244.508Hz


	-- スロット制御信号出力 

	slot_div  <= to_vector(sqdivref_sig, 8);
	slot_note <= score_reg(5);

	slot0_wrreq <= wrreq_reg(0);
	slot1_wrreq <= wrreq_reg(1);


end RTL;


----------------------------------------------------------------------
--  波形ジェネレーターサブモジュール 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity melodychime_sg is
	generic(
		ENVELOPE_TC		: integer := 28000		-- エンベロープ時定数(一次遅れ系,t=0.5秒)
	);
	port(
		reset			: in  std_logic;		-- async reset
		clk				: in  std_logic;		-- system clock
		reg_div			: in  std_logic_vector(7 downto 0);		-- 分周値データ(0～255) 
		reg_note		: in  std_logic;		-- ノートオン(1:発音開始 / 0:無効) 
		reg_write		: in  std_logic;		-- 1=レジスタ書き込み 

		timing_10us		: in  std_logic;		-- clock enable (10usタイミング,1パルス幅,1アクティブ) 
		timing_1ms		: in  std_logic;		-- clock enable (1msタイミング,1パルス幅,1アクティブ) 

		wave_out		: out std_logic_vector(15 downto 0)		-- 波形データ出力(符号付き16bit) 
	);
end melodychime_sg;

architecture RTL of melodychime_sg is
	-- Misc function
	function is_true(S:std_logic) return boolean is begin return(S='1'); end;
	function to_vector(N,W:integer) return std_logic_vector is begin return conv_std_logic_vector(N,W); end;

	-- Constant declare
	constant ENVCOUNT_INIT	: std_logic_vector(14 downto 0) := to_vector(ENVELOPE_TC, 15);

	-- signal
	signal divref_reg		: std_logic_vector(7 downto 0);
	signal note_reg			: std_logic;
	signal sqdivcount		: std_logic_vector(7 downto 0);
	signal sqwave_reg		: std_logic;

	signal env_count_reg	: std_logic_vector(14 downto 0);
	signal env_cnext_sig	: std_logic_vector(14+9 downto 0);
	signal wave_pos_sig		: std_logic_vector(15 downto 0);
	signal wave_neg_sig		: std_logic_vector(15 downto 0);

begin

	-- 入力レジスタ 

	process (clk, reset) begin
		if is_true(reset) then
			divref_reg <= (others=>'0');
			note_reg <= '0';

		elsif rising_edge(clk) then
			if is_true(reg_write) then
				divref_reg <= reg_div;
			end if;

			if is_true(reg_write) and is_true(reg_note) then
				note_reg <= '1';
			elsif is_true(timing_1ms) then
				note_reg <= '0';
			end if;

		end if;
	end process;


	-- 矩形波生成 

	process (clk, reset) begin
		if is_true(reset) then
			sqdivcount <= (others=>'0');
			sqwave_reg <= '0';

		elsif rising_edge(clk) then
			if is_true(timing_10us) then
				if (sqdivcount = 0) then
					sqdivcount <= divref_reg;
					sqwave_reg <= not sqwave_reg;
				else
					sqdivcount <= sqdivcount - 1;
				end if;
			end if;

		end if;
	end process;


	-- エンベロープ生成 

	process (clk, reset)
		variable env_cnext_val	: std_logic_vector(env_count_reg'length + 9-1 downto 0);
	begin
		if is_true(reset) then
			env_count_reg <= (others=>'0');

		elsif rising_edge(clk) then
			if is_true(timing_1ms) then
				if is_true(note_reg) then
					env_count_reg <= ENVCOUNT_INIT;
				elsif (env_count_reg /= 0) then
					env_cnext_val := (env_count_reg & "000000000") - ("000000000" & env_count_reg);
					env_count_reg <= env_cnext_val(14+9 downto 0+9);	-- vonext = ((vo<<9) - vo)>>9
				end if;
			end if;

		end if;
	end process;


	-- 波形振幅変調と出力 

	wave_pos_sig <= '0' & env_count_reg;
	wave_neg_sig <= 0 - wave_pos_sig;

	wave_out <= wave_pos_sig when is_true(sqwave_reg) else wave_neg_sig;


end RTL;


----------------------------------------------------------------------
--  Top module 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity melodychime is
	generic(
		CLOCK_FREQ_HZ	: integer := 50000000
	);
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		start		: in  std_logic;		-- play start(0→1 : start)

		timing_1ms	: out std_logic;
		tempo_led	: out std_logic;
		wave_out	: out std_logic_vector(15 downto 0);
		aud_out		: out std_logic			-- 1bit DSM
	);
end melodychime;

architecture RTL of melodychime is
	-- Misc function
	function is_true(S:std_logic) return boolean is begin return(S='1'); end;

	-- Constant declare
	constant VALUE_TEMPO_TC		: integer := 357;		-- テンポカウンタ(357ms/Tempo=84) 
	constant VALUE_ENVELOPE_TC	: integer := 28000;		-- エンベロープ時定数(一次遅れ系,t=0.5秒)
	constant CLOCKDIV_NUM		: integer := CLOCK_FREQ_HZ/100000;

	-- signal
	signal count10us		: integer range 0 to CLOCKDIV_NUM-1;
	signal count1ms			: integer range 0 to 99;
	signal timing_10us_reg	: std_logic;
	signal timing_1ms_reg	: std_logic;
	signal tempo_led_reg	: std_logic;
	signal start_in_reg		: std_logic_vector(1 downto 0);
	signal start_sig		: std_logic;

	signal tempo_sig		: std_logic;
	signal slot_div_sig		: std_logic_vector(7 downto 0);
	signal slot_note_sig	: std_logic;
	signal slot0_wrreq_sig	: std_logic;
	signal slot1_wrreq_sig	: std_logic;
	signal slot0_wav_sig	: std_logic_vector(15 downto 0);
	signal slot1_wav_sig	: std_logic_vector(15 downto 0);
	signal wav_add_sig		: std_logic_vector(16 downto 0);

	signal pcm_sig			: std_logic_vector(9 downto 0);
	signal add_sig			: std_logic_vector(pcm_sig'left+1 downto 0);
	signal dse_reg			: std_logic_vector(add_sig'left-1 downto 0);
	signal dacout_reg		: std_logic;

begin

	-- タイミングパルス生成 

	process (clk, reset) begin
		if is_true(reset) then
			count10us <= 0;
			count1ms  <= 0;
			timing_10us_reg <= '0';
			timing_1ms_reg  <= '0';
			tempo_led_reg   <= '0';

		elsif rising_edge(clk) then
			if (count10us = 0) then
				count10us <= CLOCKDIV_NUM-1;
				if (count1ms = 0) then
					count1ms <= 99;
				else 
					count1ms <= count1ms - 1;
				end if;
			else
				count10us <= count10us - 1;
			end if;

			if (count10us = 0) then
				timing_10us_reg <= '1';
			else 
				timing_10us_reg <= '0';
			end if;

			if (count10us = 0 and count1ms = 0) then
				timing_1ms_reg <= '1';
			else 
				timing_1ms_reg <= '0';
			end if;

			if is_true(tempo_sig) then
				tempo_led_reg <= not tempo_led_reg;
			end if;

		end if;
	end process;

	timing_1ms <= timing_1ms_reg;
	tempo_led <= tempo_led_reg;


	-- スタート信号入力 

	process (clk, reset) begin
		if is_true(reset) then
			start_in_reg <= "00";

		elsif rising_edge(clk) then
			start_in_reg <= start_in_reg(0) & start;

		end if;
	end process;

	start_sig <= '1' when(start_in_reg(1 downto 0) = "01") else '0';


	-- シーケンサインスタンス 

	u_seq : entity work.melodychime_seq
	generic map (
		TEMPO_TC		=> VALUE_TEMPO_TC
	)
	port map (
		reset			=> reset,
		clk				=> clk,
		timing_1ms		=> timing_1ms_reg,
		tempo_out		=> tempo_sig,
		start			=> start_sig,

		slot_div		=> slot_div_sig,
		slot_note		=> slot_note_sig,
		slot0_wrreq		=> slot0_wrreq_sig,
		slot1_wrreq		=> slot1_wrreq_sig
	);


	-- 音源スロットインスタンス 

	u_sg0 : entity work.melodychime_sg
	generic map (
		ENVELOPE_TC		=> VALUE_ENVELOPE_TC
	)
	port map (
		reset			=> reset,
		clk				=> clk,
		reg_div			=> slot_div_sig,
		reg_note		=> slot_note_sig,
		reg_write		=> slot0_wrreq_sig,

		timing_10us		=> timing_10us_reg,
		timing_1ms		=> timing_1ms_reg,

		wave_out		=> slot0_wav_sig
	);

	u_sg1 : entity work.melodychime_sg
	generic map (
		ENVELOPE_TC		=> VALUE_ENVELOPE_TC
	)
	port map (
		reset			=> reset,
		clk				=> clk,
		reg_div			=> slot_div_sig,
		reg_note		=> slot_note_sig,
		reg_write		=> slot1_wrreq_sig,

		timing_10us		=> timing_10us_reg,
		timing_1ms		=> timing_1ms_reg,

		wave_out		=> slot1_wav_sig
	);


	-- 波形加算と1bitDSM-DAC

	wav_add_sig <= (slot0_wav_sig(15) & slot0_wav_sig) + (slot1_wav_sig(15) & slot1_wav_sig);
	wave_out <= wav_add_sig(16 downto 1);

	pcm_sig(9) <= not wav_add_sig(16);
	pcm_sig(8 downto 0) <= wav_add_sig(15 downto 7);

	add_sig <= ('0' & pcm_sig) + ('0' & dse_reg);

	process (clk, reset) begin
		if is_true(reset) then
			dse_reg    <= (others=>'0');
			dacout_reg <= '0';

		elsif rising_edge(clk) then
			dse_reg    <= add_sig(add_sig'left-1 downto 0);
			dacout_reg <= add_sig(add_sig'left);

		end if;
	end process;

	aud_out <= dacout_reg;


end RTL;
