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
	CONSTANT signal_to_check_period : TIME := 8 us; -- 125kHz
	CONSTANT resolution : INTEGER := 32;
	
	SIGNAL sl_clk				: 	STD_LOGIC := '0';
	SIGNAL sl_reset_n			:	STD_LOGIC := '0';
	SIGNAL sl_signal_to_check	:	STD_LOGIC := '0';
	SIGNAL sl_clk_pol			:	STD_LOGIC := '1';
	SIGNAL usig_counter			: 	UNSIGNED(resolution-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sl_granted			:  	STD_LOGIC := '0';
BEGIN
	--create component
	my_unit_under_test : watchdog 
	GENERIC MAP(gi_counter_resolution => resolution)
	PORT MAP(
			isl_clk			=> sl_clk,
			isl_reset_n		=> sl_reset_n,
			isl_signal_to_check => sl_signal_to_check,
			isl_clk_pol => sl_clk_pol,
			iusig_counter_set => usig_counter,
			osl_granted => sl_granted
	);
	
	sl_clk 		<= NOT sl_clk after main_period/2;
	sl_signal_to_check  <= NOT sl_signal_to_check after signal_to_check_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 100*main_period;
			usig_counter <= to_unsigned(1000,resolution);
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 2000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

