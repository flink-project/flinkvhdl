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
-- Syncronized FQD                                                           --
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
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

-------------------------------------------------------------------------------
-- PACKAGE
-------------------------------------------------------------------------------
PACKAGE fqd_pkg IS
	
	COMPONENT fqd IS
		GENERIC(
			gi_pos_length : INTEGER := 16
		);
		PORT(
			isl_clk			: IN STD_LOGIC;
			isl_reset_n		: IN STD_LOGIC;
			isl_enc_A		: IN STD_LOGIC;
			isl_enc_B		: IN STD_LOGIC;
			ousig_pos		: OUT UNSIGNED(gi_pos_length - 1 DOWNTO 0)
		);
	END COMPONENT fqd;

END PACKAGE fqd_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.fqd_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY fqd IS
		GENERIC(
			gi_pos_length : INTEGER := 16
		);
		PORT (
			isl_clk			: IN STD_LOGIC;
			isl_reset_n		: IN STD_LOGIC;
			isl_enc_A		: IN STD_LOGIC;
			isl_enc_B		: IN STD_LOGIC;
			ousig_pos		: OUT UNSIGNED(gi_pos_length - 1 DOWNTO 0)
		);
END ENTITY fqd;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF fqd IS

	TYPE t_internal_register IS RECORD
		sl_enc_a1			: STD_LOGIC;
		sl_enc_a2			: STD_LOGIC;
		sl_enc_a3			: STD_LOGIC;
		sl_enc_b1			: STD_LOGIC;
		sl_enc_b2			: STD_LOGIC;
		sl_enc_b3			: STD_LOGIC;
		usig_pos 			: UNSIGNED(gi_pos_length - 1 DOWNTO 0);
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;
	
	BEGIN
		
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_enc_A, isl_enc_B, isl_reset_n)
		
		VARIABLE vi: t_internal_register;
		
		BEGIN
			-- keep variables stable
			vi := ri;
			
			-- input buffer for synchronizing asynchronous inputs
			vi.sl_enc_a3 := vi.sl_enc_a2;
			vi.sl_enc_a2 := vi.sl_enc_a1;
			vi.sl_enc_a1 := isl_enc_A;
			
			vi.sl_enc_b3 := vi.sl_enc_b2;
			vi.sl_enc_b2 := vi.sl_enc_b1;
			vi.sl_enc_b1 := isl_enc_B;
			
			-- rising edge of signal a
			IF vi.sl_enc_a2 = '1' AND vi.sl_enc_a3 = '0' THEN
				IF vi.sl_enc_b2 = '0' THEN
					vi.usig_pos := vi.usig_pos  + 1;
				ELSE
					vi.usig_pos := vi.usig_pos  - 1;
				END IF;
			-- falling edge of signal a
			ELSIF vi.sl_enc_a2 = '0' AND vi.sl_enc_a3='1' THEN
				IF vi.sl_enc_b2 = '1' THEN
					vi.usig_pos := vi.usig_pos  + 1;
				ELSE
					vi.usig_pos := vi.usig_pos  - 1;
				END IF;
			-- rising edge of signal b
			ELSIF vi.sl_enc_b2='1' AND vi.sl_enc_b3='0' THEN
				IF vi.sl_enc_a2 = '1' THEN
					vi.usig_pos := vi.usig_pos  + 1;
				ELSE
					vi.usig_pos := vi.usig_pos  - 1;
				END IF;
			-- falling edge of signal b
			ELSIF vi.sl_enc_b2='0' AND vi.sl_enc_b3='1' THEN
				IF vi.sl_enc_a2 = '0' THEN
					vi.usig_pos := vi.usig_pos  + 1;
				ELSE
					vi.usig_pos := vi.usig_pos  - 1;
				END IF;
			END IF;
			
			-- reset
			IF isl_reset_n = '0' THEN
				vi.usig_pos := (OTHERS => '0');
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
		-- output asignement
		--------------------------------------------
		ousig_pos <= ri.usig_pos ;
		
END ARCHITECTURE rtl;
