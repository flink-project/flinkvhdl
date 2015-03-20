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
-- you may not use this file except in compliance witdh the License.
-- You may obtain a copy of the License at
-- 
-- http://www.apache.org/licenses/LICENSE-2.0
--   
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- witdhOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

USE work.fLink_definitions.ALL;
USE work.info_device_pkg.ALL;

ENTITY info_device_tb IS
END ENTITY info_device_tb;

ARCHITECTURE sim OF info_device_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT dev_size: INTEGER := 128;
	CONSTANT unique_id: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0) := x"00001337";
	CONSTANT description: STD_LOGIC_VECTOR (c_int_number_of_descr_register*c_fLink_avs_data_width-1 DOWNTO 0) := x"000000000000000000000000000000664c696e6b2050726f6a656374"; --fLink Project
	
	SIGNAL sl_clk					: STD_LOGIC := '0';
	SIGNAL sl_reset_n				: STD_LOGIC := '1';
	SIGNAL slv_avs_address		: STD_LOGIC_VECTOR (info_device_address_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL sl_avs_read			: STD_LOGIC:= '0';
	SIGNAL sl_avs_write			: STD_LOGIC:= '0';
	SIGNAL slv_avs_write_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_avs_read_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_avs_byteenable	: STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0):= (OTHERS =>'1');
	
BEGIN
	--create component
	my_unit_under_test : info_device 
	GENERIC MAP(
		unique_id => unique_id,
		description => description,
		dev_size => dev_size
	)
	PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n				=> sl_reset_n,
			islv_avs_address 		=> slv_avs_address,
			isl_avs_read 			=> sl_avs_read,
			isl_avs_write			=> sl_avs_write,
			islv_avs_write_data		=> slv_avs_write_data,	
			oslv_avs_read_data		=> slv_avs_read_data,
			islv_avs_byteenable		=> slv_avs_byteenable	
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
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_typdef_address,info_device_address_width));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(info_device_interface_version,c_fLink_interface_version_length)) 
			REPORT "Interface Version Missmatch" SEVERITY FAILURE;
			
			ASSERT slv_avs_read_data(c_fLink_interface_version_length+c_fLink_subtype_length-1 DOWNTO c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(info_device_subtype_id,c_fLink_subtype_length)) 
			REPORT "Subtype ID Missmatch" SEVERITY FAILURE;

			ASSERT slv_avs_read_data(c_fLink_avs_data_width-1 DOWNTO c_fLink_interface_version_length+c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_fLink_info_id,c_fLink_id_length)) 
			REPORT "Type ID Missmatch" SEVERITY FAILURE;

--test mem size register register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_mem_size_address,info_device_address_width));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT to_integer(UNSIGNED(slv_avs_read_data)) = 4*INTEGER(2**info_device_address_width)
			REPORT "Memory Size Error: "&INTEGER'IMAGE(4*INTEGER(2**info_device_address_width))&"/"&INTEGER'IMAGE(to_integer(UNSIGNED(slv_avs_read_data))) 				SEVERITY FAILURE;
--test unique id register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_unique_id_address,info_device_address_width));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data = unique_id
			REPORT "unique ID Error" SEVERITY FAILURE;
--test number of channels register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_channels_address,info_device_address_width));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(0,c_fLink_interface_version_length)) 
			REPORT "Number of Channels Error" SEVERITY FAILURE;
--test dev_size
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(c_usig_dev_size_address);				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data = STD_LOGIC_VECTOR(to_unsigned(dev_size,c_fLink_avs_data_width)) 
			REPORT "Number of Channels Error" SEVERITY FAILURE;
--test description
		FOR i in c_int_number_of_descr_register-1 DOWNTO 0 LOOP
			WAIT FOR 10*main_period;
				sl_avs_read <= '1';
				slv_avs_address <= STD_LOGIC_VECTOR(c_usig_description_address + to_unsigned(c_int_number_of_descr_register-i-1,info_device_address_width));
			WAIT FOR main_period;
				sl_avs_read <= '0';
				slv_avs_address <= (OTHERS =>'0');
				ASSERT slv_avs_read_data = description((i+1)*32-1 DOWNTO i*32) 
				REPORT "Test Description Error: "&INTEGER'IMAGE(i) SEVERITY FAILURE;
		END LOOP;
		WAIT FOR 10*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

