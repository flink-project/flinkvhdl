-------------------------------------------------------------------------------
--  _________    _____       _____    ____  _____    ___  ____               --
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

PACKAGE avalon_pwm_interface_pkg IS
	CONSTANT c_max_number_of_PWMs 			: INTEGER := 16; --Depends off the address with and the number of registers per pwm
	CONSTANT c_pwm_interface_address_width	: INTEGER := 6;
	
	COMPONENT avalon_pwm_interface IS
			GENERIC (
				number_of_pwms: INTEGER RANGE 0 TO c_max_number_of_PWMs := 1;
				base_clk: INTEGER := 125000000;
				unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN  STD_LOGIC;
					isl_reset_n				: IN  STD_LOGIC;
					islv_avs_address		: IN  STD_LOGIC_VECTOR(c_pwm_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN  STD_LOGIC;
					isl_avs_write			: IN  STD_LOGIC;
					osl_avs_waitrequest		: OUT STD_LOGIC;
					islv_avs_write_data		: IN  STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					oslv_pwm				: OUT STD_LOGIC_VECTOR(number_of_pwms-1 DOWNTO 0)
			);
	END COMPONENT;
	
	CONSTANT c_pwm_subtype_id : INTEGER := 0;
	CONSTANT c_pwm_interface_version : INTEGER := 0;
	
END PACKAGE avalon_pwm_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.adjustable_pwm_pkg.ALL;
USE work.avalon_pwm_interface_pkg.ALL;
USE work.fLink_definitions.ALL;

ENTITY avalon_pwm_interface IS
	GENERIC (
		number_of_pwms: INTEGER RANGE 0 TO c_max_number_of_PWMs := 1;
		base_clk: INTEGER := 125000000;
		unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
	);
	PORT (
			isl_clk					: IN  STD_LOGIC;
			isl_reset_n				: IN  STD_LOGIC;
			islv_avs_address		: IN  STD_LOGIC_VECTOR(c_pwm_interface_address_width-1 DOWNTO 0);
			isl_avs_read			: IN  STD_LOGIC;
			isl_avs_write			: IN  STD_LOGIC;
			osl_avs_waitrequest		: OUT STD_LOGIC;
			islv_avs_write_data		: IN  STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
			oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			oslv_pwm				: OUT STD_LOGIC_VECTOR(number_of_pwms-1 DOWNTO 0)
	);
	
	CONSTANT c_usig_base_clk_address	: UNSIGNED(c_pwm_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers, c_pwm_interface_address_width);
	CONSTANT c_usig_frequency_address	: UNSIGNED(c_pwm_interface_address_width-1 DOWNTO 0) := c_usig_base_clk_address + 1;
	CONSTANT c_usig_ratio_address		: UNSIGNED(c_pwm_interface_address_width-1 DOWNTO 0) := c_usig_frequency_address + number_of_pwms;
	CONSTANT c_usig_max_address			: UNSIGNED(c_pwm_interface_address_width-1 DOWNTO 0) := c_usig_ratio_address + number_of_pwms;

END ENTITY avalon_pwm_interface;

ARCHITECTURE rtl OF avalon_pwm_interface IS
	Type t_pwm_regs IS ARRAY(number_of_pwms-1 DOWNTO 0) OF UNSIGNED(c_fLink_avs_data_width-1 DOWNTO 0);

	TYPE t_internal_register IS RECORD
		  	frequency_regs				: t_pwm_regs;	  
			ratio_regs					: t_pwm_regs;	
			conf_reg  					: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
	END RECORD;

	SIGNAL pwm_reset_n : STD_LOGIC; 
	SIGNAL ri,ri_next : t_internal_register;

BEGIN
	gen_pwm:
	FOR i IN 0 TO number_of_pwms-1 GENERATE
		my_adjustable_pwm :  adjustable_pwm 
			GENERIC MAP (frequency_resolution =>c_fLink_avs_data_width)
			PORT MAP (isl_clk,pwm_reset_n,ri.frequency_regs(i),ri.ratio_regs(i),oslv_pwm(i));		
	END GENERATE gen_pwm;

	-- combinatorial process
	comb_proc : PROCESS (isl_reset_n,ri,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data,islv_avs_byteenable)
		VARIABLE vi :	t_internal_register;
		
	BEGIN
		-- keep variables stable
		vi := ri;	

		--standard values
		oslv_avs_read_data <= (OTHERS => '0');
		pwm_reset_n <= '1';

		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			IF UNSIGNED(islv_avs_address) = to_unsigned(c_fLink_configuration_address,c_pwm_interface_address_width) THEN
				FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
					IF islv_avs_byteenable(i) = '1' THEN
							vi.conf_reg((i + 1) * 8 - 1 DOWNTO i * 8) := islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8);
					END IF;
				END LOOP;
			ELSIF UNSIGNED(islv_avs_address)>= c_usig_frequency_address AND UNSIGNED(islv_avs_address)< c_usig_ratio_address THEN
				FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
					IF islv_avs_byteenable(i) = '1' THEN
							vi.frequency_regs(to_integer(UNSIGNED(islv_avs_address)-c_usig_frequency_address))((i + 1) * 8 - 1 DOWNTO i * 8) := UNSIGNED(islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8));
					END IF;
				END LOOP;
			ELSIF UNSIGNED(islv_avs_address)>= c_usig_ratio_address AND UNSIGNED(islv_avs_address)< c_usig_max_address THEN 
					FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
						IF islv_avs_byteenable(i) = '1' THEN
							vi.ratio_regs(to_integer(UNSIGNED(islv_avs_address)-c_usig_ratio_address))((i + 1) * 8 - 1 DOWNTO i * 8) := UNSIGNED(islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8));
						END IF;	
					END LOOP;
			END IF;
		END IF;

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE UNSIGNED(islv_avs_address) IS
				WHEN to_unsigned(c_fLink_typdef_address,c_pwm_interface_address_width) =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_pwm_out_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(c_pwm_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(c_pwm_interface_version,c_fLink_interface_version_length));
				WHEN to_unsigned(c_fLink_mem_size_address,c_pwm_interface_address_width) => 
					oslv_avs_read_data(c_pwm_interface_address_width+2) <= '1';
				WHEN to_unsigned(c_fLink_number_of_channels_address,c_pwm_interface_address_width) => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(number_of_pwms,c_fLink_avs_data_width));
				WHEN to_unsigned(c_fLink_configuration_address,c_pwm_interface_address_width) =>
					oslv_avs_read_data <= vi.conf_reg;
				WHEN to_unsigned(c_fLink_unique_id_address,c_pwm_interface_address_width) => 
					oslv_avs_read_data <= unique_id;
				WHEN c_usig_base_clk_address => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(base_clk,c_fLink_avs_data_width));
				WHEN OTHERS => 
					IF UNSIGNED(islv_avs_address)>= c_usig_frequency_address AND UNSIGNED(islv_avs_address)< c_usig_ratio_address THEN
						oslv_avs_read_data <= STD_LOGIC_VECTOR(vi.frequency_regs(to_integer(UNSIGNED(islv_avs_address)-c_usig_frequency_address)));
					ELSIF UNSIGNED(islv_avs_address)>= c_usig_ratio_address AND UNSIGNED(islv_avs_address)< c_usig_max_address THEN 
						oslv_avs_read_data <= STD_LOGIC_VECTOR(vi.ratio_regs(to_integer(UNSIGNED(islv_avs_address)-c_usig_ratio_address)));
					ELSE
						oslv_avs_read_data <= (OTHERS => '0');
					END IF;
			END CASE;
		END IF;

		IF isl_reset_n = '0' OR  vi.conf_reg(c_fLink_reset_bit_num) = '1' THEN
			vi.conf_reg := (OTHERS =>'0');
			pwm_reset_n <= '0';
			FOR i IN 0 TO number_of_pwms-1 LOOP 
				vi.frequency_regs(i) := (OTHERS => '0');
				vi.ratio_regs(i) := (OTHERS => '1');
			END LOOP;
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
