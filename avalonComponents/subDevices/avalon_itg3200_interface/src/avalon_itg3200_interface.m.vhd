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

PACKAGE avalon_itg3200_interface_pkg IS

	CONSTANT c_itg3200_address_width : INTEGER := 5;
	CONSTANT c_itg3200_subtype_id : INTEGER := 3;
	CONSTANT c_itg3200_interface_version : INTEGER := 0;

	COMPONENT avalon_itg3200_interface IS
			GENERIC (
				BASE_CLK: INTEGER := 250000000; 
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_itg3200_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					
					osl_scl				: OUT STD_LOGIC;
					oisl_sda			: INOUT STD_LOGIC
			);
	END COMPONENT;
	
END PACKAGE avalon_itg3200_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.avalon_itg3200_interface_pkg.ALL;
USE work.fLink_definitions.ALL;
USE work.itg3200_pkg.ALL;
USE work.i2c_master_pkg.ALL;

ENTITY avalon_itg3200_interface IS
			GENERIC (
				BASE_CLK: INTEGER := 250000000; 
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_itg3200_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					
					osl_scl				: OUT STD_LOGIC;
					oisl_sda			: INOUT STD_LOGIC
			);

	CONSTANT c_usig_data_0_address: UNSIGNED(c_itg3200_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_itg3200_address_width);
	CONSTANT c_usig_last_address: UNSIGNED(c_itg3200_address_width-1 DOWNTO 0) := c_usig_data_0_address + NR_OF_DATA_REGS;
	
	
END ENTITY avalon_itg3200_interface;

ARCHITECTURE rtl OF avalon_itg3200_interface IS

	TYPE t_internal_register IS RECORD
			global_reset_n		: STD_LOGIC;
			itg3200_reset_n			: STD_LOGIC;
			sl_start	: STD_LOGIC;
	END RECORD;

	SIGNAL ri,ri_next : t_internal_register;
	SIGNAL itg3200_data : t_data_regs;
	
BEGIN
	my_itg3200 : itg3200 
		GENERIC MAP (BASE_CLK)
		PORT MAP (isl_clk,ri.itg3200_reset_n,osl_scl,oisl_sda,ri.sl_start,itg3200_data);

		
		
	-- cobinatoric process
	comb_proc : PROCESS (isl_reset_n,ri,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data,itg3200_data)
		VARIABLE vi :	t_internal_register;
		VARIABLE itg3200_part_nr: INTEGER := 0;
	BEGIN
		-- keep variables stable
		vi := ri;	

		--standard values
		
		oslv_avs_read_data <= (OTHERS => '0');
		vi.global_reset_n := '1';
		vi.itg3200_reset_n := '1';
		vi.sl_start := '0';
		
		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			IF UNSIGNED(islv_avs_address) = to_unsigned(c_fLink_configuration_address,c_itg3200_address_width) THEN
				IF islv_avs_byteenable(0) = '1' THEN
					vi.global_reset_n := NOT islv_avs_write_data(0);	
					vi.sl_start := islv_avs_write_data(1);
				END IF;
			END IF;
		END IF;

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE UNSIGNED(islv_avs_address) IS
				WHEN to_unsigned(c_fLink_typdef_address,c_itg3200_address_width) =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_sensor_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(c_itg3200_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(c_itg3200_interface_version,c_fLink_interface_version_length));
				WHEN to_unsigned(c_fLink_mem_size_address,c_itg3200_address_width) => 
					oslv_avs_read_data(c_itg3200_address_width+2) <= '1';
				WHEN to_unsigned(c_fLink_number_of_channels_address,c_itg3200_address_width) => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(NR_OF_DATA_REGS,c_fLink_avs_data_width));
				WHEN to_unsigned(c_fLink_unique_id_address,c_itg3200_address_width) => 
					oslv_avs_read_data <= UNIQUE_ID;
				WHEN OTHERS => 
					IF UNSIGNED(islv_avs_address)>= c_usig_data_0_address AND UNSIGNED(islv_avs_address)< c_usig_last_address THEN
						itg3200_part_nr := to_integer(UNSIGNED(islv_avs_address) - c_usig_data_0_address);
						oslv_avs_read_data(REGISTER_WIDTH-1 DOWNTO 0) <= itg3200_data(itg3200_part_nr);
					END IF;
			END CASE;
		END IF;

		IF isl_reset_n = '0' OR vi.global_reset_n = '0'  THEN
			vi.itg3200_reset_n := '0';
			vi.sl_start := '0';
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









