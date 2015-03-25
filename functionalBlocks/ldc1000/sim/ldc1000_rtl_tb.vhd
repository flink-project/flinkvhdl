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

USE work.ldc1000_pkg.ALL;

ENTITY ldc1000_rtl_tb IS
END ENTITY ldc1000_rtl_tb;

ARCHITECTURE sim OF ldc1000_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 4 ns; -- 250MHz
	
	
	SIGNAL sl_clk				: STD_LOGIC := '0';
	SIGNAL sl_reset_n			: STD_LOGIC := '0';
	
	
	SIGNAL sl_sclk				: STD_LOGIC := '0';
	SIGNAL slv_csb				: STD_LOGIC := '0';
	SIGNAL sl_sdo				: STD_LOGIC := '1';
	SIGNAL sl_sdi				: STD_LOGIC := '0';
	SIGNAL sl_tbclk				: STD_LOGIC := '0';
	
	SIGNAL slv_device_id			: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
	SIGNAL slv_proximity			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
	SIGNAL slv_frequency_counter	: STD_LOGIC_VECTOR(3*REGISTER_WIDTH-1 DOWNTO 0);
	SIGNAL in_config				: t_conf_regs;
	SIGNAL out_config				: t_conf_regs;
	SIGNAL sl_conf_done				: STD_LOGIC := '0';
	SIGNAL sl_OSC_dead				: STD_LOGIC := '0';
	SIGNAL sl_DRDYB					: STD_LOGIC := '0';
	SIGNAL sl_wake_up				: STD_LOGIC := '0';
	SIGNAL sl_comperator			: STD_LOGIC := '0';
	
	
BEGIN
	--create component
	my_unit_under_test : ldc1000 
	GENERIC MAP(
			BASE_CLK 			=> 250000000,
			SCLK_FREQUENCY		=> 4000000
		)
		PORT MAP(
			isl_clk				=> sl_clk,
			isl_reset_n    		=> sl_reset_n,
			
			osl_sclk			=> sl_sclk,
			oslv_csb			=> slv_csb,
			isl_sdo				=> sl_sdo,
			osl_sdi				=> sl_sdi,
			osl_tbclk			=> sl_tbclk,
			
			oslv_device_id 			=> slv_device_id,
			oslv_proximity			=> slv_proximity,
			oslv_frequency_counter	=> slv_frequency_counter,
			it_config				=> in_config,
			ot_config				=> out_config,
			osl_conf_done			=> sl_conf_done,
			osl_OSC_dead			=> sl_OSC_dead,
			osl_DRDYB				=> sl_DRDYB,
			osl_wake_up				=> sl_wake_up,
			osl_comperator			=> sl_comperator		
		);
		
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
			FOR i IN 0 TO t_conf_regs'length-1 LOOP
				in_config(i) <= (OTHERS => '0');
			END LOOP;
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
			WHILE sl_conf_done = '0' LOOP 
				WAIT FOR main_period;
			END LOOP;
			FOR i IN 0 TO t_conf_regs'length-1 LOOP
				in_config(i) <=  out_config(i);
			END LOOP;
			
		WAIT FOR 3000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

