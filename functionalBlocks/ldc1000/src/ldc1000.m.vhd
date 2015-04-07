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
	CONSTANT PWM_FREQUENCY_RESOLUTION : INTEGER := 32;
		
	TYPE t_conf_regs IS RECORD
			device_id			: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			rp_max				: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			rp_min				: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			min_sens_freq		: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			threshold_high_msb	: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			threshold_low_msb	: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
			amplitude			: STD_LOGIC_VECTOR(1 DOWNTO 0);
			response_time		: STD_LOGIC_VECTOR(2 DOWNTO 0);
			intb_mode			: STD_LOGIC_VECTOR(2 DOWNTO 0);
			pwr_mode			: STD_LOGIC;
			frequency_divider	: UNSIGNED(PWM_FREQUENCY_RESOLUTION-1 DOWNTO 0); --sensor frequency has to be between 5kHz and 5Mhz
	END RECORD;
	
	TYPE t_data_regs IS RECORD
		proximity			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		frequency_counter	: STD_LOGIC_VECTOR(3*REGISTER_WIDTH-1 DOWNTO 0);
		OSC_dead			: STD_LOGIC;
		DRDYB				: STD_LOGIC;
		wake_up				: STD_LOGIC;
		comperator			: STD_LOGIC;
	END RECORD;
	
	
	
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
			it_config					: IN t_conf_regs; 
			ot_config					: OUT t_conf_regs;
			ot_data						: OUT t_data_regs;
			osl_configuring				: OUT STD_LOGIC;
			isl_update_config			: IN STD_LOGIC;
			osl_confi_done				: OUT STD_LOGIC
		);
	END COMPONENT ldc1000;

END PACKAGE ldc1000_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.ldc1000_pkg.ALL;
USE work.spi_master_pkg.ALL;
USE work.adjustable_pwm_pkg.ALL;

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
			it_config					: IN t_conf_regs; 
			ot_config					: OUT t_conf_regs;
			ot_data						: OUT t_data_regs;
			osl_configuring				: OUT STD_LOGIC;
			isl_update_config			: IN STD_LOGIC;
			osl_confi_done				: OUT STD_LOGIC
		);
END ENTITY ldc1000;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF ldc1000 IS
	CONSTANT WRITE_TRANSFER : STD_LOGIC := '0';
	CONSTANT READ_TRANSFER : STD_LOGIC := '1';
	CONSTANT SS_HOLD_CYCLES : INTEGER := 40; -- add 2 to be sure and have a minimum number of cycles
	CONSTANT TRANSFER_WIDTH : INTEGER := 56;
	CONSTANT DEVICE_ID_ADDRESS : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
	CONSTANT RESERVED_ADDRESS : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000110";
	CONSTANT STATUS_ADDRESS : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100000";
	CONSTANT COUNTER_WIDTH : INTEGER := 12;
	CONSTANT HOLD_TIME : UNSIGNED(COUNTER_WIDTH-1 DOWNTO 0) := to_unsigned(400,COUNTER_WIDTH);
		
		
	TYPE t_states IS (	idle,
						read_config_1_start,read_config_1_end,
						read_config_2_start,read_config_2_end,
						write_config_1_start,write_config_1_end,
						write_config_2_start,write_config_2_end,
						update_data_regs_start,update_data_regs_end,
						wait_for_next_transfer
					);

	TYPE t_internal_register IS RECORD
		state				: t_states;
		state_after_wait	: t_states;
		tx_data 			: STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
		tx_start 			: STD_LOGIC;
		out_config			: t_conf_regs;
		data				: t_data_regs;
		update_config		: STD_LOGIC;
		ratio				: UNSIGNED(PWM_FREQUENCY_RESOLUTION-1 DOWNTO 0);
		counter				: UNSIGNED(COUNTER_WIDTH-1 DOWNTO 0);
		confi_done			: STD_LOGIC;
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
			CPOL				=> '1', 
			CPHA				=> '1', -- data is captured on the trialling edge see data sheet page 15
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
		
		
		my_adjustable_pwm : adjustable_pwm
		GENERIC MAP(
			frequency_resolution => PWM_FREQUENCY_RESOLUTION
		)
		PORT MAP(
			sl_clk					=> isl_clk,
			sl_reset_n				=> isl_reset_n,
			slv_frequency_divider 	=> it_config.frequency_divider,
			slv_ratio 				=> ri.ratio,
			sl_pwm 					=> osl_tbclk
		);
	
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,sl_rx_done,slv_rx_data,it_config,isl_update_config)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			--standard values
			vi.tx_start := '0';
			vi.confi_done := '0';
			
			IF isl_update_config = '1' THEN
				vi.update_config := '1';
			END IF;
			
			CASE vi.state IS 
				WHEN idle => 
					IF vi.update_config = '1' THEN
						vi.state := write_config_1_start;
					ELSE
						vi.state := update_data_regs_start;
					END IF;
					
				--######### read configuration #########  	
				WHEN read_config_1_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := DEVICE_ID_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_config_1_end; 
				WHEN read_config_1_end => 
					IF sl_rx_done = '1' THEN
						vi.out_config.device_id := slv_rx_data(47 DOWNTO 40);
						vi.out_config.rp_max := slv_rx_data(39 DOWNTO 32);
						vi.out_config.rp_min := slv_rx_data(31 DOWNTO 24);
						vi.out_config.min_sens_freq := slv_rx_data(23 DOWNTO 16);
						vi.out_config.response_time := slv_rx_data(10 DOWNTO 8);
						vi.out_config.amplitude := slv_rx_data(12 DOWNTO 11);
						vi.state_after_wait := read_config_2_start;
						vi.state := wait_for_next_transfer;
					END IF;
				WHEN read_config_2_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := RESERVED_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_config_2_end; 
				WHEN read_config_2_end => 
					IF sl_rx_done = '1' THEN
						vi.out_config.threshold_high_msb := slv_rx_data(39 DOWNTO 32);
						vi.out_config.threshold_low_msb := slv_rx_data(23 DOWNTO 16);
						vi.out_config.intb_mode := slv_rx_data(10 DOWNTO 8);		
						vi.out_config.pwr_mode	 := slv_rx_data(0);
						vi.out_config.frequency_divider := it_config.frequency_divider;
						vi.state_after_wait := idle;
						vi.state := wait_for_next_transfer;
						vi.update_config := '0';
						vi.confi_done := '1';
					END IF;
	
				
				--######### write configuration ######### 
				WHEN write_config_1_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := WRITE_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := DEVICE_ID_ADDRESS;
					vi.tx_data(39 DOWNTO 32) := it_config.rp_max;
					vi.tx_data(31 DOWNTO 24) := it_config.rp_min;
					vi.tx_data(23 DOWNTO 16) := it_config.min_sens_freq;
					vi.tx_data(12 DOWNTO 11) := it_config.amplitude;
					vi.tx_data(10 DOWNTO 8) := it_config.response_time;
					vi.tx_start := '1';
					vi.ratio := it_config.frequency_divider/2;
					vi.state := write_config_1_end;
				WHEN write_config_1_end => 	
					IF sl_rx_done = '1' THEN
						vi.state_after_wait := write_config_2_start;
						vi.state := wait_for_next_transfer;
					END IF;
				WHEN write_config_2_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := WRITE_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := RESERVED_ADDRESS;
					vi.tx_data(39 DOWNTO 32) := it_config.threshold_high_msb;
					vi.tx_data(23 DOWNTO 16) := it_config.threshold_low_msb;
					vi.tx_data(10 DOWNTO 8) := it_config.intb_mode;
					vi.tx_data(0) := it_config.pwr_mode;
					vi.tx_start := '1';
					vi.state := write_config_2_end;
				WHEN write_config_2_end => 	
					IF sl_rx_done = '1' THEN
						vi.state_after_wait := read_config_1_start;
						vi.state := wait_for_next_transfer;
					END IF;
					
				--######### read data #########	
				WHEN update_data_regs_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := STATUS_ADDRESS;
					vi.tx_start := '1';
					vi.state := update_data_regs_end;
 				WHEN update_data_regs_end => 
					IF sl_rx_done = '1' THEN
						vi.data.OSC_dead:= slv_rx_data(47);
						vi.data.DRDYB:= slv_rx_data(46);
						vi.data.wake_up:= slv_rx_data(45);
						vi.data.comperator:= slv_rx_data(44);
						vi.data.proximity := slv_rx_data(39 DOWNTO 24);
						vi.data.frequency_counter := slv_rx_data(23 DOWNTO 0);
						vi.state_after_wait := idle;
						vi.state := wait_for_next_transfer;
					END IF;
				WHEN wait_for_next_transfer =>
					vi.counter := vi.counter + 1;
					if vi.counter >= HOLD_TIME THEN
						vi.counter := (OTHERS => '0');
						vi.state := vi.state_after_wait; 
					END IF;
				
				
				WHEN OTHERS =>
					vi.state := idle; 
			END CASE;
			
			--reset
			IF isl_reset_n = '0' THEN
				vi.state := read_config_1_start; 				
				vi.state_after_wait := read_config_1_start;
				vi.tx_data := (OTHERS => '0');
				vi.tx_start := '0';
				vi.data.OSC_dead := '0';
				vi.data.DRDYB := '0';
				vi.data.wake_up := '0';
				vi.data.comperator := '0';
				vi.data.proximity := (OTHERS => '0');
				vi.data.frequency_counter := (OTHERS => '0');
				vi.out_config.device_id := (OTHERS => '0');
				vi.out_config.rp_max := (OTHERS => '0');
				vi.out_config.rp_min := (OTHERS => '0');
				vi.out_config.min_sens_freq := (OTHERS => '0');
				vi.out_config.threshold_high_msb := (OTHERS => '0');
				vi.out_config.threshold_low_msb := (OTHERS => '0');
				vi.out_config.amplitude := (OTHERS => '0');
				vi.out_config.response_time := (OTHERS => '0');
				vi.out_config.intb_mode := (OTHERS => '0');
				vi.out_config.frequency_divider := (OTHERS => '0');
				vi.out_config.pwr_mode := '0';
				vi.update_config := '1';
				vi.ratio := (OTHERS => '0');
				vi.counter := (OTHERS => '0');
				vi.confi_done := '0';
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
		
		osl_configuring <= ri.update_config;
		ot_config <= ri.out_config;
		ot_data	<= ri.data;
		osl_confi_done <= ri.confi_done;
		
END ARCHITECTURE rtl;


