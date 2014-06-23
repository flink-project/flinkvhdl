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
PACKAGE spi_slave_pkg IS
	
	COMPONENT spi_slave IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 32;
			CPOL: STD_LOGIC := '0'; -- clock polarity: 0 = The inactive state of SCK is logic zero, 1 = The inactive state of SCK is logic one. 
			CPHA: STD_LOGIC := '0'; -- clock phase 0 = Data is captured on the leading edge of SCK and changed on the trailing edge of SCK. 1 = Data is changed on the leading edge of SCK and captured on the trailing edge of SCK
			SSPOL: STD_LOGIC := '0' -- slave select 0 = slave select zero active. 1 = slave select one active.
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			
			islv_tx_data			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			oslv_rx_data			: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			osl_rx_trig				: OUT STD_LOGIC;
			
			isl_sclk				: IN STD_LOGIC;
			isl_ss					: IN STD_LOGIC;
			isl_mosi				: IN STD_LOGIC;
			osl_miso				: OUT STD_LOGIC
		);
	END COMPONENT spi_slave;

END PACKAGE spi_slave_pkg;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.spi_slave_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY spi_slave IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 32;
			CPOL: STD_LOGIC := '0'; -- clock polarity: 0 = The inactive state of SCK is logic zero, 1 = The inactive state of SCK is logic one. 
			CPHA: STD_LOGIC := '0'; -- clock phase 0 = Data is captured on the leading edge of SCK and changed on the trailing edge of SCK. 1 = Data is changed on the leading edge of SCK and captured on the trailing edge of SCK
									-- the leading edge is always the first edge! If cpol = 0 the leading edge is a rising edge. If cpol = 1 the leading edge is a falling edge.
									-- the trailing edge is always the second edge! If cpol = 0 the trailing edge is a falling edge. If cpol = 1 the training edge is a rising edge. 
			SSPOL: STD_LOGIC := '0' -- slave select 0 = slave select zero active. 1 = slave select one active.
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			
			islv_tx_data			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			oslv_rx_data			: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			osl_rx_trig				: OUT STD_LOGIC;
			
			isl_sclk				: IN STD_LOGIC;
			isl_ss					: IN STD_LOGIC;
			isl_mosi				: IN STD_LOGIC;
			osl_miso				: OUT STD_LOGIC
		);
END ENTITY spi_slave;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF spi_slave IS 


	TYPE t_states IS (idle,run,wait_for_rearm);

	TYPE t_internal_register IS RECORD
		state				:t_states;
		-- synchronize signals 
		sync_sclk_1			: STD_LOGIC;
		sync_sclk_2			: STD_LOGIC;
		sync_sclk_3			: STD_LOGIC;
		sync_ss_1			: STD_LOGIC;
		sync_ss_2			: STD_LOGIC;
		sync_mosi_1			: STD_LOGIC;
		sync_mosi_2			: STD_LOGIC;
		bit_count			: UNSIGNED(6 DOWNTO 0); --Allows a maximum transfer size of 127bit
		rx_trig				: STD_LOGIC;
		rx_buf				: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		tx_buf				: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		miso 				: STD_LOGIC;
		rx_data				: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;

	BEGIN
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,isl_sclk,isl_ss,isl_mosi,islv_tx_data)
		
		VARIABLE vi: t_internal_register;
		
		
		PROCEDURE capture_data IS
		BEGIN
			vi.rx_buf(to_integer(vi.bit_count)) := vi.sync_mosi_2;
		END capture_data;
		
		PROCEDURE change_data IS
		BEGIN
			vi.miso := vi.tx_buf(to_integer(vi.bit_count)); 
		END change_data;
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			-- synchronisation
			vi.sync_sclk_1 := isl_sclk;
			vi.sync_sclk_2 := ri.sync_sclk_1;
			vi.sync_sclk_3 := ri.sync_sclk_2;
			vi.sync_ss_1 := isl_ss;
			vi.sync_ss_2 := ri.sync_ss_1;
			vi.sync_mosi_1 := isl_mosi;
			vi.sync_mosi_2 := ri.sync_mosi_1;
			
			
			--standard values:
			vi.rx_trig := '0';
			
			
			
			CASE vi.state IS
				WHEN idle =>
					IF(vi.sync_ss_2 = SSPOL) THEN
						vi.state := run;
						vi.bit_count := to_unsigned(TRANSFER_WIDTH-1,7);
						vi.rx_buf := (OTHERS => '0');
						vi.tx_buf := islv_tx_data;
					END IF;
				WHEN run =>	
						IF vi.sync_sclk_3 /= vi.sync_sclk_2 THEN --sclk edge
							IF vi.sync_sclk_3 = CPOL THEN --leading edge
								IF CPHA = '0' THEN
									capture_data;
								ELSE
									change_data;
								END IF;
							ELSE -- trailing edge
								IF CPHA = '0' THEN
									change_data;
								ELSE
									capture_data;
								END IF;
								IF vi.bit_count = to_unsigned(0,7) THEN
									vi.state := wait_for_rearm;
									vi.rx_data := vi.rx_buf;
									vi.rx_trig := '1';
								END IF; 
								vi.bit_count := vi.bit_count - 1;
							END IF;
						END IF;
				WHEN wait_for_rearm => 
					IF(vi.sync_ss_2 /= SSPOL) THEN
						vi.state := idle;
					END IF;
				WHEN OTHERS =>
					vi.state := idle;
			END CASE;
				
			
			--reset signal
			IF isl_reset_n = '0' THEN
				vi.state := idle;
				vi.bit_count := (OTHERS => '0');
				vi.rx_buf := (OTHERS => '0');
				vi.tx_buf := (OTHERS => '0');
				vi.miso := '0';
				vi.rx_data := (OTHERS => '0');
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
		
		osl_rx_trig <= ri.rx_trig;
		osl_miso <= ri.miso;
		oslv_rx_data <= ri.rx_data;
END ARCHITECTURE rtl;


