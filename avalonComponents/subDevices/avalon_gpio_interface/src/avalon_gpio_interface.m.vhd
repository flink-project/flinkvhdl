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
-- Avalon MM interface for GPIO                                               --
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
USE IEEE.math_real.ALL;
USE work.fLink_definitions.ALL;

PACKAGE avalon_gpio_interface_pkg IS
	CONSTANT c_max_number_of_GPIOs : INTEGER := 128;
	CONSTANT c_gpio_interface_address_with : INTEGER := 4;
	
	
	COMPONENT avalon_gpio_interface IS
			GENERIC (
				number_of_gpios: INTEGER RANGE 1 TO c_max_number_of_GPIOs := 1;
				unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
			);
			PORT (
					isl_clk					: IN    STD_LOGIC;
					isl_reset_n				: IN    STD_LOGIC;
					islv_avs_address		: IN    STD_LOGIC_VECTOR(c_gpio_interface_address_with-1 DOWNTO 0);
					islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
					isl_avs_read			: IN    STD_LOGIC;
					isl_avs_write			: IN    STD_LOGIC;
					osl_avs_waitrequest		: OUT   STD_LOGIC;
					islv_avs_write_data		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					oslv_avs_read_data		: OUT   STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
					oslv_gpios				: INOUT STD_LOGIC_VECTOR(number_of_gpios-1 DOWNTO 0)
			);
	END COMPONENT;

	CONSTANT c_gpio_subtype_id : INTEGER := 0;
	CONSTANT c_gpio_interface_version : INTEGER := 0;


END PACKAGE avalon_gpio_interface_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.avalon_gpio_interface_pkg.ALL;
USE work.fLink_definitions.ALL;


ENTITY avalon_gpio_interface IS
	GENERIC (
		number_of_gpios: INTEGER RANGE 1 TO c_max_number_of_GPIOs := 1;
		unique_id: STD_LOGIC_VECTOR (c_fLink_avs_data_width-1 DOWNTO 0) := (OTHERS => '0')
	);
	PORT (
			isl_clk					: IN    STD_LOGIC;
			isl_reset_n				: IN    STD_LOGIC;
			islv_avs_address		: IN    STD_LOGIC_VECTOR(c_gpio_interface_address_with-1 DOWNTO 0);
			islv_avs_byteenable		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width_in_byte-1 DOWNTO 0);
			isl_avs_read			: IN    STD_LOGIC;
			isl_avs_write			: IN    STD_LOGIC;
			osl_avs_waitrequest		: OUT    STD_LOGIC;
			islv_avs_write_data		: IN    STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			oslv_avs_read_data		: OUT   STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			oslv_gpios				: INOUT STD_LOGIC_VECTOR(number_of_gpios-1 DOWNTO 0)
	);
	
	CONSTANT c_configuration_reg_address: UNSIGNED(c_gpio_interface_address_with-1 DOWNTO 0) := to_unsigned(c_fLink_configuration_address, c_gpio_interface_address_with);
	CONSTANT c_usig_dir_regs_address: UNSIGNED(c_gpio_interface_address_with-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_std_registers,c_gpio_interface_address_with);
	CONSTANT c_usig_number_of_regs: UNSIGNED(c_gpio_interface_address_with-1 DOWNTO 0) := to_unsigned((number_of_gpios-1)/c_fLink_avs_data_width+1,c_gpio_interface_address_with);
	CONSTANT c_usig_value_regs_address: UNSIGNED(c_gpio_interface_address_with-1 DOWNTO 0) := c_usig_dir_regs_address + c_usig_number_of_regs; 
	CONSTANT c_usig_value_regs_max_address: UNSIGNED(c_gpio_interface_address_with-1 DOWNTO 0) := c_usig_value_regs_address + c_usig_number_of_regs;
	
	CONSTANT c_int_nr_of_gpio_reg: INTEGER := number_of_gpios/c_fLink_avs_data_width;
	
END ENTITY avalon_gpio_interface;

ARCHITECTURE rtl OF avalon_gpio_interface IS

	TYPE t_internal_register IS RECORD
			conf_reg			: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 DOWNTO 0);
			dir_reg				: STD_LOGIC_VECTOR(c_max_number_of_GPIOs-1 DOWNTO 0);
			value_reg			: STD_LOGIC_VECTOR(c_max_number_of_GPIOs-1 DOWNTO 0);
			
	END RECORD;

	SIGNAL ri,ri_next : t_internal_register;
	
BEGIN
	
	-- combinatoric process
	comb_proc : PROCESS (isl_reset_n, ri, isl_avs_write, islv_avs_address, isl_avs_read, islv_avs_write_data, oslv_gpios,islv_avs_byteenable)
		VARIABLE vi :	t_internal_register;
		VARIABLE gpio_part_nr: INTEGER := 0;
		VARIABLE avs_address: UNSIGNED(c_gpio_interface_address_with-1 DOWNTO 0) := to_unsigned(0,c_gpio_interface_address_with);
		
	BEGIN
		-- Keep variables stable
		vi := ri;	
		
		avs_address := UNSIGNED(islv_avs_address);
		
		-- Set read data to default value
		oslv_avs_read_data <= (OTHERS => '0');
		
		-- Avalon slave interface: write part
		IF isl_avs_write = '1' THEN
			
			-- Write to config register
			IF avs_address = c_configuration_reg_address THEN
				FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
					IF islv_avs_byteenable(i) = '1' THEN
						vi.conf_reg((i + 1) * 8 - 1 DOWNTO i * 8) := islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8);
					END IF;
				END LOOP;
			-- Write to direction registers
			ELSIF avs_address >= c_usig_dir_regs_address AND avs_address < c_usig_value_regs_address THEN
				gpio_part_nr := to_integer(avs_address-c_usig_dir_regs_address);
				
				FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
					IF islv_avs_byteenable(i) = '1' THEN
						vi.dir_reg(gpio_part_nr * c_fLink_avs_data_width + (i + 1) * 8 - 1 DOWNTO gpio_part_nr * c_fLink_avs_data_width + i * 8) 	:=	islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8);
					END IF;
				END LOOP;
			
			-- Write to value registers
			ELSIF avs_address>= c_usig_value_regs_address AND avs_address< c_usig_value_regs_max_address THEN
				gpio_part_nr := to_integer(avs_address-c_usig_value_regs_address);
				FOR i IN 0 TO c_fLink_avs_data_width_in_byte-1 LOOP
					IF islv_avs_byteenable(i) = '1' THEN
						vi.value_reg(gpio_part_nr * c_fLink_avs_data_width + (i + 1) * 8 - 1 DOWNTO gpio_part_nr * c_fLink_avs_data_width + i * 8) 	:=	islv_avs_write_data((i + 1) * 8 - 1 DOWNTO i * 8);
					END IF;
				END LOOP;
			END IF;
		END IF;
		
		FOR i IN 0 TO number_of_gpios-1 LOOP
			IF ri.dir_reg(i) = '1' THEN --output
				oslv_gpios(i) <= ri.value_reg(i);
			ELSE --input
				oslv_gpios(i) <= 'Z';
				vi.value_reg(i) := oslv_gpios(i);
			END IF;
		END LOOP;
		
		--avalon slave interface read part
		IF isl_avs_read = '1' THEN
			CASE avs_address IS
				-- Read type register
				WHEN to_unsigned(c_fLink_typdef_address, c_gpio_interface_address_with) =>
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length-1) DOWNTO 
					(c_fLink_interface_version_length + c_fLink_subtype_length)) <= STD_LOGIC_VECTOR(to_unsigned(c_fLink_digital_io_id,c_fLink_id_length));
					oslv_avs_read_data((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) <= STD_LOGIC_VECTOR(to_unsigned(c_gpio_subtype_id,c_fLink_subtype_length));
					oslv_avs_read_data(c_fLink_interface_version_length-1 DOWNTO 0) <=  STD_LOGIC_VECTOR(to_unsigned(c_gpio_interface_version,c_fLink_interface_version_length));
				
				-- Read mem size register
				WHEN to_unsigned(c_fLink_mem_size_address,c_gpio_interface_address_with) => 
					oslv_avs_read_data(c_gpio_interface_address_with + 2) <= '1';
				
				-- Read number of channels register
				WHEN to_unsigned(c_fLink_number_of_channels_address, c_gpio_interface_address_with) => 
					oslv_avs_read_data <= std_logic_vector(to_unsigned(number_of_gpios, c_fLink_avs_data_width));
				
				-- Read config register
				WHEN to_unsigned(c_fLink_configuration_address, c_gpio_interface_address_with) =>
					oslv_avs_read_data <= vi.conf_reg;
				
				-- Read unique id register
				WHEN to_unsigned(c_fLink_unique_id_address,c_gpio_interface_address_with) => 
					oslv_avs_read_data <= unique_id;
				
				-- Read direction or value register
				WHEN OTHERS => 
					IF avs_address >= c_usig_dir_regs_address AND avs_address< c_usig_value_regs_address THEN
						gpio_part_nr := to_integer(avs_address)-c_fLink_number_of_std_registers;
						
						IF gpio_part_nr <c_int_nr_of_gpio_reg  THEN
							oslv_avs_read_data <= vi.dir_reg((gpio_part_nr+1) * c_fLink_avs_data_width -1 DOWNTO gpio_part_nr * c_fLink_avs_data_width);
						ELSE
							FOR i IN 0 TO (number_of_gpios mod c_fLink_avs_data_width)-1 LOOP
								oslv_avs_read_data(i) <= vi.dir_reg(i+gpio_part_nr*c_fLink_avs_data_width);
							END LOOP;
						END IF;
					ELSIF avs_address>= c_usig_value_regs_address AND avs_address< c_usig_value_regs_max_address THEN
						gpio_part_nr := to_integer(avs_address-c_usig_value_regs_address);
						IF gpio_part_nr <c_int_nr_of_gpio_reg  THEN
							oslv_avs_read_data <= vi.value_reg((gpio_part_nr+1) * c_fLink_avs_data_width -1 DOWNTO gpio_part_nr * c_fLink_avs_data_width);
						ELSE
							FOR i IN 0 TO (number_of_gpios mod c_fLink_avs_data_width)-1 LOOP
								oslv_avs_read_data(i) <= vi.value_reg(i+gpio_part_nr*c_fLink_avs_data_width);
							END LOOP;
						END IF;
					ELSE
						oslv_avs_read_data <= (OTHERS => '0');
					END IF;
			END CASE;
		END IF;
		
		IF isl_reset_n = '0' OR  vi.conf_reg(c_fLink_reset_bit_num) = '1' THEN
			vi.conf_reg := (OTHERS =>'0');
			vi.value_reg := (OTHERS =>'0');
			vi.dir_reg := (OTHERS =>'0');
		END IF;
		
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
