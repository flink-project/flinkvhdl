-------------------------------------------------------------------------------
--  _________    _____       _____    ____  _____    ___  ____               --
-- |_   ___  |  |_   _|     |_   _|  |_   \|_   _|  |_  ||_  _|              --
--   | |_  \_|    | |         | |      |   \ | |      | |_/ /                --
--   |  _|        | |   _     | |      | |\ \| |      |  __'.                --
--  _| |_        _| |__/ |   _| |_    _| |_\   |_    _| |  \ \_              --
-- |_____|      |________|  |_____|  |_____|\____|  |____||____|             --
--                                                                           --
-------------------------------------------------------------------------------
--                                                                           --
-- Avalon MM interface for DAC AD5754                                        --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright 2023 OST University of Applied Sciences in Technology           --
--                                                                           --
-- Licensed under the Apache License, Version 2.0 (the "License");           --
-- you may not use this file except in compliance with the License.          --
-- You may obtain a copy of the License at                                   --
--                                                                           --
-- http://www.apache.org/licenses/LICENSE-2.0                                --
--                                                                           --
-- Unless required by applicable law or agreed to in writing, software       --
-- distributed under the License is distributed on an "AS IS" BASIS,         --
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  --
-- See the License for the specific language governing permissions and       --
-- limitations under the License.                                            --
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

-------------------------------------------------------------------------------
-- PACKAGE DEFINITION
-------------------------------------------------------------------------------
PACKAGE dacad5754_pkg IS
	CONSTANT NUMBER_OF_CHANNELS : INTEGER := 4;
	CONSTANT RESOLUTION : INTEGER := 16;
	TYPE t_value_regs IS ARRAY(NUMBER_OF_CHANNELS -1 DOWNTO 0) OF STD_LOGIC_VECTOR(RESOLUTION-1 DOWNTO 0);
	
	
	COMPONENT dacad5754 IS
		GENERIC(
			BASE_CLK : INTEGER := 100000000; 
			SCLK_FREQUENCY : INTEGER := 10000000  --Max 30MHz

		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			it_set_values			: IN t_value_regs;
			
			osl_LDAC_n				: OUT STD_LOGIC;
			osl_CLR_n				: OUT STD_LOGIC;
			
			osl_SCLK				: OUT STD_LOGIC;
			osl_SYNC				: OUT STD_LOGIC;
			osl_MOSI				: OUT STD_LOGIC
		);
	END COMPONENT dacad5754;

END PACKAGE dacad5754_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.dacad5754_pkg.ALL;
USE work.spi_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY dacad5754 IS
		GENERIC(
			BASE_CLK : INTEGER := 100000000; 
			SCLK_FREQUENCY : INTEGER := 10000000  --Max 30MHz
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			it_set_values			: IN t_value_regs;
			
			osl_LDAC_n				: OUT STD_LOGIC;
			osl_CLR_n				: OUT STD_LOGIC;
			
			osl_SCLK				: OUT STD_LOGIC;
			osl_SYNC				: OUT STD_LOGIC;
			osl_MOSI				: OUT STD_LOGIC
		);
END ENTITY dacad5754;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF dacad5754 IS
	CONSTANT SS_HOLD_CYCLES : INTEGER := 40; -- minimum 15ns see datasheet 
	CONSTANT CHANNEL_COUNT_WIDTH : INTEGER := 3;
	CONSTANT TRANSFER_WIDTH : INTEGER := 24;
	
	--COMMAND CODES
	CONSTANT WRITE_AND_UPDATE_CHANNEL_N : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
	CONSTANT RANGE_SELECT_REG : STD_LOGIC_VECTOR(2 DOWNTO 0) 	:= "001";
	CONSTANT POWER_CONTROL_REG : STD_LOGIC_VECTOR(2 DOWNTO 0) 	:= "010";
	CONSTANT CONTROL_REG : STD_LOGIC_VECTOR(2 DOWNTO 0) 	:= "011";
	CONSTANT ADDR_ALL : STD_LOGIC_VECTOR(2 DOWNTO 0) 	:= "100";
	
	
	TYPE t_states IS (idle,wait_for_transfer_to_finish,wait_for_next_transfer,
	                  wait_for_transfer_to_finish_range_select,wait_after_range_select,
	                  wait_for_transfer_to_finish_control_reg,wait_after_control_reg,
	                  wait_for_transfer_to_finish_power_control,wait_after_power_control,
	                  range_select,control,power_control,keep_clear_low,wait_after_reset);


	TYPE t_internal_register IS RECORD
		state				: t_states;
		tx_data 			: STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
		tx_start 			: STD_LOGIC;
		channel_count 		: UNSIGNED(CHANNEL_COUNT_WIDTH-1 DOWNTO 0);
		cycle_count 		: UNSIGNED(10 DOWNTO 0);
		LDAC_n				: STD_LOGIC;
		CLR_n 				: STD_LOGIC;
	END RECORD;
	
	

	SIGNAL slv_rx_data : STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
	SIGNAL sl_rx_done : STD_LOGIC;
	
	SIGNAL ri, ri_next : t_internal_register;
	
	BEGIN
	
	my_spi_master :  spi_master 
	GENERIC MAP(
			BASE_CLK 			=> BASE_CLK,
			SCLK_FREQUENCY		=> SCLK_FREQUENCY,
			CS_SETUP_CYLES		=> SS_HOLD_CYCLES,
			TRANSFER_WIDTH 		=> TRANSFER_WIDTH, -- 24 bit per transfer see data sheet
			NR_OF_SS 			=> 1, -- only one ss is needed
			CPOL				=> '0', -- sckl inactive high 
			CPHA				=> '1', -- data is captured on the tailing edge see data sheet
			MSBFIRST			=> '1', -- MSB first
			SSPOL				=> '0' -- zero active see data sheet 
		)
		PORT MAP(
			isl_clk					=> isl_clk,
			isl_reset_n    			=> isl_reset_n,
			
			islv_tx_data			=> ri.tx_data,
			isl_tx_start			=> ri.tx_start,
			oslv_rx_data			=> slv_rx_data,
			osl_rx_done				=> sl_rx_done,
			islv_ss_activ(0)  		=> '1',
			
			osl_SCLK				=> osl_SCLK,
			oslv_Ss(0)				=> osl_SYNC,
			osl_MOSI				=> osl_MOSI,
			isl_MISO				=> '0'
		);
	
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,sl_rx_done,slv_rx_data,it_set_values)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			--standard values
			vi.tx_start := '0';
			vi.LDAC_n := '0';
			vi.CLR_n := '1';
			
			
			CASE vi.state IS 
				WHEN keep_clear_low => 
					vi.CLR_n := '0';
					IF vi.cycle_count = 10 THEN
						vi.state := wait_after_reset;
						vi.cycle_count := (OTHERS => '0');
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
				WHEN wait_after_reset => 
					IF vi.cycle_count = 100 THEN
						vi.state := range_select;
						vi.cycle_count := (OTHERS => '0');
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
				WHEN range_select =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(21 DOWNTO 19) := RANGE_SELECT_REG;
					vi.tx_data(18 DOWNTO 16) := ADDR_ALL; 
					vi.tx_data(2 DOWNTO 0) := "100"; -- +-10V
					vi.tx_start := '1';
					vi.state := wait_for_transfer_to_finish_range_select; 
				WHEN wait_for_transfer_to_finish_range_select =>
					IF sl_rx_done = '1' THEN
						vi.state := wait_after_range_select;
						vi.cycle_count := (OTHERS => '0');
					END IF;
				WHEN wait_after_range_select =>
					IF vi.cycle_count = 100 THEN
					    vi.state := control;
						vi.cycle_count := (OTHERS => '0');
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
				WHEN control =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(21 DOWNTO 19) := CONTROL_REG;
					vi.tx_data(18 DOWNTO 16) := "001"; 
					vi.tx_data(3 DOWNTO 0) := "0100"; -- 0V
					vi.tx_start := '1';
					vi.state := wait_for_transfer_to_finish_control_reg; 
				WHEN wait_for_transfer_to_finish_control_reg =>
					IF sl_rx_done = '1' THEN
						vi.state := wait_after_control_reg;
						vi.cycle_count := (OTHERS => '0');
					END IF;
				WHEN wait_after_control_reg =>
					IF vi.cycle_count = 100 THEN
						vi.state := power_control;
						vi.cycle_count := (OTHERS => '0');
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
				WHEN power_control =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(21 DOWNTO 19) := POWER_CONTROL_REG;
					vi.tx_data(3 DOWNTO 0) := "1111"; -- power up
					vi.tx_start := '1';
					vi.state := wait_for_transfer_to_finish_power_control; 
				WHEN wait_for_transfer_to_finish_power_control =>
					IF sl_rx_done = '1' THEN
						vi.state := wait_after_power_control;
						vi.cycle_count := (OTHERS => '0');
					END IF;
				WHEN wait_after_power_control =>
					IF vi.cycle_count = 1000 THEN
						vi.state := idle;
						vi.cycle_count := (OTHERS => '0');
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
				WHEN idle => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(18 DOWNTO 16) := STD_LOGIC_VECTOR(vi.channel_count); 
					vi.tx_data(15 DOWNTO 0) := it_set_values(to_integer(vi.channel_count)); 
					vi.tx_start := '1';
					vi.state := wait_for_transfer_to_finish; 
				WHEN wait_for_transfer_to_finish =>
					IF sl_rx_done = '1' THEN
						vi.state := wait_for_next_transfer;
						vi.cycle_count := (OTHERS => '0');
					END IF;
				WHEN wait_for_next_transfer =>
					IF vi.cycle_count = 100 THEN
						vi.cycle_count := (OTHERS => '0');
						IF vi.channel_count = NUMBER_OF_CHANNELS -1 THEN
							vi.channel_count := to_unsigned(0,CHANNEL_COUNT_WIDTH);
						ELSE
							vi.channel_count := vi.channel_count + 1;
						END IF;
						vi.state := idle;
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
					
				WHEN OTHERS =>
					vi.state := idle; 
			END CASE;
			
			--reset
			IF isl_reset_n = '0' THEN
				vi.state := keep_clear_low; 
				vi.tx_data := (OTHERS => '0');
				vi.tx_start := '0';
				vi.channel_count := to_unsigned(0,CHANNEL_COUNT_WIDTH);
				vi.cycle_count := (OTHERS => '0');
				vi.CLR_n := '0';
			END IF;
			
			-- setting outputs
			ri_next <= vi;
			
		END PROCESS comb_process;
		
		--------------------------------------------
		-- registered process
		--------------------------------------------
		reg_process: PROCESS (isl_clk)
		BEGIN
			IF rising_edge(isl_clk) THEN
				ri <= ri_next;
			END IF;
		END PROCESS reg_process;

		osl_LDAC_n <= ri.LDAC_n;
		osl_CLR_N <= ri.CLR_n;
		
END ARCHITECTURE rtl;


