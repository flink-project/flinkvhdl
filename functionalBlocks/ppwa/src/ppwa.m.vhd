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
PACKAGE ppwa_pkg IS
	
	COMPONENT ppwa IS
		GENERIC(
			counter_resolution : INTEGER := 32
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			isl_measure_signal 		: IN STD_LOGIC;
			ousig_period_count		: OUT UNSIGNED(counter_resolution - 1 DOWNTO 0);
			ousig_hightime_count	: OUT UNSIGNED(counter_resolution - 1 DOWNTO 0)
		);
	END COMPONENT ppwa;

END PACKAGE ppwa_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.ppwa_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY ppwa IS
		GENERIC(
			counter_resolution : INTEGER := 32
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			isl_measure_signal 		: IN STD_LOGIC;
			ousig_period_count		: OUT UNSIGNED(counter_resolution - 1 DOWNTO 0);
			ousig_hightime_count	: OUT UNSIGNED(counter_resolution - 1 DOWNTO 0)
		);
END ENTITY ppwa;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF ppwa IS

	TYPE t_internal_register IS RECORD
		-- synchronize signals 
		sl_measure_signal_1		: STD_LOGIC;
		sl_measure_signal_2		: STD_LOGIC;
		usig_counter_running	: UNSIGNED(counter_resolution - 1 DOWNTO 0);
		usig_counter_period		: UNSIGNED(counter_resolution - 1 DOWNTO 0);
		usig_counter_high		: UNSIGNED(counter_resolution - 1 DOWNTO 0);
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;
	
	BEGIN
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,isl_measure_signal)
		
		VARIABLE vi: t_internal_register;
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			-- input buffer, to synchronize asynchronous inputs
			vi.sl_measure_signal_2 := vi.sl_measure_signal_1;
			vi.sl_measure_signal_1 := isl_measure_signal;
            
			vi.usig_counter_running := vi.usig_counter_running + 1;
			
			
			IF vi.sl_measure_signal_2 = '0' AND vi.sl_measure_signal_1 = '1' THEN --rising edge
					vi.usig_counter_period := vi.usig_counter_running;
					vi.usig_counter_running  := (OTHERS => '0');
			ELSIF vi.sl_measure_signal_2 = '1' AND vi.sl_measure_signal_1 = '0' THEN --falling edge
					vi.usig_counter_high := vi.usig_counter_running;
			END IF;
			
            -- reset
            IF isl_reset_n = '0' THEN
				 vi.usig_counter_period := (OTHERS => '0');	
				 vi.usig_counter_high := (OTHERS => '0');	
                 vi.usig_counter_running  := (OTHERS => '0');
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

		--------------------------------------------
		-- output assignment
		--------------------------------------------
		ousig_period_count <= ri.usig_counter_period;
		ousig_hightime_count <= ri.usig_counter_high;
		
END ARCHITECTURE rtl;


