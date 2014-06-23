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

USE work.fqd_pkg.ALL;

ENTITY fqd_rtl_tb IS
END ENTITY fqd_rtl_tb;

ARCHITECTURE sim OF fqd_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT velocity : REAL := 20000.0;--500.0; --1/s
	CONSTANT direction : INTEGER := 1; -- forwards:1 backwards: -1
	CONSTANT enc_tick_per_turn : REAL := 512.0;
	CONSTANT wait_time : TIME := (1.0/velocity/enc_tick_per_turn/4.0)*1sec;
	
	SIGNAL sl_clk			: 	STD_LOGIC := '0';
	SIGNAL sl_reset_n		:	STD_LOGIC := '0';
	SIGNAL sl_enc_A			:	STD_LOGIC := '0';
	SIGNAL sl_enc_B			:	STD_LOGIC := '0';
	SIGNAL usig_pos 		: 	UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
	
BEGIN
	--create component
	my_unit_under_test : fqd PORT MAP(
			isl_clk			=> sl_clk,
			isl_reset_n		=> sl_reset_n,
			isl_enc_A		=> sl_enc_A,
			isl_enc_B		=> sl_enc_B,
			ousig_pos		=> usig_pos 
	);

	sl_clk 		<= NOT sl_clk after main_period/2;

	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 1000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;
	
	enc_sim : PROCESS 
	BEGIN
		WHILE TRUE LOOP
			IF direction >= 0 THEN
				sl_enc_A <= '1';
				WAIT FOR wait_time;
				sl_enc_B <= '1';
				WAIT FOR wait_time;	
				sl_enc_A <= '0';
				WAIT FOR wait_time;
				sl_enc_B <= '0';
				WAIT FOR wait_time;
			ELSE
				sl_enc_B <= '1';
				WAIT FOR wait_time;
				sl_enc_A <= '1';
				WAIT FOR wait_time;	
				sl_enc_B <= '0';
				WAIT FOR wait_time;
				sl_enc_A <= '0';
				WAIT FOR wait_time;
			END IF;	
		END LOOP;
	END PROCESS enc_sim;
	
	
	
	
	
END ARCHITECTURE sim;

