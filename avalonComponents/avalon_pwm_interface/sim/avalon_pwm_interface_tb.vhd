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
-- Test bench to "Avalon MM interface for PWM"                               --
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
USE work.avalon_pwm_interface_pkg.ALL;

ENTITY avalon_pwm_interface_tb IS
END ENTITY avalon_pwm_interface_tb;

ARCHITECTURE sim OF avalon_pwm_interface_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT number_of_pwms : INTEGER := 3;

	SIGNAL sl_clk					: STD_LOGIC := '0';
	SIGNAL sl_reset_n				: STD_LOGIC := '1';
	SIGNAL slv_avs_address		: STD_LOGIC_VECTOR (c_pwm_interface_address_with-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL sl_avs_read			: STD_LOGIC:= '0';
	SIGNAL sl_avs_write			: STD_LOGIC:= '0';
	SIGNAL slv_avs_write_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_avs_read_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_pwm					: STD_LOGIC_VECTOR(number_of_pwms-1 DOWNTO 0):= (OTHERS =>'0');
	
BEGIN
	--create component
	my_unit_under_test : avalon_pwm_interface 
	GENERIC MAP(
		number_of_pwms =>number_of_pwms
	)
	PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n				=> sl_reset_n,
			islv_avs_address 		=> slv_avs_address,
			isl_avs_read 			=> sl_avs_read,
			isl_avs_write			=> sl_avs_write,
			islv_avs_write_data	=> slv_avs_write_data,	
			oslv_avs_read_data	=> slv_avs_read_data,
			oslv_pwm					=> slv_pwm
	);

	sl_clk 		<= NOT sl_clk after main_period/2;

	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'1';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'0';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR main_period/2;		

--test id register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_typdef_address,c_pwm_interface_address_with));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(c_pwm_interface_version,c_fLink_interface_version_length)) 
			REPORT "Interface Version Missmatch" SEVERITY FAILURE;
			
			ASSERT slv_avs_read_data(c_fLink_interface_version_length+c_fLink_subtype_length-1 DOWNTO c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_pwm_subtype_id,c_fLink_subtype_length)) 
			REPORT "Subtype ID Missmatch" SEVERITY FAILURE;

			ASSERT slv_avs_read_data(c_fLink_avs_data_width-1 DOWNTO c_fLink_interface_version_length+c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_fLink_pwm_out_id,c_fLink_id_length)) 
			REPORT "Type ID Missmatch" SEVERITY FAILURE;

--test mem size register register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_mem_size_address,c_pwm_interface_address_with));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT to_integer(UNSIGNED(slv_avs_read_data)) = 4*INTEGER(2**c_pwm_interface_address_with)
			REPORT "Memory Size Error: "&INTEGER'IMAGE(4*INTEGER(2**number_of_pwms))&"/"&INTEGER'IMAGE(to_integer(UNSIGNED(slv_avs_read_data))) 				SEVERITY FAILURE;

--test number of chanels register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_chanels_address,c_pwm_interface_address_with));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(number_of_pwms,c_fLink_interface_version_length)) 
			REPORT "Number of Channels Error" SEVERITY FAILURE;

	FOR i IN 0 TO number_of_pwms-1 LOOP
	--test frequency register:
		WAIT FOR 1000*main_period;
			sl_avs_write <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_std_registers+1+i,c_pwm_interface_address_with));
			slv_avs_write_data <= STD_LOGIC_VECTOR(to_unsigned(1250+i,c_fLink_avs_data_width));	
		WAIT FOR main_period;
			sl_avs_write <= '0';
			slv_avs_address <= (OTHERS =>'0');
			slv_avs_write_data <= (OTHERS =>'0');
		WAIT FOR main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_std_registers+1+i,c_pwm_interface_address_with));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data = STD_LOGIC_VECTOR(to_unsigned(1250+i,c_fLink_avs_data_width)) 
			REPORT "Wrong frequency was given back" SEVERITY FAILURE;
	--test ratio register:
		WAIT FOR 1000*main_period;
			sl_avs_write <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_std_registers+number_of_pwms+i+1,c_pwm_interface_address_with));
			slv_avs_write_data <= STD_LOGIC_VECTOR(to_unsigned(125+i,c_fLink_avs_data_width));	
		WAIT FOR main_period;
			sl_avs_write <= '0';
			slv_avs_address <= (OTHERS =>'0');
			slv_avs_write_data <= (OTHERS =>'0');
		WAIT FOR main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_std_registers+number_of_pwms+i+1,c_pwm_interface_address_with));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data = STD_LOGIC_VECTOR(to_unsigned(125+i,c_fLink_avs_data_width)) 
			REPORT "Wrong ratio was given back" SEVERITY FAILURE;
	END LOOP;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

