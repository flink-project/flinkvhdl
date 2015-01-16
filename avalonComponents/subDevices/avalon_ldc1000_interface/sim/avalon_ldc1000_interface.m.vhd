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
-- Avalon MM interface for the LDC1000 inductance sensor                     --
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

PACKAGE avalon_ldc1000_interface_pkg IS

	CONSTANT c_ldc1000_interface_address_with : INTEGER := 8;
	
	SUBTYPE DATA8_SLV_T				is STD_LOGIC_VECTOR(7 DOWNTO 0);
	SUBTYPE DATA16_SLV_T			is STD_LOGIC_VECTOR(15 DOWNTO 0);
	SUBTYPE DATA32_SLV_T			is STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SUBTYPE FLINK_DATA_SLV_T		is STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
	
	SUBTYPE MODULE_ADDRESS_SLV_T	is STD_LOGIC_VECTOR(c_ldc1000_interface_address_with-1 DOWNTO 0);
	SUBTYPE MODULE_ADDRESS_USIG_T	is UNSIGNED(c_ldc1000_interface_address_with-1 DOWNTO 0);
	
	COMPONENT avalon_ldc1000_interface IS
			GENERIC (
				unice_id: FLINK_DATA_SLV_T := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN    STD_LOGIC;
					isl_reset_n				: IN    STD_LOGIC;
					islv_avs_address		: IN    MODULE_ADDRESS_SLV_T;
					isl_avs_read			: IN    STD_LOGIC;
					isl_avs_write			: IN    STD_LOGIC;
					osl_avs_waitrequest		: OUT   STD_LOGIC;
					islv_avs_write_data		: IN    FLINK_DATA_SLV_T;
					oslv_avs_read_data		: OUT   FLINK_DATA_SLV_T;
					
					-- LDC1000 interface
					isl_cs					: IN	STD_LOGIC;
					isl_sdi					: IN	STD_LOGIC;
					isl_sdo					: OUT	STD_LOGIC;
					isl_sclk				: IN	STD_LOGIC;
					isl_tbclk				: OUT	STD_LOGIC
			);
	END COMPONENT;

	CONSTANT c_ldc1000_subtype_id : INTEGER := 0;
	CONSTANT c_ldc1000_interface_version : INTEGER := 0;


END PACKAGE avalon_ldc1000_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.avalon_ldc1000_interface_pkg.ALL;
USE work.fLink_definitions.ALL;


ENTITY avalon_ldc1000_interface IS

	GENERIC (
		unice_id: FLINK_DATA_SLV_T := (OTHERS => '0')
	);
	PORT (
			isl_clk					: IN    STD_LOGIC;
			isl_reset_n				: IN    STD_LOGIC;
			islv_avs_address		: IN    MODULE_ADDRESS_SLV_T;
			isl_avs_read			: IN    STD_LOGIC;
			isl_avs_write			: IN    STD_LOGIC;
			osl_avs_waitrequest		: OUT   STD_LOGIC;
			islv_avs_write_data		: IN    FLINK_DATA_SLV_T;
			oslv_avs_read_data		: OUT   FLINK_DATA_SLV_T;
			
			-- LDC1000 interface
			isl_cs					: IN	STD_LOGIC;
			isl_sdi					: IN	STD_LOGIC;
			isl_sdo					: OUT	STD_LOGIC;
			isl_sclk				: IN	STD_LOGIC;
			isl_tbclk				: OUT	STD_LOGIC
	);
	
	-- standard registers
	
	CONSTANT c_usig_type_reg_address		: MODULE_ADDRESS_USIG_T	:= to_unsigned(c_fLink_typdef_address, c_ldc1000_interface_address_with);
	CONSTANT c_usig_mem_size_reg_address	: MODULE_ADDRESS_USIG_T	:= to_unsigned(c_fLink_mem_size_address, c_ldc1000_interface_address_with);
	CONSTANT c_usig_channels_reg_address	: MODULE_ADDRESS_USIG_T	:= to_unsigned(c_fLink_number_of_chanels_address, c_ldc1000_interface_address_with);
	CONSTANT c_usig_unice_id_reg_address	: MODULE_ADDRESS_USIG_T	:= to_unsigned(c_fLink_unice_id_address, c_ldc1000_interface_address_with);
	CONSTANT c_usig_status_reg_address		: MODULE_ADDRESS_USIG_T	:= to_unsigned(c_fLink_status_address, c_ldc1000_interface_address_with);
	CONSTANT c_usig_conf_reg_address		: MODULE_ADDRESS_USIG_T	:= to_unsigned(c_fLink_configuration_address, c_ldc1000_interface_address_with);
	
	
	-- LDC1000 registers
	
	CONSTANT c_usig_mask_reg_address	: MODULE_ADDRESS_USIG_T	:= to_unsigned(c_fLink_number_of_std_registers, c_ldc1000_interface_address_with);
	CONSTANT c_int_mask_reg_witdh		: INTEGER				:= 2;
	
	CONSTANT c_usig_res1_reg_address	: MODULE_ADDRESS_USIG_T	:= c_usig_mask_reg_address + to_unsigned(c_int_mask_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_res1_reg_witdh		: INTEGER				:= 2;
	
	CONSTANT c_usig_write_reg_address	: MODULE_ADDRESS_USIG_T	:= c_usig_res1_reg_address + to_unsigned(c_int_res1_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_write_reg_witdh		: INTEGER				:= 2;
	
	CONSTANT c_usig_read_reg_address	: MODULE_ADDRESS_USIG_T	:= c_usig_write_reg_address + to_unsigned(c_int_write_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_read_reg_witdh		: INTEGER				:= 6;
	
	CONSTANT c_usig_res2_reg_address	: MODULE_ADDRESS_USIG_T	:= c_usig_read_reg_address + to_unsigned(c_int_read_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_res2_reg_witdh		: INTEGER				:= 4;
	
	CONSTANT c_usig_p0_reg_address		: MODULE_ADDRESS_USIG_T	:= c_usig_res2_reg_address + to_unsigned(c_int_res2_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_p0_reg_witdh			: INTEGER				:= 2;
	
	CONSTANT c_usig_p1_reg_address		: MODULE_ADDRESS_USIG_T	:= c_usig_p0_reg_address + to_unsigned(c_int_p0_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_p1_reg_witdh			: INTEGER				:= 2;
	
	CONSTANT c_usig_p2_reg_address		: MODULE_ADDRESS_USIG_T	:= c_usig_p1_reg_address + to_unsigned(c_int_p1_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_p2_reg_witdh			: INTEGER				:= 2;
	
	CONSTANT c_usig_p3_reg_address		: MODULE_ADDRESS_USIG_T	:= c_usig_p2_reg_address + to_unsigned(c_int_p2_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_p3_reg_witdh			: INTEGER				:= 2;
	
	CONSTANT c_usig_p4_reg_address		: MODULE_ADDRESS_USIG_T	:= c_usig_p3_reg_address + to_unsigned(c_int_p3_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_p4_reg_witdh			: INTEGER				:= 2;
	
	CONSTANT c_usig_p5_reg_address		: MODULE_ADDRESS_USIG_T	:= c_usig_p4_reg_address + to_unsigned(c_int_p4_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_p5_reg_witdh			: INTEGER				:= 2;
	
	CONSTANT c_usig_res3_reg_address	: MODULE_ADDRESS_USIG_T	:= c_usig_p5_reg_address + to_unsigned(c_int_p5_reg_witdh, c_ldc1000_interface_address_with);
	CONSTANT c_int_res3_reg_witdh		: INTEGER				:= 4;
	
END ENTITY avalon_ldc1000_interface;

ARCHITECTURE rtl OF avalon_ldc1000_interface IS

	TYPE READ_A_T iS ARRAY(0 to 5) OF DATA8_SLV_T;
	TYPE PROXIMITY_A_T iS ARRAY(0 to 5) OF DATA16_SLV_T;

	TYPE t_internal_register IS RECORD
		conf		: FLINK_DATA_SLV_T;
		mask		: DATA16_SLV_T;
		res1		: DATA16_SLV_T;
		write_data	: DATA16_SLV_T;
		read_data	: READ_A_T;
		res2		: DATA32_SLV_T;
		proximity	: PROXIMITY_A_T;
		res3		: DATA32_SLV_T;
	END RECORD;
	
	CONSTANT t_internal_register_default : t_internal_register := (
		(OTHERS => '0'),				-- conf
		(OTHERS => '1'),				-- mask
		(OTHERS => '0'),				-- res1
		(OTHERS => '0'),				-- write_data
		(OTHERS => (OTHERS => '0')),	-- read_data
		(OTHERS => '0'),				-- res2
		(OTHERS => (OTHERS => '0')),	-- proximity
		(OTHERS => '0')					-- res3
	);

	SIGNAL ri,ri_next : t_internal_register;
	
BEGIN
	
	-- combinatoric process
	comb_proc : PROCESS (isl_reset_n, ri, isl_avs_write, islv_avs_address, isl_avs_read, islv_avs_write_data)
		VARIABLE vi :	t_internal_register;
		VARIABLE ldc1000_part_nr: INTEGER := 0;
	BEGIN
		-- keep variables stable
		vi := ri;	
		
		-- set read data to default value
		oslv_avs_read_data <= (OTHERS => '0');
		
		-- avalon slave interface: write part
		IF isl_avs_write = '1' THEN
			CASE UNSIGNED(islv_avs_address) IS
				WHEN c_usig_conf_reg_address  => vi.conf       := islv_avs_write_data;
				WHEN c_usig_mask_reg_address  => vi.mask       := islv_avs_write_data(15 downto 0);
				WHEN c_usig_write_reg_address => vi.write_data := islv_avs_write_data(15 downto 0);
				WHEN OTHERS => -- do nothing
			END CASE;
		END IF;

		-- TODO
		-- read from / write to sensor
		
		-- avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE UNSIGNED(islv_avs_address) IS
			
				-- Read type register
				WHEN c_usig_type_reg_address =>
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length-1) DOWNTO 
					(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_digital_io_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(c_ldc1000_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(c_ldc1000_interface_version,c_fLink_interface_version_length));
				
				-- Read mem size register
				WHEN c_usig_mem_size_reg_address => 
					oslv_avs_read_data(c_ldc1000_interface_address_with + 2) <= '1';
				
				-- Read number of channels register
				WHEN c_usig_channels_reg_address => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(6, c_fLink_avs_data_width));
				
				-- Read unice id register
				WHEN c_usig_unice_id_reg_address => 
					oslv_avs_read_data <= unice_id;
				
				-- Read status register
				WHEN c_usig_status_reg_address =>
					oslv_avs_read_data <= (OTHERS => '0');
					
				-- Read config register
				WHEN c_usig_conf_reg_address =>
					oslv_avs_read_data <= vi.conf;

				WHEN OTHERS =>
					-- do nothing

			END CASE;
		END IF;
		
		IF isl_reset_n = '0' OR  vi.conf(c_fLink_reset_bit_num) = '1' THEN
			vi := t_internal_register_default;
		END IF;
		
		ri_next <= vi;
	
	END PROCESS comb_proc;
	
	reg_proc : PROCESS (isl_clk)
	BEGIN
		IF rising_edge(isl_clk) THEN
			ri <= ri_next;
		END IF;
	END PROCESS reg_proc;
	
	osl_avs_waitrequest <= '0';
	
END rtl;
