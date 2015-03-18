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
PACKAGE eim_slave_to_avalon_master_pkg IS
	COMPONENT eim_slave_to_avalon_master IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 16
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			--eim_interface
			islv_address			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			ioslv_data				: INOUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			isl_cs_n				: IN STD_LOGIC;
			isl_we_n				: IN STD_LOGIC;
			isl_oe_n				: IN STD_LOGIC;
			osl_data_ack			: OUT STD_LOGIC;
		
			--avalon master
			oslv_address	:  	OUT STD_LOGIC_VECTOR (TRANSFER_WIDTH-1 DOWNTO 0);
			oslv_read		:  	OUT STD_LOGIC;
			islv_readdata	:  	IN  STD_LOGIC_VECTOR (TRANSFER_WIDTH-1 DOWNTO 0);
			oslv_write 		:  	OUT STD_LOGIC;
			oslv_writedata	:  	OUT STD_LOGIC_VECTOR (TRANSFER_WIDTH-1 DOWNTO 0);
			islv_waitrequest:  	IN STD_LOGIC
		);
	END COMPONENT eim_slave_to_avalon_master;
	
END PACKAGE eim_slave_to_avalon_master_pkg;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.eim_slave_to_avalon_master_pkg.ALL;
USE work.eim_slave_pkg.ALL;

ENTITY eim_slave_to_avalon_master IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 16
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			--eim_interface
			islv_address			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			ioslv_data				: INOUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			isl_cs_n				: IN STD_LOGIC;
			isl_we_n				: IN STD_LOGIC;
			isl_oe_n				: IN STD_LOGIC;
			osl_data_ack			: OUT STD_LOGIC;
		
			--avalon master
			oslv_address	:  	OUT STD_LOGIC_VECTOR (TRANSFER_WIDTH-1 DOWNTO 0);
			oslv_read		:  	OUT STD_LOGIC;
			islv_readdata	:  	IN  STD_LOGIC_VECTOR (TRANSFER_WIDTH-1 DOWNTO 0);
			oslv_write 		:  	OUT STD_LOGIC;
			oslv_writedata	:  	OUT STD_LOGIC_VECTOR (TRANSFER_WIDTH-1 DOWNTO 0);
			islv_waitrequest:  	IN STD_LOGIC
		);
END ENTITY eim_slave_to_avalon_master;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF eim_slave_to_avalon_master IS 

	TYPE t_states IS (	idle,wait_for_read_data,wait_for_write_done);


	TYPE t_internal_register IS RECORD
		state				: t_states;
		slv_read_data		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); 
		sl_read_data_valid	: STD_LOGIC; 
		avalon_address		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		avalon_writedata	: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		read				: STD_LOGIC;
		write				: STD_LOGIC;
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;

	SIGNAL slv_address_out		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); 
	SIGNAL sl_read_not_write	: STD_LOGIC; 
	SIGNAL sl_got_address		: STD_LOGIC; 
	SIGNAL slv_write_data		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
	SIGNAL sl_got_write_data	: STD_LOGIC;
	
	BEGIN
	
	my_eim : eim_slave 
		GENERIC MAP(TRANSFER_WIDTH)
		PORT MAP(isl_clk,isl_reset_n,islv_address,isl_cs_n,isl_we_n,isl_oe_n,osl_data_ack,ioslv_data,slv_address_out,sl_read_not_write,sl_got_address,ri.slv_read_data,ri.sl_read_data_valid,slv_write_data,sl_got_write_data);

		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,sl_got_address,sl_read_not_write,slv_address_out,islv_waitrequest,islv_readdata)
		
		VARIABLE vi: t_internal_register;

		BEGIN
			-- keep variables stable 
			vi:=ri;

			vi.sl_read_data_valid := '0';
			
			CASE vi.state IS
				WHEN idle =>
					IF sl_got_address = '1' THEN 
						vi.avalon_address := slv_address_out;
						IF sl_read_not_write = '1' THEN --read transfer;
							vi.read := '1';
							vi.state := wait_for_read_data;
						END IF;
					END IF;
					IF sl_got_write_data = '1' THEN
						vi.avalon_writedata := slv_write_data;
						vi.write := '1';
						vi.state := wait_for_write_done;
					END IF;
					
				WHEN wait_for_read_data =>
					
					IF islv_waitrequest = '0' THEN
						vi.slv_read_data := islv_readdata;
						vi.sl_read_data_valid := '1';
						vi.read := '0';
						vi.state := idle;
					END IF;
				WHEN wait_for_write_done =>
					IF islv_waitrequest = '0' THEN
						vi.write := '0';
						vi.state := idle;
					END IF;				
				WHEN OTHERS =>
					vi.state := idle;
			END CASE;
			
			
			
			
			--reset signal
			IF isl_reset_n = '0' THEN
				vi.state := idle;
				vi.slv_read_data := (OTHERS => '0');
				vi.sl_read_data_valid := '0';
				vi.avalon_address := (OTHERS => '0');
				vi.avalon_writedata := (OTHERS => '0');
				vi.read := '0';
				vi.write:= '0';
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
