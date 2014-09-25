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

USE work.watchdog_pkg.ALL;

ENTITY watchdog_rtl_tb IS
END ENTITY watchdog_rtl_tb;

ARCHITECTURE sim OF watchdog_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT resolution : INTEGER := 32;
	
	SIGNAL sl_clk					: 	STD_LOGIC := '0';
	SIGNAL sl_reset_n				:	STD_LOGIC := '0';
	SIGNAL usig_counter_set 		:	UNSIGNED(resolution-1 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL sl_counter_change 		:	STD_LOGIC := '0'; 
	SIGNAL sl_rearm					:	STD_LOGIC := '0'; 
	SIGNAL sl_counter_val 			:	UNSIGNED(resolution-1 DOWNTO 0) := (OTHERS => '0'); 
	SIGNAL sl_granted 				:	STD_LOGIC := '0'; 
	
BEGIN
	--create component
	my_unit_under_test : watchdog 
	GENERIC MAP(gi_counter_resolution => resolution)
	PORT MAP(
			isl_clk			=> sl_clk,
			isl_reset_n		=> sl_reset_n,
			iusig_counter_set => usig_counter_set,
			isl_counter_change => sl_counter_change,
			isl_rearm => sl_rearm,
			osl_counter_val => sl_counter_val,
			osl_granted => sl_granted
	); 
	

	
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'0';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 2*main_period;
			usig_counter_set <= to_unsigned(100,resolution);
		WAIT FOR 10*main_period;
			ASSERT sl_granted = '0' REPORT "ERROR: Power granted after reset when rearm is not called" SEVERITY FAILURE;
		WAIT FOR 2*main_period;
			sl_counter_change <= '1';
		WAIT FOR 2*main_period;
			sl_counter_change <= '0';
		WAIT FOR 10*main_period;
			ASSERT sl_granted = '0' REPORT "ERROR: Power granted after reset when rearm counter is called" SEVERITY FAILURE;
			ASSERT sl_counter_val = to_unsigned(100,resolution)	REPORT "ERROR: Counter not set after rearm" SEVERITY FAILURE;
		WAIT FOR 10*main_period;
			sl_rearm <= '1';
		WAIT FOR 2*main_period;
			sl_rearm <= '0';
			ASSERT sl_granted = '1' REPORT "ERROR: Power granted not set after rearm" SEVERITY FAILURE;
		WAIT FOR 200*main_period;
			ASSERT sl_granted = '0' REPORT "ERROR: Power granted not set to low after counter is zero" SEVERITY FAILURE;
		WAIT FOR 200*main_period;
			sl_rearm <= '1';
			sl_counter_change <= '1';
		WAIT FOR 2*main_period;
			sl_rearm <= '0';
			sl_counter_change <= '0';
		WAIT FOR 50*main_period;
			sl_counter_change <= '1';
		WAIT FOR 2*main_period;
			sl_counter_change <= '0';
		WAIT FOR 2000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

