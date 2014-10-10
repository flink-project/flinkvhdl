-------------------------------------------------------------------------------
--     ____  _____          __    __    ________    _______
--    |    | \    \        |   \ |  |  |__    __|  |   __  \
--    |____|  \____\       |    \|  |     |  |     |  |__>  ) 
--     ____   ____         |  |\ \  |     |  |     |   __  <
--    |    | |    |        |  | \   |     |  |     |  |__>  )
--    |____| |____|        |__|  \__|     |__|     |_______/
--
--    NTB University of Applied Sciences in Technology
--
--    Campus Buchs - Werdenbergstrasse 4 - 9471 Buchs - Switzerland
--    Campus Waldau - Schoenauweg 4 - 9013 St. Gallen - Switzerland
--
--    Web http://www.ntb.ch        Tel. +41 81 755 33 11
--
-------------------------------------------------------------------------------
-- Copyright 2013 NTB University of Applied Sciences in Technology
-------------------------------------------------------------------------------
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
-- http://www.apache.org/licenses/LICENSE-2.0
--   
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

-------------------------------------------------------------------------------
-- PACKAGE DEFINITION
-------------------------------------------------------------------------------
PACKAGE dacad5668_pkg IS
	CONSTANT NUMBER_OF_CHANELS : INTEGER := 8;
	CONSTANT RESOLUTION : INTEGER := 16;
	TYPE t_value_regs IS ARRAY(NUMBER_OF_CHANELS -1 DOWNTO 0) OF STD_LOGIC_VECTOR(RESOLUTION-1 DOWNTO 0);
	
	
	COMPONENT dacad5668 IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; 
			SCLK_FREQUENCY : INTEGER := 8000000;  --Max 50MHz
			INTERNAL_REFERENCE : STD_LOGIC := '0'  -- '0' = set to internal reference, '1' set to externel reference
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			it_set_values			: IN t_value_regs;
			
			osl_LDAC_n				: OUT STD_LOGIC;
			osl_CLR_n				: OUT STD_LOGIC;
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC;
			osl_mosi				: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC
		);
	END COMPONENT dacad5668;

END PACKAGE dacad5668_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.dacad5668_pkg.ALL;
USE work.spi_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY dacad5668 IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; 
			SCLK_FREQUENCY : INTEGER := 10000000;  --Max 50MHz
			INTERNAL_REFERENCE : STD_LOGIC := '0'  -- '0' = set to internal reference, '1' set to externel reference
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			it_set_values			: IN t_value_regs;
			
			osl_LDAC_n				: OUT STD_LOGIC;
			osl_CLR_n				: OUT STD_LOGIC;
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC;
			osl_mosi				: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC
		);
END ENTITY dacad5668;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF dacad5668 IS
	CONSTANT SS_HOLD_CYCLES : INTEGER := 40; -- minimum 15ns see datasheet 
	CONSTANT CHANEL_COUNT_WIDTH : INTEGER := 4;
	CONSTANT TRANSFER_WIDTH : INTEGER := 32;
	
	--COMMAND CODES
	CONSTANT WRITE_INPUT_REGISTER_N : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	CONSTANT UPDATE_DAC_REGISTER_N : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
	CONSTANT WRITE_AND_UPDATE_CHANNEL_N : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
	
	CONSTANT SETUP_INTERNAL_REF : STD_LOGIC_VECTOR(3 DOWNTO 0) 	:= "1000";
	CONSTANT POWER_MODE : STD_LOGIC_VECTOR(3 DOWNTO 0) 	:= "0100";
	
	
	TYPE t_states IS (idle,wait_for_transfer_to_finish,wait_for_next_transfer,set_internal_reference,update_channels,power_up_mode);


	TYPE t_internal_register IS RECORD
		state				:t_states;
		tx_data 			: STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
		tx_start 			: STD_LOGIC;
		channel_count 		: UNSIGNED(CHANEL_COUNT_WIDTH-1 DOWNTO 0);
		cycle_count 		: UNSIGNED(6 DOWNTO 0);
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
			TRANSFER_WIDTH 		=> TRANSFER_WIDTH, -- 32 bit per transfer see data sheet
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
			
			osl_sclk				=> osl_sclk,
			oslv_Ss(0)				=> oslv_Ss,
			osl_mosi				=> osl_mosi,
			isl_miso				=> isl_miso
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
			vi.LDAC_n := '1';
			vi.CLR_n := '1';
			
			
			CASE vi.state IS 
				WHEN power_up_mode => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH -5 DOWNTO TRANSFER_WIDTH-8) := POWER_MODE;
					vi.tx_data(NUMBER_OF_CHANELS -1 DOWNTO 0) := (OTHERS => '1'); -- power up all chanels
					vi.tx_start := '1';
					vi.state := wait_for_transfer_to_finish; 
					vi.channel_count := to_unsigned(NUMBER_OF_CHANELS-1,CHANEL_COUNT_WIDTH);
				--WHEN set_internal_reference =>
					--vi.tx_data := (OTHERS => '0');
					--vi.tx_data(TRANSFER_WIDTH -5 DOWNTO TRANSFER_WIDTH-8) := SETUP_INTERNAL_REF;
					--vi.tx_data(0) := INTERNAL_REFERENCE; 
					--vi.tx_start := '1';
					--vi.state := wait_for_transfer_to_finish; 
				WHEN idle => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH -5 DOWNTO TRANSFER_WIDTH-8) := WRITE_AND_UPDATE_CHANNEL_N;
					vi.tx_data(TRANSFER_WIDTH -9 DOWNTO TRANSFER_WIDTH-12) := STD_LOGIC_VECTOR(vi.channel_count); 
					vi.tx_data(TRANSFER_WIDTH -13 DOWNTO TRANSFER_WIDTH-28) := it_set_values(to_integer(vi.channel_count)); 
					vi.tx_start := '1';
					vi.state := wait_for_transfer_to_finish; 
				WHEN wait_for_transfer_to_finish =>
					IF sl_rx_done = '1' THEN
						vi.state := update_channels;
						vi.cycle_count := (OTHERS => '0');
					END IF;
				WHEN update_channels => 
						vi.LDAC_n := '0';
						IF vi.cycle_count = 20 THEN
							vi.state := wait_for_next_transfer;
							vi.cycle_count := (OTHERS => '0');
						ELSE
							vi.cycle_count := vi.cycle_count + 1;
						END IF;
				WHEN wait_for_next_transfer =>
					IF vi.cycle_count = 100 THEN
						vi.cycle_count := to_unsigned(0,7);
						IF vi.channel_count = NUMBER_OF_CHANELS -1 THEN
							vi.channel_count := to_unsigned(0,CHANEL_COUNT_WIDTH);
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
				vi.state := power_up_mode; 
				vi.tx_data := (OTHERS => '0');
				vi.tx_start := '0';
				vi.channel_count := to_unsigned(0,CHANEL_COUNT_WIDTH);
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


