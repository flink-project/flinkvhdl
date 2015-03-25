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
PACKAGE ldc1000_pkg IS
	CONSTANT REGISTER_WIDTH : INTEGER := 8;
	TYPE t_conf_regs IS ARRAY(11 DOWNTO 0) OF STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
	
	COMPONENT ldc1000 IS
		GENERIC(
			BASE_CLK : INTEGER := 250000000; 
			SCLK_FREQUENCY : INTEGER := 4000000  --Max 4MHz
		);
		PORT(
			isl_clk						: IN STD_LOGIC;
			isl_reset_n    				: IN STD_LOGIC;
			--sensor signals
			osl_sclk					: OUT STD_LOGIC;
			oslv_csb					: OUT STD_LOGIC;
			isl_sdo						: IN STD_LOGIC;
			osl_sdi						: OUT STD_LOGIC;
			osl_tbclk					: OUT STD_LOGIC;
			--internal signals
			oslv_device_id				: OUT STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			oslv_proximity				: OUT STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
			oslv_frequency_counter		: OUT STD_LOGIC_VECTOR(3*REGISTER_WIDTH-1 DOWNTO 0);
			it_config					: IN t_conf_regs; --register 0 correspond with register 0x01 from the manual site 15
			ot_config					: OUT t_conf_regs; --register 0 correspond with register 0x01 from the manual site 15
			osl_conf_done				: OUT STD_LOGIC;
			osl_OSC_dead				: OUT STD_LOGIC;
			osl_DRDYB					: OUT STD_LOGIC;
			osl_wake_up					: OUT STD_LOGIC;
			osl_comperator				: OUT STD_LOGIC
		);
	END COMPONENT ldc1000;

END PACKAGE ldc1000_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.ldc1000_pkg.ALL;
USE work.spi_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY ldc1000 IS
		GENERIC(
			BASE_CLK : INTEGER := 250000000; 
			SCLK_FREQUENCY : INTEGER := 4000000  --Max 4MHz
		);
		PORT(
			isl_clk						: IN STD_LOGIC;
			isl_reset_n    				: IN STD_LOGIC;
			--sensor signals
			osl_sclk					: OUT STD_LOGIC;
			oslv_csb					: OUT STD_LOGIC;
			isl_sdo						: IN STD_LOGIC;
			osl_sdi						: OUT STD_LOGIC;
			osl_tbclk					: OUT STD_LOGIC;
			--internal signals
			oslv_device_id				: OUT STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			oslv_proximity				: OUT STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
			oslv_frequency_counter		: OUT STD_LOGIC_VECTOR(3*REGISTER_WIDTH-1 DOWNTO 0);
			it_config					: IN t_conf_regs; --register 0 correspond with register 0x01 from the manual site 15
			ot_config					: OUT t_conf_regs; --register 0 correspond with register 0x01 from the manual site 15
			osl_conf_done				: OUT STD_LOGIC;
			osl_OSC_dead				: OUT STD_LOGIC;
			osl_DRDYB					: OUT STD_LOGIC;
			osl_wake_up					: OUT STD_LOGIC;
			osl_comperator				: OUT STD_LOGIC
			
		);
END ENTITY ldc1000;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF ldc1000 IS
	CONSTANT WRITE_TRANSFER : STD_LOGIC := '0';
	CONSTANT READ_TRANSFER : STD_LOGIC := '1';
	CONSTANT SS_HOLD_CYCLES : INTEGER := 2; -- add 2 to be sure and have a minimum number of cycles
	CONSTANT TRANSFER_WIDTH : INTEGER := 16;
	CONSTANT DEVICE_ID_ADDRESS : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
	CONSTANT STATUS_ADDRESS : UNSIGNED(6 DOWNTO 0) := "0100000";
	CONSTANT PROXIMITY_LSB_ADDRESS : UNSIGNED(6 DOWNTO 0) := "0100001";	
	CONSTANT PROXIMITY_MSB_ADDRESS : UNSIGNED(6 DOWNTO 0) := "0100010";		
	CONSTANT FREQUENCY_LSB_ADDRESS : UNSIGNED(6 DOWNTO 0) := "0100011";
	CONSTANT FREQUENCY_MID_ADDRESS : UNSIGNED(6 DOWNTO 0) := "0100100";		
	CONSTANT FREQUENCY_MSB_ADDRESS : UNSIGNED(6 DOWNTO 0) := "0100101";		
		
		
		
		
	TYPE t_states IS (idle,cache_device_id_start,cache_device_id_end,cache_config_start,cache_config_wait,write_config_start,write_config_end,read_config_start,read_config_end,
						update_data_regs_start,update_data_regs_end
					);

	TYPE t_internal_register IS RECORD
		state				:t_states;
		tx_data 			: STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
		tx_start 			: STD_LOGIC;
		in_config			: t_conf_regs;
		out_config			: t_conf_regs;
		device_id			: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
		config_read_address : UNSIGNED(6 DOWNTO 0);
		conf_done			: STD_LOGIC;
		proximity			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		frequency_counter	: STD_LOGIC_VECTOR(3*REGISTER_WIDTH-1 DOWNTO 0);
		OSC_dead			: STD_LOGIC;
		DRDYB				: STD_LOGIC;
		wake_up				: STD_LOGIC;
		comperator			: STD_LOGIC;
	END RECORD;
	
	

	SIGNAL slv_rx_data : STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
	SIGNAL sl_rx_done : STD_LOGIC;
	
	SIGNAL ri, ri_next : t_internal_register;

	
	BEGIN
	
	my_spi_master :  spi_master 
	GENERIC MAP(
			BASE_CLK 			=> BASE_CLK,
			SCLK_FREQUENCY		=> SCLK_FREQUENCY,
			CS_SETUP_CYLES		=> SS_HOLD_CYCLES,
			TRANSFER_WIDTH 		=> TRANSFER_WIDTH,
			NR_OF_SS 			=> 1, -- only one ss is needed
			CPOL				=> '1', -- sckl inactive high -> leading edge = falling edge, trailing edge = rising edge
			CPHA				=> '0', -- data is captured on the trialling edge see data sheet page 15
			MSBFIRST			=> '1', -- MSB first
			SSPOL				=> '0' -- zero active see data sheet page 14
		)
		PORT MAP(
			isl_clk					=> isl_clk,
			isl_reset_n    			=> isl_reset_n,
			
			islv_tx_data			=> ri.tx_data,
			isl_tx_start			=> ri.tx_start,
			oslv_rx_data			=> slv_rx_data,
			osl_rx_done				=> sl_rx_done,
			islv_ss_activ(0)  		=> '1',
			
			osl_sclk				=> osl_sclk,
			oslv_Ss(0)				=> oslv_csb,
			osl_mosi				=> osl_sdi,
			isl_miso				=> isl_sdo
		);
	
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,sl_rx_done,slv_rx_data,it_config)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			vi.in_config := it_config;
			
			
			
			--standard values
			vi.tx_start := '0';
			vi.conf_done := '0';
			
			CASE vi.state IS 
				WHEN idle => 
					FOR i IN 0 TO t_conf_regs'length-1 LOOP
						IF vi.in_config(i) /= vi.out_config(i) THEN
							vi.config_read_address := to_unsigned(i,7);
							vi.state := write_config_start;
						END IF;
					END LOOP;
					vi.state := update_data_regs_start;
					vi.config_read_address := STATUS_ADDRESS;
					
					
				WHEN cache_device_id_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(15) := READ_TRANSFER;
					vi.tx_data(14 DOWNTO 8) := DEVICE_ID_ADDRESS;
					vi.tx_start := '1';
					vi.state := cache_device_id_end; 
				WHEN cache_device_id_end => 
					IF sl_rx_done = '1' THEN
							vi.device_id := slv_rx_data(7 DOWNTO 0);
							vi.state := cache_config_start; 
					END IF;
				WHEN cache_config_start =>
					IF vi.config_read_address < t_conf_regs'length THEN
						vi.tx_data := (OTHERS => '0');
						vi.tx_data(15) := READ_TRANSFER;
						vi.tx_data(14 DOWNTO 8) := STD_LOGIC_VECTOR(vi.config_read_address);
						vi.tx_start := '1';
						vi.state := cache_config_wait;
					ELSE
						vi.conf_done := '1';
						vi.state := idle;
					END IF;
				WHEN cache_config_wait => 
					IF sl_rx_done = '1' THEN
							vi.out_config(to_integer(vi.config_read_address)) := slv_rx_data(7 DOWNTO 0);
							vi.state := cache_config_start; 
							vi.config_read_address := ri.config_read_address + 1;
					END IF;
				WHEN write_config_start => 
					vi.tx_data(15) := WRITE_TRANSFER;
					vi.tx_data(14 DOWNTO 8) := STD_LOGIC_VECTOR(vi.config_read_address);
					vi.tx_data(7 DOWNTO 0) := vi.in_config(to_integer(vi.config_read_address));
					vi.tx_start := '1';
					vi.state := write_config_end;
				WHEN write_config_end => 
					IF sl_rx_done = '1' THEN
						vi.state := read_config_start;
					END IF;
				WHEN read_config_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(15) := READ_TRANSFER;
					vi.tx_data(14 DOWNTO 8) := STD_LOGIC_VECTOR(vi.config_read_address);
					vi.tx_start := '1';
					vi.state := read_config_end;
				WHEN read_config_end =>
					IF sl_rx_done = '1' THEN
						vi.out_config(to_integer(vi.config_read_address)) := slv_rx_data(7 DOWNTO 0);
						vi.conf_done := '1';
						vi.state := idle;
					END IF;
					
				WHEN update_data_regs_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(15) := READ_TRANSFER;
					vi.tx_data(14 DOWNTO 8) := STD_LOGIC_VECTOR(vi.config_read_address);
					vi.tx_start := '1';
					vi.state := update_data_regs_end;
 				WHEN update_data_regs_end => 
					IF sl_rx_done = '1' THEN
						vi.config_read_address := vi.config_read_address + 1;
						vi.state := update_data_regs_start;
						CASE vi.config_read_address IS 
							WHEN STATUS_ADDRESS => 
								vi.OSC_dead:= slv_rx_data(7);
								vi.DRDYB:= slv_rx_data(6);
								vi.wake_up:= slv_rx_data(5);
								vi.comperator:= slv_rx_data(4);
							WHEN PROXIMITY_LSB_ADDRESS => 
								vi.proximity(REGISTER_WIDTH-1 DOWNTO 0) := slv_rx_data(7 DOWNTO 0);
							WHEN PROXIMITY_MSB_ADDRESS => 
								vi.proximity(2*REGISTER_WIDTH-1 DOWNTO REGISTER_WIDTH) := slv_rx_data(7 DOWNTO 0);
							WHEN FREQUENCY_LSB_ADDRESS => 
								vi.frequency_counter(REGISTER_WIDTH-1 DOWNTO 0) := slv_rx_data(7 DOWNTO 0);
							WHEN FREQUENCY_MID_ADDRESS => 
								vi.frequency_counter(2*REGISTER_WIDTH-1 DOWNTO REGISTER_WIDTH) := slv_rx_data(7 DOWNTO 0);
							WHEN FREQUENCY_MSB_ADDRESS => 
								vi.frequency_counter(3*REGISTER_WIDTH-1 DOWNTO 2*REGISTER_WIDTH) := slv_rx_data(7 DOWNTO 0);
								vi.state := idle;
							WHEN OTHERS =>
								vi.state := idle;
						END CASE;
					END IF;
					
				
				WHEN OTHERS =>
					vi.state := idle; 
			END CASE;
			
			--reset
			IF isl_reset_n = '0' THEN
				vi.state := cache_device_id_start; 
				vi.tx_data := (OTHERS => '0');
				vi.tx_start := '0';
				vi.config_read_address := (OTHERS => '0');
				vi.conf_done := '0';
				FOR i IN 0 TO t_conf_regs'length-1 LOOP
					vi.in_config(i) := (OTHERS => '0');
					vi.out_config(i) := (OTHERS => '0');
				END LOOP;
				vi.device_id := (OTHERS => '0');
				vi.proximity := (OTHERS => '0');
				vi.frequency_counter := (OTHERS => '0');
				vi.OSC_dead:= '0';
				vi.DRDYB:= '0';
				vi.wake_up:= '0';
				vi.comperator:= '0';
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
		
		osl_tbclk <= '0';
		osl_conf_done <= ri.conf_done;
		ot_config <= ri.out_config;
		osl_OSC_dead <= ri.OSC_dead;
		osl_DRDYB <= ri.DRDYB;
		osl_wake_up<= ri.wake_up; 
		osl_comperator <= ri.comperator ;
		
END ARCHITECTURE rtl;


