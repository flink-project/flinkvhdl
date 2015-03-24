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

PACKAGE avalon_dacad5668_interface_pkg IS

	CONSTANT c_analog_output_interface_address_width			: INTEGER := 5;

	COMPONENT avalon_dacad5668_interface IS
			GENERIC (
				BASE_CLK: INTEGER := 33000000; 
				SCLK_FREQUENCY : INTEGER := 10000000;
				INTERNAL_REFERENCE : STD_LOGIC := '0';  -- '0' = set to internal reference, '1' set to external reference
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_analog_output_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					osl_sclk				: OUT STD_LOGIC;
					oslv_Ss					: OUT STD_LOGIC;
					osl_mosi				: OUT STD_LOGIC;
					osl_LDAC_n				: OUT STD_LOGIC;
					osl_CLR_n				: OUT STD_LOGIC
			);
	END COMPONENT;

	CONSTANT c_dacad5668_subtype_id : STD_LOGIC_VECTOR(c_fLink_subtype_length-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(1,c_fLink_subtype_length));
	CONSTANT c_dacad5668_interface_version : STD_LOGIC_VECTOR(c_fLink_interface_version_length-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0,c_fLink_interface_version_length));


END PACKAGE avalon_dacad5668_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.avalon_dacad5668_interface_pkg.ALL;
USE work.fLink_definitions.ALL;
USE work.dacad5668_pkg.ALL;

ENTITY avalon_dacad5668_interface IS
	GENERIC (
				BASE_CLK: INTEGER := 33000000; 
				SCLK_FREQUENCY : INTEGER := 10000000;
				INTERNAL_REFERENCE : STD_LOGIC := '0';  -- '0' = set to internal reference, '1' set to external reference
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_analog_output_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					osl_sclk				: OUT STD_LOGIC;
					oslv_Ss					: OUT STD_LOGIC;
					osl_mosi				: OUT STD_LOGIC;
					osl_LDAC_n				: OUT STD_LOGIC;
					osl_CLR_n				: OUT STD_LOGIC
			);

	CONSTANT c_configuration_address:		UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_configuration_address,c_analog_output_interface_address_width);
	CONSTANT c_typdef_address :				UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_typdef_address,c_analog_output_interface_address_width);
	CONSTANT c_mem_size_address:			UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_mem_size_address,c_analog_output_interface_address_width);
	CONSTANT c_number_of_channels_address: 	UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_channels_address,c_analog_output_interface_address_width);
	CONSTANT c_unique_id_address: 			UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_unique_id_address,c_analog_output_interface_address_width);
	CONSTANT c_usig_resolution_address:		UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_analog_output_interface_address_width);
	CONSTANT c_usig_value_0_address:		UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := c_usig_resolution_address + 1;
	CONSTANT c_usig_last_address:			UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := c_usig_value_0_address + NUMBER_OF_CHANNELS;

END ENTITY avalon_dacad5668_interface;

ARCHITECTURE rtl OF avalon_dacad5668_interface IS

	TYPE t_internal_register IS RECORD
			global_reset_n		: STD_LOGIC;
			adc_reset_n			: STD_LOGIC;
			set_values			: t_value_regs;
	END RECORD;

	SIGNAL ri,ri_next : t_internal_register;
	
BEGIN
	my_dacad5668 : dacad5668 
		GENERIC MAP (BASE_CLK,SCLK_FREQUENCY,INTERNAL_REFERENCE)
		PORT MAP (isl_clk,ri.adc_reset_n,ri.set_values,osl_LDAC_n,osl_CLR_n,osl_sclk,oslv_Ss,osl_mosi);
	
	-- cobinatoric process
	comb_proc : PROCESS (isl_reset_n,ri,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data)
		VARIABLE vi :	t_internal_register;
		VARIABLE dacad5668_part_nr: INTEGER := 0;
		VARIABLE address: UNSIGNED(c_analog_output_interface_address_width-1 DOWNTO 0) := to_unsigned(0,c_analog_output_interface_address_width);
	BEGIN
		-- keep variables stable
		vi := ri;	

		--standard values
		oslv_avs_read_data <= (OTHERS => '0');
		vi.global_reset_n := '1';
		vi.adc_reset_n := '1';
		address := UNSIGNED(islv_avs_address);
		

		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			IF address = c_configuration_address THEN
				IF islv_avs_byteenable(0) = '1' THEN
							vi.global_reset_n := NOT islv_avs_write_data(c_fLink_reset_bit_num);
				END IF;
			ELSIF address>= c_usig_value_0_address AND address< c_usig_last_address THEN
				dacad5668_part_nr := to_integer(UNSIGNED(islv_avs_address) - c_usig_value_0_address);
				--only 16 bit are needed cause adc resolution is 16
				IF islv_avs_byteenable(0) = '1' THEN
							vi.set_values(dacad5668_part_nr)(7 DOWNTO 0) := islv_avs_write_data(7 DOWNTO 0);
				END IF;
				IF islv_avs_byteenable(1) = '1' THEN
							vi.set_values(dacad5668_part_nr)(15 DOWNTO 8) := islv_avs_write_data(15 DOWNTO 8);
				END IF;
			END IF;
		END IF;

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE address IS
				WHEN c_typdef_address =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_analog_output_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= c_dacad5668_subtype_id;
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  c_dacad5668_interface_version;
				WHEN c_mem_size_address => 
					oslv_avs_read_data(c_analog_output_interface_address_width+2) <= '1';
				WHEN c_number_of_channels_address => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(NUMBER_OF_CHANNELS,c_fLink_avs_data_width));
				WHEN c_unique_id_address => 
					oslv_avs_read_data <= UNIQUE_ID;
				WHEN c_usig_resolution_address =>
					oslv_avs_read_data <= std_logic_vector(to_unsigned(RESOLUTION,c_fLink_avs_data_width));
				WHEN OTHERS => 
					IF address >= c_usig_value_0_address AND address < c_usig_last_address THEN
						dacad5668_part_nr := to_integer(address - c_usig_value_0_address);
						oslv_avs_read_data(RESOLUTION-1 DOWNTO 0) <= std_logic_vector(vi.set_values(dacad5668_part_nr));
					END IF;
			END CASE;
		END IF;

		IF isl_reset_n = '0' OR vi.global_reset_n = '0'  THEN
			vi.adc_reset_n := '0';
			FOR i IN 0 TO NUMBER_OF_CHANNELS-1 LOOP
				vi.set_values(i) := (OTHERS => '0');
			END LOOP;
			
		END IF;
		
		--keep variables stable
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









