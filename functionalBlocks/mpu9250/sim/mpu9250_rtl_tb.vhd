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

USE work.mpu9250_pkg.ALL;

ENTITY mpu9250_rtl_tb IS
END ENTITY mpu9250_rtl_tb;

ARCHITECTURE sim OF mpu9250_rtl_tb IS
	--Sumulation Parameter:
	CONSTANT main_period : TIME := 30.3 ns;
	CONSTANT spi_period : TIME := 10 us; 
		
	SIGNAL sl_clk				: STD_LOGIC := '0';
	SIGNAL sl_reset_n			: STD_LOGIC := '0';
	
	SIGNAL sl_sclk				: STD_LOGIC := '0';
	SIGNAL slv_cs_n				: STD_LOGIC := '0';
	SIGNAL sl_sdo				: STD_LOGIC := '1';
	SIGNAL sl_sdi				: STD_LOGIC := '0';
	
	
	SIGNAL data					: t_data_regs;
	SIGNAL out_conf				: t_config;
	SIGNAL in_conf				: t_config;
	SIGNAL sl_configuring		: STD_LOGIC := '0';
	SIGNAL sl_update_config		: STD_LOGIC := '0';
	SIGNAL sl_update_done		: STD_LOGIC := '0';
	
BEGIN
	--create component
	my_unit_under_test : mpu9250 
	GENERIC MAP(
			BASE_CLK 			=> 33000000,
			SCLK_FREQUENCY		=> 100000
		)
		PORT MAP(
			isl_clk				=> sl_clk,
			isl_reset_n    		=> sl_reset_n,
			
			osl_sclk			=> sl_sclk,
			oslv_cs_n			=> slv_cs_n,
			isl_sdo				=> sl_sdo,
			osl_sdi				=> sl_sdi,
			
			ot_data				=> data,
			it_conf				=> in_conf,
			ot_conf				=> out_conf,
			osl_configuring		=> sl_configuring,
			isl_update_config	=> sl_update_config,
			osl_update_done		=> sl_update_done
		);
		
	sl_clk 		<= NOT sl_clk after main_period/2;
	
	tb_main_proc : PROCESS
	BEGIN
	
			in_conf.acceleration_offset_x <= (OTHERS => '0');
			in_conf.acceleration_offset_y <= (OTHERS => '0');
			in_conf.acceleration_offset_z <= (OTHERS => '0');
			in_conf.gyro_offset_x <= (OTHERS => '0');
			in_conf.gyro_offset_y <= (OTHERS => '0');
			in_conf.gyro_offset_z <= (OTHERS => '0');
			in_conf.samplerate_divider <= (OTHERS => '0');
			in_conf.DLPF_CFG <= (OTHERS => '0');
			in_conf.EXT_SYNC_SET  <= (OTHERS => '0');
			in_conf.FIFO_MODE <= '0';
			in_conf.FCHOICE_B <= (OTHERS => '0');
			in_conf.GYRO_FS_SEL <= (OTHERS => '0');
			in_conf.ZGYRO_Cten <= '0';
			in_conf.YGYRO_Cten <= '0';
			in_conf.XGYRO_Cten <= '0';
			in_conf.ACCEL_FS_SEL <= (OTHERS => '0');
			in_conf.az_st_en <= '0';
			in_conf.ay_st_en <= '0';
			in_conf.ax_st_en <= '0';
			in_conf.A_DLPF_CFG <= '0';
			in_conf.ACCEL_FCHOICE_B <= '0';
			in_conf.Lposc_clksel <= (OTHERS => '0');
	
	
			sl_reset_n	<=	'0';
		WAIT FOR 2*main_period;
			sl_reset_n	<=	'1';
		WAIT FOR 2000*spi_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;

END ARCHITECTURE sim;

