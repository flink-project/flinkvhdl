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
PACKAGE adc128S102_pkg IS
	CONSTANT NUMBER_OF_CHANELS : INTEGER := 8;
	CONSTANT RESOLUTION : INTEGER := 12;
	TYPE t_value_regs IS ARRAY(NUMBER_OF_CHANELS -1 DOWNTO 0) OF STD_LOGIC_VECTOR(RESOLUTION-1 DOWNTO 0);
	
	
	COMPONENT adc128S102 IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; 
			SCLK_FREQUENCY : INTEGER := 8000000  --Min 0.8 Mhz, max 16Mhz
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			ot_values				: OUT t_value_regs;
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC;
			osl_mosi				: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC
		);
	END COMPONENT adc128S102;

END PACKAGE adc128S102_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.adc128S102_pkg.ALL;
USE work.spi_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY adc128S102 IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; 
			SCLK_FREQUENCY : INTEGER := 8000000  --Min 0.8 Mhz, max 16Mhz
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			ot_values				: OUT t_value_regs;
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC;
			osl_mosi				: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC
		);
END ENTITY adc128S102;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF adc128S102 IS
	CONSTANT SS_HOLD_FREQUENCY : INTEGER := 100000000; -- (10ns)^-1 see data sheet for this value
	CONSTANT SS_HOLD_CYCLES : INTEGER := BASE_CLK/SS_HOLD_FREQUENCY + 2; -- add 2 to be sure and have a minimum number of cycles
	CONSTANT TRANSFER_WIDTH : INTEGER := 16;
	CONSTANT CHANEL_COUNT_WIDTH : INTEGER := integer(ceil(log2(real(NUMBER_OF_CHANELS))));
	
	
	TYPE t_states IS (idle,wait_for_data,store_data,wait_for_next_transfer);


	TYPE t_internal_register IS RECORD
		state				:t_states;
		tx_data 			: STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
		tx_start 			: STD_LOGIC;
		channel_count 		: UNSIGNED(CHANEL_COUNT_WIDTH-1 DOWNTO 0);
		values				: t_value_regs;
		cycle_count			: UNSIGNED(6 DOWNTO 0);
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
			TRANSFER_WIDTH 		=> 16, -- 16 bit per transfer see data sheet
			NR_OF_SS 			=> 1, -- only one ss is needed
			CPOL				=> '1', -- sckl inactive high see data sheet 
			CPHA				=> '1', -- data is captured on the leading edge see data sheet
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
		comb_process: PROCESS(ri, isl_reset_n,sl_rx_done,slv_rx_data)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			--standard values
			vi.tx_start := '0';
			
			CASE vi.state IS 
				WHEN idle => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH -3 DOWNTO TRANSFER_WIDTH-5) := STD_LOGIC_VECTOR(vi.channel_count); 
					vi.tx_start := '1';
					vi.state := wait_for_data; 
				WHEN wait_for_data =>
					IF sl_rx_done = '1' THEN
						vi.state := store_data;
					END IF;
				WHEN store_data =>
					IF vi.channel_count = to_unsigned(0,CHANEL_COUNT_WIDTH) THEN 
						vi.values(NUMBER_OF_CHANELS-1) := slv_rx_data(RESOLUTION-1 DOWNTO 0);
					ELSE
						vi.values(to_integer(vi.channel_count)-1) := slv_rx_data(RESOLUTION-1 DOWNTO 0);
					END IF;
					
					IF vi.channel_count >= NUMBER_OF_CHANELS-1 THEN 
						vi.channel_count := to_unsigned(0,CHANEL_COUNT_WIDTH);
					ELSE
						vi.channel_count := vi.channel_count + 1;
					END IF;
					vi.state := wait_for_next_transfer;
				WHEN wait_for_next_transfer =>
					IF vi.cycle_count = 50 THEN
						vi.cycle_count := to_unsigned(0,7);
						vi.state := idle;
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
				WHEN OTHERS =>
					vi.state := idle; 
			END CASE;
			
			--reset
			IF isl_reset_n = '0' THEN
				vi.state := idle; 
				vi.tx_data := (OTHERS => '0');
				vi.tx_start := '0';
				vi.channel_count := to_unsigned(0,CHANEL_COUNT_WIDTH);
				FOR i IN 0 TO NUMBER_OF_CHANELS-1 LOOP
					vi.values(i) := (OTHERS => '0');
				END LOOP;
				vi.cycle_count := (OTHERS => '0');
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
		
		
		ot_values <= ri.values;
END ARCHITECTURE rtl;


