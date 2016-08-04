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
USE work.avalon_itg3200_interface_pkg.ALL;
USE work.itg3200_pkg.ALL;

ENTITY avalon_itg3200_interface_tb IS
END ENTITY avalon_itg3200_interface_tb;

ARCHITECTURE sim OF avalon_itg3200_interface_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := x"00616463"; --adc
	CONSTANT c_usig_data_0_address: UNSIGNED(c_itg3200_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_itg3200_address_width);

	SIGNAL sl_clk					: STD_LOGIC := '0';
	SIGNAL sl_reset_n				: STD_LOGIC := '1';
	SIGNAL slv_avs_address		: STD_LOGIC_VECTOR (c_itg3200_address_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL sl_avs_read			: STD_LOGIC:= '0';
	SIGNAL sl_avs_write			: STD_LOGIC:= '0';
	SIGNAL slv_avs_write_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS =>'0');
	SIGNAL slv_avs_read_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS =>'0');
	SIGNAL slv_avs_byteenable	: STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0) := (OTHERS =>'1');
	
	
	SIGNAL osl_scl				: STD_LOGIC;
	SIGNAL oisl_sda			: STD_LOGIC;
	
	
	
BEGIN
	--create component
	my_unit_under_test : avalon_itg3200_interface 
	GENERIC MAP(
		BASE_CLK => 33000000,
		unique_id => unique_id
	)
	PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n				=> sl_reset_n,
			islv_avs_address 		=> slv_avs_address,
			isl_avs_read 			=> sl_avs_read,
			isl_avs_write			=> sl_avs_write,
			islv_avs_write_data		=> slv_avs_write_data,	
			oslv_avs_read_data		=> slv_avs_read_data,
			islv_avs_byteenable		=> slv_avs_byteenable,
			osl_scl					=> osl_scl,
			oisl_sda				=> oisl_sda
	);
	
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR main_period/2;		

--test id register:
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_typdef_address,c_itg3200_address_width));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(c_itg3200_interface_version,c_fLink_interface_version_length)) 
			REPORT "Interface Version Missmatch" SEVERITY FAILURE;
			
			ASSERT slv_avs_read_data(c_fLink_interface_version_length+c_fLink_subtype_length-1 DOWNTO c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_itg3200_subtype_id,c_fLink_subtype_length)) 
			REPORT "Subtype ID Missmatch" SEVERITY FAILURE;

			ASSERT slv_avs_read_data(c_fLink_avs_data_width-1 DOWNTO c_fLink_interface_version_length+c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_fLink_sensor_id,c_fLink_id_length)) 
			REPORT "Type ID Missmatch" SEVERITY FAILURE;

--test mem size register register:
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_mem_size_address,c_itg3200_address_width));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT to_integer(UNSIGNED(slv_avs_read_data)) = 4*INTEGER(2**c_itg3200_address_width)
			REPORT "Memory Size Error: "&INTEGER'IMAGE(4*INTEGER(2**NR_OF_DATA_REGS))&"/"&INTEGER'IMAGE(to_integer(UNSIGNED(slv_avs_read_data))) 				SEVERITY FAILURE;
--test unique id register:
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_unique_id_address,c_itg3200_address_width));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data = unique_id
			REPORT "Unic Id Error" SEVERITY FAILURE;
			
--test number of channels register:
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_channels_address,c_itg3200_address_width));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(NR_OF_DATA_REGS,c_fLink_interface_version_length)) 
			REPORT "Number of Channels Error" SEVERITY FAILURE;
		
-- send start condition		
		WAIT FOR 100*main_period;
			sl_avs_write <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_configuration_address,c_itg3200_address_width));	
			slv_avs_write_data <= (OTHERS =>'0');
			slv_avs_write_data(0) <= '0';
			slv_avs_write_data(1) <= '1';
		WAIT FOR main_period;
			sl_avs_write <= '0';
			slv_avs_address <= (OTHERS =>'0');
			slv_avs_write_data <= (OTHERS =>'0');
		
		
		WAIT FOR 200000*main_period;
		
		
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(c_usig_data_0_address);				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(c_usig_data_0_address+1);				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(c_usig_data_0_address+2);				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(c_usig_data_0_address+3);				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(c_usig_data_0_address+4);				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
		WAIT FOR 100*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(c_usig_data_0_address+5);				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
		
		
		
		
		
		
		
		
		
		
		
		
			ASSERT false REPORT "End of simulation!!!" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

