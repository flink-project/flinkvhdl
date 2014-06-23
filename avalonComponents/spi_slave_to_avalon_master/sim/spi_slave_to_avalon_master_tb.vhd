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
USE IEEE.math_real.ALL;
USE work.fLink_definitions.ALL;
USE work.spi_slave_to_avalon_master_pkg.ALL;


ENTITY spi_slave_to_avalon_master_tb IS
END ENTITY spi_slave_to_avalon_master_tb;

ARCHITECTURE sim OF spi_slave_to_avalon_master_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT spi_period : TIME := 40 ns; --  25MHz
	
	
	SIGNAL sl_clk					: STD_LOGIC := '0';
	SIGNAL sl_reset_n				: STD_LOGIC := '1';
	
	SIGNAL sl_sclk					: STD_LOGIC := '0';
	SIGNAL sl_ss					: STD_LOGIC := '1';
	SIGNAL sl_mosi					: STD_LOGIC := '0';
	SIGNAL sl_miso					: STD_LOGIC := '0';
	
	
	SIGNAL slv_address		: STD_LOGIC_VECTOR (31 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_read			: STD_LOGIC:= '0';
	SIGNAL slv_write		: STD_LOGIC:= '0';
	SIGNAL slv_readdata		: STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS =>'1');
	SIGNAL slv_writedata	: STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS =>'0');
	SIGNAL slv_waitrequest	: STD_LOGIC:= '0';
	
BEGIN
	--create component
	my_unit_under_test : spi_slave_to_avalon_master 
	GENERIC MAP(
		TRANSFER_WIDTH => 8,
		CPOL => '0',
		CPHA => '0',
		SSPOL => '0'
	)
	PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n				=> sl_reset_n,
			
			isl_sclk				=> sl_sclk,
			isl_ss					=> sl_ss,
			isl_mosi				=> sl_mosi,
			osl_miso				=> sl_miso,
			
			
			oslv_address 			=> slv_address,
			oslv_read 				=> slv_read,
			islv_readdata			=> slv_readdata,
			oslv_write				=> slv_write,	
			oslv_writedata 			=> slv_writedata,
			islv_waitrequest		=> slv_waitrequest
		
	);

	sl_clk 		<= NOT sl_clk after main_period/2;

	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'1';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'0';
		WAIT FOR 100*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 100*main_period;
		
		sl_mosi <='1';
		FOR u IN 0 TO 11 LOOP
				sl_ss <= '0';
				WAIT FOR spi_period;
				FOR i IN 0 TO 15 LOOP
					sl_sclk <= NOT sl_sclk;
					WAIT FOR spi_period;
				END LOOP;
			WAIT FOR 10*main_period;
				sl_sclk <= '0';
				sl_ss <= '1';
			WAIT FOR 100*main_period;
		END LOOP;
		sl_mosi <= '0';
		WAIT FOR 1000*main_period;
		WAIT FOR 1000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

