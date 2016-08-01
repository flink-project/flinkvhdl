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

USE work.itg3200_pkg.ALL;

ENTITY itg3200_rtl_tb IS
END ENTITY itg3200_rtl_tb;

ARCHITECTURE sim OF itg3200_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 30.3 ns; -- 250MHz
	CONSTANT spi_period : TIME := 10 us; -- 4MHz
		
	SIGNAL sl_clk				: STD_LOGIC := '0';
	SIGNAL sl_reset_n			: STD_LOGIC := '0';
	
	SIGNAL scl				: STD_LOGIC;
	SIGNAL sda				: STD_LOGIC;
	SIGNAL data				: t_data_regs;

BEGIN
	--create component
	my_unit_under_test : itg3200 
	GENERIC MAP(
			BASE_CLK 			=> 250000000
		)
		PORT MAP(
			isl_clk				=> sl_clk,
			isl_reset_n    		=> sl_reset_n,
			
			osl_scl			=> scl,
			oisl_sda			=> sda,
			ot_data				=> data
		);
		
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 10*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 400*spi_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

