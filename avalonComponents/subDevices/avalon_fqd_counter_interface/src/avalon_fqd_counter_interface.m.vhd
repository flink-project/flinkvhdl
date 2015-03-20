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
-- Avalon MM interface for FQD                                               --
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

PACKAGE avalon_fqd_counter_interface_pkg IS
	CONSTANT c_max_number_of_FQDs : INTEGER := 16; -- Depens off the address width and the number of registers per FQD
	CONSTANT c_counter_interface_address_width			: INTEGER := 5;
	
	
	COMPONENT avalon_fqd_counter_interface IS
			GENERIC (
				number_of_fqds: INTEGER RANGE 0 TO c_max_number_of_FQDs := 1;
				unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN  STD_LOGIC;
					isl_reset_n				: IN  STD_LOGIC;
					islv_avs_address		: IN  STD_LOGIC_VECTOR(c_counter_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN  STD_LOGIC;
					isl_avs_write			: IN  STD_LOGIC;
					osl_avs_waitrequest		: OUT    STD_LOGIC;
					islv_avs_write_data		: IN  STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_enc_A				: IN  STD_LOGIC_VECTOR(number_of_fqds-1 DOWNTO 0);
					islv_enc_B				: IN  STD_LOGIC_VECTOR(number_of_fqds-1 DOWNTO 0)
			);
	END COMPONENT;
	
	CONSTANT c_fqd_subtype_id : INTEGER := 0;
	CONSTANT c_fqd_interface_version : INTEGER := 0;

END PACKAGE avalon_fqd_counter_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.fqd_pkg.ALL;
USE work.avalon_fqd_counter_interface_pkg.ALL;
USE work.fLink_definitions.ALL;


ENTITY avalon_fqd_counter_interface IS
	GENERIC (
		number_of_fqds: INTEGER RANGE 0 TO c_max_number_of_FQDs := 1;
		unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
	);
	PORT (
			isl_clk					: IN  STD_LOGIC;
			isl_reset_n				: IN  STD_LOGIC;
			islv_avs_address		: IN  STD_LOGIC_VECTOR(c_counter_interface_address_width-1 DOWNTO 0);
			isl_avs_read			: IN  STD_LOGIC;
			isl_avs_write			: IN  STD_LOGIC;
			osl_avs_waitrequest		: OUT    STD_LOGIC;
			islv_avs_write_data		: IN  STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
			oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			islv_enc_A				: IN  STD_LOGIC_VECTOR(number_of_fqds-1 DOWNTO 0);
			islv_enc_B				: IN  STD_LOGIC_VECTOR(number_of_fqds-1 DOWNTO 0)
	);
END ENTITY avalon_fqd_counter_interface;

ARCHITECTURE rtl OF avalon_fqd_counter_interface IS
	
	TYPE t_pos_regs IS ARRAY(number_of_fqds-1 DOWNTO 0) OF UNSIGNED(15 DOWNTO 0);
	
	TYPE t_internal_register IS RECORD
		  conf_reg : STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
	END RECORD;
	
	SIGNAL pos_regs    : t_pos_regs;
	SIGNAL fqd_reset_n : STD_LOGIC; 
	SIGNAL ri, ri_next : t_internal_register;
	
	CONSTANT avs_fqd_pos_length : INTEGER := 16;
	
BEGIN
	gen_fqd:
	FOR i IN 0 TO number_of_fqds-1 GENERATE
		my_fqd : fqd 
			GENERIC MAP (gi_pos_length => avs_fqd_pos_length)
			PORT MAP (isl_clk, fqd_reset_n, islv_enc_A(i), islv_enc_B(i), pos_regs(i));
	END GENERATE gen_fqd;
	
	-- cobinatoric process
	comb_proc : PROCESS (isl_reset_n, ri, isl_avs_write, islv_avs_address, isl_avs_read, islv_avs_write_data, pos_regs)
		VARIABLE vi : t_internal_register;
	BEGIN
		-- keep variables stable
		vi := ri;
		
		--standard values
		oslv_avs_read_data <= (OTHERS => '0');
		fqd_reset_n <= '1';
		
		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			IF UNSIGNED(islv_avs_address) = to_unsigned(c_fLink_configuration_address,c_counter_interface_address_width) THEN
				FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
					IF islv_avs_byteenable(i) = '1' THEN
							vi.conf_reg((i + 1) * 8 - 1 DOWNTO i * 8) := islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8);
					END IF;
				END LOOP;
			END IF;
		END IF;
		
		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE UNSIGNED(islv_avs_address) IS
				WHEN to_unsigned(c_fLink_typdef_address,c_counter_interface_address_width) =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_counter_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(c_fqd_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(c_fqd_interface_version,c_fLink_interface_version_length));
				WHEN to_unsigned(c_fLink_mem_size_address,c_counter_interface_address_width) => 
					oslv_avs_read_data(c_counter_interface_address_width+2) <= '1';
				WHEN to_unsigned(c_fLink_number_of_channels_address,c_counter_interface_address_width) => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(number_of_fqds,c_fLink_avs_data_width));
				WHEN to_unsigned(c_fLink_configuration_address,c_counter_interface_address_width) =>
					oslv_avs_read_data <= vi.conf_reg;
				WHEN to_unsigned(c_fLink_unique_id_address,c_counter_interface_address_width) => 
					oslv_avs_read_data <= unique_id;
				WHEN OTHERS => 
					IF UNSIGNED(islv_avs_address)>= to_unsigned(c_fLink_number_of_std_registers,c_counter_interface_address_width) AND 
						UNSIGNED(islv_avs_address)< to_unsigned(c_fLink_number_of_std_registers + number_of_fqds,c_counter_interface_address_width)
					THEN
						oslv_avs_read_data(avs_fqd_pos_length-1 DOWNTO 0) <= STD_LOGIC_VECTOR(pos_regs(to_integer(UNSIGNED(islv_avs_address))-c_fLink_number_of_std_registers));
					ELSE
						oslv_avs_read_data <= (OTHERS => '0');
					END IF;
			END CASE;
		END IF;

		IF isl_reset_n = '0' OR  vi.conf_reg(c_fLink_reset_bit_num) = '1' THEN
			vi.conf_reg := (OTHERS =>'0');
			fqd_reset_n <= '0';
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
