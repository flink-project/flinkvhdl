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
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

-------------------------------------------------------------------------------
-- PACKAGE DEFINITION
-------------------------------------------------------------------------------
PACKAGE watchdog_pkg IS
	
	COMPONENT watchdog IS
		GENERIC(
			gi_counter_resolution : INTEGER := 32
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			isl_signal_to_check		: IN STD_LOGIC;
			isl_clk_pol				: IN STD_LOGIC; --0 = reset counter on rising edge, 1 = reset counter on falling edge
			iusig_counter_set		: IN UNSIGNED(gi_counter_resolution-1 DOWNTO 0);
			osl_granted				: OUT STD_LOGIC
		);
	END COMPONENT watchdog;

END PACKAGE watchdog_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.watchdog_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY watchdog IS
		GENERIC(
			gi_counter_resolution : INTEGER := 32
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			isl_signal_to_check		: IN STD_LOGIC;
			isl_clk_pol				: IN STD_LOGIC;
			iusig_counter_set		: IN UNSIGNED(gi_counter_resolution-1 DOWNTO 0);
			osl_granted				: OUT STD_LOGIC
		);
END ENTITY watchdog;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF watchdog IS

	TYPE t_internal_register IS RECORD
		-- synchronize signals 
		sync_signal_to_check_1			: STD_LOGIC;
		sync_signal_to_check_2			: STD_LOGIC;
		sync_signal_to_check_3			: STD_LOGIC;
		watchdog_fired					: STD_LOGIC;
		granted							: STD_LOGIC;
		counter							: UNSIGNED(gi_counter_resolution-1 DOWNTO 0);
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;
	
	BEGIN
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_signal_to_check, isl_reset_n,iusig_counter_set,isl_clk_pol)
		
		VARIABLE vi: t_internal_register;
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			-- input buffer, to synchronize asynchronous inputs
			vi.sync_signal_to_check_3 := vi.sync_signal_to_check_2;
			vi.sync_signal_to_check_2 := vi.sync_signal_to_check_1;
			vi.sync_signal_to_check_1 := isl_signal_to_check;
			
	
	
			if vi.counter > to_unsigned(0,gi_counter_resolution) THEN
				vi.counter := vi.counter -1;
			END IF;
			 
			
			
			IF	vi.sync_signal_to_check_2 /= vi.sync_signal_to_check_3 AND --edge in signal to check
				vi.sync_signal_to_check_3 = isl_clk_pol AND --only react if edge is the right kind 
				vi.watchdog_fired = '0' -- only reset if watchdog has not fired till the last reset 
			THEN
				vi.counter := iusig_counter_set;
			END IF;
			
			IF vi.counter > to_unsigned(0,gi_counter_resolution) THEN
				vi.granted := '1';
			ELSE
				vi.watchdog_fired := '1';
				vi.granted := '0';
			END IF;
			
            -- reset
            IF isl_reset_n = '0' THEN
                 vi.counter := iusig_counter_set;
				 vi.watchdog_fired := '0';
				 vi.granted := '0';
            END IF;
				
			-- setting outputs
			ri_next <= vi;
			
			
		END PROCESS comb_process;
		
		--------------------------------------------
		-- registered process
		--------------------------------------------
		reg_process: PROCESS (isl_clk)
		BEGIN
			IF rising_edge(isl_clk) THEN
				ri <= ri_next;
			END IF;
		END PROCESS reg_process;
		
		osl_granted <= ri.granted;
		
END ARCHITECTURE rtl;


