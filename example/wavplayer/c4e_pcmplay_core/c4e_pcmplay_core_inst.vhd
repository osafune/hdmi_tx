	component c4e_pcmplay_core is
		port (
			clk_100m_clk  : in    std_logic                     := 'X';             -- clk
			clk_25m_clk   : in    std_logic                     := 'X';             -- clk
			gpio_export   : inout std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			pcm_clk_128fs : in    std_logic                     := 'X';             -- clk_128fs
			pcm_fs        : out   std_logic;                                        -- fs
			pcm_ldata     : out   std_logic_vector(15 downto 0);                    -- ldata
			pcm_rdata     : out   std_logic_vector(15 downto 0);                    -- rdata
			pcm_mute      : out   std_logic;                                        -- mute
			reset_reset_n : in    std_logic                     := 'X';             -- reset_n
			sd_clk        : out   std_logic;                                        -- clk
			sd_cmd        : out   std_logic;                                        -- cmd
			sd_dat0       : in    std_logic                     := 'X';             -- dat0
			sd_dat3       : out   std_logic;                                        -- dat3
			sd_cd_n       : in    std_logic                     := 'X';             -- cd_n
			sd_pwr        : out   std_logic;                                        -- pwr
			sdr_addr      : out   std_logic_vector(12 downto 0);                    -- addr
			sdr_ba        : out   std_logic_vector(1 downto 0);                     -- ba
			sdr_cas_n     : out   std_logic;                                        -- cas_n
			sdr_cke       : out   std_logic;                                        -- cke
			sdr_cs_n      : out   std_logic;                                        -- cs_n
			sdr_dq        : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdr_dqm       : out   std_logic_vector(1 downto 0);                     -- dqm
			sdr_ras_n     : out   std_logic;                                        -- ras_n
			sdr_we_n      : out   std_logic;                                        -- we_n
			uart_rxd      : in    std_logic                     := 'X';             -- rxd
			uart_txd      : out   std_logic;                                        -- txd
			vga_videoclk  : in    std_logic                     := 'X';             -- videoclk
			vga_active    : out   std_logic;                                        -- active
			vga_rout      : out   std_logic_vector(7 downto 0);                     -- rout
			vga_gout      : out   std_logic_vector(7 downto 0);                     -- gout
			vga_bout      : out   std_logic_vector(7 downto 0);                     -- bout
			vga_hsync_n   : out   std_logic;                                        -- hsync_n
			vga_vsync_n   : out   std_logic;                                        -- vsync_n
			vga_csync_n   : out   std_logic;                                        -- csync_n
			bar_export    : out   std_logic_vector(11 downto 0)                     -- export
		);
	end component c4e_pcmplay_core;

	u0 : component c4e_pcmplay_core
		port map (
			clk_100m_clk  => CONNECTED_TO_clk_100m_clk,  -- clk_100m.clk
			clk_25m_clk   => CONNECTED_TO_clk_25m_clk,   --  clk_25m.clk
			gpio_export   => CONNECTED_TO_gpio_export,   --     gpio.export
			pcm_clk_128fs => CONNECTED_TO_pcm_clk_128fs, --      pcm.clk_128fs
			pcm_fs        => CONNECTED_TO_pcm_fs,        --         .fs
			pcm_ldata     => CONNECTED_TO_pcm_ldata,     --         .ldata
			pcm_rdata     => CONNECTED_TO_pcm_rdata,     --         .rdata
			pcm_mute      => CONNECTED_TO_pcm_mute,      --         .mute
			reset_reset_n => CONNECTED_TO_reset_reset_n, --    reset.reset_n
			sd_clk        => CONNECTED_TO_sd_clk,        --       sd.clk
			sd_cmd        => CONNECTED_TO_sd_cmd,        --         .cmd
			sd_dat0       => CONNECTED_TO_sd_dat0,       --         .dat0
			sd_dat3       => CONNECTED_TO_sd_dat3,       --         .dat3
			sd_cd_n       => CONNECTED_TO_sd_cd_n,       --         .cd_n
			sd_pwr        => CONNECTED_TO_sd_pwr,        --         .pwr
			sdr_addr      => CONNECTED_TO_sdr_addr,      --      sdr.addr
			sdr_ba        => CONNECTED_TO_sdr_ba,        --         .ba
			sdr_cas_n     => CONNECTED_TO_sdr_cas_n,     --         .cas_n
			sdr_cke       => CONNECTED_TO_sdr_cke,       --         .cke
			sdr_cs_n      => CONNECTED_TO_sdr_cs_n,      --         .cs_n
			sdr_dq        => CONNECTED_TO_sdr_dq,        --         .dq
			sdr_dqm       => CONNECTED_TO_sdr_dqm,       --         .dqm
			sdr_ras_n     => CONNECTED_TO_sdr_ras_n,     --         .ras_n
			sdr_we_n      => CONNECTED_TO_sdr_we_n,      --         .we_n
			uart_rxd      => CONNECTED_TO_uart_rxd,      --     uart.rxd
			uart_txd      => CONNECTED_TO_uart_txd,      --         .txd
			vga_videoclk  => CONNECTED_TO_vga_videoclk,  --      vga.videoclk
			vga_active    => CONNECTED_TO_vga_active,    --         .active
			vga_rout      => CONNECTED_TO_vga_rout,      --         .rout
			vga_gout      => CONNECTED_TO_vga_gout,      --         .gout
			vga_bout      => CONNECTED_TO_vga_bout,      --         .bout
			vga_hsync_n   => CONNECTED_TO_vga_hsync_n,   --         .hsync_n
			vga_vsync_n   => CONNECTED_TO_vga_vsync_n,   --         .vsync_n
			vga_csync_n   => CONNECTED_TO_vga_csync_n,   --         .csync_n
			bar_export    => CONNECTED_TO_bar_export     --      bar.export
		);

