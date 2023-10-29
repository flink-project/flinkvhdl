---------------------------------------------------------------------------------------------
--    ____   _____ _______            _________  _____     _____  ____  _____  ___  ____   
--   / __ \ / ____|__   __|          |_   ___  ||_   _|   |_   _||_   \|_   _||_  ||_  _|  
--  | |  | | (___    | |    _______    | |_  \_|  | |       | |    |   \ | |    | |_/ /   
--  | |  | |\___ \   | |   |_______|   |  _|      | |   _   | |    | |\ \| |    |  __'.   
--  | |__| |____) |  | |              _| |_      _| |__/ | _| |_  _| |_\   |_  _| |  \ \_ 
--   \____/|_____/   |_|             |_____|    |________||_____||_____|\____||____||____|
--
--  O S T S C H W E I Z E R   F A C H H O C H S C H U L E
--  Campus Buchs - Werdenbergstrasse 4 - CH-9471 Buchs
--  Tel. +41 (0)81 755 33 11   Fax +41 (0)81 756 54 34
---------------------------------------------------------------------------------------------
--  Title             : reflective_sensor_tb.vhd
--  Project           : FLINK
--  Description       : Testbench for reflective_sensor
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  12.10.2023 GOOP :	Initial version
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE work.reflective_sensor_pkg.ALL;

ENTITY reflective_sensor_tb IS 
END ENTITY reflective_sensor_tb;

ARCHITECTURE sim OF reflective_sensor_tb IS
    CONSTANT I_CLOCK_MULTIPLIER : INTEGER := 10; -- Multiplier of Base clock 1ns ==> 100MHz
    CONSTANT T_CLOCK_PERIOD : TIME := 1 ns * I_CLOCK_MULTIPLIER;
    CONSTANT I_NOF_DECODER_LINES : INTEGER := 4;
    
    SIGNAL sl_clk  : STD_LOGIC := '0';
    SIGNAL sl_rst  : STD_LOGIC := '0';
    SIGNAL slv_decoder_lines : STD_LOGIC_VECTOR(I_NOF_DECODER_LINES-1 DOWNTO 0);
    SIGNAL slav12_hex_data : t_adc_data;
    SIGNAL sl_puls : STD_LOGIC;
    
    SIGNAL b_stop_simulation : BOOLEAN := FALSE;
    SIGNAL t_time_puls : TIME := 0 ns;
    SIGNAL t_duty_cycle : TIME := 0 ns;
    SIGNAL b_first_run : BOOLEAN := TRUE;
    SHARED VARIABLE b_fail : BOOLEAN := FALSE;
    
    FUNCTION ErrorIfUnEqual(s_error_msg : STRING; i_num_errors : INTEGER; vector_to_check: UNSIGNED; vector_should_be : UNSIGNED) RETURN NATURAL IS
    BEGIN
        IF vector_to_check /= vector_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
    FUNCTION ErrorIfEqual(s_error_msg : STRING; i_num_errors : INTEGER; vector_to_check: UNSIGNED; vector_should_be : UNSIGNED) RETURN NATURAL IS
    BEGIN
        IF vector_to_check /= vector_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors;
    END FUNCTION;
        FUNCTION ErrorIfUnEqual(s_error_msg : STRING; i_num_errors : INTEGER; vector_to_check: STD_LOGIC_VECTOR; vector_should_be : STD_LOGIC_VECTOR) RETURN NATURAL IS
    BEGIN
        IF vector_to_check /= vector_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
    FUNCTION ErrorIfEqual(s_error_msg : STRING; i_num_errors : INTEGER; vector_to_check: STD_LOGIC_VECTOR; vector_should_be : STD_LOGIC_VECTOR) RETURN NATURAL IS
    BEGIN
        IF vector_to_check = vector_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
BEGIN 

    --## Unit Under Test Instantiation
    u_gen : reflective_sensor
        GENERIC MAP(
			nof_decoder_signals		=> I_NOF_DECODER_LINES,
            frequency_resolution    => 32,
            frequency_divider       => 200000,
            ratio                   => 8000,
            adc_trigger             => 7990
        )
		PORT MAP(
			isl_clk					=> sl_clk,
			isl_reset				=> sl_rst,
			isl_adc_sdata           => '1',
			osl_puls                => sl_puls,
			oslv_decoder_lines		=> slv_decoder_lines,
			oslav12_hex_data		=> slav12_hex_data,
			islv_upper_hys          => (OTHERS => (OTHERS => '0')), -- not tested here
			islv_lower_hys          => (OTHERS => (OTHERS => '0')) -- not tested here
		);
    
    -- Clock generation process
    clock_gen : PROCESS
    BEGIN
        WHILE NOT b_stop_simulation LOOP
            sl_clk <= NOT sl_clk AFTER T_CLOCK_PERIOD / 2;
            WAIT FOR T_CLOCK_PERIOD;
        END LOOP;
    END PROCESS clock_gen;
    
   
    -- Validation processes
    valdation_rst : PROCESS
    VARIABLE num_errors : INTEGER := 0;
    BEGIN
        -- wait 2 clocks because of simulation init
        WAIT UNTIL rising_edge(sl_clk);
        WAIT UNTIL rising_edge(sl_clk);
        -- reset and check all values
        sl_rst <= '1';
        FOR i IN 0 TO (2**I_NOF_DECODER_LINES)-1 LOOP
            num_errors := ErrorIfUnEqual("Has not initial value " & integer'image(i), num_errors, slav12_hex_data(i), STD_LOGIC_VECTOR(TO_UNSIGNED(0,12)));
        END LOOP;
        sl_rst <= '0';
        WAIT UNTIL falling_edge(sl_puls);
        
        FOR i IN 0 TO (2**I_NOF_DECODER_LINES)-1 LOOP
            WAIT UNTIL falling_edge(sl_puls);
            num_errors := ErrorIfUnEqual("Has not updated value " & integer'image(i), num_errors, slav12_hex_data(i), "010101010101");
        END LOOP;
        
        -- reset values again to control it
        sl_rst <= '1';
        WAIT UNTIL rising_edge(sl_clk);
        sl_rst <= '0';
        WAIT UNTIL rising_edge(sl_clk);
        FOR i IN 0 TO (2**I_NOF_DECODER_LINES)-1 LOOP
            num_errors := ErrorIfUnEqual("Has not initial value " & integer'image(i), num_errors, slav12_hex_data(i), STD_LOGIC_VECTOR(TO_UNSIGNED(0,12)));
        END LOOP;
        
        
        IF num_errors = 0 THEN 
            REPORT "Simulation without errors" SEVERITY NOTE;
        ELSE 
            REPORT "SIMULATION WITH ERRORS" SEVERITY FAILURE; 
        END IF; -- Stop Simulation
        ASSERT FALSE REPORT "End of simulation" SEVERITY FAILURE;
    END PROCESS valdation_rst;
    
   
END ARCHITECTURE sim;