-------------------------------------------------------------------------------
--  _________     _____      _____    ____  _____    ___  ____               --
-- |_   ___  |  |_   _|     |_   _|  |_   \|_   _|  |_  ||_  _|              --
--   | |_  \_|    | |         | |      |   \ | |      | |_/ /                --
--   |  _|        | |   _     | |      | |\ \| |      |  __'.                --
--  _| |_        _| |__/ |   _| |_    _| |_\   |_    _| |  \ \_              --
-- |_____|      |________|  |_____|  |_____|\____|  |____||____|             --
--                                                                           --
-------------------------------------------------------------------------------
--                                                                           --
-- fLink definitions                                                         --
--                                                                           --
--  THIS FILE WAS CREATED AUTOMATICALLY - do not change                      --
--                                                                           --
--  Created with: flinkinterface/func_id/                                    --
--                   create_flink_definitions.vhd_flinkVHDL.sh               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright 2014 NTB University of Applied Sciences in Technology           --
--                                                                           --
-- Licensed under the Apache License, Version 2.0 (the "License");           --
-- you may not use this file except in compliance with the License.          --
-- You may obtain a copy of the License at                                   --
--                                                                           --
-- http://www.apache.org/licenses/LICENSE-2.0                                --
--                                                                           --
-- Unless required by applicable law or agreed to in writing, software       --
-- distributed under the License is distributed on an "AS IS" BASIS,         --
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  --
-- See the License for the specific language governing permissions and       --
-- limitations under the License.                                            --
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE fLink_definitions IS

	-- Global
	CONSTANT c_fLink_avs_data_width						: INTEGER := 32;
	CONSTANT c_fLink_avs_data_width_in_byte 			: INTEGER := c_fLink_avs_data_width/8;

	-- Header registers
	CONSTANT c_fLink_number_of_std_registers			: INTEGER := 8;
	
	CONSTANT c_fLink_typdef_address						: INTEGER := 0;
	CONSTANT c_fLink_mem_size_address					: INTEGER := 1;
	CONSTANT c_fLink_number_of_channels_address 		: INTEGER := 2;
	CONSTANT c_fLink_unique_id_address					: INTEGER := 3;
	CONSTANT c_fLink_status_address						: INTEGER := 4;
	CONSTANT c_fLink_configuration_address				: INTEGER := 5;
	
	CONSTANT c_fLink_id_length			 				: INTEGER := 16;
	CONSTANT c_fLink_subtype_length						: INTEGER := 8;
	CONSTANT c_fLink_interface_version_length			: INTEGER := 8;
	
	CONSTANT c_fLink_reset_bit_num						: INTEGER := 0;
	
	-- Interface IDs:
	CONSTANT c_fLink_info_id							: INTEGER RANGE 0 TO 65535 := 0;
	CONSTANT c_fLink_analog_input_id					: INTEGER RANGE 0 TO 65535 := 1;
	CONSTANT c_fLink_analog_output_id					: INTEGER RANGE 0 TO 65535 := 2;
	CONSTANT c_fLink_digital_io_id						: INTEGER RANGE 0 TO 65535 := 5;
	CONSTANT c_fLink_counter_id							: INTEGER RANGE 0 TO 65535 := 6;
	CONSTANT c_fLink_timer_id							: INTEGER RANGE 0 TO 65535 := 7;
	CONSTANT c_fLink_memory_id							: INTEGER RANGE 0 TO 65535 := 8;
	CONSTANT c_fLink_pwm_out_id							: INTEGER RANGE 0 TO 65535 := 12;
	CONSTANT c_fLink_ppwa_id							: INTEGER RANGE 0 TO 65535 := 13;
	CONSTANT c_fLink_watchdog_id						: INTEGER RANGE 0 TO 65535 := 16;
	CONSTANT c_fLink_sensor_id							: INTEGER RANGE 0 TO 65535 := 17;
 
 END PACKAGE fLink_definitions; 

