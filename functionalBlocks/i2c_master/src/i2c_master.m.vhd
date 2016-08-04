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
PACKAGE i2c_master_pkg IS
	CONSTANT REGISTER_WIDTH : INTEGER := 8;
	CONSTANT DEV_ADDRESS_WIDTH : INTEGER := 7;
	
	COMPONENT i2c_master IS
		GENERIC(
			BASE_CLK : INTEGER := 250000000
		);
		PORT(
			isl_clk						: IN STD_LOGIC;
			isl_reset_n    				: IN STD_LOGIC;
			--i2c signals
			osl_scl						: OUT STD_LOGIC;
			oisl_sda					: INOUT STD_LOGIC;
			--internal signals
			islv_dev_address			: IN STD_LOGIC_VECTOR(DEV_ADDRESS_WIDTH-1 DOWNTO 0);
			islv_register_address		: IN STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			islv_write_data				: IN STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			oslv_read_data				: OUT STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			isl_start_transfer			: IN STD_LOGIC;
			isl_write_n_read			: IN STD_LOGIC;
			isl_enable_burst_transfer	: IN STD_LOGIC;
			osl_transfer_done			: OUT STD_LOGIC
		);
	END COMPONENT i2c_master;

END PACKAGE i2c_master_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.i2c_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY i2c_master IS
		GENERIC(
			BASE_CLK : INTEGER := 250000000
		);
		PORT(
			isl_clk						: IN STD_LOGIC;
			isl_reset_n    				: IN STD_LOGIC;
			--i2c signals
			osl_scl						: OUT STD_LOGIC;
			oisl_sda					: INOUT STD_LOGIC;
			--internal signals
			islv_dev_address			: IN STD_LOGIC_VECTOR(DEV_ADDRESS_WIDTH-1 DOWNTO 0);
			islv_register_address		: IN STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			islv_write_data				: IN STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			oslv_read_data				: OUT STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			isl_start_transfer			: IN STD_LOGIC;
			isl_write_n_read			: IN STD_LOGIC;
			isl_enable_burst_transfer	: IN STD_LOGIC;
			osl_transfer_done			: OUT STD_LOGIC
		);
END ENTITY i2c_master;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF i2c_master IS	
	CONSTANT I2C_PERIOD_COUNT : INTEGER := BASE_CLK/400000;	
	CONSTANT I2C_HALF_PERIOD_COUNT : INTEGER := BASE_CLK/400000/2;	
	CONSTANT START_CONDITION_HOLD_CYCLES : INTEGER := I2C_PERIOD_COUNT/4;-- min 0.6usec with a clk frequency of 400Hz (2.5us) this is around 4.16 so 5 cycles!	
		
	TYPE t_states IS (	idle,start_condition,address_write,read_write,wait_for_ack,register_address_write,
						burst_read_1,wait_for_ack_2,write_data,wait_for_ack_3,stop_transfer,repeated_start,address_read,read_bit,wait_for_ack_4,read_data,send_ack,send_nack,wait_bevore_restart
					);

	TYPE t_internal_register IS RECORD
		state				: t_states;
		scl					: STD_LOGIC;
		sda					: STD_LOGIC;
		clk_count 			: UNSIGNED(31 DOWNTO 0);
		byte_count 			: UNSIGNED(3 DOWNTO 0);
		read_data			: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
		transfer_done		: STD_LOGIC;
	END RECORD;
	
	CONSTANT INTERNAL_REG_RESET : t_internal_register := (
                                   state => idle,
                                   scl => '1',
                                   sda => '1',
								   clk_count => (OTHERS => '0'),
								   byte_count => to_unsigned(DEV_ADDRESS_WIDTH - 1,4),
								   read_data => (OTHERS => '0'),
								   transfer_done => '0'
								   
     );
	
	
	SIGNAL ri, ri_next : t_internal_register := INTERNAL_REG_RESET;

	
	BEGIN
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,isl_start_transfer,isl_write_n_read,islv_write_data)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			vi.transfer_done := '0';
			
			CASE vi.state IS 
				WHEN idle => 
						IF(isl_start_transfer = '1') THEN
							vi.state := start_condition;
							vi.clk_count := (OTHERS => '0');
							vi.scl := '1';
							vi.sda := '0';
						END IF;
						
						
				WHEN start_condition => 
						vi.clk_count := vi.clk_count + 1;
						IF(vi.clk_count = START_CONDITION_HOLD_CYCLES) THEN
							vi.scl := '0';
							vi.state := address_write;
							vi.byte_count := to_unsigned(DEV_ADDRESS_WIDTH - 1,4);
							vi.sda := islv_dev_address(to_integer(vi.byte_count));
							vi.clk_count := (OTHERS => '0');
						END IF;
				
				WHEN address_write => 
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.byte_count := vi.byte_count - 1;
						IF(vi.byte_count >= to_unsigned(DEV_ADDRESS_WIDTH,4))THEN
							vi.state := read_write;
						ELSE
							vi.sda := islv_dev_address(to_integer(vi.byte_count));
						END IF;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				WHEN read_write => 
					vi.clk_count := vi.clk_count + 1;
					vi.sda := '0'; --write transfer
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.state := wait_for_ack;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				
				
				WHEN wait_for_ack => 
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.state := register_address_write;
						vi.byte_count := to_unsigned(REGISTER_WIDTH - 1,4);
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when register_address_write =>
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.byte_count := vi.byte_count - 1;
						IF(vi.byte_count >= to_unsigned(REGISTER_WIDTH,4))THEN
							vi.state := wait_for_ack_2;
						ELSE
							vi.sda := islv_register_address(to_integer(vi.byte_count));
						END IF;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when wait_for_ack_2 => 
				
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						
						vi.clk_count := (OTHERS => '0');
						
						vi.byte_count := to_unsigned(REGISTER_WIDTH - 1,4);
						IF(isl_write_n_read = '1') THEN
							vi.scl := '0';
							vi.state := write_data;
						ELSE
							vi.scl := '1';
							vi.sda := '1';
							vi.state := repeated_start;
						END IF;
						
						
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when write_data => 
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.byte_count := vi.byte_count - 1;
						IF(vi.byte_count >= to_unsigned(REGISTER_WIDTH,4))THEN
							vi.state := wait_for_ack_3;
						ELSE
							vi.sda := islv_write_data(to_integer(vi.byte_count));
						END IF;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when wait_for_ack_3 => 
				
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.clk_count := (OTHERS => '0');
						IF(isl_enable_burst_transfer = '1') THEN
							vi.scl := '0';
							vi.state := write_data;
							vi.transfer_done := '1';
						ELSE
							vi.state := stop_transfer;
						END IF;
						
						
						vi.byte_count := to_unsigned(REGISTER_WIDTH - 1,4);
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when stop_transfer =>
					
					vi.clk_count := vi.clk_count + 1;
					IF(vi.clk_count < I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.sda := '0';
					ELSIF(vi.clk_count >= I2C_HALF_PERIOD_COUNT + START_CONDITION_HOLD_CYCLES) THEN
						vi.sda := '1';
						vi.scl := '1';
						vi.state := wait_bevore_restart;
						vi.transfer_done := '1';
						vi.clk_count := (OTHERS => '0');
					ELSE
						vi.scl := '1';
						vi.sda := '0';
					END IF;
				WHEN wait_bevore_restart=> 
					vi.sda := '1';
					vi.scl := '1';
					vi.clk_count := vi.clk_count + 1;
					IF(vi.clk_count >= I2C_PERIOD_COUNT) THEN
							vi.state := idle;
							vi.clk_count := (OTHERS => '0');
					END IF;
				
				
				WHEN repeated_start => 
						vi.scl := '1';
						vi.clk_count := vi.clk_count + 1;
						IF(vi.clk_count = START_CONDITION_HOLD_CYCLES) THEN
							vi.sda := '0';
						ELSIF(vi.clk_count >= I2C_HALF_PERIOD_COUNT + START_CONDITION_HOLD_CYCLES) THEN
							vi.scl := '0';
							vi.state := address_read;
							vi.byte_count := to_unsigned(DEV_ADDRESS_WIDTH - 1,4);
							vi.sda := islv_dev_address(to_integer(vi.byte_count));
							vi.clk_count := (OTHERS => '0');
						END IF;
				WHEN address_read => 
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.byte_count := vi.byte_count - 1;
						IF(vi.byte_count >= to_unsigned(DEV_ADDRESS_WIDTH,4))THEN
							vi.state := read_bit;
						ELSE
							vi.sda := islv_dev_address(to_integer(vi.byte_count));
						END IF;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when read_bit => 
					vi.clk_count := vi.clk_count + 1;
					vi.sda := '1'; --read transfer
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.state := wait_for_ack_4;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when wait_for_ack_4 => 
					vi.clk_count := vi.clk_count + 1;
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.clk_count := (OTHERS => '0');
						vi.state := read_data;
						vi.byte_count := to_unsigned(REGISTER_WIDTH - 1,4);
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when read_data => 	
					vi.clk_count := vi.clk_count + 1;
					vi.sda := '0';
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						IF(vi.byte_count >= to_unsigned(REGISTER_WIDTH,4))THEN
							IF(isl_enable_burst_transfer = '1') THEN
								vi.state := send_ack;
								vi.transfer_done := '1';
							ELSE
								vi.state := send_nack;
							END IF;
						ELSE
							vi.read_data(to_integer(vi.byte_count)) := oisl_sda;
						END IF;
						vi.byte_count := vi.byte_count - 1;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when send_ack => 
					vi.clk_count := vi.clk_count + 1;
					vi.sda := '0'; --ack
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.byte_count := to_unsigned(REGISTER_WIDTH - 1,4);
						vi.state := read_data;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				when send_nack =>
					vi.clk_count := vi.clk_count + 1;
					vi.sda := '1'; --nack
					IF (vi.clk_count > I2C_PERIOD_COUNT) THEN
						vi.scl := '0';
						vi.clk_count := (OTHERS => '0');
						vi.state := stop_transfer;
					ELSIF(vi.clk_count > I2C_HALF_PERIOD_COUNT) THEN
						vi.scl := '1';
					END IF;
				WHEN OTHERS =>
					vi.state := idle; 
			END CASE;
			
			
	
			
			IF(vi.state = wait_for_ack OR vi.state = wait_for_ack_2 OR vi.state = wait_for_ack_3 OR vi.state = wait_for_ack_4 OR vi.state = read_data) THEN
				oisl_sda <= 'Z';
			ELSE
				oisl_sda <= ri.sda;
			END IF;
			
			
			--reset
			IF isl_reset_n = '0' THEN
				vi := INTERNAL_REG_RESET;
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
		
		osl_scl <= ri.scl;
		oslv_read_data <= ri.read_data;
		osl_transfer_done <= ri.transfer_done;
		
		
END ARCHITECTURE rtl;


