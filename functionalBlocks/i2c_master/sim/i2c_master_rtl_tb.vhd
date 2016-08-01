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

USE work.i2c_master_pkg.ALL;

ENTITY i2c_master_rtl_tb IS
END ENTITY i2c_master_rtl_tb;

ARCHITECTURE sim OF i2c_master_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 30.3 ns; -- 250MHz

		
	SIGNAL sl_clk				: STD_LOGIC := '0';
	SIGNAL sl_reset_n			: STD_LOGIC := '0';
	
	
	
	
	
	SIGNAL osl_scl : STD_LOGIC;
	SIGNAL oisl_sda : STD_LOGIC := '0';
			
	SIGNAL islv_dev_address : STD_LOGIC_VECTOR(DEV_ADDRESS_WIDTH-1 DOWNTO 0) :=  "1010101";
	SIGNAL islv_register_address : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0)  := (OTHERS => '0');
	SIGNAL islv_write_data : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0)  := (OTHERS => '0');
	SIGNAL oslv_read_data : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
	SIGNAL isl_start_transfer : STD_LOGIC := '0';
	SIGNAL isl_write_n_read	: STD_LOGIC := '0';
	SIGNAL isl_enable_burst_transfer : STD_LOGIC := '1';
	SIGNAL osl_transfer_done : STD_LOGIC; 
	
BEGIN
	--create component
	my_unit_under_test : i2c_master 
	GENERIC MAP(
			BASE_CLK 			=> 250000000
		)
		PORT MAP(
			isl_clk				=> sl_clk,
			isl_reset_n    		=> sl_reset_n,
			
			
			
			osl_scl => osl_scl,
			oisl_sda => oisl_sda,
			--internal signals
			islv_dev_address => islv_dev_address,	
			islv_register_address => islv_register_address,
			islv_write_data => islv_write_data,
			oslv_read_data => oslv_read_data,
			isl_start_transfer => isl_start_transfer, 
			isl_write_n_read => isl_write_n_read,
			isl_enable_burst_transfer => isl_enable_burst_transfer,
			osl_transfer_done => osl_transfer_done
		);
		
		
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 20*main_period;	
			sl_reset_n	<=	'1';
		WAIT FOR 10*main_period;
			isl_start_transfer <= '1';
		WAIT FOR 10*main_period;
			isl_start_transfer <= '0';
		WAIT FOR 1ms;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

