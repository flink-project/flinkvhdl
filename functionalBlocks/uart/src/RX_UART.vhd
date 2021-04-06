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
--  Title             : RX_UART.vhd
--  Project           : FLINK
--  Description       : VHDL UART design
---------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------
--  History
--  12.10.2020 ARAL :	Initial version
--  06.04.2021 GRAU :   Sampling of bits must be earlier, shorten stop bit
---------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE RX_UART_pkg IS
	COMPONENT RX_UART IS
		PORT (
			isl_4x_uart_clk		: IN  STD_LOGIC;
			isl_reset			: IN  STD_LOGIC;
			isl_serial_data	    : IN  STD_LOGIC;
			osl_data_valid		: OUT STD_LOGIC;
			oslv8_data			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT RX_UART;
END PACKAGE RX_UART_pkg;

----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RX_UART IS
	PORT (
			isl_4x_uart_clk		: IN  STD_LOGIC;
			isl_reset			: IN  STD_LOGIC;
			isl_serial_data     : IN  STD_LOGIC;
			osl_data_valid		: OUT STD_LOGIC;
			oslv8_data			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY RX_UART;

----------------------------------------------------------------------

ARCHITECTURE rtl of RX_UART IS

	TYPE t_rx_fsm_state IS (IDLE, S0, S1, S2, S3,     D0_0, D0_1, D0_SH, D0_3, D1_0, D1_1, D1_SH, D1_3, 
									D2_0, D2_1, D2_SH, D2_3,  D3_0, D3_1, D3_SH, D3_3, D4_0, D4_1, D4_SH, D4_3, 
									D5_0, D5_1, D5_SH, D5_3,  D6_0, D6_1, D6_SH, D6_3, D7_0, D7_1, D7_SH, D7_3, 
									ST_0, ST_1, ST_2,  ST_3);
	
	TYPE t_registers IS RECORD
		fsm_state				: t_rx_fsm_state;
		sl_rx_data_d1			: STD_LOGIC;
		sl_rx_data_d2			: STD_LOGIC;
		sl_rx_data_d3           : STD_LOGIC;
		sl_rx_data_d4           : STD_LOGIC;
		slv8_data				: STD_LOGIC_VECTOR(7 DOWNTO 0);
		slv8_out_data			: STD_LOGIC_VECTOR(7 DOWNTO 0);
		sl_data_valid			: STD_LOGIC;
	END RECORD t_registers;
	
	SIGNAL r, r_next			: t_registers := (
										 fsm_state			=> IDLE,
										 sl_rx_data_d1		=> '1',
										 sl_rx_data_d2		=> '1',
										 sl_rx_data_d3      => '1',
										 sl_rx_data_d4      => '1',
										 slv8_data			=> (OTHERS => '0'),
										 slv8_out_data		=> (OTHERS => '0'),
										 sl_data_valid		=> '0'
									  );

BEGIN
	
	--                   ___     ___     ___     ___     ___     ___     ___     ___     ___     ___     ___     ___     ___ 
	--  4MHz clock:   __|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |
	--                ____                                 _______________________________ _______________________________
	--  1MHz Data In:     |_____ Start Bit _______________X___________ Data D0 ___________X___________ Data D1 ___________X
	--
	--  Actions:          ^ Trigger                                             ^ Sample Point                  ^ Sample Point
	--
	--  FSM States       IDLE   | S0    | S1    | S2    | S3    | D0_0  | D0_1  | D0_SH | D0_3  | D1_0  | D1_1  | D1_SH | D1_3 ... 
	
	

	--##	Combinatorial Priocess
	--##
	--##########################
	comb_proc : PROCESS (r, isl_reset, isl_serial_data)
	BEGIN

		r_next						<= r;					-- Keep signals stable
		r_next.sl_data_valid		<= '0';					-- Single-cycle signal default value
		
		r_next.sl_rx_data_d1		<= isl_serial_data;		-- Re-Sync double buffering
		r_next.sl_rx_data_d2		<= r.sl_rx_data_d1;
		r_next.sl_rx_data_d3		<= r.sl_rx_data_d2;
	
		CASE r.fsm_state IS
			WHEN IDLE	=> --	Wait for Start Bit
								IF (r.sl_rx_data_d2 = '0' AND r.sl_rx_data_d3 = '1') THEN
									r_next.fsm_state	<= S0;
								END IF;
								
			WHEN S0		=> r_next.fsm_state	<= S1;		    -- Start-Bit, 1st cycle
			WHEN S1		=> r_next.fsm_state	<= S2;		    -- Start-Bit, 2nd cycle
			WHEN S2		=> r_next.fsm_state	<= S3;		    -- Start-Bit, 3rd cycle
			WHEN S3		=> r_next.fsm_state	<= D0_0;		-- Start-Bit, 4th cycle
			
			WHEN D0_0	=> r_next.fsm_state	<= D0_1;		-- Data 0, 1st cycle
			WHEN D0_1	=> r_next.fsm_state	<= D0_SH;	    -- Data 0, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D0_SH	=> r_next.fsm_state	<= D0_3;		-- Data 0, 3rd cycle = sample cycle
			WHEN D0_3	=> r_next.fsm_state	<= D1_0;		-- Data 0, 4th cycle
			
			WHEN D1_0	=> r_next.fsm_state	<= D1_1;		-- Data 1, 1st cycle
			WHEN D1_1	=> r_next.fsm_state	<= D1_SH;	    -- Data 1, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D1_SH	=> r_next.fsm_state	<= D1_3;		-- Data 1, 3rd cycle = sample cycle
			WHEN D1_3	=> r_next.fsm_state	<= D2_0;		-- Data 1, 4th cycle
			
			WHEN D2_0	=> r_next.fsm_state	<= D2_1;		-- Data 2, 1st cycle
			WHEN D2_1	=> r_next.fsm_state	<= D2_SH;	    -- Data 2, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D2_SH	=> r_next.fsm_state	<= D2_3;		-- Data 2, 3rd cycle = sample cycle
			WHEN D2_3	=> r_next.fsm_state	<= D3_0;		-- Data 2, 4th cycle
			
			WHEN D3_0	=> r_next.fsm_state	<= D3_1;		-- Data 3, 1st cycle
			WHEN D3_1	=> r_next.fsm_state	<= D3_SH;	    -- Data 3, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D3_SH	=> r_next.fsm_state	<= D3_3;		-- Data 3, 3rd cycle = sample cycle
			WHEN D3_3	=> r_next.fsm_state	<= D4_0;		-- Data 3, 4th cycle
			
			WHEN D4_0	=> r_next.fsm_state	<= D4_1;		-- Data 4, 1st cycle
			WHEN D4_1	=> r_next.fsm_state	<= D4_SH;	    -- Data 4, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D4_SH	=> r_next.fsm_state	<= D4_3;		-- Data 4, 3rd cycle = sample cycle
			WHEN D4_3	=> r_next.fsm_state	<= D5_0;		-- Data 4, 4th cycle
			
			WHEN D5_0	=> r_next.fsm_state	<= D5_1;		-- Data 5, 1st cycle
			WHEN D5_1	=> r_next.fsm_state	<= D5_SH;	    -- Data 5, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D5_SH	=> r_next.fsm_state	<= D5_3;		-- Data 5, 3rd cycle = sample cycle
			WHEN D5_3	=> r_next.fsm_state	<= D6_0;		-- Data 5, 4th cycle
			
			WHEN D6_0	=> r_next.fsm_state	<= D6_1;		-- Data 6, 1st cycle
			WHEN D6_1	=> r_next.fsm_state	<= D6_SH;	    -- Data 6, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D6_SH	=> r_next.fsm_state	<= D6_3;		-- Data 6, 3rd cycle = sample cycle
			WHEN D6_3	=> r_next.fsm_state	<= D7_0;		-- Data 6, 4th cycle
			
			WHEN D7_0	=> r_next.fsm_state	<= D7_1;		-- Data 7, 1st cycle
			WHEN D7_1	=> r_next.fsm_state	<= D7_SH;	    -- Data 7, 2nd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D7_SH	=> r_next.fsm_state	<= D7_3;		-- Data 7, 3rd cycle = sample cycle
								r_next.slv8_out_data		<= r.slv8_data;
			WHEN D7_3	=> r_next.fsm_state	<= ST_0;		-- Data 7, 4th cycle
								r_next.sl_data_valid		<= '1';
			WHEN ST_0	=> r_next.fsm_state	<= ST_1;		--	Stop Bit, 1st cycle
			WHEN ST_1	=> r_next.fsm_state	<= IDLE;		--	Stop Bit, 1st cycle
--			WHEN ST_2	=> r_next.fsm_state	<= ST_3;		--	Stop Bit, 1st cycle
--								r_next.slv8_out_data		<= r.slv8_data;
--								r_next.slv8_out_data		<= x"5a";

--			WHEN ST_3	=> r_next.fsm_state	<= IDLE;		--	Stop Bit, 1st cycle
								--r_next.sl_data_valid		<= '1';
								--	If there is more than one Stop Bit, it will be handled by the IDLE state
			
			WHEN OTHERS	=>	r_next.fsm_state	<= IDLE;
		END CASE;
		
		--##	Reset Logic
		IF isl_reset = '1' THEN
			r_next.fsm_state			<= IDLE;
			r_next.sl_rx_data_d1		<= '1';
			r_next.sl_rx_data_d2		<= '1';
			r_next.sl_rx_data_d3		<= '1';
			r_next.slv8_data			<= (OTHERS => '0');
			r_next.slv8_out_data		<= (OTHERS => '0');
			r_next.sl_data_valid		<= '0';
		END IF;
		
	END PROCESS comb_proc;
	
	
	
	--##	Registered Priocess
	--##
	--#######################
	reg_proc : PROCESS (isl_4x_uart_clk)
	BEGIN
		IF rising_edge(isl_4x_uart_clk) THEN r <= r_next; END IF;
	END PROCESS reg_proc;


	--##	Output Assignments
	--##
	--######################
	osl_data_valid	<= r.sl_data_valid;
	oslv8_data		<= r.slv8_out_data;

END ARCHITECTURE rtl;