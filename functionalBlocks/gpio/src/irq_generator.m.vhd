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
--  Title             : irq_generator.m.vhd
--  Project           : FLINK
--  Description       : IRQ Generator for GPIO's
---------------------------------------------------------------------------------------------
--  Copyright(C) 2023 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  14.10.2023 GOOP :    Initial version
--  19.10.2023 GOOP :    Final version
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE irq_generator_pgk IS
    COMPONENT irq_generator IS
        GENERIC (
            i_bus_width : Integer := 32
        );
        PORT (
            isl_clk              : IN STD_LOGIC;
            isl_rst              : IN STD_LOGIC;
            islv_irq_debounce    : IN STD_LOGIC_VECTOR(i_bus_width-1 DOWNTO 0);
            isl_direction        : IN STD_LOGIC;
            isl_value            : IN STD_LOGIC;
            osl_irq_rising_edge  : OUT STD_LOGIC;
            osl_irq_falling_edge : OUT STD_LOGIC
        ); 
    END COMPONENT irq_generator; 
END PACKAGE irq_generator_pgk;

---------------------------------------------------------------------------------------------
-- ENTITIY
---------------------------------------------------------------------------------------------
LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY irq_generator IS
    GENERIC (
        i_bus_width : Integer := 32
    );
    PORT (
        isl_clk              : IN STD_LOGIC;
        isl_rst              : IN STD_LOGIC;
        islv_irq_debounce    : IN STD_LOGIC_VECTOR(i_bus_width-1 DOWNTO 0);
        isl_direction        : IN STD_LOGIC;
        isl_value            : IN STD_LOGIC;
        osl_irq_rising_edge  : OUT STD_LOGIC;
        osl_irq_falling_edge : OUT STD_LOGIC
    ); 
END ENTITY irq_generator;

---------------------------------------------------------------------------------------------
-- ARCHITECTURE
---------------------------------------------------------------------------------------------
ARCHITECTURE rtl of irq_generator is
    
SIGNAL old_value : STD_LOGIC;
SIGNAL counter : UNSIGNED(i_bus_width-1 DOWNTO 0);
    
BEGIN

    reg_process: PROCESS (isl_clk)
    BEGIN
        IF rising_edge(isl_clk) THEN
            IF isl_rst = '1' THEN
                osl_irq_rising_edge <= '0';
                osl_irq_falling_edge <= '0';
                counter <= UNSIGNED(islv_irq_debounce);
                old_value <= isl_value;
            ELSIF isl_direction = '0' THEN
                IF counter < UNSIGNED(islv_irq_debounce) THEN -- debouncing
                    osl_irq_rising_edge <= '0';
                    osl_irq_falling_edge <= '0';
                    counter <= counter + 1;
                ELSIF old_value = '0' AND isl_value = '1' THEN -- rising edge
                    osl_irq_rising_edge <= '1';
                    osl_irq_falling_edge <= '0';
                    counter <= (OTHERS => '0');
                    old_value <= isl_value;
                ELSIF old_value = '1' AND isl_value = '0' THEN -- falling edge
                    osl_irq_rising_edge <= '0';
                    osl_irq_falling_edge <= '1';
                    counter <= (OTHERS => '0');
                    old_value <= isl_value;
                ELSE
                    osl_irq_rising_edge <= '0';
                    osl_irq_falling_edge <= '0';
                    counter <= counter;
                    old_value <= isl_value;
                END IF;
            ELSE
                osl_irq_rising_edge <= '0';
                osl_irq_falling_edge <= '0';
                counter <= counter;
                old_value <= isl_value;
            END IF;
        END IF;
    END PROCESS reg_process;
        
END rtl;
