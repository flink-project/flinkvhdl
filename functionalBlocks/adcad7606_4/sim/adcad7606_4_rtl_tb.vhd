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
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.adcad7606_4_pkg.ALL;

ENTITY adcad7606_4_rtl_tb IS
END ENTITY adcad7606_4_rtl_tb;

ARCHITECTURE sim OF adcad7606_4_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	
	
	SIGNAL sl_clk				: STD_LOGIC := '0';
	SIGNAL sl_reset_n			: STD_LOGIC := '0';
	SIGNAL values 				: t_value_regs;
	
	
	SIGNAL sl_sclk				: STD_LOGIC := '0';
	SIGNAL slv_Ss				: STD_LOGIC := '0';
	SIGNAL sl_mosi				: STD_LOGIC := '0';
	SIGNAL sl_miso				: STD_LOGIC := '0';
	SIGNAL sl_d_out_b			: STD_LOGIC := '0';
	SIGNAL slv_conv_start		:  STD_LOGIC_VECTOR(1 DOWNTO 0):= (OTHERS => '0');
	SIGNAL sl_range				: STD_LOGIC := '0';
	SIGNAL slv_os				: STD_LOGIC_VECTOR(2 DOWNTO 0):= (OTHERS => '0');
	SIGNAL sl_busy				: STD_LOGIC := '0';
	SIGNAL sl_first_data		: STD_LOGIC := '0';
	SIGNAL sl_stby_n			: STD_LOGIC := '0';
	SIGNAL sl_adc_reset			: STD_LOGIC := '0';
	SIGNAL config 				: t_config;
	
	
BEGIN
	--create component
	my_unit_under_test : adcad7606_4 
	GENERIC MAP(
			BASE_CLK 			=> 33000000,
			SCLK_FREQUENCY		=> 1000000
		)
		PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n    			=> sl_reset_n,
			
			ot_values			=> values,
			config				=> config,
			osl_sclk				=> sl_sclk,
			oslv_Ss					=> slv_Ss,
			osl_mosi				=> sl_mosi,
			isl_miso				=> sl_miso,
			isl_d_out_b				=> sl_d_out_b,
			oslv_conv_start			=> slv_conv_start,
			osl_range				=> sl_range,
			oslv_os					=> slv_os,
			isl_busy				=> sl_busy,
			isl_first_data			=> sl_first_data,
			osl_stby_n				=> sl_stby_n,
			osl_adc_reset			=> sl_adc_reset
		);

		
		
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	config.range_select <= '0';
	config.oversampling <= (OTHERS => '0');
	config.standby <= '1';
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 3000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

