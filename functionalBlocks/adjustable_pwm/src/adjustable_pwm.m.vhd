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
-- Adjustable PWM Signal Generator                                           --
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

-- Based on the PWM block of Marco Tinner from the AirBotOne project

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-------------------------------------------------------------------------------
-- PACKAGE DEFINITION
-------------------------------------------------------------------------------

PACKAGE adjustable_pwm_pkg IS
	
	COMPONENT adjustable_pwm IS
		GENERIC(frequency_resolution : INTEGER := 32);
		PORT (
			sl_clk					: IN  STD_LOGIC;
			sl_reset_n				: IN  STD_LOGIC;
			slv_frequency_divider 	: IN  UNSIGNED(frequency_resolution-1 DOWNTO 0);
			slv_ratio 				: IN  UNSIGNED(frequency_resolution-1 DOWNTO 0);
			sl_pwm 					: OUT STD_LOGIC
		);
	END COMPONENT adjustable_pwm;
	
END PACKAGE adjustable_pwm_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.adjustable_pwm_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------

ENTITY adjustable_pwm IS
	GENERIC(frequency_resolution : INTEGER := 32);
	PORT (
			sl_clk					: IN  STD_LOGIC;
			sl_reset_n				: IN  STD_LOGIC;
			slv_frequency_divider 	: IN  UNSIGNED(frequency_resolution-1 DOWNTO 0); -- pwm frequency divider for example if this value is 2 the pwm output frequency is f_sl_clk/2
			slv_ratio 				: IN  UNSIGNED(frequency_resolution-1 DOWNTO 0); -- the high time part in clk cyles this value has alway to be smaller than the slv_frequency_divider
			sl_pwm 					: OUT STD_LOGIC
	);
	
END ENTITY adjustable_pwm;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------

ARCHITECTURE rtl OF adjustable_pwm IS
	
	SIGNAL cycle_counter : UNSIGNED(frequency_resolution-1 DOWNTO 0) := (OTHERS => '0');
	
BEGIN
	
	proc : PROCESS (sl_reset_n,sl_clk)
	BEGIN
	
	IF sl_reset_n = '0' THEN
		sl_pwm <= '0';
		cycle_counter <= (OTHERS => '0');
	ELSIF rising_edge(sl_clk) THEN
		IF slv_ratio > slv_frequency_divider THEN
			sl_pwm <= '0';
			cycle_counter <= (OTHERS => '0');
		ELSIF cycle_counter >= slv_frequency_divider THEN
			sl_pwm <= '0';
			cycle_counter <= (OTHERS => '0');
		ELSIF cycle_counter < slv_ratio THEN
			sl_pwm <= '1';
			cycle_counter <= cycle_counter + 1;
		ELSE
			sl_pwm <= '0';
			cycle_counter <= cycle_counter + 1;
		END IF;
	END IF;
	END PROCESS proc;
	
END ARCHITECTURE rtl;
