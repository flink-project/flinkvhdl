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

PACKAGE avalon_watchdog_interface_pkg IS
	CONSTANT c_watchdog_interface_address_width : INTEGER := 5;


	COMPONENT avalon_watchdog_interface IS
			GENERIC (
				base_clk: INTEGER := 125000000;
				unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_watchdog_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					osl_avs_waitrequest		: OUT STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_watchdog_pwm		: OUT STD_LOGIC;
					osl_granted				: OUT STD_LOGIC
			);
	END COMPONENT;

	CONSTANT c_watchdog_subtype_id : INTEGER := 0;
	CONSTANT c_watchdog_interface_version : INTEGER := 0;

	--addresses
	CONSTANT c_usig_base_clk_address: UNSIGNED(c_watchdog_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_watchdog_interface_address_width);
	CONSTANT c_usig_wd_status_conf_address: UNSIGNED(c_watchdog_interface_address_width-1 DOWNTO 0) := c_usig_base_clk_address + 1;
	CONSTANT c_usig_counter_address: UNSIGNED(c_watchdog_interface_address_width-1 DOWNTO 0) := c_usig_wd_status_conf_address + 1;
	--status reg bits 
	CONSTANT c_int_status_bit: INTEGER := 0;
	CONSTANT c_int_rearm_bit: INTEGER := 1;

END PACKAGE avalon_watchdog_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.avalon_watchdog_interface_pkg.ALL;
USE work.fLink_definitions.ALL;
USE work.watchdog_pkg.ALL;

ENTITY avalon_watchdog_interface IS
	GENERIC (
				base_clk: INTEGER := 125000000;
				unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_watchdog_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					osl_avs_waitrequest		: OUT STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT	STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_watchdog_pwm		: OUT STD_LOGIC;
					osl_granted				: OUT STD_LOGIC
	);

END ENTITY avalon_watchdog_interface;

ARCHITECTURE rtl OF avalon_watchdog_interface IS

	TYPE t_internal_register IS RECORD
			counter_set_reg				: UNSIGNED(c_fLink_avs_data_width-1 DOWNTO 0);
			wd_reset_n 				: STD_LOGIC;
			wd_rearm 				: STD_LOGIC;
			wd_counter_changed		: STD_LOGIC;
			pwm_state				: STD_LOGIC;
			granted					: STD_LOGIC;
			global_reset_n			: STD_LOGIC;
	END RECORD;

	
	SIGNAL ri,ri_next : t_internal_register;
	SIGNAL granted : STD_LOGIC;
	SIGNAL counter_val : UNSIGNED(c_fLink_avs_data_width-1 DOWNTO 0);
	
BEGIN
	
	my_wd : watchdog 
			GENERIC MAP (gi_counter_resolution =>c_fLink_avs_data_width)
			PORT MAP (isl_clk,ri.wd_reset_n,ri.counter_set_reg,ri.wd_counter_changed,ri.wd_rearm,counter_val,granted); 

	-- cobinatoric process
	comb_proc : PROCESS (isl_reset_n,ri,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data,granted,counter_val)
		VARIABLE vi :	t_internal_register;
	BEGIN
		-- keep variables stable
		vi := ri;	
		
		vi.granted := granted;

		--standard values
		oslv_avs_read_data <= (OTHERS => '0');
		vi.wd_reset_n := '1';
		vi.global_reset_n := '1';
		vi.wd_rearm := '0';
		vi.wd_counter_changed := '0';
		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			IF UNSIGNED(islv_avs_address) = to_unsigned(c_fLink_configuration_address,c_watchdog_interface_address_width) THEN
				IF islv_avs_byteenable(0) = '1' THEN
					vi.global_reset_n := NOT islv_avs_write_data(0);		
				END IF;
			ELSIF UNSIGNED(islv_avs_address) = c_usig_wd_status_conf_address THEN
				IF islv_avs_byteenable(0) = '1' THEN
					vi.wd_rearm := islv_avs_write_data(c_int_rearm_bit);
				END IF;
			ELSIF UNSIGNED(islv_avs_address) = c_usig_counter_address THEN
				FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
					IF islv_avs_byteenable(i) = '1' THEN
							vi.counter_set_reg((i + 1) * 8 - 1 DOWNTO i * 8) := UNSIGNED(islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8));
					END IF;
				END LOOP;
				vi.wd_counter_changed := '1';
				IF granted = '1' THEN
					vi.pwm_state := NOT vi.pwm_state;
				END IF;
			END IF;
		END IF;

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE UNSIGNED(islv_avs_address) IS
				WHEN to_unsigned(c_fLink_typdef_address,c_watchdog_interface_address_width) =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_watchdog_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(c_watchdog_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(c_watchdog_interface_version,c_fLink_interface_version_length));
				WHEN to_unsigned(c_fLink_mem_size_address,c_watchdog_interface_address_width) => 
					oslv_avs_read_data(c_watchdog_interface_address_width+2) <= '1';
				WHEN to_unsigned(c_fLink_number_of_channels_address,c_watchdog_interface_address_width) => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(1,c_fLink_avs_data_width));
				WHEN to_unsigned(c_fLink_unique_id_address,c_watchdog_interface_address_width) => 
					oslv_avs_read_data <= unique_id;
				WHEN c_usig_base_clk_address =>
					oslv_avs_read_data <= std_logic_vector(to_unsigned(base_clk,c_fLink_avs_data_width));
				WHEN c_usig_wd_status_conf_address =>
					oslv_avs_read_data(c_int_status_bit) <= vi.granted;
				WHEN c_usig_counter_address =>
					oslv_avs_read_data <= std_logic_vector(counter_val);
				WHEN OTHERS => 
			END CASE;
		END IF;

		IF isl_reset_n = '0' OR vi.global_reset_n = '0'  THEN
			vi.counter_set_reg := (OTHERS =>'0');
			vi.wd_reset_n := '0';
			vi.wd_rearm := '0';
			vi.wd_counter_changed := '0';
			vi.pwm_state := '0';
			vi.granted := '0';
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
	osl_watchdog_pwm <= ri.pwm_state;
	osl_granted <= ri.granted;
END rtl;









