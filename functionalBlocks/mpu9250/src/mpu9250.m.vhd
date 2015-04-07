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
PACKAGE mpu9250_pkg IS
	CONSTANT REGISTER_WIDTH : INTEGER := 8;
	
	TYPE t_data_regs IS RECORD
		acceleration_x		: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		acceleration_y		: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		acceleration_z		: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		gyro_data_x			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		gyro_data_y			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		gyro_data_z			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		mag_data_x			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		mag_data_y			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		mag_data_z			: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
	END RECORD;
	
	TYPE t_config IS RECORD
		acceleration_offset_x		: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		acceleration_offset_y		: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		acceleration_offset_z		: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		gyro_offset_x				: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		gyro_offset_y				: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		gyro_offset_z				: STD_LOGIC_VECTOR(2*REGISTER_WIDTH-1 DOWNTO 0);
		samplerate_divider			: STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
		DLPF_CFG					: STD_LOGIC_VECTOR(2 DOWNTO 0);
		EXT_SYNC_SET				: STD_LOGIC_VECTOR(2 DOWNTO 0);
		FIFO_MODE					: STD_LOGIC;
		FCHOICE_B					: STD_LOGIC_VECTOR(1 DOWNTO 0);
		GYRO_FS_SEL					: STD_LOGIC_VECTOR(1 DOWNTO 0);
		ZGYRO_Cten					: STD_LOGIC;
		YGYRO_Cten					: STD_LOGIC;
		XGYRO_Cten					: STD_LOGIC;
		ACCEL_FS_SEL				: STD_LOGIC_VECTOR(1 DOWNTO 0);
		az_st_en					: STD_LOGIC;
		ay_st_en					: STD_LOGIC;
		ax_st_en					: STD_LOGIC;
		A_DLPF_CFG					: STD_LOGIC;
		ACCEL_FCHOICE_B				: STD_LOGIC;
		Lposc_clksel				: STD_LOGIC_VECTOR(3 DOWNTO 0);
	END RECORD;
	
	
	
	COMPONENT mpu9250 IS
		GENERIC(
			BASE_CLK : INTEGER := 250000000; 
			SCLK_FREQUENCY : INTEGER := 4000000  --Max 4MHz
		);
		PORT(
			isl_clk						: IN STD_LOGIC;
			isl_reset_n    				: IN STD_LOGIC;
			--sensor signals
			osl_sclk					: OUT STD_LOGIC;
			oslv_cs_n					: OUT STD_LOGIC;
			isl_sdo						: IN STD_LOGIC;
			osl_sdi						: OUT STD_LOGIC;
			--internal signals
			ot_data						: OUT t_data_regs;
			it_conf						: IN t_config;
			ot_conf						: OUT t_config;
			osl_configuring				: OUT STD_LOGIC;
			isl_update_config			: IN STD_LOGIC;
			osl_update_done				: OUT STD_LOGIC
		);
	END COMPONENT mpu9250;

END PACKAGE mpu9250_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.mpu9250_pkg.ALL;
USE work.spi_master_pkg.ALL;

-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY mpu9250 IS
		GENERIC(
			BASE_CLK : INTEGER := 250000000; 
			SCLK_FREQUENCY : INTEGER := 4000000  --Max 4MHz
		);
		PORT(
			isl_clk						: IN STD_LOGIC;
			isl_reset_n    				: IN STD_LOGIC;
			--sensor signals
			osl_sclk					: OUT STD_LOGIC;
			oslv_cs_n					: OUT STD_LOGIC;
			isl_sdo						: IN STD_LOGIC;
			osl_sdi						: OUT STD_LOGIC;
			--internal signals
			ot_data						: OUT t_data_regs;
			it_conf						: IN t_config;
			ot_conf						: OUT t_config;
			osl_configuring				: OUT STD_LOGIC;
			isl_update_config			: IN STD_LOGIC;
			osl_update_done				: OUT STD_LOGIC
		);
END ENTITY mpu9250;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF mpu9250 IS
	CONSTANT WRITE_TRANSFER : STD_LOGIC := '0';
	CONSTANT READ_TRANSFER : STD_LOGIC := '1';
	CONSTANT SS_HOLD_CYCLES : INTEGER := 40; -- add 2 to be sure and have a minimum number of cycles
	CONSTANT TRANSFER_WIDTH : INTEGER := 56;
	CONSTANT ACCEL_XOUT_L_ADDRESS : STD_LOGIC_VECTOR := "0111011";
	CONSTANT GYRO_XOUT_L_ADDRESS : STD_LOGIC_VECTOR := "1000011";
	CONSTANT XG_OFFSET_H_ADDRESS : STD_LOGIC_VECTOR := "0010011";
	CONSTANT SMPLRT_DIV_ADDRESS : STD_LOGIC_VECTOR := "0011001";
	CONSTANT XA_OFFSET_H_ADDRESS : STD_LOGIC_VECTOR := "1110111";
	CONSTANT I2C_SLV0_ADDR_ADDRESS : STD_LOGIC_VECTOR := "0100101";
	CONSTANT EXT_SENS_DATA_00_ADDRESS : STD_LOGIC_VECTOR := "1001001";
	CONSTANT USER_CTRL_ADDRESS : STD_LOGIC_VECTOR := "1101010";
	CONSTANT I2C_MST_CTRL : STD_LOGIC_VECTOR := "0100100";
	
	CONSTANT I2C_READ : STD_LOGIC := '1';
	CONSTANT MAG_I2C_ADDRESS : STD_LOGIC_VECTOR := "0001100";
	CONSTANT MAG_DATA_ADDRESS : STD_LOGIC_VECTOR := x"03";
	
	CONSTANT COUNTER_WIDTH : INTEGER := 16;
	
	CONSTANT HOLD_TIME : UNSIGNED(COUNTER_WIDTH-1 DOWNTO 0) := to_unsigned(1000,COUNTER_WIDTH);
	CONSTANT I2C_WAIT_TIME : UNSIGNED(COUNTER_WIDTH-1 DOWNTO 0) := to_unsigned(60000,COUNTER_WIDTH);
		
	TYPE t_states IS (	idle,
						enable_i2c_master,enable_i2c_master_wait,
						write_gyro_offset_start, write_gyro_offset_wait, 
						read_gyro_offset_start,read_gyro_offset_wait,
						write_conf_start, write_conf_wait, 
						read_conf_start, read_conf_wait,
						write_accel_offset_start, write_accel_offset_wait, 
						read_accel_offset_start,read_accel_offset_wait,
						read_acc_data_start,read_acc_data_wait,
						read_gyro_data_start,read_gyro_data_wait,
						read_mag_data_start,read_mag_data_wait_1,read_mag_data_wait_i2c_end,read_mag_data_i2c_receive_data,read_mag_data_i2c_receive_wait,
						wait_for_next_transfer
						
					);

	TYPE t_internal_register IS RECORD
		state				: t_states;
		tx_data 			: STD_LOGIC_VECTOR(TRANSFER_WIDTH -1 DOWNTO 0);
		tx_start 			: STD_LOGIC;
		data				: t_data_regs;
		conf				: t_config;
		configuring			: STD_LOGIC;
		counter				: UNSIGNED(COUNTER_WIDTH-1 DOWNTO 0);
		state_after_wait	: t_states;
		update_done			: STD_LOGIC;
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
			--for the spi config see data sheet page 16
			CPOL				=> '1', --sclk is normal '1'
			CPHA				=> '1', --data is changed on leading edge and captured on the trialling edge 
			MSBFIRST			=> '1', --MSB first 
			SSPOL				=> '0' --zero active
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
			oslv_Ss(0)				=> oslv_cs_n,
			osl_mosi				=> osl_sdi,
			isl_miso				=> isl_sdo
		);
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,sl_rx_done,slv_rx_data,it_conf,isl_update_config)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			--standard values
			vi.tx_start := '0';
			vi.update_done := '0';
			
			IF isl_update_config = '1' THEN
				vi.configuring := '1'; 
			END IF;
			
			
			CASE vi.state IS 
				WHEN idle => 
						IF vi.configuring = '1' THEN
							vi.state := write_gyro_offset_start;
						ELSE
							vi.state := read_acc_data_start;
						END IF;
				when wait_for_next_transfer => 
					vi.counter := vi.counter + 1;
					IF vi.counter >= HOLD_TIME THEN
						vi.state := vi.state_after_wait;
						vi.counter := (OTHERS => '0');
					END IF;
				
				
				--######### read configuration #########  	
				WHEN read_acc_data_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := ACCEL_XOUT_L_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_acc_data_wait; 
				WHEN read_acc_data_wait => 
					IF sl_rx_done = '1' THEN
						vi.data.acceleration_x := slv_rx_data(47 DOWNTO 32);
						vi.data.acceleration_y := slv_rx_data(31 DOWNTO 16);
						vi.data.acceleration_z := slv_rx_data(15 DOWNTO 0);
						vi.state_after_wait := read_gyro_data_start; 
						vi.state := wait_for_next_transfer; 
					END IF;
				WHEN read_gyro_data_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := GYRO_XOUT_L_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_gyro_data_wait; 
				WHEN read_gyro_data_wait => 
					IF sl_rx_done = '1' THEN
						vi.data.gyro_data_x := slv_rx_data(47 DOWNTO 32);
						vi.data.gyro_data_y := slv_rx_data(31 DOWNTO 16);
						vi.data.gyro_data_z := slv_rx_data(15 DOWNTO 0);
						vi.state_after_wait := read_mag_data_start; 
						vi.state := wait_for_next_transfer; 
					END IF;
				WHEN read_mag_data_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := WRITE_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := I2C_MST_CTRL;
					vi.tx_data(47 DOWNTO 40) := x"0D";
					vi.tx_data(39) := I2C_READ;
					vi.tx_data(38 DOWNTO 32) := MAG_I2C_ADDRESS;
					vi.tx_data(31 DOWNTO 24) := MAG_DATA_ADDRESS;
					vi.tx_data(23 DOWNTO 16) := x"86";
					vi.tx_start := '1';
					vi.state := read_mag_data_wait_1;
				WHEN read_mag_data_wait_1 => 
					IF sl_rx_done = '1' THEN
						vi.state_after_wait := read_mag_data_wait_i2c_end; 
						vi.state := wait_for_next_transfer;
					END IF;
				WHEN read_mag_data_wait_i2c_end => 
					vi.counter := vi.counter + 1;
					IF vi.counter >= I2C_WAIT_TIME THEN
						vi.state := read_mag_data_i2c_receive_data;
						vi.counter := (OTHERS => '0');
					END IF;
				WHEN read_mag_data_i2c_receive_data =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := EXT_SENS_DATA_00_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_mag_data_i2c_receive_wait;
				
				WHEN read_mag_data_i2c_receive_wait =>
					IF sl_rx_done = '1' THEN
						vi.data.mag_data_x := slv_rx_data(47 DOWNTO 32);
						vi.data.mag_data_y := slv_rx_data(31 DOWNTO 16);
						vi.data.mag_data_z := slv_rx_data(15 DOWNTO 0);
						vi.state_after_wait := idle; 
						vi.state := wait_for_next_transfer;
					END IF;
				WHEN read_gyro_offset_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := XG_OFFSET_H_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_gyro_offset_wait; 
				WHEN read_gyro_offset_wait =>
					IF sl_rx_done = '1' THEN
						vi.conf.gyro_offset_x := slv_rx_data(47 DOWNTO 32);
						vi.conf.gyro_offset_y := slv_rx_data(31 DOWNTO 16);
						vi.conf.gyro_offset_z := slv_rx_data(15 DOWNTO 0);
						vi.state_after_wait := read_conf_start; 
						vi.state := wait_for_next_transfer;
					END IF;
				WHEN read_conf_start => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := SMPLRT_DIV_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_conf_wait; 
				WHEN read_conf_wait =>
					IF sl_rx_done = '1' THEN
						vi.conf.samplerate_divider := slv_rx_data(47 DOWNTO 40);
						
						vi.conf.DLPF_CFG := slv_rx_data(34 DOWNTO 32);
						vi.conf.EXT_SYNC_SET := slv_rx_data(37 DOWNTO 35);
						vi.conf.FIFO_MODE := slv_rx_data(38);
						
						vi.conf.FCHOICE_B := slv_rx_data(25 DOWNTO 24);
						vi.conf.GYRO_FS_SEL := slv_rx_data(28 DOWNTO 27);
						vi.conf.ZGYRO_Cten := slv_rx_data(29);
						vi.conf.YGYRO_Cten := slv_rx_data(30);
						vi.conf.XGYRO_Cten := slv_rx_data(31);
						
						vi.conf.ACCEL_FS_SEL := slv_rx_data(20 DOWNTO 19);
						vi.conf.az_st_en := slv_rx_data(21);
						vi.conf.ay_st_en := slv_rx_data(22);
						vi.conf.ax_st_en := slv_rx_data(23);
						
						vi.conf.A_DLPF_CFG := slv_rx_data(8);
						vi.conf.ACCEL_FCHOICE_B := slv_rx_data(9);
						
						vi.conf.Lposc_clksel := slv_rx_data(3 DOWNTO 0);
						vi.state_after_wait := read_accel_offset_start; 
						vi.state := wait_for_next_transfer;
					END IF;
				WHEN read_accel_offset_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := READ_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := XA_OFFSET_H_ADDRESS;
					vi.tx_start := '1';
					vi.state := read_accel_offset_wait; 
				WHEN read_accel_offset_wait	=>
					IF sl_rx_done = '1' THEN
						vi.conf.acceleration_offset_x := slv_rx_data(47 DOWNTO 32);
						vi.conf.acceleration_offset_y := slv_rx_data(31 DOWNTO 16);
						vi.conf.acceleration_offset_z := slv_rx_data(15 DOWNTO 0);
						vi.configuring := '0';
						vi.state_after_wait := idle; 
						vi.state := wait_for_next_transfer;
						vi.update_done := '1';
					END IF;
				WHEN write_gyro_offset_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := WRITE_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := XG_OFFSET_H_ADDRESS;
					vi.tx_data(47 DOWNTO 32) := it_conf.gyro_offset_x;
					vi.tx_data(31 DOWNTO 16) := it_conf.gyro_offset_y;
					vi.tx_data(15 DOWNTO 0) := it_conf.gyro_offset_z;
					vi.tx_start := '1';
					vi.state := write_gyro_offset_wait; 
				WHEN write_gyro_offset_wait =>
					IF sl_rx_done = '1' THEN
						vi.state_after_wait := write_conf_start; 
						vi.state := wait_for_next_transfer; 
					END IF;
				WHEN write_conf_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := WRITE_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := SMPLRT_DIV_ADDRESS;
					vi.tx_data(47 DOWNTO 40) := it_conf.samplerate_divider;
					vi.tx_data(34 DOWNTO 32) := it_conf.DLPF_CFG;
					vi.tx_data(37 DOWNTO 35) := it_conf.EXT_SYNC_SET;
					vi.tx_data(38) := it_conf.FIFO_MODE;
		
					vi.tx_data(25 DOWNTO 24) := it_conf.FCHOICE_B;
					vi.tx_data(28 DOWNTO 27) := it_conf.GYRO_FS_SEL;
					vi.tx_data(29) := it_conf.ZGYRO_Cten;
					vi.tx_data(30) := it_conf.YGYRO_Cten;
					vi.tx_data(31) := it_conf.XGYRO_Cten;
					
					vi.tx_data(20 DOWNTO 19) := it_conf.ACCEL_FS_SEL;
					vi.tx_data(21) := it_conf.az_st_en;
					vi.tx_data(22) := it_conf.ay_st_en;
					vi.tx_data(23) := it_conf.ax_st_en;
					
					vi.tx_data(8) := it_conf.A_DLPF_CFG;
					vi.tx_data(9) := it_conf.ACCEL_FCHOICE_B;
					
					vi.tx_data(3 DOWNTO 0) := it_conf.Lposc_clksel;

					vi.tx_start := '1';
					vi.state := write_conf_wait; 
				WHEN write_conf_wait =>
					IF sl_rx_done = '1' THEN
						vi.state_after_wait := write_accel_offset_start; 
						vi.state := wait_for_next_transfer; 
					END IF;
				WHEN write_accel_offset_start =>
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := WRITE_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := XA_OFFSET_H_ADDRESS;
					vi.tx_data(47 DOWNTO 32) := it_conf.acceleration_offset_x;
					vi.tx_data(31 DOWNTO 16) := it_conf.acceleration_offset_y;
					vi.tx_data(15 DOWNTO 0) := it_conf.acceleration_offset_z;
					vi.tx_start := '1';
					vi.state := write_accel_offset_wait; 
				WHEN write_accel_offset_wait =>
					IF sl_rx_done = '1' THEN
						vi.state_after_wait := read_gyro_offset_start; 
						vi.state := wait_for_next_transfer; 
					END IF;
				WHEN enable_i2c_master => 
					vi.tx_data := (OTHERS => '0');
					vi.tx_data(TRANSFER_WIDTH-1) := WRITE_TRANSFER;
					vi.tx_data(TRANSFER_WIDTH-2 DOWNTO TRANSFER_WIDTH-8) := USER_CTRL_ADDRESS;
					vi.tx_data(47 DOWNTO 40) := x"20";
					vi.tx_data(39 DOWNTO 32) := x"01";
					vi.tx_start := '1';
					vi.state := enable_i2c_master_wait; 
				WHEN enable_i2c_master_wait => 
					IF sl_rx_done = '1' THEN
						vi.state_after_wait := read_gyro_offset_start; 
						vi.state := wait_for_next_transfer; 
					END IF;
				
				
				WHEN OTHERS =>
					vi.state := idle;
			END CASE;
			
			--reset
			IF isl_reset_n = '0' THEN
				vi.state := enable_i2c_master; 
				vi.tx_data := (OTHERS => '0');
				vi.tx_start := '0';
				vi.data.acceleration_x := (OTHERS => '0');
				vi.data.acceleration_y := (OTHERS => '0');
				vi.data.acceleration_z := (OTHERS => '0');
				vi.data.gyro_data_x := (OTHERS => '0');
				vi.data.gyro_data_y := (OTHERS => '0');
				vi.data.gyro_data_z := (OTHERS => '0');
				vi.data.mag_data_x := (OTHERS => '0');
				vi.data.mag_data_y := (OTHERS => '0');
				vi.data.mag_data_z := (OTHERS => '0');
				vi.conf.acceleration_offset_x := (OTHERS => '0');
				vi.conf.acceleration_offset_y := (OTHERS => '0');
				vi.conf.acceleration_offset_z := (OTHERS => '0');
				vi.conf.gyro_offset_x := (OTHERS => '0');
				vi.conf.gyro_offset_y := (OTHERS => '0');
				vi.conf.gyro_offset_z := (OTHERS => '0');
				vi.conf.samplerate_divider := (OTHERS => '0');
				vi.conf.DLPF_CFG := (OTHERS => '0');
				vi.conf.EXT_SYNC_SET  := (OTHERS => '0');
				vi.conf.FIFO_MODE := '0';
				vi.conf.FCHOICE_B := (OTHERS => '0');
				vi.conf.GYRO_FS_SEL := (OTHERS => '0');
				vi.conf.ZGYRO_Cten := '0';
				vi.conf.YGYRO_Cten := '0';
				vi.conf.XGYRO_Cten := '0';
				vi.conf.ACCEL_FS_SEL := (OTHERS => '0');
				vi.conf.az_st_en := '0';
				vi.conf.ay_st_en := '0';
				vi.conf.ax_st_en := '0';
				vi.conf.A_DLPF_CFG := '0';
				vi.conf.ACCEL_FCHOICE_B := '0';
				vi.conf.Lposc_clksel := (OTHERS => '0');
				vi.configuring := '1';
				vi.state_after_wait := idle;
				vi.counter := (OTHERS => '0');
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
		
		-- output assignment
		ot_data	<= ri.data;
		osl_configuring <= ri.configuring;
		ot_conf <= ri.conf;
		osl_update_done <= ri.update_done;
		
		
END ARCHITECTURE rtl;


