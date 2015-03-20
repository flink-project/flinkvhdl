-------------------------------------------------------------------------------
--  _________     _____      _____    ____  _____    ___  ____               --
-- |_   ___  |  |_   _|     |_   _|  |_   \|_   _|  |_  ||_  _|              --
--   | |_  \_|    | |         | |      |   \ | |      | |_/ /                --
--   |  _|        | |   _     | |      | |\ \| |      |  __'.                --
--  _| |_        _| |__/ |   _| |_    _| |_\   |_    _| |  \ \_              --
-- |_____|      |________|  |_____|  |_____|\____|  |____||____|             --
--                                                                           --
-------------------------------------------------------------------------------
--                                                                           --
-- Avalon MM interface for PWM                                               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright 2014 NTB University of Applied Sciences in Technology           --
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
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

USE work.fLink_definitions.ALL;

PACKAGE info_device_pkg IS
	CONSTANT c_int_number_of_descr_register: INTEGER := 7;
	CONSTANT info_device_address_width	: INTEGER := 5;
	
	COMPONENT info_device IS
			GENERIC (
				unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0');
				description: STD_LOGIC_VECTOR (c_int_number_of_descr_register*c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0');
				dev_size: INTEGER := 0
			);
			PORT (
					isl_clk					: IN  STD_LOGIC;
					isl_reset_n				: IN  STD_LOGIC;
					islv_avs_address		: IN  STD_LOGIC_VECTOR(info_device_address_width-1 DOWNTO 0);
					isl_avs_read			: IN  STD_LOGIC;
					isl_avs_write			: IN  STD_LOGIC;
					osl_avs_waitrequest		: OUT STD_LOGIC;
					islv_avs_write_data		: IN  STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0)
			);
	END COMPONENT;
	
	CONSTANT info_device_subtype_id : INTEGER := 0;
	CONSTANT info_device_interface_version : INTEGER := 0;
	
	
	CONSTANT c_usig_typdef_address		: UNSIGNED(info_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_typdef_address,info_device_address_width);
	CONSTANT c_usig_mem_size_address 	: UNSIGNED(info_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_mem_size_address,info_device_address_width);
	CONSTANT c_usig_unique_id_address 	: UNSIGNED(info_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_unique_id_address,info_device_address_width);
	CONSTANT c_usig_dev_size_address	: UNSIGNED(info_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers, info_device_address_width);
	CONSTANT c_usig_description_address	: UNSIGNED(info_device_address_width-1 DOWNTO 0) := c_usig_dev_size_address + 1;
	CONSTANT c_usig_max_address			: UNSIGNED(info_device_address_width-1 DOWNTO 0) := c_usig_dev_size_address + c_int_number_of_descr_register;
	
	
END PACKAGE info_device_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.info_device_pkg.ALL;
USE work.fLink_definitions.ALL;

ENTITY info_device IS
	GENERIC (
		unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0');
		description: STD_LOGIC_VECTOR (c_int_number_of_descr_register*c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0');
		dev_size: INTEGER := 0
	);
	PORT (
			isl_clk					: IN  STD_LOGIC;
			isl_reset_n				: IN  STD_LOGIC;
			islv_avs_address		: IN  STD_LOGIC_VECTOR(info_device_address_width-1 DOWNTO 0);
			isl_avs_read			: IN  STD_LOGIC;
			isl_avs_write			: IN  STD_LOGIC;
			osl_avs_waitrequest		: OUT STD_LOGIC;
			islv_avs_write_data		: IN  STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			islv_avs_byteenable		: IN  STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0)
	);

END ENTITY info_device;

ARCHITECTURE rtl OF info_device IS

BEGIN

	-- combinatoric process
	comb_proc : PROCESS (isl_reset_n,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data,isl_clk)
		VARIABLE description_part: INTEGER := 0;
		VARIABLE address: UNSIGNED(info_device_address_width-1 DOWNTO 0) := to_unsigned(0,info_device_address_width);
	BEGIN
		
		--type conversion
		address := UNSIGNED(islv_avs_address);
		
		--standard values
		oslv_avs_read_data <= (OTHERS => '0');

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE address IS
				WHEN c_usig_typdef_address =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_info_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(info_device_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(info_device_interface_version,c_fLink_interface_version_length));
				WHEN c_usig_mem_size_address => 
					oslv_avs_read_data(info_device_address_width+2) <= '1';
				WHEN c_usig_unique_id_address => 
					oslv_avs_read_data <= unique_id;
				WHEN c_usig_dev_size_address =>
					oslv_avs_read_data <= std_logic_vector(to_unsigned(dev_size,c_fLink_avs_data_width));
				WHEN OTHERS => 
					IF address >= c_usig_description_address AND address <= c_usig_max_address THEN
						description_part := to_integer(address - c_usig_description_address); 
						oslv_avs_read_data <= description(((c_int_number_of_descr_register-description_part))*32-1 DOWNTO (c_int_number_of_descr_register-description_part-1)*32);
					END IF;
			END CASE;
		END IF;

	END PROCESS comb_proc;

	osl_avs_waitrequest <= '0';
END rtl;
