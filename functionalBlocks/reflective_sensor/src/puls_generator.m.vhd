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
--  Title             : puls_generator.m.vhd
--  Project           : FLINK
--  Description       : Puls generator
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  03.10.2020 GOOP :    Initial version
--  08.10.2023 GOOP :    Final and Tested
---------------------------------------------------------------------------------------------

-- Based on the adjustable PWM module from OST (Buchs) Flink Project, 
-- which is based on Marco Tinner's PWM module from the AirBotOne project.

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE puls_generator_pkg IS
    
    COMPONENT puls_generator IS
        GENERIC(
            frequency_resolution : INTEGER := 32;
            -- pwm frequency divider for example if this value is 2 the pwm output frequency is f_sl_clk/2
            frequency_divider    : INTEGER := 200000; -- target 500Hz by a base frequency of 100MHz
            -- the high time part in clk cyles this value has alway to be smaller than the slv_frequency_divider
            ratio                : INTEGER := 8000; -- target 12.5KHz(80us) by a base frequenzy of 100MHz
            -- have to be smaller than ratio. Triggers the ADC to read the value
            adc_trigger          : INTEGER := 7990 
        );
        PORT (
            isl_clk          : IN  STD_LOGIC;
            isl_reset        : IN  STD_LOGIC;
            osl_puls         : OUT STD_LOGIC;
            osl_adc_trigger  : OUT STD_LOGIC
        );
    END COMPONENT puls_generator;
    
END PACKAGE puls_generator_pkg;

---------------------------------------------------------------------------------------------
-- ENTITIY
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.puls_generator_pkg.ALL;

ENTITY puls_generator IS
    GENERIC(
        frequency_resolution : INTEGER := 32;
        frequency_divider    : INTEGER := 200000;
        ratio                : INTEGER := 8000;
        adc_trigger          : INTEGER := 7990 
    );
    PORT (
        isl_clk         : IN  STD_LOGIC;
        isl_reset       : IN  STD_LOGIC;
        osl_puls        : OUT STD_LOGIC;
        osl_adc_trigger : OUT STD_LOGIC
    );
    
END ENTITY puls_generator;

---------------------------------------------------------------------------------------------
-- ARCHITECTURE
---------------------------------------------------------------------------------------------

ARCHITECTURE rtl OF puls_generator IS
    CONSTANT usig_frequency_divider : UNSIGNED(frequency_resolution-1 DOWNTO 0) := TO_UNSIGNED(frequency_divider, frequency_resolution);
    CONSTANT usig_ratio             : UNSIGNED(frequency_resolution-1 DOWNTO 0) := TO_UNSIGNED(ratio, frequency_resolution);
    CONSTANT usig_adc_trigger       : UNSIGNED(frequency_resolution-1 DOWNTO 0) := TO_UNSIGNED(adc_trigger, frequency_resolution);

    TYPE t_reg IS RECORD
        usig_cycle_counter : UNSIGNED(frequency_resolution-1 DOWNTO 0);
        sl_puls            : STD_LOGIC;
        sl_adc_trigger     : STD_LOGIC;
    END RECORD;
    CONSTANT C_RESET_REGS : t_reg := (
        usig_cycle_counter  => (OTHERS => '0'),
        sl_puls             => '0',
        sl_adc_trigger      => '0'
    );
    SIGNAL r, r_next : t_reg := C_RESET_REGS;

BEGIN
    
    --------------------------------------------
    -- combinatorial process
    --------------------------------------------
    comb_proc : PROCESS (r)
    VARIABLE v : t_reg := C_RESET_REGS;
    BEGIN
    v := r;
    IF usig_ratio > usig_frequency_divider OR usig_adc_trigger >= usig_ratio THEN -- illegal config
        v := C_RESET_REGS;
    ELSIF r.usig_cycle_counter >= usig_frequency_divider THEN -- restart period
        v := C_RESET_REGS;
    ELSIF r.usig_cycle_counter < usig_ratio THEN -- hightime of puls
        v.sl_puls := '1';
        v.usig_cycle_counter := r.usig_cycle_counter + 1;
        IF r.usig_cycle_counter = usig_adc_trigger THEN -- activte trigger a few clocks befor puls has a falling edge
            v.sl_adc_trigger := '1';
        ELSE
            v.sl_adc_trigger := '0';
        END IF;
    ELSE -- lowtime of puls
        v.sl_puls := '0';
        v.usig_cycle_counter := r.usig_cycle_counter + 1;
    END IF;

    IF isl_reset = '1' THEN
        v := C_RESET_REGS;
    END IF;

    r_next <= v;
    END PROCESS comb_proc;

    -----------------------------------------
    --registered process
    -----------------------------------------
    reg_proc : PROCESS (isl_clk)
    BEGIN
        IF rising_edge(isl_clk) THEN
            r <= r_next;
        END IF;
    END PROCESS reg_proc;

    -----------------------------------------
    -- output assignment 
    -----------------------------------------
    osl_puls             <= r.sl_puls;
    osl_adc_trigger        <= r.sl_adc_trigger;
    
END ARCHITECTURE rtl;