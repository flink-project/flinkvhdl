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
--  Title             : TX_UART.vhd
--  Project           : FLINK
--  Description       : VHDL UART design
---------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------
--  History
--  14.10.2020 ARAL :	Initial version

---------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE TX_UART_pkg IS
	COMPONENT TX_UART IS
		PORT (
			isl_4x_uart_clk		: IN  STD_LOGIC;
			isl_reset			: IN  STD_LOGIC;
			isl_data_valid		: IN  STD_LOGIC;
			islv8_data			: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			osl_serial_data     : OUT STD_LOGIC;
			osl_busy            : OUT STD_LOGIC
		);
	END COMPONENT TX_UART;
END PACKAGE TX_UART_pkg;

----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY TX_UART IS
	PORT (
			isl_4x_uart_clk		: IN  STD_LOGIC;
			isl_reset			: IN  STD_LOGIC;
			isl_data_valid		: IN  STD_LOGIC;
			islv8_data			: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			osl_serial_data     : OUT STD_LOGIC;
			osl_busy            : OUT STD_LOGIC
	);
END ENTITY TX_UART;

----------------------------------------------------------------------

ARCHITECTURE rtl of TX_UART IS

	TYPE t_tx_fsm_state IS (IDLE, START, D0, D1, D2, D3, D4, D5, D6, D7, D8, STOP1, STOP2);
	
	TYPE t_registers IS RECORD
		fsm_state				: t_tx_fsm_state;
		usig2_clk_divider		: UNSIGNED(1 DOWNTO 0);
		slv8_next_data			: STD_LOGIC_VECTOR(7 DOWNTO 0);
		sl_next_data_ready      : STD_LOGIC;
		slv8_data				: STD_LOGIC_VECTOR(7 DOWNTO 0);
		sl_tx_data				: STD_LOGIC;
		sl_busy					: STD_LOGIC;
	END RECORD t_registers;
	
	SIGNAL r, r_next			: t_registers		:= (
										fsm_state				=> IDLE,
										usig2_clk_divider		=> (OTHERS => '0'),
										slv8_next_data			=> (OTHERS => '0'),
										sl_next_data_ready	=> '0',
										slv8_data				=> (OTHERS => '0'),
										sl_tx_data				=> '1',
										sl_busy					=> '0'
									);

BEGIN

	
	--	Clock is divided by 4 to be able to use the same clock as RX_UART
	--	Data is registered with "isl_data_valid", which will start transmission
	--	Format is 1 Start bit, 8 data bits, 2 stop bits, no parity
	
	

	--##	Combinatorial Priocess
	--##
	--##########################
	comb_proc : PROCESS (r, isl_reset, isl_data_valid, islv8_data)
	VARIABLE v					: t_registers;
	BEGIN

		v								:= r;							--	Keep signals stable
		
		--	Capture data, when it is available
		IF isl_data_valid = '1' THEN
			v.slv8_next_data		:= islv8_data;
			v.sl_next_data_ready	:= '1';
		END IF;
		
		
		v.usig2_clk_divider	:= r.usig2_clk_divider + 1;	--	Modulo 4 counter
			
		IF r.usig2_clk_divider = "00" THEN	--	Only take action every 4th cycle
		
			CASE r.fsm_state IS
				WHEN IDLE	=> --	Wait for Data valid signal
									v.sl_tx_data				:= '1';
									v.sl_busy					:= '0';
									IF (r.sl_next_data_ready = '1') THEN
										v.sl_next_data_ready	:= '0';
										v.slv8_data				:= r.slv8_next_data;
										v.fsm_state				:= START;
										v.sl_busy				:= '1';
									END IF;
									
				WHEN START	=> v.sl_tx_data				:= '0';	--	Send Start bit
									v.fsm_state					:= D0;
									
				WHEN D0		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= D1;
				
				WHEN D1		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= D2;
				
				WHEN D2		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= D3;
				
				WHEN D3		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= D4;
				
				WHEN D4		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= D5;
				
				WHEN D5		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= D6;
				
				WHEN D6		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= D7;
				
				WHEN D7		=> v.sl_tx_data				:= r.slv8_data(0);
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= STOP1;
				
				WHEN STOP1	=> v.sl_tx_data				:= '1';	--	Send Stop Bit
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.fsm_state					:= STOP2;
				
				WHEN STOP2	=> v.sl_tx_data				:= '1';	--	Send Stop Bit
									v.slv8_data(7 DOWNTO 0)	:= '0' & r.slv8_data(7 DOWNTO 1);
									v.sl_busy					:= '0';
									v.fsm_state					:= IDLE;
				
				
				WHEN OTHERS	=>	v.fsm_state					:= IDLE;
			END CASE;
		END IF;	--  Only take action every 4th clock cycle
		
		--##	Reset Logic
		IF isl_reset = '1' THEN
			v.fsm_state					:= IDLE;
			v.usig2_clk_divider		:= (OTHERS => '0');
			v.slv8_data					:= (OTHERS => '0');
			v.sl_tx_data				:= '1';
			v.sl_busy					:= '0';
		END IF;
		
		r_next	<= v;
		
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
	osl_serial_data	<= r.sl_tx_data;
	osl_busy				<= r.sl_busy;

END ARCHITECTURE rtl;

