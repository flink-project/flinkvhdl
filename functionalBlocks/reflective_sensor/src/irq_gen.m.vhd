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
--  Title             : irq_gen.m.vhd
--  Project           : FLINK
--  Description       : IRQ generator
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  19.10.2020 GOOP :    Initial & Final version
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE irq_gen_pkg IS
    
    COMPONENT irq_gen IS
        GENERIC(
            i_bus_width : INTEGER := 32
        );
        PORT (
            isl_clk           : IN STD_LOGIC;
            isl_reset         : IN STD_LOGIC;
            islv_value        : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            islv_upper_hys    : IN STD_LOGIC_VECTOR(i_bus_width-1 DOWNTO 0);
            islv_lower_hys    : IN STD_LOGIC_VECTOR(i_bus_width-1 DOWNTO 0);
            osl_interrupt_low : OUT STD_LOGIC;
            osl_interrupt_up  : OUT STD_LOGIC
        );
    END COMPONENT irq_gen;
    
END PACKAGE irq_gen_pkg;

---------------------------------------------------------------------------------------------
-- ENTITIY
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.puls_generator_pkg.ALL;

ENTITY irq_gen IS
    GENERIC(
        i_bus_width : INTEGER := 32
    );
    PORT (
        isl_clk           : IN STD_LOGIC;
        isl_reset         : IN STD_LOGIC;
        islv_value        : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        islv_upper_hys    : IN STD_LOGIC_VECTOR(i_bus_width-1 DOWNTO 0);
        islv_lower_hys    : IN STD_LOGIC_VECTOR(i_bus_width-1 DOWNTO 0);
        osl_interrupt_low : OUT STD_LOGIC;
        osl_interrupt_up  : OUT STD_LOGIC
    );
    
END ENTITY irq_gen;

---------------------------------------------------------------------------------------------
-- ARCHITECTURE
---------------------------------------------------------------------------------------------

ARCHITECTURE rtl OF irq_gen IS

SIGNAL sl_state : STD_LOGIC;

BEGIN
    
    --------------------------------------------
    -- combinatorial process
    --------------------------------------------
    comb_proc : PROCESS (isl_clk)
    BEGIN
    
    END PROCESS comb_proc;

    -----------------------------------------
    --registered process
    -----------------------------------------
    reg_proc : PROCESS (isl_clk)
    BEGIN
        IF rising_edge(isl_clk) THEN
            IF isl_reset = '1' THEN
                IF islv_value > islv_upper_hys THEN
                    sl_state <= '0';
                ELSE 
                    sl_state <= '1';
                END IF;
                osl_interrupt_low <= '0';
                osl_interrupt_up <= '0';
            ELSIF (islv_value > islv_upper_hys) AND sl_state = '1' THEN
                sl_state <= '0';
                osl_interrupt_low <= '0';
                osl_interrupt_up <= '1';
            ELSIF (islv_value < islv_lower_hys) AND sl_state = '0' THEN
                sl_state <= '1';
                osl_interrupt_low <= '1';
                osl_interrupt_up <= '0';
            ELSE
                osl_interrupt_low <= '0';
                osl_interrupt_up <= '0';
            END IF;
        END IF;
    END PROCESS reg_proc;

    -----------------------------------------
    -- output assignment 
    -----------------------------------------

    
END ARCHITECTURE rtl;