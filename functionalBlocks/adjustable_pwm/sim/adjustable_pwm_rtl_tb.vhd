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
USE work.adjustable_pwm_pkg.ALL;


ENTITY adjustable_pwm_rtl_tb IS
END ENTITY adjustable_pwm_rtl_tb;



ARCHITECTURE sim OF adjustable_pwm_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT frequency_resolution : INTEGER := 32;


	SIGNAL sl_clk						: 	STD_LOGIC := '0';
	SIGNAL sl_reset_n					:	STD_LOGIC := '0';
	SIGNAL slv_frequency_divider	:	UNSIGNED(frequency_resolution-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL slv_ratio					:	UNSIGNED(frequency_resolution-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sl_pwm 						: 	STD_LOGIC := '0';
	
BEGIN
	
	--create component
	my_unit_under_test : adjustable_pwm 
	GENERIC MAP(frequency_resolution => frequency_resolution)
	PORT MAP(
			sl_clk						=> sl_clk,
			sl_reset_n					=> sl_reset_n,
			slv_frequency_divider	=> slv_frequency_divider,
			slv_ratio					=> slv_ratio,
			sl_pwm						=> sl_pwm 
	);

	sl_clk 		<= NOT sl_clk after main_period/2;

	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 1000*main_period;
			slv_frequency_divider <= to_unsigned(125,frequency_resolution);
		WAIT FOR 1000*main_period;
			slv_ratio <= to_unsigned(10,frequency_resolution);
		WAIT FOR 1000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;
	
END ARCHITECTURE sim;

