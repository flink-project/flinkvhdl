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

PACKAGE ldc1000_interface_pkg IS

	CONSTANT c_ldc1000_interface_address_width			: INTEGER := 4;

	COMPONENT ldc1000_interface IS
			GENERIC (
				BASE_CLK: INTEGER := 250000000; 
				SCLK_FREQUENCY : INTEGER := 4000000;
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_ldc1000_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					osl_sclk				: OUT STD_LOGIC;
					oslv_csb				: OUT STD_LOGIC;
					isl_sdo					: IN STD_LOGIC;
					osl_sdi					: OUT STD_LOGIC;
					osl_tbclk				: OUT STD_LOGIC
			);
	END COMPONENT;

	CONSTANT c_ldc1000_subtype_id : STD_LOGIC_VECTOR(c_fLink_subtype_length-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0,c_fLink_subtype_length));
	CONSTANT c_ldc1000_interface_version : STD_LOGIC_VECTOR(c_fLink_interface_version_length-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0,c_fLink_interface_version_length));


END PACKAGE ldc1000_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.ldc1000_interface_pkg.ALL;
USE work.fLink_definitions.ALL;
USE work.ldc1000_pkg.ALL;

ENTITY ldc1000_interface IS
			GENERIC (
				BASE_CLK: INTEGER := 250000000; 
				SCLK_FREQUENCY : INTEGER := 4000000;
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_ldc1000_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					osl_sclk				: OUT STD_LOGIC;
					oslv_csb				: OUT STD_LOGIC;
					isl_sdo					: IN STD_LOGIC;
					osl_sdi					: OUT STD_LOGIC;
					osl_tbclk				: OUT STD_LOGIC
			);

	CONSTANT c_configuration_address:			UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_configuration_address,c_ldc1000_interface_address_width);
	CONSTANT c_status_address:					UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_status_address,c_ldc1000_interface_address_width);
	CONSTANT c_typdef_address :					UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_typdef_address,c_ldc1000_interface_address_width);
	CONSTANT c_mem_size_address:				UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_mem_size_address,c_ldc1000_interface_address_width);
	CONSTANT c_number_of_channels_address: 		UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_channels_address,c_ldc1000_interface_address_width);
	CONSTANT c_unique_id_address: 				UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_unique_id_address,c_ldc1000_interface_address_width);
	
	CONSTANT c_usig_base_clk_address:			UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_ldc1000_interface_address_width);
	CONSTANT c_usig_tbclk_frequency_address:	UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := c_usig_base_clk_address + 1;
	CONSTANT c_usig_Rp_address:					UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := c_usig_tbclk_frequency_address + 1;
	CONSTANT c_usig_min_sens_freq_address:		UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := c_usig_Rp_address + 1;
	CONSTANT c_usig_threshold_address:			UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := c_usig_min_sens_freq_address + 1;
	CONSTANT c_usig_proximity_address:			UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := c_usig_threshold_address + 1;
	CONSTANT c_usig_frequ_cnt_address:			UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := c_usig_proximity_address + 1;
	
	
END ENTITY ldc1000_interface;

ARCHITECTURE rtl OF ldc1000_interface IS

	TYPE t_internal_register IS RECORD
			global_reset_n		: STD_LOGIC;
			ldc_reset_n			: STD_LOGIC;
			config_reg			: t_conf_regs;
			update_config		: STD_LOGIC;
	END RECORD;

	SIGNAL ri,ri_next : t_internal_register;
	SIGNAL out_config : t_conf_regs;
	SIGNAL ldc1000_data	: t_data_regs;
	SIGNAL configuring : STD_LOGIC;
	SIGNAL confi_done : STD_LOGIC;
	
BEGIN
	my_ldc1000 : ldc1000 
		GENERIC MAP (BASE_CLK,SCLK_FREQUENCY)
		PORT MAP (isl_clk,ri.ldc_reset_n,
					osl_sclk,oslv_csb,isl_sdo,osl_sdi,osl_tbclk,					
					ri.config_reg,out_config,ldc1000_data,configuring,ri.update_config,confi_done
				);

				
	-- cobinatoric process
	comb_proc : PROCESS (isl_reset_n,ri,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data,configuring,out_config,ldc1000_data,islv_avs_byteenable,confi_done)
		VARIABLE vi :	t_internal_register;
		VARIABLE address: UNSIGNED(c_ldc1000_interface_address_width-1 DOWNTO 0) := to_unsigned(0,c_ldc1000_interface_address_width);
	BEGIN
		-- keep variables stable
		vi := ri;	

		--standard values
		oslv_avs_read_data <= (OTHERS => '0');
		vi.global_reset_n := '1';
		vi.ldc_reset_n := '1';
		address := UNSIGNED(islv_avs_address);
		vi.update_config := '0';
		
		
		IF confi_done = '1' THEN
			vi.config_reg := out_config;		
		END IF;
		
		
		
		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			CASE address IS
				WHEN c_configuration_address =>
					IF islv_avs_byteenable(0) = '1' THEN
								vi.global_reset_n := NOT islv_avs_write_data(c_fLink_reset_bit_num);
								vi.update_config := islv_avs_write_data(1);
								vi.config_reg.response_time := islv_avs_write_data( 4 DOWNTO 2);
								vi.config_reg.amplitude := islv_avs_write_data( 6 DOWNTO 5);
								
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
						vi.config_reg.intb_mode := islv_avs_write_data( 10 DOWNTO 8);
						vi.config_reg.pwr_mode := islv_avs_write_data(11);
					
					END IF;
				WHEN c_usig_tbclk_frequency_address =>
					FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
						IF islv_avs_byteenable(i) = '1' THEN
							vi.config_reg.frequency_divider((i+1)*8-1 DOWNTO 8*i) := UNSIGNED(islv_avs_write_data((i+1)*8-1 DOWNTO 8*i));
						END IF;
					
					END LOOP;
				WHEN c_usig_Rp_address =>	
					IF islv_avs_byteenable(0) = '1' THEN
								vi.config_reg.rp_min := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
								vi.config_reg.rp_max := islv_avs_write_data(15 DOWNTO 8);
					END IF;
				
				WHEN c_usig_min_sens_freq_address =>
					IF islv_avs_byteenable(0) = '1' THEN
								vi.config_reg.min_sens_freq := islv_avs_write_data(7 DOWNTO 0);
					END IF;
				
				WHEN c_usig_threshold_address =>	
					IF islv_avs_byteenable(0) = '1' THEN
								vi.config_reg.threshold_low_msb := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
								vi.config_reg.threshold_high_msb:= islv_avs_write_data(15 DOWNTO 8);
					END IF;
				WHEN OTHERS => 
			END CASE;
		END IF;

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE address IS
				WHEN c_typdef_address =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_ldc100_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= c_ldc1000_subtype_id;
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  c_ldc1000_interface_version;
				WHEN c_mem_size_address => 
					oslv_avs_read_data(c_ldc1000_interface_address_width+2) <= '1';
				WHEN c_number_of_channels_address => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(1,c_fLink_avs_data_width));
				WHEN c_unique_id_address => 
					oslv_avs_read_data <= UNIQUE_ID;
				WHEN c_usig_base_clk_address =>
					oslv_avs_read_data <= std_logic_vector(to_unsigned(BASE_CLK,c_fLink_avs_data_width));
				WHEN c_configuration_address =>
					oslv_avs_read_data(0) <=  NOT vi.global_reset_n;
					oslv_avs_read_data(1) <= vi.update_config;
					oslv_avs_read_data(4 DOWNTO 2) <= vi.config_reg.response_time;
					oslv_avs_read_data(6 DOWNTO 5) <= vi.config_reg.amplitude;
					oslv_avs_read_data(10 DOWNTO 8) <= vi.config_reg.intb_mode;
					oslv_avs_read_data(11) <= vi.config_reg.pwr_mode;
				WHEN c_status_address =>	
					oslv_avs_read_data(7 DOWNTO 0) <= vi.config_reg.device_id;
					oslv_avs_read_data(8) <= configuring;
					oslv_avs_read_data(9) <= ldc1000_data.comperator;
					oslv_avs_read_data(10) <= ldc1000_data.wake_up;
					oslv_avs_read_data(11) <= ldc1000_data.DRDYB;
					oslv_avs_read_data(12) <= ldc1000_data.OSC_dead;
				WHEN c_usig_tbclk_frequency_address =>	
					oslv_avs_read_data <= STD_LOGIC_VECTOR(vi.config_reg.frequency_divider);
				WHEN c_usig_Rp_address =>
					oslv_avs_read_data(7 DOWNTO 0) <= vi.config_reg.rp_min;
					oslv_avs_read_data(15 DOWNTO 8) <= vi.config_reg.rp_max;
				WHEN c_usig_min_sens_freq_address =>
					oslv_avs_read_data(7 DOWNTO 0) <= vi.config_reg.min_sens_freq;
				WHEN c_usig_threshold_address =>
					oslv_avs_read_data(7 DOWNTO 0) <= vi.config_reg.threshold_low_msb;
					oslv_avs_read_data(15 DOWNTO 8) <= vi.config_reg.threshold_high_msb;
				WHEN c_usig_proximity_address =>
					oslv_avs_read_data(15 DOWNTO 0) <= ldc1000_data.proximity;
				WHEN c_usig_frequ_cnt_address =>	
					oslv_avs_read_data(23 DOWNTO 0) <= ldc1000_data.frequency_counter;
				WHEN OTHERS => 
			END CASE;
		END IF;

		IF isl_reset_n = '0' OR vi.global_reset_n = '0'  THEN
			vi.ldc_reset_n := '0';
			vi.update_config := '0';
			vi.config_reg.device_id := (OTHERS => '0');
			vi.config_reg.rp_max := (OTHERS => '0');
			vi.config_reg.rp_min := (OTHERS => '0');
			vi.config_reg.min_sens_freq := (OTHERS => '0');
			vi.config_reg.threshold_high_msb := (OTHERS => '0');
			vi.config_reg.threshold_low_msb := (OTHERS => '0');
			vi.config_reg.amplitude := (OTHERS => '0');
			vi.config_reg.response_time := (OTHERS => '0');
			vi.config_reg.intb_mode := (OTHERS => '0');
			vi.config_reg.frequency_divider := (OTHERS => '0');
			vi.config_reg.pwr_mode := '0';
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









