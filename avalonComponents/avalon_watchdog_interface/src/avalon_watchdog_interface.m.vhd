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
	CONSTANT c_max_number_of_watchdogs : INTEGER := 8;

	COMPONENT avalon_watchdog_interface IS
			GENERIC (
				number_of_watchdogs: INTEGER RANGE 1 TO c_max_number_of_watchdogs:= 1;
				base_clk: INTEGER := 125000000
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_watchdog_interface_address_with-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					oslv_avs_read_data		: OUT	STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_signals_to_check	: IN STD_LOGIC_VECTOR(number_of_watchdogs-1 DOWNTO 0);
					osl_granted				: OUT STD_LOGIC
			);
	END COMPONENT;

	CONSTANT c_watchdog_subtype_id : INTEGER := 0;
	CONSTANT c_watchdog_interface_version : INTEGER := 0;


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
		number_of_watchdogs: INTEGER RANGE 1 TO c_max_number_of_watchdogs:= 1;
		base_clk: INTEGER := 125000000
	);
	PORT (
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			islv_avs_address		: IN STD_LOGIC_VECTOR(c_watchdog_interface_address_with-1 DOWNTO 0);
			isl_avs_read			: IN STD_LOGIC;
			isl_avs_write			: IN STD_LOGIC;
			islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			oslv_avs_read_data		: OUT	STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			islv_signals_to_check	: IN STD_LOGIC_VECTOR(number_of_watchdogs-1 DOWNTO 0);
			osl_granted				: OUT STD_LOGIC
	);

	CONSTANT c_usig_base_clk_address: UNSIGNED(c_watchdog_interface_address_with-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_watchdog_interface_address_with);
	CONSTANT c_usig_counter_set_address: UNSIGNED(c_watchdog_interface_address_with-1 DOWNTO 0) := c_usig_base_clk_address + 1;
	CONSTANT c_usig_wd_conf_address: UNSIGNED(c_watchdog_interface_address_with-1 DOWNTO 0) := c_usig_counter_set_address + number_of_watchdogs;
	CONSTANT c_usig_wd_max_address: UNSIGNED(c_watchdog_interface_address_with-1 DOWNTO 0) := c_usig_wd_conf_address + number_of_watchdogs;
	CONSTANT ONES : STD_LOGIC_VECTOR(number_of_watchdogs-1 DOWNTO 0) := (OTHERS => '1');
	
END ENTITY avalon_watchdog_interface;

ARCHITECTURE rtl OF avalon_watchdog_interface IS
	Type t_counter_regs IS ARRAY(number_of_watchdogs-1 DOWNTO 0) OF UNSIGNED(c_fLink_avs_data_width-1 DOWNTO 0);

	TYPE t_internal_register IS RECORD
			counter_regs				: t_counter_regs;
			clk_pols				: STD_LOGIC_VECTOR(number_of_watchdogs-1 DOWNTO 0);
			wd_reset_n 				: STD_LOGIC_VECTOR(number_of_watchdogs-1 DOWNTO 0);
			global_reset_n			: STD_LOGIC;
	END RECORD;

	SIGNAL ri,ri_next : t_internal_register;
	SIGNAL granted : STD_LOGIC_VECTOR(number_of_watchdogs-1 DOWNTO 0);
BEGIN
	gen_wd:
	FOR i IN 0 TO number_of_watchdogs-1 GENERATE
		my_wd : watchdog 
			GENERIC MAP (gi_counter_resolution =>c_fLink_avs_data_width)
			PORT MAP (isl_clk,ri.wd_reset_n(i),islv_signals_to_check(i),ri.clk_pols(i),ri.counter_regs(i),granted(i));
	END GENERATE gen_wd;

	
	
	-- cobinatoric process
	comb_proc : PROCESS (isl_reset_n,ri,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data,granted)
		VARIABLE vi :	t_internal_register;
		VARIABLE watchdog_part_nr: INTEGER := 0;
	BEGIN
		-- keep variables stable
		vi := ri;	

		--standard values
		oslv_avs_read_data <= (OTHERS => '0');
		vi.wd_reset_n := (OTHERS => '1');
		vi.global_reset_n := '1';
		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			IF UNSIGNED(islv_avs_address) = to_unsigned(c_fLink_configuration_address,c_watchdog_interface_address_with) THEN
				vi.global_reset_n := NOT islv_avs_write_data(0);		
			ELSIF UNSIGNED(islv_avs_address)>= c_usig_counter_set_address AND UNSIGNED(islv_avs_address)< c_usig_wd_conf_address THEN
					watchdog_part_nr := to_integer(UNSIGNED(islv_avs_address)-c_usig_counter_set_address); 		
					vi.counter_regs(watchdog_part_nr)  := unsigned(islv_avs_write_data);
			ELSIF UNSIGNED(islv_avs_address)>= c_usig_wd_conf_address AND UNSIGNED(islv_avs_address)< c_usig_wd_max_address THEN
					watchdog_part_nr := to_integer(UNSIGNED(islv_avs_address)-c_usig_wd_conf_address);
					vi.clk_pols(watchdog_part_nr) := islv_avs_write_data(1);
					vi.wd_reset_n(watchdog_part_nr) :=  NOT islv_avs_write_data(0);
			END IF;
		END IF;

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE UNSIGNED(islv_avs_address) IS
				WHEN to_unsigned(c_fLink_typdef_address,c_watchdog_interface_address_with) =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_watchdog_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(c_watchdog_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(c_watchdog_interface_version,c_fLink_interface_version_length));
				WHEN to_unsigned(c_fLink_mem_size_address,c_watchdog_interface_address_with) => 
					oslv_avs_read_data(c_watchdog_interface_address_with+2) <= '1';
				WHEN to_unsigned(c_fLink_number_of_chanels_address,c_watchdog_interface_address_with) => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(number_of_watchdogs,c_fLink_avs_data_width));
				WHEN c_usig_base_clk_address =>
					oslv_avs_read_data <= std_logic_vector(to_unsigned(base_clk,c_fLink_avs_data_width));
				WHEN OTHERS => 
					IF UNSIGNED(islv_avs_address)>= c_usig_counter_set_address AND UNSIGNED(islv_avs_address)< c_usig_wd_conf_address THEN
						watchdog_part_nr := to_integer(UNSIGNED(islv_avs_address)-c_usig_counter_set_address); 		
						oslv_avs_read_data <= std_logic_vector(vi.counter_regs(watchdog_part_nr));
					ELSIF UNSIGNED(islv_avs_address)>= c_usig_wd_conf_address AND UNSIGNED(islv_avs_address)< c_usig_wd_max_address THEN
							watchdog_part_nr := to_integer(UNSIGNED(islv_avs_address)-c_usig_wd_conf_address);
							oslv_avs_read_data(0) <= not vi.wd_reset_n(watchdog_part_nr);
							oslv_avs_read_data(1) <= vi.clk_pols(watchdog_part_nr);
					END IF;
			END CASE;
		END IF;

		IF isl_reset_n = '0' OR vi.global_reset_n = '0'  THEN
			FOR i IN 0 TO number_of_watchdogs-1 LOOP
				vi.counter_regs(i) := (OTHERS =>'0');
			END LOOP;
			vi.clk_pols := (OTHERS =>'0');
			vi.wd_reset_n := (OTHERS => '0');
		END IF;
		
		--only if all outputs are set to one set granted signal 
		IF granted = ONES THEN
			osl_granted <= '1';
		ELSE
			osl_granted <= '0';
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

END rtl;









