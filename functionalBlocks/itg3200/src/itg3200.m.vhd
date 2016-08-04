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
USE work.i2c_master_pkg.ALL;
-------------------------------------------------------------------------------
-- PACKAGE DEFINITION
-------------------------------------------------------------------------------
PACKAGE itg3200_pkg IS
	CONSTANT NR_OF_DATA_REGS : INTEGER := 6;
	CONSTANT WAIT_CYCLES : INTEGER := 2014;
	
	CONSTANT WHO_AM_I : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"00";
	CONSTANT SMPLRT_DIV : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"15";
	CONSTANT DLPF_FS : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"16";
	CONSTANT INT_CFG : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"17";
	CONSTANT INT_STATUS : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"1A";
	CONSTANT TEMP_OUT_H : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"1B";
	CONSTANT TEMP_OUT_L : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"1C";
	CONSTANT GYRO_XOUT_H : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"1D";
	CONSTANT GYRO_XOUT_L : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"1E";
	CONSTANT GYRO_YOUT_H : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"1F";
	CONSTANT GYRO_YOUT_L : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"20";
	CONSTANT GYRO_ZOUT_H : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"21";
	CONSTANT GYRO_ZOUT_L : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"22";
	CONSTANT PWR_MGM : STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0) := x"3E";
	
	
	
	Type t_data_regs IS ARRAY(NR_OF_DATA_REGS-1 DOWNTO 0) OF STD_LOGIC_VECTOR(REGISTER_WIDTH - 1 DOWNTO 0);
	
	
	
	COMPONENT itg3200 IS
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
			ot_data						: OUT t_data_regs
		);
	END COMPONENT itg3200;

END PACKAGE itg3200_pkg;	


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.itg3200_pkg.ALL;
USE work.i2c_master_pkg.ALL;
-------------------------------------------------------------------------------
-- ENTITIY
-------------------------------------------------------------------------------
ENTITY itg3200 IS
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
			ot_data						: OUT t_data_regs
		);
END ENTITY itg3200;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF itg3200 IS	
	
	TYPE t_states IS (	idle,write_power_mode,write_samplerate,read_gyro_out
					);

	TYPE t_internal_register IS RECORD
		state				: t_states;
		dev_address	: STD_LOGIC_VECTOR(DEV_ADDRESS_WIDTH-1 DOWNTO 0);
		byte_count : UNSIGNED(3 DOWNTO 0);
		out_data : t_data_regs;
		register_address : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
		write_data : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
		start_transfer : STD_LOGIC;
		write_n_read	: STD_LOGIC;
		enable_burst_transfer : STD_LOGIC;
	END RECORD;
	
	
	CONSTANT INTERNAL_REG_RESET : t_internal_register := (
									state => idle,
									byte_count => (OTHERS => '0'),
									out_data => (OTHERS => (OTHERS => '0')),
									dev_address => (OTHERS => '0'),
									register_address => (OTHERS => '0'),
									write_data => (OTHERS => '0'),
									start_transfer => '0',
									write_n_read => '0',
									enable_burst_transfer => '0'						   
     );
	
	
	
	SIGNAL ri, ri_next : t_internal_register := INTERNAL_REG_RESET;

	SIGNAL read_data : STD_LOGIC_VECTOR(REGISTER_WIDTH-1 DOWNTO 0);
	SIGNAL transfer_done : STD_LOGIC; 
 
	
	BEGIN
	
	--create component
	my_i2c : i2c_master 
	GENERIC MAP(
			BASE_CLK 			=> 250000000
		)
		PORT MAP(
			isl_clk				=> isl_clk,
			isl_reset_n    		=> isl_reset_n,
			
			
			
			osl_scl => osl_scl,
			oisl_sda => oisl_sda,
			--internal signals
			islv_dev_address => ri.dev_address,	
			islv_register_address => ri.register_address,
			islv_write_data => ri.write_data,
			oslv_read_data => read_data,
			isl_start_transfer => ri.start_transfer, 
			isl_write_n_read => ri.write_n_read,
			isl_enable_burst_transfer => ri.enable_burst_transfer,
			osl_transfer_done => transfer_done
		);
	
	
	
	
	
		--------------------------------------------
		-- combinatorial process
		--------------------------------------------
		comb_process: PROCESS(ri, isl_reset_n,transfer_done,read_data)
		
		VARIABLE vi: t_internal_register;
		
		
		BEGIN
			-- keep variables stable
			vi:=ri;
			
			CASE vi.state IS 
				WHEN idle => 
					vi.state := write_power_mode;
				
				WHEN write_power_mode => 
					vi.dev_address := "1101000";
					vi.register_address := DLPF_FS;
					vi.write_data := x"19";
					vi.start_transfer := '1';
					vi.write_n_read := '1';
					vi.enable_burst_transfer := '0';
					IF(transfer_done = '1') THEN
						vi.start_transfer := '0';
						vi.state := write_samplerate;
					END IF;
				WHEN write_samplerate => 
					vi.dev_address := "1101000";
					vi.register_address := PWR_MGM;
					vi.write_data := x"03";
					vi.start_transfer := '1';
					vi.write_n_read := '1';
					vi.enable_burst_transfer := '0';
					IF(transfer_done = '1') THEN
						vi.start_transfer := '0';
						vi.state := read_gyro_out;
						vi.byte_count := (OTHERS => '0');
						vi.enable_burst_transfer := '1';
					END IF;
				WHEN read_gyro_out => 
					vi.dev_address := "1101000";
					vi.register_address := GYRO_XOUT_H;
					vi.start_transfer := '1';
					vi.write_n_read := '0';
					IF(transfer_done = '1') THEN
						vi.out_data(to_integer(vi.byte_count)) := read_data;
						vi.byte_count := vi.byte_count + 1;
						IF(vi.byte_count = NR_OF_DATA_REGS-1) THEN
							vi.enable_burst_transfer := '0';
						
						ELSIF(vi.byte_count = NR_OF_DATA_REGS) THEN
							vi.start_transfer := '0';
							vi.enable_burst_transfer := '1';
							vi.byte_count := (OTHERS => '0');
							vi.state := read_gyro_out;
						END IF;
					END IF;
				
				WHEN OTHERS =>
					vi.state := idle; 
			END CASE;
			
			--reset
			IF isl_reset_n = '0' THEN
				vi:= INTERNAL_REG_RESET;			
				
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

		ot_data <= ri.out_data;
		
END ARCHITECTURE rtl;


