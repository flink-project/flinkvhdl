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
PACKAGE spi_slave_to_avalon_master_pkg IS
	CONSTANT address_with : INTEGER := 32;
	
	COMPONENT spi_slave_to_avalon_master IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 8;
			CPOL: STD_LOGIC := '0'; -- clock polarity: 0 = The inactive state of SCK is logic zero, 1 = The inactive state of SCK is logic one. 
			CPHA: STD_LOGIC := '0'; -- clock phase 0 = Data is captured on the leading edge of SCK and changed on the trailing edge of SCK. 1 = Data is changed on the leading edge of SCK and captured on the trailing edge of SCK
			SSPOL: STD_LOGIC := '0' -- slave select 0 = slave select zero active. 1 = slave select one active.
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			--spi_interface
			isl_sclk				: IN STD_LOGIC;
			isl_ss					: IN STD_LOGIC;
			isl_mosi				: IN STD_LOGIC;
			osl_miso				: OUT STD_LOGIC;
			--avalon master
			oslv_address	:  	OUT STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
			oslv_read		:  	OUT STD_LOGIC;
			islv_readdata	:  	IN  STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
			oslv_write 		:  	OUT STD_LOGIC;
			oslv_writedata	:  	OUT STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
			islv_waitrequest:  	IN STD_LOGIC
		);
	END COMPONENT spi_slave_to_avalon_master;
	
END PACKAGE spi_slave_to_avalon_master_pkg;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.spi_slave_to_avalon_master_pkg.ALL;
USE work.spi_slave_pkg.ALL;

ENTITY spi_slave_to_avalon_master IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 8;
			CPOL: STD_LOGIC := '0'; -- clock polarity: 0 = The inactive state of SCK is logic zero, 1 = The inactive state of SCK is logic one. 
			CPHA: STD_LOGIC := '0'; -- clock phase 0 = Data is captured on the leading edge of SCK and changed on the trailing edge of SCK. 1 = Data is changed on the leading edge of SCK and captured on the trailing edge of SCK
			SSPOL: STD_LOGIC := '0' -- slave select 0 = slave select zero active. 1 = slave select one active.
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			--spi_interface
			isl_sclk				: IN STD_LOGIC;
			isl_ss					: IN STD_LOGIC;
			isl_mosi				: IN STD_LOGIC;
			osl_miso				: OUT STD_LOGIC;
			--avalon master
			oslv_address	:  	OUT STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
			oslv_read		:  	OUT STD_LOGIC;
			islv_readdata	:  	IN  STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
			oslv_write 		:  	OUT STD_LOGIC;
			oslv_writedata	:  	OUT STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
			islv_waitrequest:  	IN STD_LOGIC
		);
		
END ENTITY spi_slave_to_avalon_master;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF spi_slave_to_avalon_master IS 

	TYPE t_states IS (	idle,
						read_address_byte_0,read_address_byte_1,read_address_byte_2,
						write_address_byte_0, write_address_byte_1,write_address_byte_2,write_address_byte_3,
						write_data_byte_0, write_data_byte_1,write_data_byte_2,write_data_byte_3
					  );
	TYPE t_avalon_states IS (idle,start_read_data,save_read_data,start_write_data,end_write_data);

	TYPE t_internal_register IS RECORD
		state				: t_states;
		avalon_state		: t_avalon_states;
		spi_tx_data 		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		avalon_address		: STD_LOGIC_VECTOR(address_with-1 DOWNTO 0);
		avalon_writedata	: STD_LOGIC_VECTOR(address_with-1 DOWNTO 0);
		readaddress			: STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
		readdata			: STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
		read				: STD_LOGIC;
		write				: STD_LOGIC;
		writeaddress		: STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
		writedata			: STD_LOGIC_VECTOR (address_with-1 DOWNTO 0);
		
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;
	SIGNAL spi_rx_data :STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
	SIGNAL spi_rx_trig :STD_LOGIC;
	BEGIN
	
	my_spi : spi_slave 
		GENERIC MAP(TRANSFER_WIDTH,CPOL,CPHA,SSPOL)
		PORT MAP(isl_clk,isl_reset_n,ri.spi_tx_data,spi_rx_data,spi_rx_trig,isl_sclk,isl_ss,isl_mosi,osl_miso);

		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,spi_rx_trig,spi_rx_data,islv_waitrequest,islv_readdata)
		
		VARIABLE vi: t_internal_register;

		BEGIN
			-- keep variables stable
			vi:=ri;

			CASE vi.state IS
				WHEN idle =>
					vi.spi_tx_data := (OTHERS => '0');
					IF spi_rx_trig = '1' THEN
						vi.readaddress(31 DOWNTO 24) := spi_rx_data;
						vi.state := read_address_byte_2;
					END IF;
				WHEN read_address_byte_2 => 
					IF spi_rx_trig = '1' THEN
						vi.readaddress(23 DOWNTO 16) := spi_rx_data;
						vi.state := read_address_byte_1;
					END IF;
				WHEN read_address_byte_1 => 
					IF spi_rx_trig = '1' THEN
						vi.readaddress(15 DOWNTO 8) := spi_rx_data;
						vi.state := read_address_byte_0;
					END IF;
				WHEN read_address_byte_0 => 
					IF spi_rx_trig = '1' THEN
						vi.readaddress(7 DOWNTO 0) := spi_rx_data;
						vi.state := write_address_byte_3;
						vi.avalon_state := start_read_data;
					END IF;
				WHEN write_address_byte_3 => 
					IF spi_rx_trig = '1' THEN
						vi.writeaddress(31 DOWNTO 24) := spi_rx_data;
						vi.state := write_address_byte_2;
					END IF;
				WHEN write_address_byte_2 => 
					IF spi_rx_trig = '1' THEN
						vi.writeaddress(23 DOWNTO 16) := spi_rx_data;
						vi.state := write_address_byte_1;
					END IF;
				WHEN write_address_byte_1 => 
					IF spi_rx_trig = '1' THEN
						vi.writeaddress(15 DOWNTO 8) := spi_rx_data;
						vi.state := write_address_byte_0;
					END IF;
				WHEN write_address_byte_0 => 
					IF spi_rx_trig = '1' THEN
						vi.writeaddress(7 DOWNTO 0) := spi_rx_data;
						vi.spi_tx_data := vi.readdata(31 DOWNTO 24);
						vi.state := write_data_byte_3;
					END IF;
				WHEN write_data_byte_3 => 
					IF spi_rx_trig = '1' THEN
						vi.writedata(31 DOWNTO 24) := spi_rx_data;
						vi.spi_tx_data := vi.readdata(23 DOWNTO 16);
						vi.state := write_data_byte_2;
					END IF;
				WHEN write_data_byte_2 => 
					IF spi_rx_trig = '1' THEN
						vi.writedata(23 DOWNTO 16) := spi_rx_data;
						vi.spi_tx_data := vi.readdata(15 DOWNTO 8);
						vi.state := write_data_byte_1;
					END IF;
				WHEN write_data_byte_1 => 
					IF spi_rx_trig = '1' THEN
						vi.writedata(15 DOWNTO 8) := spi_rx_data;
						vi.spi_tx_data := vi.readdata(7 DOWNTO 0);
						vi.state := write_data_byte_0;
					END IF;
				WHEN write_data_byte_0 => 
					IF spi_rx_trig = '1' THEN
						vi.writedata(7 DOWNTO 0) := spi_rx_data;
						vi.state := idle;
						vi.avalon_state := start_write_data;
					END IF;
				WHEN OTHERS =>
					vi.state := idle;
			END CASE;
			
			
			
			CASE vi.avalon_state IS
				WHEN idle =>
					vi.read := '0';
					vi.write := '0';
					vi.avalon_address := (OTHERS => '0');
				WHEN start_read_data =>
					vi.read := '1';
					vi.write := '0';
					vi.avalon_address := vi.readaddress;
					IF islv_waitrequest = '0' THEN
						vi.readdata := islv_readdata;
						vi.avalon_state := save_read_data;
					END IF;
				WHEN save_read_data =>
					vi.read := '0';
					vi.write := '0';
					vi.avalon_address := (OTHERS => '0');
					vi.avalon_state := idle;
				WHEN start_write_data => 
					vi.read := '0';
					vi.write := '1';
					vi.avalon_address := vi.writeaddress;
					vi.avalon_writedata := vi.writedata;
					IF islv_waitrequest = '0' THEN
						vi.avalon_state := end_write_data;
					END IF;
				WHEN end_write_data => 
					vi.read := '0';
					vi.write := '0';
					vi.avalon_address := (OTHERS => '0');
					vi.avalon_writedata := (OTHERS => '0');
					vi.avalon_state := idle;
				WHEN OTHERS =>
						vi.avalon_state := idle;
			END CASE;
			
			--reset signal
			IF isl_reset_n = '0' THEN
				vi.state := idle;
				vi.avalon_state := idle;
				vi.spi_tx_data := (OTHERS => '0');
				vi.avalon_address := (OTHERS => '0');
				vi.avalon_writedata := (OTHERS => '0');
				vi.readaddress := (OTHERS => '0');
				vi.readdata := (OTHERS => '0');
				vi.read := '0';
				vi.write:= '0';
				vi.writeaddress := (OTHERS => '0');
				vi.writedata := (OTHERS => '0');
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
		
		oslv_address <= ri.avalon_address;
		oslv_read <= ri.read;
		oslv_write <= ri.write;
		oslv_writedata <= ri.avalon_writedata;
		
END ARCHITECTURE rtl;
