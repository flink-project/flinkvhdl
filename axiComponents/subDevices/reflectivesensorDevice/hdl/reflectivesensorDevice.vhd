---------------------------------------------------------------------------------------------
--    ____   _____ _______            _________  _____     _____  ____  _____  ___  ____   
--   / __ \ / ____|__   __|          |_   ___  ||_   _|   |_   _||_   \|_   _||_  ||_  _|  
--  | |  | | (___    | |    _______    | |_  \_|  | |       | |    |   \ | |    | |_/ /   
--  | |  | |\___ \   | |   |_______|   |  _|      | |   _   | |    | |\ \| |    |  __'.   
--  | |__| |____) |  | |              _| |_      _| |__/ | _| |_  _| |_\   |_  _| |  \ \_ 
--   \____/|_____/   |_|             |_____|    |________||_____||_____|\____||____||____|
--
--  O S T S C H W E I Z E R   F A C H H O C H S C H U L E
--  Campus Buchs - Werdenbergstrasse 4 - CH-9471 Buchs
--  Tel. +41 (0)81 755 33 11   Fax +41 (0)81 756 54 34
---------------------------------------------------------------------------------------------
--  Title             : reflectivesensorDevice.vhd
--  Project           : FLINK
--  Description       : Device Interface between Axi Module and IP description (.xci)
---------------------------------------------------------------------------------------------
--  Copyright(C) 2023 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  05.10.2023 GOOP :    Initial version
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reflectivesensor_v1_0 is
    generic (
        -- Users to add parameters here
        unique_id           : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        nof_decoder_signals : INTEGER := 4; -- number of lines to decoder
        frequency_divider   : INTEGER := 200000; -- target 500Hz by a base frequency of 100MHz
        ratio               : INTEGER := 8000; -- target 12.5KHz(80us) by a base frequenzy of 100MHz
        adc_trigger         : INTEGER := 7990; -- just a few clocks less than ratio
        sclk_frequency      : INTEGER := 8000000; -- max 20Mhz
        base_clk            : INTEGER := 33000000; 
        -- User parameters ends
        -- Do not modify the parameters beyond this line


        -- Parameters of Axi Slave Bus Interface S00_AXI
        C_S00_AXI_ID_WIDTH   : integer    := 1;
        C_S00_AXI_DATA_WIDTH : integer    := 32;
        C_S00_AXI_ADDR_WIDTH : integer    := 12
    );
    port (
        -- Users to add ports here
        oslv_decoder_lines    : OUT STD_LOGIC_VECTOR(nof_decoder_signals -1 DOWNTO 0);
        osl_puls              : OUT STD_LOGIC;
        osl_adc_sclk          : OUT  STD_LOGIC;    -- ADC clock
        osl_adc_csn           : OUT  STD_LOGIC;    -- ADC chip select not
        isl_adc_sdata         : IN   STD_LOGIC;    -- ADC serial data
        osl_interrupt_rising  : OUT STD_LOGIC_VECTOR((2**nof_decoder_signals)-1 DOWNTO 0);
        osl_interrupt_falling : OUT STD_LOGIC_VECTOR((2**nof_decoder_signals)-1 DOWNTO 0);
        -- User ports ends
        -- Do not modify the ports beyond this line


        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk    : in std_logic;
        s00_axi_aresetn    : in std_logic;
        s00_axi_awid    : in std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
        s00_axi_awaddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_awlen    : in std_logic_vector(7 downto 0);
        s00_axi_awsize    : in std_logic_vector(2 downto 0);
        s00_axi_awburst    : in std_logic_vector(1 downto 0);
        s00_axi_awvalid    : in std_logic;
        s00_axi_awready    : out std_logic;
        s00_axi_wdata    : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_wstrb    : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
        s00_axi_wlast    : in std_logic;
        s00_axi_wvalid    : in std_logic;
        s00_axi_wready    : out std_logic;
        s00_axi_bid    : out std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
        s00_axi_bresp    : out std_logic_vector(1 downto 0);
        s00_axi_bvalid    : out std_logic;
        s00_axi_bready    : in std_logic;
        s00_axi_arid    : in std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
        s00_axi_araddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_arlen    : in std_logic_vector(7 downto 0);
        s00_axi_arsize    : in std_logic_vector(2 downto 0);
        s00_axi_arburst    : in std_logic_vector(1 downto 0);
        s00_axi_arvalid    : in std_logic;
        s00_axi_arready    : out std_logic;
        s00_axi_rid    : out std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
        s00_axi_rdata    : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_rresp    : out std_logic_vector(1 downto 0);
        s00_axi_rlast    : out std_logic;
        s00_axi_rvalid    : out std_logic;
        s00_axi_rready    : in std_logic
    );
end reflectivesensor_v1_0;

architecture arch_imp of reflectivesensor_v1_0 is

    -- component declaration
    component reflectivesensorDevice_v1_0_S00_AXI is
        generic (
        unique_id             : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        nof_decoder_signals    : INTEGER := 4;
        frequency_divider    : INTEGER := 200000;
        ratio                : INTEGER := 8000;
        adc_trigger            : INTEGER := 7990;
        sclk_frequency        : INTEGER := 8000000;
        base_clk            : INTEGER := 33000000;
        C_S_AXI_ID_WIDTH    : integer    := 1;
        C_S_AXI_DATA_WIDTH    : integer    := 32;
        C_S_AXI_ADDR_WIDTH    : integer    := 12
        );
        port (
        oslv_decoder_lines    : OUT STD_LOGIC_VECTOR(nof_decoder_signals -1 DOWNTO 0);
        osl_puls              : OUT STD_LOGIC;
        osl_adc_sclk          : OUT  STD_LOGIC;
        osl_adc_csn           : OUT  STD_LOGIC;
        isl_adc_sdata         : IN   STD_LOGIC;
        osl_interrupt_rising  : OUT STD_LOGIC_VECTOR((2**nof_decoder_signals)-1 DOWNTO 0);
        osl_interrupt_falling : OUT STD_LOGIC_VECTOR((2**nof_decoder_signals)-1 DOWNTO 0);
        S_AXI_ACLK    : in std_logic;
        S_AXI_ARESETN    : in std_logic;
        S_AXI_AWID    : in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        S_AXI_AWADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWLEN    : in std_logic_vector(7 downto 0);
        S_AXI_AWSIZE    : in std_logic_vector(2 downto 0);
        S_AXI_AWBURST    : in std_logic_vector(1 downto 0);
        S_AXI_AWVALID    : in std_logic;
        S_AXI_AWREADY    : out std_logic;
        S_AXI_WDATA    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WLAST    : in std_logic;
        S_AXI_WVALID    : in std_logic;
        S_AXI_WREADY    : out std_logic;
        S_AXI_BID    : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        S_AXI_BRESP    : out std_logic_vector(1 downto 0);
        S_AXI_BVALID    : out std_logic;
        S_AXI_BREADY    : in std_logic;
        S_AXI_ARID    : in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        S_AXI_ARADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARLEN    : in std_logic_vector(7 downto 0);
        S_AXI_ARSIZE    : in std_logic_vector(2 downto 0);
        S_AXI_ARBURST    : in std_logic_vector(1 downto 0);
        S_AXI_ARVALID    : in std_logic;
        S_AXI_ARREADY    : out std_logic;
        S_AXI_RID    : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP    : out std_logic_vector(1 downto 0);
        S_AXI_RLAST    : out std_logic;
        S_AXI_RVALID    : out std_logic;
        S_AXI_RREADY    : in std_logic
        );
    end component reflectivesensorDevice_v1_0_S00_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
reflectivesensorDevice_v1_0_S00_AXI_inst : reflectivesensorDevice_v1_0_S00_AXI
    generic map (
        unique_id             => unique_id,
        nof_decoder_signals    => nof_decoder_signals,
        frequency_divider    => frequency_divider,
        ratio                => ratio,
        adc_trigger            => adc_trigger,
        sclk_frequency        => sclk_frequency,
        base_clk            => base_clk,
        C_S_AXI_ID_WIDTH    => C_S00_AXI_ID_WIDTH,
        C_S_AXI_DATA_WIDTH    => C_S00_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH    => C_S00_AXI_ADDR_WIDTH
    )
    port map (
        oslv_decoder_lines    => oslv_decoder_lines,
        osl_puls            => osl_puls,
        osl_adc_sclk        => osl_adc_sclk,
        osl_adc_csn            => osl_adc_csn,
        isl_adc_sdata        => isl_adc_sdata,
        osl_interrupt_rising  => osl_interrupt_rising,
        osl_interrupt_falling => osl_interrupt_falling,
        S_AXI_ACLK    => s00_axi_aclk,
        S_AXI_ARESETN    => s00_axi_aresetn,
        S_AXI_AWID    => s00_axi_awid,
        S_AXI_AWADDR    => s00_axi_awaddr,
        S_AXI_AWLEN    => s00_axi_awlen,
        S_AXI_AWSIZE    => s00_axi_awsize,
        S_AXI_AWBURST    => s00_axi_awburst,
        S_AXI_AWVALID    => s00_axi_awvalid,
        S_AXI_AWREADY    => s00_axi_awready,
        S_AXI_WDATA    => s00_axi_wdata,
        S_AXI_WSTRB    => s00_axi_wstrb,
        S_AXI_WLAST    => s00_axi_wlast,
        S_AXI_WVALID    => s00_axi_wvalid,
        S_AXI_WREADY    => s00_axi_wready,
        S_AXI_BID    => s00_axi_bid,
        S_AXI_BRESP    => s00_axi_bresp,
        S_AXI_BVALID    => s00_axi_bvalid,
        S_AXI_BREADY    => s00_axi_bready,
        S_AXI_ARID    => s00_axi_arid,
        S_AXI_ARADDR    => s00_axi_araddr,
        S_AXI_ARLEN    => s00_axi_arlen,
        S_AXI_ARSIZE    => s00_axi_arsize,
        S_AXI_ARBURST    => s00_axi_arburst,
        S_AXI_ARVALID    => s00_axi_arvalid,
        S_AXI_ARREADY    => s00_axi_arready,
        S_AXI_RID    => s00_axi_rid,
        S_AXI_RDATA    => s00_axi_rdata,
        S_AXI_RRESP    => s00_axi_rresp,
        S_AXI_RLAST    => s00_axi_rlast,
        S_AXI_RVALID    => s00_axi_rvalid,
        S_AXI_RREADY    => s00_axi_rready
    );

    -- Add user logic here

    -- User logic ends

end arch_imp;
