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

USE work.spi_slave_pkg.ALL;

ENTITY spi_slave_rtl_tb IS
END ENTITY spi_slave_rtl_tb;

ARCHITECTURE sim OF spi_slave_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT spi_period : TIME := 100 ns; -- 125MHz
	CONSTANT transf_wdt : INTEGER := 32;
	CONSTANT cpol_sym : STD_LOGIC := '0';
	CONSTANT cpha_sym : STD_LOGIC := '0';
	CONSTANT sspol_sym : STD_LOGIC := '0';
	
	SIGNAL sl_clk				: STD_LOGIC := '0';
	SIGNAL sl_reset_n			: STD_LOGIC := '0';
	SIGNAL slv_tx_data			: STD_LOGIC_VECTOR(transf_wdt-1 DOWNTO 0) := x"ABCD1234";
	SIGNAL slv_rx_data			: STD_LOGIC_VECTOR(transf_wdt-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sl_rx_start			: STD_LOGIC := '0';
	SIGNAL sl_sclk				: STD_LOGIC := cpol_sym;
	SIGNAL slv_Ss				: STD_LOGIC := NOT sspol_sym;
	SIGNAL sl_mosi				: STD_LOGIC := '1';
	SIGNAL sl_miso				: STD_LOGIC := '0';
BEGIN
	--create component
	my_unit_under_test : spi_slave 
	GENERIC MAP(
			TRANSFER_WIDTH 		=> transf_wdt,
			CPOL				=> cpol_sym,
			CPHA				=> cpha_sym,
			SSPOL				=>sspol_sym 
		)
		PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset_n    			=> sl_reset_n,
			
			islv_tx_data			=> slv_tx_data,
			oslv_rx_data			=> slv_rx_data,
			osl_rx_trig				=> sl_rx_start,
			
			isl_sclk				=> sl_sclk,
			isl_ss					=> slv_Ss,
			isl_mosi				=> sl_mosi,
			osl_miso				=> sl_miso
		);
	
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 100*main_period;
			slv_Ss <= sspol_sym;
		WAIT FOR spi_period;
			FOR i IN 0 TO 31 LOOP
				sl_sclk <= not sl_sclk;
				WAIT FOR spi_period;
				sl_sclk <= not sl_sclk;
				WAIT FOR spi_period;
			END LOOP;
		slv_Ss <= not sspol_sym;
		WAIT FOR 2000*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

