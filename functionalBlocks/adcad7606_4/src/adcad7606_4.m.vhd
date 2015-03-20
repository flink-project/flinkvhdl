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
PACKAGE adcad7606_4_pkg IS
	CONSTANT NUMBER_OF_CHANNELS : INTEGER := 8;
	CONSTANT RESOLUTION : INTEGER := 16;
	TYPE t_value_regs IS ARRAY(NUMBER_OF_CHANNELS -1 DOWNTO 0) OF STD_LOGIC_VECTOR(RESOLUTION-1 DOWNTO 0);
	
	TYPE t_config IS RECORD
		range_select		: STD_LOGIC; -- '0' range is +-5V, '1' range is +-10V
		oversampling		: STD_LOGIC_VECTOR(2 DOWNTO 0); --select oversampling ratio
		standby				: STD_LOGIC; --when range='0' stby = '0' is shutdown mode, if range = '1' stby= '0' is standby mode
	END RECORD;
	
	
	
	COMPONENT adcad7606_4 IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; 
			SCLK_FREQUENCY : INTEGER := 8000000  --Min 0.8 Mhz, max 16Mhz
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			ot_values				: OUT t_value_regs;
			config					: IN t_config;
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC;
			osl_mosi				: OUT STD_LOGIC;
			isl_d_out_b				: IN STD_LOGIC;
			oslv_conv_start			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --initiates conversion
			osl_range				: OUT STD_LOGIC; -- '0' range is +-5V, '1' range is +-10V
			oslv_os					: OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --select oversampling ratio
			isl_busy				: IN STD_LOGIC; --indicate that conversion has started, stays high till all channels has been sampled 
			isl_first_data			: IN STD_LOGIC; --indicates when the first channel is being output
			osl_adc_reset			: OUT STD_LOGIC; --rising edge resets the adc
			osl_stby_n				: OUT STD_LOGIC
		);
	END COMPONENT adcad7606_4;

END PACKAGE adcad7606_4_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.adcad7606_4_pkg.ALL;
USE work.spi_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY adcad7606_4 IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; 
			SCLK_FREQUENCY : INTEGER := 8000000  --Min 0.8 Mhz, max 16Mhz
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			ot_values				: OUT t_value_regs;
			config					: IN t_config;
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC;
			osl_mosi				: OUT STD_LOGIC;
			isl_d_out_b				: IN STD_LOGIC;
			oslv_conv_start			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --initiates conversion
			osl_range				: OUT STD_LOGIC; -- '0' range is +-5V, '1' range is +-10V
			oslv_os					: OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --select oversampling ratio
			isl_busy				: IN STD_LOGIC; --indicate that conversion has started, stays high till all channels has been sampled 
			isl_first_data			: IN STD_LOGIC; --indicates when the first channel is being output
			osl_adc_reset			: OUT STD_LOGIC; --rising edge resets the adc
			osl_stby_n				: OUT STD_LOGIC
		);
END ENTITY adcad7606_4;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF adcad7606_4 IS
	CONSTANT SS_HOLD_CYCLES : INTEGER := 2; -- add 2 to be sure and have a minimum number of cycles
	CONSTANT TRANSFER_WIDTH : INTEGER := 128;
	CONSTANT CHANNEL_COUNT_WIDTH : INTEGER := integer(ceil(log2(real(NUMBER_OF_CHANNELS))));
	
	
	TYPE t_states IS (idle,wait_for_sampling_done,wait_for_data,store_data,wait_for_next_transfer);


	TYPE t_internal_register IS RECORD
		state				:t_states;
		tx_data 			: STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
		tx_start 			: STD_LOGIC;
		values				: t_value_regs;
		cycle_count			: UNSIGNED(6 DOWNTO 0);
		slv_conv_start 		: STD_LOGIC_VECTOR(1 DOWNTO 0);
		sl_adc_reset		: STD_LOGIC;
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
			TRANSFER_WIDTH 		=> 128, -- 128 bit per transfer only use one channel for the first version
			NR_OF_SS 			=> 1, -- only one ss is needed
			CPOL				=> '1', -- sckl inactive high see data sheet 
			CPHA				=> '0', -- data is captured on the trialling edge see data sheet
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
		comb_process: PROCESS(ri, isl_reset_n,sl_rx_done,slv_rx_data,isl_busy)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			--standard values
			vi.tx_start := '0';
			vi.slv_conv_start := (OTHERS => '0');
			vi.sl_adc_reset := '0';
			
			CASE vi.state IS 
				WHEN idle => 
					vi.slv_conv_start := (OTHERS => '1');
					 vi.state := wait_for_sampling_done;
				WHEN wait_for_sampling_done =>
					IF vi.cycle_count > 2 AND isl_busy = '0' THEN
						vi.cycle_count := to_unsigned(0,7);
						vi.tx_start := '1';
						vi.tx_data := (OTHERS => '0');
						vi.state := wait_for_data;
					ELSE
						vi.cycle_count := vi.cycle_count + 1;
					END IF;
				WHEN wait_for_data =>
					IF sl_rx_done = '1' THEN
						vi.state := store_data;
					END IF;
				WHEN store_data =>
					FOR i IN NUMBER_OF_CHANNELS DOWNTO 1 LOOP
						vi.values(NUMBER_OF_CHANNELS-i) := slv_rx_data(i*RESOLUTION-1 DOWNTO RESOLUTION*(i-1));
					END LOOP;
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
				FOR i IN 0 TO NUMBER_OF_CHANNELS-1 LOOP
					vi.values(i) := (OTHERS => '0');
				END LOOP;
				vi.cycle_count := (OTHERS => '0');
				vi.sl_adc_reset := '1';
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
		
		oslv_conv_start <= ri.slv_conv_start;
		ot_values <= ri.values;
		osl_range <= config.range_select;
		oslv_os <= config.oversampling;
		osl_adc_reset <= ri.sl_adc_reset;
		osl_stby_n <= config.standby;
		
		
		
END ARCHITECTURE rtl;


