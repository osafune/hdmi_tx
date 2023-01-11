-- ===================================================================
-- TITLE : PERIDOT-NGS / SD card Interface & FileSystem
--
--     DESIGN : s.osafune@j7system.jp (J-7SYSTEM WORKS LIMITED)
--     DATE   : 2019/08/27 -> 2019/09/01
--
--     MODITY : 
-- ===================================================================

-- The MIT License (MIT)
-- Copyright (c) 2019 J-7SYSTEM WORKS LIMITED.
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


-- [USAGE]
--
-- reg00 control : bit15:irqena, bit14:sd_pwr, bit13:cd_alt(w0 clear), bit12:frc_zf, bit10:sd_cd,
--					bit9:start(w)/ready(r), bit8:sd_assert, bit7-0:txd(w)/rxd(r)
-- reg01 divref  : bit7-0:divref
-- reg02 frc     : bit26-0:frc
-- reg03 message : bit31-0


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity peridot_sdif is
	port(
	--==== Avalon-MM信号線 ===========================================
		csi_reset			: in  std_logic;
		csi_clk				: in  std_logic;

		avs_address			: in  std_logic_vector(1 downto 0);
		avs_read			: in  std_logic;
		avs_readdata		: out std_logic_vector(31 downto 0);
		avs_write			: in  std_logic;
		avs_writedata		: in  std_logic_vector(31 downto 0);

		ins_irq				: out std_logic;

	--==== SDカード信号線 ============================================
		coe_sd_clk			: out std_logic;
		coe_sd_cmd			: out std_logic;
		coe_sd_dat0			: in  std_logic;
		coe_sd_dat3			: out std_logic;
		coe_sd_cd_n			: in  std_logic := '0';	-- カード検出(カード挿入で'0')
		coe_sd_pwr			: out std_logic			-- pwr='1'でカード電源ON
	);
end peridot_sdif;

architecture RTL of peridot_sdif is
	type SPI_STATE is (IDLE,SDO,SDI,DONE);
	signal state : SPI_STATE;
	signal bitcount		: integer range 0 to 7;

	signal read_0_sig	: std_logic_vector(31 downto 0);
	signal read_1_sig	: std_logic_vector(31 downto 0);
	signal read_2_sig	: std_logic_vector(31 downto 0);
	signal read_3_sig	: std_logic_vector(31 downto 0);

	signal divref_reg	: std_logic_vector(7 downto 0);
	signal divcount_reg	: std_logic_vector(divref_reg'range);
	signal rxd_reg		: std_logic_vector(7 downto 0);
	signal txd_reg		: std_logic_vector(7 downto 0);
	signal irqena_reg	: std_logic;
	signal ready_reg	: std_logic;
	signal sd_cd_sig	: std_logic;
	signal sd_cd_in_reg	: std_logic_vector(2 downto 0);
	signal devena_reg	: std_logic;
	signal sck_reg		: std_logic;
	signal sdo_reg		: std_logic;
	signal sdi_sig		: std_logic;
	signal frc_reg		: std_logic_vector(26 downto 0);
	signal frczero_reg	: std_logic;
	signal cdalter_reg	: std_logic;
	signal pwrena_reg	: std_logic;
	signal message_reg	: std_logic_vector(31 downto 0);

begin

--==== Avalon-MM信号 =================================================

	ins_irq <= ready_reg when(irqena_reg = '1') else '0';

	with avs_address select avs_readdata <=
		read_3_sig when "11",
		read_2_sig when "10",
		read_1_sig when "01",
		read_0_sig when others;

	read_0_sig(31 downto 16) <= (others=>'0');
	read_0_sig(15) <= irqena_reg;
	read_0_sig(14) <= pwrena_reg;
	read_0_sig(13) <= cdalter_reg;
	read_0_sig(12) <= frczero_reg;
	read_0_sig(11) <= '0';
	read_0_sig(10) <= sd_cd_in_reg(2);
	read_0_sig(9) <= ready_reg;
	read_0_sig(8) <= devena_reg;
	read_0_sig(7 downto 0) <= rxd_reg;

	read_1_sig(31 downto divref_reg'left+1) <= (others=>'0');
	read_1_sig(divref_reg'left downto 0) <= divref_reg;

	read_2_sig(31 downto frc_reg'left+1) <= (others=>'0');
	read_2_sig(frc_reg'left downto 0) <= frc_reg;

	read_3_sig <= message_reg;

	coe_sd_clk <= sck_reg when(pwrena_reg = '1') else 'Z';
	coe_sd_cmd <= sdo_reg when(pwrena_reg = '1') else 'Z';
	sdi_sig <= coe_sd_dat0;
	coe_sd_dat3 <= not devena_reg when(pwrena_reg = '1') else 'Z';

	sd_cd_sig <= not coe_sd_cd_n;

	coe_sd_pwr <= pwrena_reg;


--==== メインステートマシン ==========================================

	process (csi_clk, csi_reset) begin
		if (csi_reset = '1') then
			state <= IDLE;
			divref_reg <= (others=>'1');
			irqena_reg <= '0';
			pwrena_reg <= '0';
			devena_reg <= '0';
			sck_reg <= '1';
			sdo_reg <= '1';
			ready_reg <= '1';
			frc_reg <= (others=>'0');
			frczero_reg <= '1';
			sd_cd_in_reg <= "000";
			cdalter_reg <= '0';
			message_reg <= (others=>'0');

		elsif rising_edge(csi_clk) then

		-- SPIの送受信 

			case state is
			when IDLE =>
				if (avs_write = '1') then
					case avs_address is
					when "00" =>
						if (avs_writedata(9) = '1') then	-- start
							state <= SDO;
							bitcount <= 0;
							divcount_reg <= divref_reg;
							ready_reg <= '0';
						end if;

						irqena_reg <= avs_writedata(15);
						pwrena_reg <= avs_writedata(14);
						devena_reg <= avs_writedata(8);
						txd_reg <= avs_writedata(7 downto 0);

					when "01" =>
						divref_reg <= avs_writedata(divref_reg'left downto 0);

					when others =>
					end case;
				end if;

			when SDO =>
				if (divcount_reg = 0) then
					state <= SDI;
					divcount_reg <= divref_reg;
					sck_reg <= not sck_reg;
					sdo_reg <= txd_reg(7);
					txd_reg <= txd_reg(6 downto 0) & '0';
				else
					divcount_reg <= divcount_reg - '1';
				end if;

			when SDI =>
				if (divcount_reg = 0) then
					if (bitcount = 7) then
						state <= DONE;
					else
						state <= SDO;
					end if;

					bitcount <= bitcount + 1;
					divcount_reg <= divref_reg;
					sck_reg <= not sck_reg;
					rxd_reg <= rxd_reg(6 downto 0) & sdi_sig;
				else
					divcount_reg <= divcount_reg - '1';
				end if;

			when DONE =>
				if (divcount_reg = 0) then
					state <= IDLE;
					sck_reg <= '1';
					sdo_reg <= '1';
					ready_reg <= '1';
				else
					divcount_reg <= divcount_reg - '1';
				end if;

			end case;


		-- フリーランカウンタの処理 

			if (avs_write = '1' and avs_address = "10") then
				frc_reg <= avs_writedata(frc_reg'left downto 0);
			elsif (frc_reg /= 0) then
				frc_reg <= frc_reg - '1';
			end if;

			if (frc_reg = 0) then
				frczero_reg <= '1';
			else
				frczero_reg <= '0';
			end if;


		-- メッセージレジスタの処理 

			if (avs_write = '1' and avs_address = "11") then
				message_reg <= avs_writedata;
			end if;


		-- カードスロット状態変化の検出 

			sd_cd_in_reg <= sd_cd_in_reg(1 downto 0) & sd_cd_sig;

			if (sd_cd_in_reg(1) /= sd_cd_in_reg(2)) then
				cdalter_reg <= '1';
			elsif (avs_write = '1' and avs_address = "00" and avs_writedata(13) = '0') then
				cdalter_reg <= '0';
			end if;

		end if;
	end process;


end RTL;
