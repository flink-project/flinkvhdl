--------------------------------------------------------------------------------
--     ____  _____          __    __    ________    _______
--    |    | \    \        |   \ |  |  |__    __|  |   __  \
--    |____|  \____\       |    \|  |     |  |     |  |__>  ) 
--     ____   ____         |  |\ \  |     |  |     |   __  <
--    |    | |    |        |  | \   |     |  |     |  |__>  )
--    |____| |____|        |__|  \__|     |__|     |_______/
--
--    INTERSTATE UNIVERSITY OF AAPLIED SCIENCES OF TECHNOLOGY
--
--    Campus Buchs - Werdenbergstrasse 4 - CH-9471 Buchs
--    Campus Waldau - Schoenauweg4 - CH9013 St. Gallen
--
--    Tel. +41 (0)81 755 33 11   Fax +41 (0)81 756 54 34
--
--------------------------------------------------------------------------------
--    Project : 	ADC Interface for ADCS7476A
--    Unit    : 	adcs7476A_interface
--    Author  : 	Laszlo Arato
--    Created : 	June 2014
--------------------------------------------------------------------------------
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--    
--        http://www.apache.org/licenses/LICENSE-2.0
--    
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.
--------------------------------------------------------------------------------

	--	ADCS7476A  Analog-Digital Converter
	--	SCLK max frequency				= 20 MHz
	--	t_convert						= 16 x t_sclk
	--	t_quiet							= 50 ns min.
	--	t2 = CS-to-SCLK Setup time		= 10 ns min.
	--	SCLK-to-Data Valid hold time	= 7 ns
	
	--  __      ______                                        _____________
	--  CS            \______________________________________/             \
	--                 <- t2 ->                               <- t_quiet ->
	--          _______________    __    __    __    __    __    __    __    __   _   _   _   _
	--  SCLK                   \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/ \_/ \_/ \_/ \_/ \_/ \_/  
	--                  _______ _____ _____ _____ _____ _____ ______
	--  SDATA   -------<___Z3__X__Z2_X__Z1_X__Z0_X_D11_X_D10_X
	
	--	Data is applied on the falling edge, so sample it on falling edge for maximum timing
	
	
	--                 _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _
	--  50 MHz Clock    \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ 
	--  __          ______
	--  CS                \_____________________________________________________
	--              __________             ___________             ___________
	--  SCLK                  \___________/           \___________/           \___________/
	--                     ___ _______________________ _______________________ _______________________ 
	--	SDATA       ------< Z0X__________Z1___________X_______________________X_______________________


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE adcad7476A_pkg IS
	COMPONENT adcad7476A IS
		GENERIC(
            base_clk            : INTEGER := 33000000; 
            sclk_frequency      : INTEGER := 8000000                    -- max 20Mhz
        );
   		PORT (
			isl_reset			: IN  std_logic ;						-- Reset
			isl_clock			: IN  std_logic ;						-- Clock

			osl_adc_sclk		: OUT  std_logic;						-- ADC clock
			osl_adc_csn			: OUT  std_logic;						-- ADC chip select not
			isl_adc_sdata		: IN   std_logic;						-- ADC serial data
			
			oslv12_hex_data  	: OUT std_logic_vector(11 DOWNTO 0) 	-- ADC result out
		);
	END COMPONENT adcad7476A;
END PACKAGE adcad7476A_pkg;

-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY adcad7476A IS
		GENERIC(
            base_clk            : INTEGER := 33000000; 
            sclk_frequency      : INTEGER := 8000000                    -- max 20Mhz
        );
		PORT (
			isl_reset			: IN  std_logic ;						-- Reset
			isl_clock			: IN  std_logic ;						-- Clock

			osl_adc_sclk		: OUT  std_logic;						-- ADC clock
			osl_adc_csn			: OUT  std_logic;						-- ADC chip select not
			isl_adc_sdata		: IN   std_logic;						-- ADC serial data
			
			oslv12_hex_data  	: OUT std_logic_vector(11 DOWNTO 0) 	-- ADC result out
		);
END ENTITY adcad7476A;

-------------------------------------------------------------------------------

ARCHITECTURE rtl OF adcad7476A IS

	CONSTANT cint_rx_bitcount	: integer	:= 16;

	TYPE t_fsm_state	IS (INIT, CS_START, READ_Z3, SCLK_LOW, SCLK_HIGH);
	
	TYPE t_adc_signals IS RECORD
		sl_serial_clock		: std_logic;
		sl_chip_select_bar	: std_logic;
		fsm_state			: t_fsm_state;
		usig2_clk_div_count	: unsigned(1 DOWNTO 0);
		usig4_bit_count		: unsigned(3 DOWNTO 0);
		slv_rx_tmp_data		: std_logic_vector(cint_rx_bitcount - 1 DOWNTO 0);
		slv_rx_out_data		: std_logic_vector(cint_rx_bitcount - 1 DOWNTO 0);
	END RECORD;
	
	SIGNAL r, r_next		: t_adc_signals;
	
	SIGNAL sl_reset			: std_logic;

BEGIN
			
	adc_comb_proc : PROCESS (isl_reset, isl_adc_sdata, r)
		VARIABLE v			: t_adc_signals;
	BEGIN
		v := r;		--	Initialize variables
		
		CASE r.fsm_state IS
			WHEN INIT		=>	v.sl_chip_select_bar		:= '1';
								v.sl_serial_clock			:= '1';
								v.slv_rx_out_data           := r.slv_rx_tmp_data;
								v.fsm_state					:= CS_START;
		
			WHEN CS_START	=>	v.sl_chip_select_bar		:= '0';
								v.usig4_bit_count			:= to_unsigned(cint_rx_bitcount - 1,4);
								v.usig2_clk_div_count		:= "10";
								v.fsm_state					:= READ_Z3;
								
			WHEN READ_Z3	=>	v.sl_serial_clock			:= '0';
								v.fsm_state					:= SCLK_LOW;
			
			WHEN SCLK_LOW	=>	IF r.usig2_clk_div_count = 2 THEN
									v.usig4_bit_count		:= r.usig4_bit_count - 1;
									v.usig2_clk_div_count	:= r.usig2_clk_div_count - 1;
								ELSIF r.usig2_clk_div_count > 0 THEN
									v.usig2_clk_div_count	:= r.usig2_clk_div_count - 1;
								ELSE
									v.sl_serial_clock		:= '1';
									v.usig2_clk_div_count	:= "10";
									v.fsm_state				:= SCLK_HIGH;
								END IF;
								
			WHEN SCLK_HIGH	=>	IF r.usig2_clk_div_count > 0 THEN
									v.usig2_clk_div_count	:= r.usig2_clk_div_count - 1;
								ELSE
									IF r.usig4_bit_count = 0 THEN
										v.fsm_state				:= INIT;
									ELSE
										v.sl_serial_clock		:= '0';
										v.usig2_clk_div_count	:= "10";
										v.fsm_state				:= SCLK_LOW;
									END IF;
								END IF;			
			WHEN OTHERS		=>	v.fsm_state				:= INIT;
		END CASE;
		
		--	Sample Serial Data Values
		IF r.fsm_state = SCLK_HIGH AND r.usig2_clk_div_count = 2 THEN
			v.slv_rx_tmp_data(to_integer(r.usig4_bit_count)) := isl_adc_sdata;
		END IF;
		
		--	Reset State
		IF isl_reset = '1' THEN
			v.fsm_state				:= INIT;
		END IF;
		
		r_next <= v;	--	Copy variables to signal
		
	END PROCESS adc_comb_proc;
	
	adc_reg_proc : PROCESS (isl_clock)
	BEGIN
		IF rising_edge(isl_clock) THEN
			r	<= r_next;
		END IF;
	END PROCESS adc_reg_proc;

	osl_adc_sclk		<= r.sl_serial_clock;		--	ADC_SCLK
	osl_adc_csn			<= r.sl_chip_select_bar;	--	ADC_CSN
	oslv12_hex_data	    <= r.slv_rx_out_data(oslv12_hex_data'LENGTH - 1 DOWNTO 0);
	
END ARCHITECTURE rtl;
