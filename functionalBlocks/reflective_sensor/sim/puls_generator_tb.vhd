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
--  Title             : puls_generator_tb.vhd
--  Project           : FLINK
--  Description       : Testbench for Puls generator
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  12.10.2020 GOOP :	Initial version
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE work.puls_generator_pkg.ALL;

ENTITY puls_generator_tb IS 
END ENTITY puls_generator_tb;

ARCHITECTURE sim OF puls_generator_tb IS
    CONSTANT I_CLOCK_MULTIPLIER : INTEGER := 10; -- Multiplier of Base clock 1ns
    CONSTANT T_CLOCK_PERIOD : TIME := 1 ns * I_CLOCK_MULTIPLIER;
    
    SIGNAL sl_clk  : STD_LOGIC := '0';
    SIGNAL sl_rst  : STD_LOGIC := '0';
    SIGNAL i_period : INTEGER := 1000000/(I_CLOCK_MULTIPLIER*2); -- 1ms / (CLOCK_PERIOD * 2)
    SIGNAL i_duty_cycle : INTEGER := 90000/(I_CLOCK_MULTIPLIER*2); -- 0.09ms / (CLOCK_PERIOD * 2)
    SIGNAL u_period : UNSIGNED (31 DOWNTO 0) := TO_UNSIGNED(i_period, 32);
    SIGNAL u_duty_cycle : UNSIGNED (31 DOWNTO 0) := TO_UNSIGNED(i_duty_cycle, 32);
    SIGNAL sl_pulse_out : STD_LOGIC;
    SIGNAL sl_adc_trigger : STD_LOGIC;
    
   
    CONSTANT FREQUENCY_RESOLUTION : INTEGER := 32;
    CONSTANT FREQUENCY_DIVIDER    : INTEGER := 200000;
    CONSTANT RATIO                : INTEGER := 8000;
    CONSTANT ADC_TRIGGER          : INTEGER := 7990;
    
    FUNCTION ErrorIfUnEqual(s_error_msg : STRING; i_num_errors : INTEGER; bit_to_check: STD_LOGIC; bit_should_be : STD_LOGIC) RETURN NATURAL IS
    BEGIN
        IF bit_to_check /= bit_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
    FUNCTION ErrorIfEqual(s_error_msg : STRING; i_num_errors : INTEGER; bit_to_check: STD_LOGIC; bit_should_be : STD_LOGIC) RETURN NATURAL IS
    BEGIN
        IF bit_to_check = bit_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
    
BEGIN 

    --## Unit Under Test Instantiation
    u_gen : puls_generator 
    GENERIC MAP (
        frequency_resolution => FREQUENCY_RESOLUTION,
        frequency_divider    => FREQUENCY_DIVIDER, -- target 500Hz by a base frequency of 100MHz
        ratio                => RATIO, -- target 12.5KHz(80us) by a base frequenzy of 100MHz
        adc_trigger          => ADC_TRIGGER 
    )
    PORT MAP ( 
        isl_clk => sl_clk,
        isl_reset => sl_rst,
        osl_puls => sl_pulse_out,
        osl_adc_trigger => sl_adc_trigger
    ); 
    
    -- Clock generation process
    clock_gen : PROCESS
    BEGIN
        WHILE TRUE LOOP
            sl_clk <= NOT sl_clk AFTER T_CLOCK_PERIOD / 2;
            WAIT FOR T_CLOCK_PERIOD;
        END LOOP;
    END PROCESS clock_gen;
    
    valdation_puls : PROCESS
        VARIABLE num_errors : INTEGER := 0;
    BEGIN
        -- check adc trigger
            WAIT UNTIL rising_edge(sl_pulse_out);
            FOR i IN 0 TO ADC_TRIGGER-1 LOOP
                WAIT UNTIL falling_edge(sl_clk);
                num_errors := ErrorIfUnEqual("ADC Trigger rised to early: " & integer'image(i), num_errors, sl_adc_trigger, '0');
            END LOOP;
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("ADC Trigger didn't rised", num_errors, sl_adc_trigger, '1');
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("ADC Trigger was longer than one clock high", num_errors, sl_adc_trigger, '0');
        
        -- check Puls
            WAIT UNTIL rising_edge(sl_pulse_out);
            FOR i IN 0 TO RATIO-1 LOOP
                WAIT UNTIL falling_edge(sl_clk);
                num_errors := ErrorIfUnEqual("Puls was falling to early: " & integer'image(i), num_errors, sl_pulse_out, '1');
            END LOOP;
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Puls was too long high", num_errors, sl_pulse_out, '0');
            FOR i IN 0 TO FREQUENCY_DIVIDER-RATIO-1 LOOP
                WAIT UNTIL falling_edge(sl_clk);
                num_errors := ErrorIfUnEqual("Puls not long enough low: " & integer'image(i), num_errors, sl_pulse_out, '0');
            END LOOP;
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Puls was not high again", num_errors, sl_pulse_out, '1');
        
        
        IF num_errors = 0 THEN 
            REPORT "Simulation without errors" SEVERITY NOTE;
        ELSE 
            REPORT "SIMULATION WITH ERRORS" SEVERITY FAILURE; 
        END IF; -- Stop Simulation
        ASSERT FALSE REPORT "End of simulation" SEVERITY FAILURE;
    END PROCESS valdation_puls;
    
END ARCHITECTURE sim;