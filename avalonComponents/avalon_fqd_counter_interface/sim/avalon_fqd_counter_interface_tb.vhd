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
-- Test bench to "Avalon MM interface for FQD"                               --
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
USE work.avalon_fqd_counter_interface_pkg.ALL;

ENTITY avalon_fqd_counter_interface_tb IS
END ENTITY avalon_fqd_counter_interface_tb;

ARCHITECTURE sim OF avalon_fqd_counter_interface_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT number_of_fqds : INTEGER := 1;
	CONSTANT velocity : REAL := 20000.0;--500.0; --1/s
	CONSTANT direction : INTEGER := 1; -- forwards:1 backwards: -1
	CONSTANT enc_tick_per_turn : REAL := 512.0;
	CONSTANT wait_time : TIME := (1.0 / velocity / enc_tick_per_turn / 4.0) * 1 sec;



	SIGNAL sl_clk					: STD_LOGIC := '0';
	SIGNAL sl_reset_n				: STD_LOGIC := '0';
	SIGNAL slv_avs_address		: STD_LOGIC_VECTOR (c_counter_interface_address_with-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL sl_avs_read			: STD_LOGIC:= '0';
	SIGNAL sl_avs_write			: STD_LOGIC:= '0';
	SIGNAL slv_avs_write_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_avs_read_data	: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_enc_A				: STD_LOGIC_VECTOR(number_of_fqds-1 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_enc_B				: STD_LOGIC_VECTOR(number_of_fqds-1 DOWNTO 0):= (OTHERS =>'0');
	
BEGIN
	--create component
	my_unit_under_test : avalon_fqd_counter_interface 
	GENERIC MAP(
		number_of_fqds =>number_of_fqds
	)
	PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n				=> sl_reset_n,
			islv_avs_address 		=> slv_avs_address,
			isl_avs_read 			=> sl_avs_read,
			isl_avs_write			=> sl_avs_write,
			islv_avs_write_data	=> slv_avs_write_data,	
			oslv_avs_read_data	=> slv_avs_read_data,
			islv_enc_A				=> slv_enc_A,
			islv_enc_B				=> slv_enc_B
	);

	sl_clk 		<= NOT sl_clk after main_period/2;

	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR main_period/2;		

--test id register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_typdef_address,c_counter_interface_address_with));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(c_fqd_interface_version,c_fLink_interface_version_length)) 
			REPORT "Interface Version Missmatch" SEVERITY FAILURE;
			
			ASSERT slv_avs_read_data(c_fLink_interface_version_length+c_fLink_subtype_length-1 DOWNTO c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_fqd_subtype_id,c_fLink_subtype_length)) 
			REPORT "Subtype ID Missmatch" SEVERITY FAILURE;

			ASSERT slv_avs_read_data(c_fLink_avs_data_width-1 DOWNTO c_fLink_interface_version_length+c_fLink_interface_version_length) = STD_LOGIC_VECTOR(to_unsigned(c_fLink_counter_id,c_fLink_id_length)) 
			REPORT "Type ID Missmatch" SEVERITY FAILURE;

--test mem size register register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_mem_size_address,c_counter_interface_address_with));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT to_integer(UNSIGNED(slv_avs_read_data)) = 4*INTEGER(2**c_counter_interface_address_with)
			REPORT "Memory Size Error: "&INTEGER'IMAGE(4*INTEGER(2**ceil(log2(REAL(number_of_fqds*c_number_of_register_per_counter_generic+c_fLink_number_of_std_registers)))))&"/"&INTEGER'IMAGE(to_integer(UNSIGNED(slv_avs_read_data))) 				SEVERITY FAILURE;

--test number of chanels register:
		WAIT FOR 10*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_chanels_address,c_counter_interface_address_with));				
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
			ASSERT slv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) = STD_LOGIC_VECTOR(to_unsigned(number_of_fqds,c_fLink_interface_version_length)) 
			REPORT "Number of Channels Error" SEVERITY FAILURE;

--test number of chanels register:



		WAIT FOR 1000*main_period;
			sl_avs_read <= '1';
			slv_avs_address <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_std_registers,c_counter_interface_address_with));
		WAIT FOR main_period;
			sl_avs_read <= '0';
			slv_avs_address <= (OTHERS =>'0');
		WAIT FOR 1000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

	enc_sim : PROCESS 
	BEGIN
		WHILE TRUE LOOP
			IF direction >= 0 THEN
				slv_enc_A <= (OTHERS => '1');
				WAIT FOR wait_time;
				slv_enc_B <= (OTHERS => '1');
				WAIT FOR wait_time;	
				slv_enc_A <= (OTHERS => '0');
				WAIT FOR wait_time;
				slv_enc_B <= (OTHERS => '0');
				WAIT FOR wait_time;
			ELSE
				slv_enc_B <= (OTHERS => '1');
				WAIT FOR wait_time;
				slv_enc_A <= (OTHERS => '1');
				WAIT FOR wait_time;	
				slv_enc_B <= (OTHERS => '0');
				WAIT FOR wait_time;
				slv_enc_A <= (OTHERS => '0');
				WAIT FOR wait_time;
			END IF;	
		END LOOP;
	END PROCESS enc_sim;







END ARCHITECTURE sim;

