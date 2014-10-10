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
PACKAGE spi_master_pkg IS
	
	COMPONENT spi_master IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; -- frequency of the isl_clk signal
			SCLK_FREQUENCY : INTEGER := 10000; -- frequency of the osl_sclk signal can not be bigger than BASE_CLK/2;
			CS_SETUP_CYLES : INTEGER := 10; -- number of isl_clk cycles till the first osl_sclk edge is coming out after oslv_Ss is asserted. 
			TRANSFER_WIDTH : INTEGER := 32; -- number of bits per transfer
			NR_OF_SS 	   : INTEGER := 1; -- number of slave selects
			CPOL: STD_LOGIC := '0'; -- clock polarity: 0 = The inactive state of SCK is logic zero, 1 = The inactive state of SCK is logic one. 
			CPHA: STD_LOGIC := '0'; -- clock phase 0 = Data is captured on the leading edge of SCK and changed on the trailing edge of SCK. 1 = Data is changed on the leading edge of SCK and captured on the trailing edge of SCK
			MSBFIRST: STD_LOGIC := '1'; -- msb first = 0 Data is shifted out with the lsb first, msb first = 1 data is shifted out with the msb first.
			SSPOL: STD_LOGIC := '0' -- slave select 0 = slave select zero active. 1 = slave select one active.
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			islv_tx_data			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			isl_tx_start			: IN STD_LOGIC;
			oslv_rx_data			: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			osl_rx_done				: OUT STD_LOGIC;
			islv_ss_activ  			: IN STD_LOGIC_VECTOR(NR_OF_SS-1 DOWNTO 0);
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC_VECTOR(NR_OF_SS-1 DOWNTO 0);
			osl_mosi				: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC
		);
	END COMPONENT spi_master;

END PACKAGE spi_master_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.spi_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY spi_master IS
		GENERIC(
			BASE_CLK : INTEGER := 33000000; -- frequency of the isl_clk signal
			SCLK_FREQUENCY : INTEGER := 10000; -- frequency of the osl_sclk signal can not be bigger than BASE_CLK/2;
			CS_SETUP_CYLES : INTEGER := 10; -- number of isl_clk cycles till the first osl_sclk edge is coming out after oslv_Ss is asserted. 
			TRANSFER_WIDTH : INTEGER := 32; -- number of bits per transfer
			NR_OF_SS 	   : INTEGER := 1; -- number of slave selects
			CPOL: STD_LOGIC := '0'; -- clock polarity: 0 = The inactive state of SCK is logic zero, 1 = The inactive state of SCK is logic one. 
			CPHA: STD_LOGIC := '0'; -- clock phase 0 = Data is captured on the leading edge of SCK and changed on the trailing edge of SCK. 1 = Data is changed on the leading edge of SCK and captured on the trailing edge of SCK
			MSBFIRST: STD_LOGIC := '1'; -- msb first = 0 Data is shifted out with the lsb first, msb first = 1 data is shifted out with the msb first.
			SSPOL: STD_LOGIC := '0' -- slave select 0 = slave select zero active. 1 = slave select one active.
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n    			: IN STD_LOGIC;
			
			islv_tx_data			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); -- data to transmit, should not be changed after tx_start is asserted till rx_done is received
			isl_tx_start			: IN STD_LOGIC; --if this signal is set to one the transmission starts 
			oslv_rx_data			: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); --received data only valid if rx_done is high
			osl_rx_done				: OUT STD_LOGIC; --if this signal goes high the receiving of data is finished
			islv_ss_activ  			: IN STD_LOGIC_VECTOR(NR_OF_SS-1 DOWNTO 0); -- decides which ss line should be active always write a logic high to set the ss active. the block itselve handles the logic level of the ss depending on the sspol value
			
			osl_sclk				: OUT STD_LOGIC;
			oslv_Ss					: OUT STD_LOGIC_VECTOR(NR_OF_SS-1 DOWNTO 0);
			osl_mosi				: OUT STD_LOGIC;
			isl_miso				: IN STD_LOGIC
		);
END ENTITY spi_master;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF spi_master IS

	CONSTANT NR_OF_TICKS_PER_SCLK_EDGE : INTEGER := BASE_CLK/SCLK_FREQUENCY/2;
	CONSTANT CYCLE_COUNTHER_WIDTH : INTEGER := integer(ceil(log2(real(SCLK_FREQUENCY))))+1;
	
	TYPE t_states IS (idle,wait_ss_enable_setup,process_data,wait_ss_disable_setup);


	TYPE t_internal_register IS RECORD
		state				:t_states;
		-- synchronize signals 
		sync_miso_1			: STD_LOGIC;
		sync_miso_2			: STD_LOGIC;
		clk_count 			: UNSIGNED(CYCLE_COUNTHER_WIDTH-1 DOWNTO 0);
		sclk				: STD_LOGIC;
		ss					: STD_LOGIC_VECTOR(NR_OF_SS-1 DOWNTO 0);
		bit_count			: INTEGER;
		mosi				: STD_LOGIC;
		leading_edge		: STD_LOGIC;
		rx_data_buf			: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		rx_done				: STD_LOGIC;
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;
	
	BEGIN
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,isl_tx_start,islv_ss_activ,islv_tx_data,isl_miso)
		
		VARIABLE vi: t_internal_register;
		
		PROCEDURE change_bitcount IS
		BEGIN
			IF MSBFIRST = '0' THEN
				IF vi.bit_count >= TRANSFER_WIDTH-1 THEN
					vi.clk_count := to_unsigned(0,CYCLE_COUNTHER_WIDTH);
					vi.state := wait_ss_disable_setup; 
					vi.bit_count := 0;
				ELSE
					vi.bit_count := vi.bit_count + 1;
				END IF;
			ELSE
				IF vi.bit_count <= 0 THEN
					vi.clk_count := to_unsigned(0,CYCLE_COUNTHER_WIDTH);
					vi.state := wait_ss_disable_setup; 
					vi.bit_count := TRANSFER_WIDTH-1;
				ELSE
					vi.bit_count := vi.bit_count - 1;
				END IF;
			END IF;
		END change_bitcount;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			--standard values
			vi.rx_done := '0';
			
			--synchronisation
			vi.sync_miso_2 := vi.sync_miso_1;
			vi.sync_miso_1 := isl_miso;
			
			
			CASE vi.state IS 
				WHEN idle => 
					vi.mosi := '0';
					vi.ss := (OTHERS => NOT SSPOL);
					vi.sclk := CPOL;
					
					IF isl_tx_start = '1' THEN
						vi.state := wait_ss_enable_setup;
						vi.clk_count := to_unsigned(0,CYCLE_COUNTHER_WIDTH);
						FOR i IN 0 TO NR_OF_SS-1 LOOP
							IF islv_ss_activ(i) = '1' THEN
								vi.ss(i) := SSPOL;
							END IF;
						END LOOP;
						
					END IF;
				WHEN wait_ss_enable_setup => 
					vi.clk_count := vi.clk_count + 1;
					IF vi.clk_count >= CS_SETUP_CYLES THEN
						vi.clk_count := to_unsigned(0,CYCLE_COUNTHER_WIDTH);
						vi.leading_edge := '1';
						vi.rx_data_buf := (OTHERS => '0');
						vi.state := process_data;
					END IF;
				WHEN process_data =>	
					--toggle sclk
					IF vi.clk_count = to_unsigned(0,CYCLE_COUNTHER_WIDTH) THEN
						vi.sclk := NOT vi.sclk;
						vi.clk_count := to_unsigned(NR_OF_TICKS_PER_SCLK_EDGE,CYCLE_COUNTHER_WIDTH);
						IF CPHA = '0' THEN -- clock phase 0 = Data is captured on the leading edge of SCK and changed on the trailing edge of SCK.
							IF vi.leading_edge = '1' THEN
								vi.rx_data_buf(vi.bit_count) := vi.sync_miso_2;
							ELSE --trailing edge
								vi.mosi := islv_tx_data(vi.bit_count);
								change_bitcount;
							END IF;
						ELSE -- clock phase 1 = Data is changed on the leading edge of SCK and captured on the trailing edge of SCK
							IF vi.leading_edge = '1' THEN
								vi.mosi := islv_tx_data(vi.bit_count);
							ELSE --trailing edge
								vi.rx_data_buf(vi.bit_count) := vi.sync_miso_2;
								change_bitcount;
							END IF;
						END IF;
						vi.leading_edge := NOT vi.leading_edge;
					ELSE
						vi.clk_count := vi.clk_count - 1;
					END IF; 
				WHEN wait_ss_disable_setup =>
					IF vi.clk_count >= CS_SETUP_CYLES THEN
						vi.ss := (OTHERS => NOT SSPOL);
						vi.clk_count := to_unsigned(0,CYCLE_COUNTHER_WIDTH);
						vi.state := idle;
						vi.rx_done := '1';
					ELSE
						vi.clk_count := vi.clk_count + 1;
					END IF;
				WHEN OTHERS =>
					vi.state := idle; 
				
			END CASE;
			
			--reset
			IF isl_reset_n = '0' THEN
				vi.state := idle;
				vi.sclk := CPOL;
				vi.clk_count := to_unsigned(0,CYCLE_COUNTHER_WIDTH);
				vi.ss := (OTHERS => NOT SSPOL);
				IF MSBFIRST = '0' THEN
					vi.bit_count := 0;
				ELSE
					vi.bit_count := TRANSFER_WIDTH-1;
				END IF;
				vi.mosi := '0';
				vi.leading_edge := '0';
				vi.rx_data_buf := (OTHERS => '0');
				vi.rx_done := '0';
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
		
		
		--output assignement 
		osl_sclk <= ri.sclk;
		oslv_Ss <= ri.ss;
		osl_mosi <= ri.mosi;
		osl_rx_done <= ri.rx_done;
		oslv_rx_data <= ri.rx_data_buf;
END ARCHITECTURE rtl;


