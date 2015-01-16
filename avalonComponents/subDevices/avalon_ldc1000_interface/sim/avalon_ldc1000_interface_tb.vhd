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
USE work.avalon_ldc1000_interface_pkg.ALL;

ENTITY avalon_ldc1000_interface_tb IS
END ENTITY avalon_ldc1000_interface_tb;

ARCHITECTURE sim OF avalon_ldc1000_interface_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT number_of_pwms : INTEGER := 3;
	CONSTANT unice_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := x"0070776d"; --fqd
	
	SIGNAL sl_clk					: STD_LOGIC := '0';
	SIGNAL sl_reset_n				: STD_LOGIC := '1';
	SIGNAL slv_avs_address		: MODULE_ADDRESS_SLV_T;
	SIGNAL sl_avs_read			: STD_LOGIC:= '0';
	SIGNAL sl_avs_write			: STD_LOGIC:= '0';
	SIGNAL slv_avs_write_data	: FLINK_DATA_SLV_T;
	SIGNAL slv_avs_read_data	: FLINK_DATA_SLV_T;
	SIGNAL slv_pwm					: STD_LOGIC_VECTOR(number_of_pwms-1 DOWNTO 0):= (OTHERS =>'0');
	
	SIGNAL sl_cs: STD_LOGIC:= '0';
	SIGNAL sl_sdi: STD_LOGIC:= '0';
	SIGNAL sl_sdo: STD_LOGIC:= '0';
	SIGNAL sl_sclk: STD_LOGIC:= '0';
	SIGNAL sl_tbclk: STD_LOGIC:= '0';
	SIGNAL sl_avs_waitrequest: STD_LOGIC:= '0';
BEGIN
	--create component
	my_unit_under_test : avalon_ldc1000_interface 
	GENERIC MAP(
		unice_id => unice_id
	)
	PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n				=> sl_reset_n,
			islv_avs_address 		=> slv_avs_address,
			isl_avs_read 			=> sl_avs_read,
			isl_avs_write			=> sl_avs_write,
			islv_avs_write_data	=> slv_avs_write_data,	
			oslv_avs_read_data	=> slv_avs_read_data,
			osl_avs_waitrequest			=> sl_avs_waitrequest,
			isl_cs	=> sl_cs,
			isl_sdi => sl_sdi,
			isl_sdo => sl_sdo,
			isl_sclk => sl_sclk,
			isl_tbclk => sl_tbclk
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
--test number of chanels register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_chanels_address,c_ldc1000_interface_address_with));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(6,c_fLink_interface_version_length)) 
			REPORT "Number of Channels Error" SEVERITY FAILURE;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

