---------------------------------------------------------------------
--    ____   _____ _______ 
--   / __ \ / ____|__   __|
--  | |  | | (___    | |   
--  | |  | |\___ \   | |   
--  | |__| |____) |  | |   
--   \____/|_____/   |_|                       
--
--  O S T S C H W E I Z E R   F A C H H O C H S C H U L E
--  Campus Buchs - Werdenbergstrasse 4 - CH-9471 Buchs
--  Tel. +41 (0)81 755 33 11   Fax +41 (0)81 756 54 34
---------------------------------------------------------------------
--  Title             : UART.vhd
--  Project           : FLINK
--  Description       : VHDL UART design
---------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------
--  History
--  12.10.2020 ARAL :	Initial version
--  06.04.2021 GRAU :   FIFO is common clock
---------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE UART_pkg IS
    COMPONENT UART IS
		PORT (
		    --  System Signals
			isl_clk_100mhz       : IN  STD_LOGIC;
			isl_reset            : IN  STD_LOGIC;
            --  Serial Signals
            osl_txd              : OUT STD_LOGIC;
            isl_rxd              : IN  STD_LOGIC;
			--  Data Signals
            isl_write_tx_data    : IN  STD_LOGIC;
			islv8_tx_data        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            isl_read_rx_data     : IN  STD_LOGIC;
            oslv8_rx_data        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            oslv10_rx_count      : OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
            islv32_div_data      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            --  FIFO Signals
            osl_tx_fifo_full     : OUT STD_LOGIC;
            osl_tx_fifo_half     : OUT STD_LOGIC;
            osl_tx_fifo_empty    : OUT STD_LOGIC;
            osl_rx_fifo_full     : OUT STD_LOGIC;
            osl_rx_fifo_half     : OUT STD_LOGIC;
            osl_rx_fifo_empty    : OUT STD_LOGIC;
            --  Interrupt Signals
            isl_irq_enable       : IN  STD_LOGIC;
            osl_rx_irq           : OUT STD_LOGIC
		);
	END COMPONENT UART;
END PACKAGE UART_pkg;

----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.TX_UART_pkg.ALL;
USE work.RX_UART_pkg.ALL;

ENTITY UART IS
	PORT (
		    --  System Signals
            isl_clk_100mhz       : IN  STD_LOGIC;
            isl_reset            : IN  STD_LOGIC;
            --  Serial Signals
            osl_txd              : OUT STD_LOGIC;
            isl_rxd              : IN  STD_LOGIC;
            --  Data Signals
            isl_write_tx_data    : IN  STD_LOGIC;
            islv8_tx_data        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            isl_read_rx_data     : IN  STD_LOGIC;
            oslv8_rx_data        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            oslv10_rx_count      : OUT  STD_LOGIC_VECTOR(9 DOWNTO 0);
            islv32_div_data      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            --  FIFO Signals
            osl_tx_fifo_full     : OUT STD_LOGIC;
            osl_tx_fifo_half     : OUT STD_LOGIC;
            osl_tx_fifo_empty    : OUT STD_LOGIC;
            osl_rx_fifo_full     : OUT STD_LOGIC;
            osl_rx_fifo_half     : OUT STD_LOGIC;
            osl_rx_fifo_empty    : OUT STD_LOGIC;
            --  Interrupt Signals
            isl_irq_enable       : IN  STD_LOGIC;
            osl_rx_irq           : OUT STD_LOGIC
	);
END ENTITY UART;

----------------------------------------------------------------------

ARCHITECTURE rtl of UART IS

    SIGNAL sl_4x_uart_clk       : STD_LOGIC                     := '0';
    
    SIGNAL slv8_tx_fifo_out     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sl_tx_fifo_empty     : STD_LOGIC;
    SIGNAL slv10_tx_fifo_count  : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sl_tx_busy           : STD_LOGIC;
    
    SIGNAL sl_rx_uart_valid     : STD_LOGIC;
    SIGNAL slv8_rx_data         : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sl_rx_fifo_empty     : STD_LOGIC;
    SIGNAL slv10_rx_fifo_count  : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');

    TYPE t_registers IS RECORD
        sl_read_tx_fifo         : STD_LOGIC;
        sl_tx_write_uart        : STD_LOGIC;
        sl_tx_busy              : STD_LOGIC;
        sl_rx_uart_valid_d1     : STD_LOGIC;
        sl_write_rx_fifo        : STD_LOGIC;
        sl_rx_fifo_empty_d1     : STD_LOGIC;
        sl_rx_irq               : STD_LOGIC;
    END RECORD t_registers;

    SIGNAL r, r_next            : t_registers;

    SIGNAL usig14_div_count     : UNSIGNED(13 DOWNTO 0)     := (OTHERS => '0');

    COMPONENT fifo_1k_x_8_dual_port IS
        PORT (
            clk           : IN STD_LOGIC;
            rst           : IN STD_LOGIC;
            din           : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en         : IN STD_LOGIC;
            rd_en         : IN STD_LOGIC;
            dout          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full          : OUT STD_LOGIC;
            empty         : OUT STD_LOGIC;
            data_count    : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
			wr_rst_busy   : OUT STD_LOGIC;
            rd_rst_busy   : OUT STD_LOGIC
        );
    END COMPONENT fifo_1k_x_8_dual_port;

BEGIN

    --##    Combinatorial Process
    --##
    --###########################
    comb_proc : PROCESS (r, isl_reset, 
                         slv8_tx_fifo_out, slv10_tx_fifo_count, sl_tx_fifo_empty, sl_tx_busy,
                         sl_rx_uart_valid, slv10_rx_fifo_count, sl_rx_fifo_empty, isl_irq_enable)
    VARIABLE v          : t_registers;
    BEGIN
        v                       := r;                 --  Keep signals stable
        v.sl_read_tx_fifo       := '0';               --  Single-cycle signal
        v.sl_write_rx_fifo      := '0';               --  Single-cycle signal
        v.sl_tx_busy            := sl_tx_busy;        --  Edge Detect
        v.sl_rx_uart_valid_d1   := sl_rx_uart_valid;  -- Edge Detect
        
        --  Generate Tx half-full flags out of data-counters
        IF UNSIGNED(slv10_tx_fifo_count) > 512 THEN osl_tx_fifo_half    <= '1';
        ELSE                                        osl_tx_fifo_half    <= '0'; END IF;
 
        --  Generate Rx half-full flags out of data-counters
        IF UNSIGNED(slv10_rx_fifo_count) > 512 THEN osl_rx_fifo_half    <= '1';
        ELSE                                        osl_rx_fifo_half    <= '0'; END IF;
       
        --   Write data from TX Fifo to Tx UART
        IF sl_tx_fifo_empty = '0'                           --  only if data is available, and 
        AND sl_tx_busy = '0'                                --  only if the Tx Fifo is not busy, and
        AND r.sl_tx_write_uart = '0' THEN                   --  only if there is not already a transfer ongoing
            v.sl_tx_write_uart          := '1';
        END IF;
        
        --  Clear tx_write_uart signal once the UART has started to process the data
        IF sl_tx_busy = '1' AND r.sl_tx_busy = '0' THEN
            v.sl_tx_write_uart          := '0';
            v.sl_read_tx_fifo           := '1';             --  Advance TX Fifo, now that TX UART has sampled the data
        END IF;
       
        --  Generate single-cycle Fifo write on the rising edge of RX UART data valid
        IF sl_rx_uart_valid = '1' AND r.sl_rx_uart_valid_d1 = '0' THEN
            v.sl_write_rx_fifo    := '1';
        END IF;
        
        --  RX Interrupt handler:
        --  - Raise interrupt, when RX Fifo goes from Emtpy to Not-Empty
        --  - Clear interrupt, when RX Fifo is read
        IF  sl_rx_fifo_empty = '0' AND r.sl_rx_fifo_empty_d1 = '1' 
        AND isl_irq_enable = '1' THEN
            v.sl_rx_irq         := '1';
        END IF;
        
        IF isl_read_rx_data = '1' THEN
            v.sl_rx_irq         := '0';
        END IF;
       
       
        --##    Reset Logic
        IF isl_reset = '1' THEN
            v.sl_rx_irq             := '0';
            v.sl_tx_write_uart      := '0';
            v.sl_tx_busy            := '0';
            v.sl_rx_uart_valid_d1   := '0';
            v.sl_write_rx_fifo      := '0';
            v.sl_rx_fifo_empty_d1   := '0';
            v.sl_rx_irq             := '0';
        END IF;
       
        r_next          <= v;       --  Export variable as signal
    END PROCESS comb_proc;
    
    
    --##    Registered Process
    --##
    --########################
    reg_proc : PROCESS (isl_clk_100mhz)
    BEGIN
        IF RISING_EDGE(isl_clk_100mhz) THEN r <= r_next; END IF;
    END PROCESS reg_proc;


    --##    Generate 4x UART Clock
    --##
    --############################
    clock_div_proc : PROCESS (isl_clk_100mhz)
    BEGIN
        IF rising_edge(isl_clk_100mhz) THEN
            usig14_div_count        <= usig14_div_count + 1;
            IF usig14_div_count >= to_integer(unsigned(islv32_div_data))/8 THEN
                usig14_div_count    <= (OTHERS => '0');
                sl_4x_uart_clk      <= NOT sl_4x_uart_clk;
            END IF;
        END IF;
    END PROCESS clock_div_proc;




    --##    TX FIFO
    --##
    --#############
    u_tx_fifo : fifo_1k_x_8_dual_port PORT MAP (
        clk              => isl_clk_100mhz,
		rst              => isl_reset,
        din              => islv8_tx_data,
        wr_en            => isl_write_tx_data,
        rd_en            => r.sl_read_tx_fifo,
        dout             => slv8_tx_fifo_out,
        full             => osl_tx_fifo_full,
        empty            => sl_tx_fifo_empty,
		data_count       => slv10_tx_fifo_count,
		wr_rst_busy      => open,
		rd_rst_busy      => open
    );


    --##    TX UART
    --##
    --#############
    u_tx_uart : TX_UART PORT MAP (
        isl_4x_uart_clk     => sl_4x_uart_clk,
        isl_reset           => isl_reset,
        isl_data_valid      => r.sl_tx_write_uart,
        islv8_data          => slv8_tx_fifo_out,
        osl_serial_data     => osl_txd,
        osl_busy            => sl_tx_busy
    );


    --##    RX UART
    --##
    --#############
    u_rx_uart : RX_UART PORT MAP (
        isl_4x_uart_clk     => sl_4x_uart_clk,
        isl_reset           => isl_reset,
        isl_serial_data     => isl_rxd,
        osl_data_valid      => sl_rx_uart_valid,
        oslv8_data          => slv8_rx_data
    );
    

    --##    RX FIFO
    --##
    --#############
    u_rx_fifo : fifo_1k_x_8_dual_port PORT MAP (
        clk              => isl_clk_100mhz,
		rst              => isl_reset,
        din              => slv8_rx_data,
        wr_en            => r.sl_write_rx_fifo,
        rd_en            => isl_read_rx_data,
        dout             => oslv8_rx_data,
        full             => osl_rx_fifo_full,
        empty            => sl_rx_fifo_empty,
		data_count       => slv10_rx_fifo_count,
		wr_rst_busy      => open,
		rd_rst_busy      => open
    );


    --##    Output Assignments
    --##
    --########################
    osl_tx_fifo_empty   <= sl_tx_fifo_empty;
    osl_rx_fifo_empty   <= sl_rx_fifo_empty;
    osl_rx_irq          <= r.sl_rx_irq;
	oslv10_rx_count     <= slv10_rx_fifo_count(9 DOWNTO 0);

END ARCHITECTURE rtl;