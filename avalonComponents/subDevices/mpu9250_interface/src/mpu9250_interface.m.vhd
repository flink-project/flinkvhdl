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
USE IEEE.math_real.ALL;

USE work.fLink_definitions.ALL;

PACKAGE mpu9250_interface_pkg IS

	CONSTANT c_mpu9250_interface_address_width			: INTEGER := 5;

	COMPONENT mpu9250_interface IS
			GENERIC (
				BASE_CLK: INTEGER := 33000000; 
				SCLK_FREQUENCY : INTEGER := 100000;
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_mpu9250_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					osl_sclk				: OUT STD_LOGIC;
					oslv_cs_n				: OUT STD_LOGIC;
					isl_sdo					: IN STD_LOGIC;
					osl_sdi					: OUT STD_LOGIC
			);
	END COMPONENT;

	CONSTANT c_mpu9250_subtype_id : STD_LOGIC_VECTOR(c_fLink_subtype_length-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(2,c_fLink_subtype_length));
	CONSTANT c_mpu9250_interface_version : STD_LOGIC_VECTOR(c_fLink_interface_version_length-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0,c_fLink_interface_version_length));


END PACKAGE mpu9250_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.mpu9250_interface_pkg.ALL;
USE work.fLink_definitions.ALL;
USE work.mpu9250_pkg.ALL;

ENTITY mpu9250_interface IS
			GENERIC (
				BASE_CLK: INTEGER := 33000000; 
				SCLK_FREQUENCY : INTEGER := 100000;
				UNIQUE_ID: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN STD_LOGIC;
					isl_reset_n				: IN STD_LOGIC;
					islv_avs_address		: IN STD_LOGIC_VECTOR(c_mpu9250_interface_address_width-1 DOWNTO 0);
					isl_avs_read			: IN STD_LOGIC;
					isl_avs_write			: IN STD_LOGIC;
					islv_avs_write_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					islv_avs_byteenable		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					oslv_avs_read_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					osl_avs_waitrequest		: OUT STD_LOGIC;
					osl_sclk				: OUT STD_LOGIC;
					oslv_cs_n				: OUT STD_LOGIC;
					isl_sdo					: IN STD_LOGIC;
					osl_sdi					: OUT STD_LOGIC
			);

	CONSTANT c_configuration_address:			UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_configuration_address,c_mpu9250_interface_address_width);
	CONSTANT c_status_address:					UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_status_address,c_mpu9250_interface_address_width);
	CONSTANT c_typdef_address :					UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_typdef_address,c_mpu9250_interface_address_width);
	CONSTANT c_mem_size_address:				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_mem_size_address,c_mpu9250_interface_address_width);
	CONSTANT c_number_of_channels_address: 		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_channels_address,c_mpu9250_interface_address_width);
	CONSTANT c_unique_id_address: 				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_unique_id_address,c_mpu9250_interface_address_width);
	
	CONSTANT c_usig_accel_offset_x_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_mpu9250_interface_address_width);
	CONSTANT c_usig_accel_offset_y_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_accel_offset_x_address + 1;
	CONSTANT c_usig_accel_offset_z_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_accel_offset_y_address + 1;
	CONSTANT c_usig_gyro_offset_x_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_accel_offset_z_address + 1;
	CONSTANT c_usig_gyro_offset_y_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_gyro_offset_x_address + 1;
	CONSTANT c_usig_gyro_offset_z_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_gyro_offset_y_address + 1;
	CONSTANT c_usig_acceleration_x_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_gyro_offset_z_address + 1;
	CONSTANT c_usig_acceleration_y_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_acceleration_x_address + 1;
	CONSTANT c_usig_acceleration_z_address:		UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_acceleration_y_address + 1;
	CONSTANT c_usig_gyro_x_address:				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_acceleration_z_address + 1;
	CONSTANT c_usig_gyro_y_address:				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_gyro_x_address + 1;
	CONSTANT c_usig_gyro_z_address:				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_gyro_y_address + 1;
	CONSTANT c_usig_mag_x_address:				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_gyro_z_address + 1;
	CONSTANT c_usig_mag_y_address:				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_mag_x_address + 1;
	CONSTANT c_usig_mag_z_address:				UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := c_usig_mag_y_address + 1;

	
END ENTITY mpu9250_interface;

ARCHITECTURE rtl OF mpu9250_interface IS

	TYPE t_internal_register IS RECORD
			global_reset_n		: STD_LOGIC;
			mpu9250_reset_n			: STD_LOGIC;
			in_conf				: t_config;
			sl_update_config	: STD_LOGIC;	
	END RECORD;

	SIGNAL ri,ri_next : t_internal_register;
	SIGNAL mpu9250_data	: t_data_regs;
	SIGNAL out_conf : t_config;
	SIGNAL sl_configuring : STD_LOGIC;
	SIGNAL sl_update_done : STD_LOGIC;
BEGIN
	my_mpu9250 : mpu9250 
		GENERIC MAP (BASE_CLK,SCLK_FREQUENCY)
		PORT MAP (isl_clk,ri.mpu9250_reset_n,
					osl_sclk,oslv_cs_n,isl_sdo,osl_sdi,					
					mpu9250_data,ri.in_conf,out_conf,sl_configuring,ri.sl_update_config,sl_update_done
				);

				
	-- cobinatoric process
	comb_proc : PROCESS (isl_reset_n,ri,isl_avs_write,islv_avs_address,isl_avs_read,islv_avs_write_data,mpu9250_data,islv_avs_byteenable,out_conf,sl_configuring,sl_update_done)
		VARIABLE vi :	t_internal_register;
		VARIABLE address: UNSIGNED(c_mpu9250_interface_address_width-1 DOWNTO 0) := to_unsigned(0,c_mpu9250_interface_address_width);
	BEGIN
		-- keep variables stable
		vi := ri;	

		--standard values
		oslv_avs_read_data <= (OTHERS => '0');
		vi.global_reset_n := '1';
		vi.mpu9250_reset_n := '1';
		vi.sl_update_config := '0';
		address := UNSIGNED(islv_avs_address);
		
		
		--avalon slave interface write part
		IF isl_avs_write = '1' THEN
			CASE address IS
				WHEN c_configuration_address =>
					IF islv_avs_byteenable(0) = '1' THEN
							vi.global_reset_n := NOT islv_avs_write_data(c_fLink_reset_bit_num);
							vi.sl_update_config := islv_avs_write_data(1);
							vi.in_conf.GYRO_FS_SEL := islv_avs_write_data(3 DOWNTO 2);
							vi.in_conf.ACCEL_FS_SEL := islv_avs_write_data(5 DOWNTO 4);
					END IF;
				WHEN c_usig_accel_offset_x_address =>
					IF islv_avs_byteenable(0) = '1' THEN
						vi.in_conf.acceleration_offset_x(7 DOWNTO 0) := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
						vi.in_conf.acceleration_offset_x(15 DOWNTO 8) := islv_avs_write_data(15 DOWNTO 8);
					END IF;
				WHEN c_usig_accel_offset_y_address =>
					IF islv_avs_byteenable(0) = '1' THEN
						vi.in_conf.acceleration_offset_y(7 DOWNTO 0) := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
						vi.in_conf.acceleration_offset_y(15 DOWNTO 8) := islv_avs_write_data(15 DOWNTO 8);
					END IF;
				WHEN c_usig_accel_offset_z_address =>
					IF islv_avs_byteenable(0) = '1' THEN
						vi.in_conf.acceleration_offset_z(7 DOWNTO 0) := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
						vi.in_conf.acceleration_offset_z(15 DOWNTO 8) := islv_avs_write_data(15 DOWNTO 8);
					END IF;
				WHEN c_usig_gyro_offset_x_address =>
					IF islv_avs_byteenable(0) = '1' THEN
						vi.in_conf.gyro_offset_x(7 DOWNTO 0) := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
						vi.in_conf.gyro_offset_x(15 DOWNTO 8) := islv_avs_write_data(15 DOWNTO 8);
					END IF;
				WHEN c_usig_gyro_offset_y_address =>
					IF islv_avs_byteenable(0) = '1' THEN
						vi.in_conf.gyro_offset_y(7 DOWNTO 0) := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
						vi.in_conf.gyro_offset_y(15 DOWNTO 8) := islv_avs_write_data(15 DOWNTO 8);
					END IF;
				WHEN c_usig_gyro_offset_z_address =>
					IF islv_avs_byteenable(0) = '1' THEN
						vi.in_conf.gyro_offset_z(7 DOWNTO 0) := islv_avs_write_data(7 DOWNTO 0);
					END IF;
					IF islv_avs_byteenable(1) = '1' THEN
						vi.in_conf.gyro_offset_z(15 DOWNTO 8) := islv_avs_write_data(15 DOWNTO 8);
					END IF;
				WHEN OTHERS => 
			END CASE;
		END IF;

		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE address IS
				WHEN c_typdef_address =>
					oslv_avs_read_data ((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO 
												(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_sensor_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= c_mpu9250_subtype_id;
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  c_mpu9250_interface_version;
				WHEN c_mem_size_address => 
					oslv_avs_read_data(c_mpu9250_interface_address_width+2) <= '1';
				WHEN c_number_of_channels_address => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(1,c_fLink_avs_data_width));
				WHEN c_unique_id_address => 
					oslv_avs_read_data <= UNIQUE_ID;
				WHEN c_status_address => 
					oslv_avs_read_data(0) <= sl_configuring;
				WHEN c_configuration_address => 
					oslv_avs_read_data(c_fLink_reset_bit_num) <= NOT vi.global_reset_n;
					oslv_avs_read_data(1) <= vi.sl_update_config; 
					oslv_avs_read_data(3 DOWNTO 2) <= vi.in_conf.GYRO_FS_SEL; 
					oslv_avs_read_data(5 DOWNTO 4) <= vi.in_conf.ACCEL_FS_SEL; 
				WHEN c_usig_accel_offset_x_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= vi.in_conf.acceleration_offset_x;
				WHEN c_usig_accel_offset_y_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= vi.in_conf.acceleration_offset_y;
				WHEN c_usig_accel_offset_z_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= vi.in_conf.acceleration_offset_z;
				WHEN c_usig_gyro_offset_x_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= vi.in_conf.gyro_offset_x;
				WHEN c_usig_gyro_offset_y_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= vi.in_conf.gyro_offset_y;
				WHEN c_usig_gyro_offset_z_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= vi.in_conf.gyro_offset_z;
				WHEN c_usig_acceleration_x_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.acceleration_x;
				WHEN c_usig_acceleration_y_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.acceleration_y;
				WHEN c_usig_acceleration_z_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.acceleration_z;
				WHEN c_usig_gyro_x_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.gyro_data_x;
				WHEN c_usig_gyro_y_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.gyro_data_y;
				WHEN c_usig_gyro_z_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.gyro_data_z;
				WHEN c_usig_mag_x_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.mag_data_x;
				WHEN c_usig_mag_y_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.mag_data_y;
				WHEN c_usig_mag_z_address =>
					oslv_avs_read_data(2*REGISTER_WIDTH-1 DOWNTO 0) <= mpu9250_data.mag_data_z;
				WHEN OTHERS => 
			END CASE;
		END IF;

		IF sl_update_done = '1' THEN
			vi.in_conf := out_conf;
		END IF;
		
		
		
		IF isl_reset_n = '0' OR vi.global_reset_n = '0'  THEN
			vi.mpu9250_reset_n := '0';
			vi.sl_update_config := '0';
			vi.in_conf.acceleration_offset_x := (OTHERS => '0');
			vi.in_conf.acceleration_offset_y := (OTHERS => '0');
			vi.in_conf.acceleration_offset_z := (OTHERS => '0');
			vi.in_conf.gyro_offset_x := (OTHERS => '0');
			vi.in_conf.gyro_offset_y := (OTHERS => '0');
			vi.in_conf.gyro_offset_z := (OTHERS => '0');
			vi.in_conf.samplerate_divider := (OTHERS => '0');
			vi.in_conf.DLPF_CFG := (OTHERS => '0');
			vi.in_conf.EXT_SYNC_SET  := (OTHERS => '0');
			vi.in_conf.FIFO_MODE := '0';
			vi.in_conf.FCHOICE_B := (OTHERS => '0');
			vi.in_conf.GYRO_FS_SEL := (OTHERS => '0');
			vi.in_conf.ZGYRO_Cten := '0';
			vi.in_conf.YGYRO_Cten := '0';
			vi.in_conf.XGYRO_Cten := '0';
			vi.in_conf.ACCEL_FS_SEL := (OTHERS => '0');
			vi.in_conf.az_st_en := '0';
			vi.in_conf.ay_st_en := '0';
			vi.in_conf.ax_st_en := '0';
			vi.in_conf.A_DLPF_CFG := '0';
			vi.in_conf.ACCEL_FCHOICE_B := '0';
			vi.in_conf.Lposc_clksel := (OTHERS => '0');
			
		END IF;
		
		--keep variables stable
		ri_next <= vi;
	
	END PROCESS comb_proc;
	
	reg_proc : PROCESS (isl_clk)
	BEGIN
		IF rising_edge(isl_clk) THEN
			ri <= ri_next;
		END IF;
	END PROCESS reg_proc;

	osl_avs_waitrequest <= '0';

END rtl;









