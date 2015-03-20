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
PACKAGE eim_slave_pkg IS
	
	COMPONENT eim_slave IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 16 --only 16 is available at the moment further releases will support 8 and 32bit versions
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			--external eim signals: 
			islv_address			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			isl_cs_n				: IN STD_LOGIC;
			isl_we_n				: IN STD_LOGIC;
			isl_oe_n				: IN STD_LOGIC;
			osl_data_ack			: OUT STD_LOGIC;
			ioslv_data				: INOUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			--fpga internal signals: 
			oslv_address_out		: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); --contains the address which was transferred from the bus. It is only valid if osl_got_address is '1';
			osl_read_not_write		: OUT STD_LOGIC; --'1' if last transfer was a read transfer, '0' if last transfer was a write access 
			
			osl_got_address			: OUT STD_LOGIC; --As soon as the address has been received this signal goes high for one cycle
			islv_read_data			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); --data which should be read by a read access from the bus. This data have to be set as fast as possible after osl_got_address is '1' and osl_read_not_write is '1'
			isl_read_data_valid		: IN STD_LOGIC; --this signal indicates that the read data are now valid and can be provided to the bus; 
			
			oslv_write_data			: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); --data which have been written from the bus
			osl_got_write_data		: OUT STD_LOGIC --'1' if the write data are stored successfully in the oslv_write_data signal
		);
	END COMPONENT eim_slave;

END PACKAGE eim_slave_pkg;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.eim_slave_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY eim_slave IS
		GENERIC(
			TRANSFER_WIDTH : INTEGER := 16 --only 16 is available at the moment further releases will support 8 and 32bit versions
		);
		PORT(
			isl_clk					: IN STD_LOGIC;
			isl_reset_n				: IN STD_LOGIC;
			--external eim signals: 
			islv_address			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			isl_cs_n				: IN STD_LOGIC;
			isl_we_n				: IN STD_LOGIC;
			isl_oe_n				: IN STD_LOGIC;
			osl_data_ack			: OUT STD_LOGIC;
			ioslv_data				: INOUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
			--fpga internal signals: 
			oslv_address_out		: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); --contains the address which was transferred from the bus. It is only valid if osl_got_address is '1';
			osl_read_not_write		: OUT STD_LOGIC; --'1' if last transfer was a read transfer, '0' if last transfer was a write access 
			
			osl_got_address			: OUT STD_LOGIC; --As soon as the address has been received this signal goes high for one cycle
			islv_read_data			: IN STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); --data which should be read by a read access from the bus. This data have to be set as fast as possible after osl_got_address is '1' and osl_read_not_write is '1'
			isl_read_data_valid		: IN STD_LOGIC; --this signal indicates that the read data are now valid and can be provided to the bus; 
			
			oslv_write_data			: OUT STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0); --data which have been written from the bus
			osl_got_write_data		: OUT STD_LOGIC --'1' if the write data are stored successfully in the oslv_write_data signal
		);
END ENTITY eim_slave;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF eim_slave IS 


	TYPE t_states IS (idle,run,wait_for_rearm);

	TYPE t_internal_register IS RECORD
		state				:t_states;
		-- synchronize signals 
		sync_cs				: STD_LOGIC_VECTOR(2 DOWNTO 0);
		sync_we				: STD_LOGIC_VECTOR(2 DOWNTO 0);
		sync_oe				: STD_LOGIC_VECTOR(2 DOWNTO 0);
		
		slv_address_out		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		slv_write_data		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
		sl_read_not_write	: STD_LOGIC;
		sl_got_address		: STD_LOGIC;
		sl_got_write_data	: STD_LOGIC;
		sl_data_ack			: STD_LOGIC;
		slv_read_data		: STD_LOGIC_VECTOR(TRANSFER_WIDTH-1 DOWNTO 0);
	END RECORD;
	
	SIGNAL ri, ri_next : t_internal_register;

	BEGIN
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,islv_address,isl_cs_n,isl_we_n,isl_oe_n,islv_read_data,isl_read_data_valid,ioslv_data)
		
		VARIABLE vi: t_internal_register;
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			-- synchronisation
			vi.sync_cs(0) := isl_cs_n;
			vi.sync_cs(1) := ri.sync_cs(0);
			vi.sync_cs(2) := ri.sync_cs(1);
			
			vi.sync_we(0) := isl_we_n;
			vi.sync_we(1) := ri.sync_we(0);
			vi.sync_we(2) := ri.sync_we(1);
			
			
			vi.sync_oe(0) := isl_oe_n;
			vi.sync_oe(1) := ri.sync_oe(0);
			vi.sync_oe(2) := ri.sync_oe(1);
			
			
			--standard values:
			vi.sl_read_not_write := '0';
			vi.sl_got_address := '0';
			vi.sl_got_write_data := '0';
			
			IF isl_cs_n = '0' THEN --cs is low
				IF vi.sync_oe(2) = '1' AND vi.sync_oe(1) = '0' THEN --falling edge oe_n then read transfer
					vi.slv_address_out := islv_address;
					vi.sl_read_not_write := '1';
					vi.sl_got_address := '1';
					vi.sl_data_ack := '1';
				
				ELSIF vi.sync_we(2) = '1' AND vi.sync_we(1) = '0' THEN --falling edge we_n then write transfer
					vi.slv_address_out := islv_address;
					vi.sl_read_not_write := '0';
					vi.sl_got_address := '1';
				END IF;
			
				IF isl_read_data_valid = '1' THEN
					vi.slv_read_data := islv_read_data;
					vi.sl_data_ack := '0';
				END IF; 
				
				IF vi.sync_we(1) = '0' AND vi.sync_we(2) = '1' THEN --rising edge we_n
					vi.sl_got_write_data := '1';
					vi.slv_write_data := ioslv_data;
				END IF;
			ELSE
				IF vi.sl_data_ack = '1' THEN
					vi.sl_data_ack := '0';
				END IF;
			END IF;
			
			IF isl_oe_n = '0' THEN
				ioslv_data <= vi.slv_read_data;
			ELSE
				ioslv_data <= (OTHERS => 'Z');
			END IF;
			
			IF isl_reset_n = '0' THEN
				vi.slv_address_out := (OTHERS => '0');
				vi.slv_write_data := (OTHERS => '0');
				vi.sl_read_not_write := '0';
				vi.sl_got_address := '0';
				vi.sl_got_write_data := '0';
				vi.slv_read_data := (OTHERS => '0');
				vi.sl_data_ack := '0';
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

		oslv_address_out <= ri.slv_address_out;
		osl_read_not_write <= ri.sl_read_not_write;
		osl_got_address <= ri.sl_got_address;
		oslv_write_data <= ri.slv_write_data;
		osl_got_write_data <= ri.sl_got_write_data;
		osl_data_ack <= ri.sl_data_ack;
		
END ARCHITECTURE rtl;


