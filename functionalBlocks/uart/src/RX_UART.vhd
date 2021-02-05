-------------------------------------------------------------------------------
--
--    O S T S C H W E I Z E R   F A C H H O C H S C H U L E
--
--    Campus Buchs - Werdenbergstrasse 4 - CH-9471 Buchs
--
--    Tel. +41 (0)81 755 33 11   Fax +41 (0)81 756 54 34
--
-------------------------------------------------------------------------------
----  Project : 	UART
----  Unit    : 	RX UART
----  Author  : 	Laszlo Arato
----  Created :     October 2020
-------------------------------------------------------------------------------
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--    
--        http://www.apache.org/licenses/LICENSE-2.0
--    
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.
-------------------------------------------------------------------------------
--  History
--  12.10.2020 ARAL :	Initial version
--  04.01.2021 ARAL :	Changed reset state of sl_rx_data_d1 and 
--                      sl_rx_data_d1 from '0' to '1' (Idle)
--  20.01.2021 ARAL :   Cleaned-up state names 
--  22.01.2021 ARAL :   Changed Start-Bit detection from level to edge
-------------------------------------------------------------------------------

---------------------------------------------------------------------
--   __  __ _       _    _____ _                   _   _           _     
--  |  \/  (_)     (_)  / ____(_)                 | | | |         | |    
--  | \  / |_ _ __  _  | (___  _  __ _ _ __   __ _| | | |     __ _| |__  
--  | |\/| | | '_ \| |  \___ \| |/ _` | '_ \ / _` | | | |    / _` | '_ \ 
--  | |  | | | | | | |  ____) | | (_| | | | | (_| | | | |___| (_| | |_) |
--  |_|  |_|_|_| |_|_| |_____/|_|\__, |_| |_|\__,_|_| |______\__,_|_.__/ 
--                                __/ |                                  
--                               |___/                                   
--
--  O S T S C H W E I Z E R   F A C H H O C H S C H U L E
--  Campus Buchs - Werdenbergstrasse 4 - CH-9471 Buchs
--  Tel. +41 (0)81 755 33 11   Fax +41 (0)81 756 54 34
---------------------------------------------------------------------
--  Title             : RX_UART.vhd
--  Project           : ELIO
--  Description       : VHDL UART design
---------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------
--  History
--  12.10.2020 ARAL :	Initial version
--	 04.01.2021 ARAL :	Changed reset state of sl_rx_data_d1 and 
--								sl_rx_data_d1 from '0' to '1' (Idle)
--  20.01.2021 ARAL :   Cleaned-up state names 
--  22.01.2021 ARAL :   Changed Start-Bit detection from level to edge
---------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE RX_UART_pkg IS
	COMPONENT RX_UART IS
		PORT (
			isl_4x_uart_clk		: IN  STD_LOGIC;
			isl_reset			: IN  STD_LOGIC;
			isl_serial_data	: IN  STD_LOGIC;
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
			isl_serial_data	: IN  STD_LOGIC;
			osl_data_valid		: OUT STD_LOGIC;
			oslv8_data			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY RX_UART;

----------------------------------------------------------------------

ARCHITECTURE rtl of RX_UART IS

	TYPE t_rx_fsm_state IS (IDLE, S0, S1, S2, S3,   D0_0, D0_1, D0_2, D0_3, D1_0, D1_1, D1_2, D1_3, 
									D2_0, D2_1, D2_2, D2_3, D3_0, D3_1, D3_2, D3_3, D4_0, D4_1, D4_2, D4_3, 
									D5_0, D5_1, D5_2, D5_3, D6_0, D6_1, D6_2, D6_3, D7_0, D7_1, D7_2, D7_3, 
									ST_0, ST_1, ST_2, ST_3);
	
	TYPE t_registers IS RECORD
		fsm_state				: t_rx_fsm_state;
		sl_rx_data_d1			: STD_LOGIC;
		sl_rx_data_d2			: STD_LOGIC;
		sl_rx_data_d3			: STD_LOGIC;
		slv8_data				: STD_LOGIC_VECTOR(7 DOWNTO 0);
		slv8_out_data			: STD_LOGIC_VECTOR(7 DOWNTO 0);
		sl_data_valid			: STD_LOGIC;
	END RECORD t_registers;
	
	SIGNAL r, r_next			: t_registers := (
										 fsm_state			=> IDLE,
										 sl_rx_data_d1		=> '1',
										 sl_rx_data_d2		=> '1',
										 sl_rx_data_d3		=> '1',
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

		r_next						<= r;							--	Keep signals stable
		r_next.sl_data_valid		<= '0';						--	Single-cycle signal default value
		
		r_next.sl_rx_data_d1		<= isl_serial_data;		--	Re-Sync double buffering
		r_next.sl_rx_data_d2		<= r.sl_rx_data_d1;
		r_next.sl_rx_data_d3		<= r.sl_rx_data_d2;
	
		CASE r.fsm_state IS
			WHEN IDLE	=> --	Wait for Falling Edge of Start Bit
								IF (r.sl_rx_data_d2 = '0' AND r.sl_rx_data_d3 = '1') THEN
									r_next.fsm_state	<= S0;
								END IF;
								
			WHEN S0		=> r_next.fsm_state	<= S1;		--	Start-Bit, 1st cycle
			WHEN S1		=> r_next.fsm_state	<= S2;		--	Start-Bit, 2nd cycle
			
			WHEN S2		=> r_next.fsm_state	<= S3;	 	--	Start-Bit, 3rd cycle
			WHEN S3		=> r_next.fsm_state	<= D0_0;		--	Start-Bit, 4th cycle
			
			WHEN D0_0	=> r_next.fsm_state	<= D0_1;		-- Data 0, 1st cycle
			WHEN D0_1	=> r_next.fsm_state	<= D0_2;		-- Data 0, 2nd cycle
			WHEN D0_2	=> r_next.fsm_state	<= D0_3;		-- Data 0, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is LSB first
			WHEN D0_3	=> r_next.fsm_state	<= D1_0;		-- Data 0, 4th cycle = sample cycle
			
			WHEN D1_0	=> r_next.fsm_state	<= D1_1;		-- Data 1, 1st cycle
			WHEN D1_1	=> r_next.fsm_state	<= D1_2;		-- Data 1, 2nd cycle
			WHEN D1_2	=> r_next.fsm_state	<= D1_3;		-- Data 1, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is 7th bit
			WHEN D1_3	=> r_next.fsm_state	<= D2_0;		-- Data 1, 4th cycle = sample cycle
			
			WHEN D2_0	=> r_next.fsm_state	<= D2_1;		-- Data 2, 1st cycle
			WHEN D2_1	=> r_next.fsm_state	<= D2_2;		-- Data 2, 2nd cycle
			WHEN D2_2	=> r_next.fsm_state	<= D2_3;		-- Data 2, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is 6th bit
			WHEN D2_3	=> r_next.fsm_state	<= D3_0;		-- Data 2, 4th cycle = sample cycle
			
			WHEN D3_0	=> r_next.fsm_state	<= D3_1;		-- Data 3, 1st cycle
			WHEN D3_1	=> r_next.fsm_state	<= D3_2;		-- Data 3, 2nd cycle
			WHEN D3_2	=> r_next.fsm_state	<= D3_3;		-- Data 3, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is 5th bit
			WHEN D3_3	=> r_next.fsm_state	<= D4_0;		-- Data 3, 4th cycle = sample cycle
			
			WHEN D4_0	=> r_next.fsm_state	<= D4_1;		-- Data 4, 1st cycle
			WHEN D4_1	=> r_next.fsm_state	<= D4_2;		-- Data 4, 2nd cycle
			WHEN D4_2	=> r_next.fsm_state	<= D4_3;		-- Data 4, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is 4th bit
			WHEN D4_3	=> r_next.fsm_state	<= D5_0;		-- Data 4, 4th cycle = sample cycle
			
			WHEN D5_0	=> r_next.fsm_state	<= D5_1;		-- Data 5, 1st cycle
			WHEN D5_1	=> r_next.fsm_state	<= D5_2;		-- Data 5, 2nd cycle
			WHEN D5_2	=> r_next.fsm_state	<= D5_3;		-- Data 5, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is 3rd bit
			WHEN D5_3	=> r_next.fsm_state	<= D6_0;		-- Data 5, 4th cycle = sample cycle
			
			WHEN D6_0	=> r_next.fsm_state	<= D6_1;		-- Data 6, 1st cycle
			WHEN D6_1	=> r_next.fsm_state	<= D6_2;		-- Data 6, 2nd cycle
			WHEN D6_2	=> r_next.fsm_state	<= D6_3;		-- Data 6, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is 2nd bit
			WHEN D6_3	=> r_next.fsm_state	<= D7_0;		-- Data 6, 4th cycle = sample cycle
			
			WHEN D7_0	=> r_next.fsm_state	<= D7_1;		-- Data 7, 1st cycle
			WHEN D7_1	=> r_next.fsm_state	<= D7_2;		-- Data 7, 2nd cycle
			WHEN D7_2	=> r_next.fsm_state	<= D7_3;		-- Data 7, 3rd cycle
								r_next.slv8_data	<= r.sl_rx_data_d2 & r.slv8_data(7 DOWNTO 1);	--	RS-232 is MSB last
			WHEN D7_3	=> r_next.fsm_state	<= ST_0;		-- Data 7, 4th cycle = sample cycle
			
			WHEN ST_0	=> r_next.fsm_state	<= ST_1;		--	Stop Bit, 1st cycle
			WHEN ST_1	=> r_next.fsm_state	<= ST_3;		--	Stop Bit, 1st cycle
--			WHEN ST_2	=> r_next.fsm_state	<= ST_3;		--	Stop Bit, 1st cycle
			WHEN ST_3	=> r_next.fsm_state	<= IDLE;		--	Stop Bit, 1st cycle
								r_next.slv8_out_data		<= r.slv8_data;
								r_next.sl_data_valid		<= '1';
								--	If there is more than one Stop Bit, it will be handled by the IDLE state
			
			WHEN OTHERS	=>	r_next.fsm_state	<= IDLE;
		END CASE;
		
		--##	Reset Logic
		IF isl_reset = '1' THEN
			r_next.fsm_state			<= IDLE;
			r_next.sl_rx_data_d1		<= '1';
			r_next.sl_rx_data_d2		<= '1';
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
