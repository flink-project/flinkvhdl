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

USE work.eim_slave_pkg.ALL;

ENTITY eim_slave_rtl_tb IS
END ENTITY eim_slave_rtl_tb;

ARCHITECTURE sim OF eim_slave_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 20 ns; -- 50MHz
	CONSTANT transf_wdt : INTEGER := 16;
	
	SIGNAL sl_clk				: STD_LOGIC := '0';
	SIGNAL sl_reset_n			: STD_LOGIC := '0';
	SIGNAL slv_address			: STD_LOGIC_VECTOR(transf_wdt-1 DOWNTO 0) := x"1234";
	SIGNAL sl_cs_n				: STD_LOGIC := '1';
	SIGNAL sl_we_n				: STD_LOGIC := '1';
	SIGNAL sl_oe_n				: STD_LOGIC := '1';
	SIGNAL slv_data				: STD_LOGIC_VECTOR(transf_wdt-1 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL sl_data_ack			: STD_LOGIC := '1';
			
	SIGNAL slv_address_out			: STD_LOGIC_VECTOR(transf_wdt-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL slv_read_data		: STD_LOGIC_VECTOR(transf_wdt-1 DOWNTO 0) := x"ABCD";
	SIGNAL slv_write_data		: STD_LOGIC_VECTOR(transf_wdt-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sl_read_not_write	: STD_LOGIC := '0';
	SIGNAL sl_got_write_data	: STD_LOGIC := '0';
	SIGNAL sl_got_address 		: STD_LOGIC := '0';
	SIGNAL sl_read_data_valid 	: STD_LOGIC := '0';
BEGIN
	--create component
	my_unit_under_test : eim_slave 
	GENERIC MAP(
			TRANSFER_WIDTH 		=> transf_wdt
		)
		PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n    			=> sl_reset_n,
			
			islv_address			=> slv_address,
			isl_cs_n				=> sl_cs_n,
			isl_we_n				=> sl_we_n,
			isl_oe_n				=> sl_oe_n,
			osl_data_ack			=> sl_data_ack,
			ioslv_data				=> slv_data,
			
			oslv_address_out		=> slv_address_out,
			islv_read_data			=> slv_read_data,
			oslv_write_data			=> slv_write_data,
			osl_read_not_write		=> sl_read_not_write,
			osl_got_address			=> sl_got_address,
			osl_got_write_data		=> sl_got_write_data,
			isl_read_data_valid		=> sl_read_data_valid
		);
		

	
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	

		
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'1';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 100*main_period;
		--read transfer
			sl_cs_n <= '0';
			sl_we_n <= '1';
		WAIT FOR 1 ns;
			sl_oe_n <= '0';
		WAIT FOR 2*main_period;	
		WHILE sl_data_ack = '1' LOOP
			WAIT FOR  1 ns;
		END LOOP;
		WAIT FOR 2 ns;	
			sl_oe_n <= '1';
		WAIT FOR 1 ns;	
			sl_cs_n <= '1';
		WAIT FOR 1000*main_period;
		--write transfer 
			slv_data <= x"AFFE";
			sl_cs_n <= '0';
			sl_oe_n <= '1';
		WAIT FOR 3 ns;
			sl_we_n <= '0';
		WAIT FOR 44 ns;	
			sl_we_n <= '1';
		WAIT FOR 3 ns;	
			slv_data <= (OTHERS => 'Z');
			sl_cs_n <= '1';
		WAIT FOR 100*main_period;
		--read transfer
			sl_cs_n <= '0';
			sl_we_n <= '1';
		WAIT FOR 3 ns;
			sl_oe_n <= '0';
		WAIT FOR 44 ns;	
			sl_oe_n <= '1';
		WAIT FOR 3 ns;	
			sl_cs_n <= '1';
			slv_data <= (OTHERS => 'Z');
		WAIT FOR 2000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

	
		tb_data_valid_proc : PROCESS
	BEGIN
		
		IF sl_got_address = '1' THEN
			WAIT FOR main_period/2;
			sl_read_data_valid <= '0';
			WAIT FOR main_period;
			slv_read_data <= x"A132";
			sl_read_data_valid <= '1';
			WAIT FOR main_period;
			sl_read_data_valid <= '0';
		ELSE
			sl_read_data_valid <= '0';
		END IF;
		WAIT FOR main_period;
		
	END PROCESS tb_data_valid_proc;
	
	
END ARCHITECTURE sim;

