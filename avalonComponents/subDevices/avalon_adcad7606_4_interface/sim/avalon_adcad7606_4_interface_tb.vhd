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
USE IEEE.math_real.ALL;

USE work.fLink_definitions.ALL;
USE work.avalon_adcad7606_4_interface_pkg.ALL;
USE work.adcad7606_4_pkg.ALL;

ENTITY avalon_adcad7606_4_interface_tb IS
END ENTITY avalon_adcad7606_4_interface_tb;

ARCHITECTURE sim OF avalon_adcad7606_4_interface_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT unice_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := x"00616463"; --adc

	SIGNAL sl_clk					: STD_LOGIC := '0';
	SIGNAL sl_reset_n				: STD_LOGIC := '1';
	SIGNAL slv_avs_address		: STD_LOGIC_VECTOR (c_adcad7606_4_address_with-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL sl_avs_read			: STD_LOGIC:= '0';
	SIGNAL sl_avs_write			: STD_LOGIC:= '0';
	SIGNAL slv_avs_write_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_avs_read_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	
	SIGNAL sl_sclk			: STD_LOGIC:= '0';
	SIGNAL slv_Ss			: STD_LOGIC:= '0';
	SIGNAL sl_mosi			: STD_LOGIC:= '0';
	SIGNAL sl_miso			: STD_LOGIC:= '1';
	
	SIGNAL sl_d_out_b				: STD_LOGIC := '0';
	SIGNAL slv_conv_start			: STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS =>'0');
	SIGNAL sl_range				: STD_LOGIC := '0';
	SIGNAL slv_os					: STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS =>'0');
	SIGNAL sl_busy					: STD_LOGIC := '0'; 
	SIGNAL sl_first_data			: STD_LOGIC := '0';
	SIGNAL sl_adc_reset			: STD_LOGIC := '0';
	SIGNAL sl_stby_n				: STD_LOGIC := '0';
	
	
	
BEGIN
	--create component
	my_unit_under_test : avalon_adcad7606_4_interface 
	GENERIC MAP(
		BASE_CLK => 33000000,
		SCLK_FREQUENCY => 1000000,
		unice_id => unice_id
	)
	PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n				=> sl_reset_n,
			islv_avs_address 		=> slv_avs_address,
			isl_avs_read 			=> sl_avs_read,
			isl_avs_write			=> sl_avs_write,
			islv_avs_write_data		=> slv_avs_write_data,	
			oslv_avs_read_data		=> slv_avs_read_data,
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
			osl_adc_reset			=> sl_adc_reset,
			osl_stby_n				=> sl_stby_n
			
			
	);
	
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR main_period/2;		

--test id register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_typdef_address,c_adcad7606_4_address_with));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(c_adcad7606_4_interface_version,c_fLink_interface_version_length)) 
			REPORT "Interface Version Missmatch" SEVERITY FAILURE;
			
			ASSERT slv_avs_read_data(c_fLink_interface_version_length+c_fLink_subtype_length-1 DOWNTO c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_adcad7606_4_subtype_id,c_fLink_subtype_length)) 
			REPORT "Subtype ID Missmatch" SEVERITY FAILURE;

			ASSERT slv_avs_read_data(c_fLink_avs_data_width-1 DOWNTO c_fLink_interface_version_length+c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_fLink_analog_input_id,c_fLink_id_length)) 
			REPORT "Type ID Missmatch" SEVERITY FAILURE;

--test mem size register register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_mem_size_address,c_adcad7606_4_address_with));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT to_integer(UNSIGNED(slv_avs_read_data)) = 4*INTEGER(2**c_adcad7606_4_address_with)
			REPORT "Memory Size Error: "&INTEGER'IMAGE(4*INTEGER(2**NUMBER_OF_CHANELS))&"/"&INTEGER'IMAGE(to_integer(UNSIGNED(slv_avs_read_data))) 				SEVERITY FAILURE;
--test unique id register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_unice_id_address,c_adcad7606_4_address_with));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data = unice_id
			REPORT "Unic Id Error" SEVERITY FAILURE;
			
--test number of channels register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_chanels_address,c_adcad7606_4_address_with));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(NUMBER_OF_CHANELS,c_fLink_interface_version_length)) 
			REPORT "Number of Channels Error" SEVERITY FAILURE;

		WAIT FOR 10000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

