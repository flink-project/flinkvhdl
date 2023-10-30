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
--  Title             : irq_gen_tb.vhd
--  Project           : FLINK
--  Description       : testbench for IRQ generator
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  03.10.2020 GOOP :    Initial version
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE work.irq_gen_pkg.ALL;

ENTITY irq_gen_tb IS 
END ENTITY irq_gen_tb;

ARCHITECTURE sim OF irq_gen_tb IS
    CONSTANT I_CLOCK_MULTIPLIER : INTEGER := 10; -- Multiplier of Base clock 1ns ==> 100MHz
    CONSTANT T_CLOCK_PERIOD : TIME := 1 ns * I_CLOCK_MULTIPLIER;
    CONSTANT I_NOF_DECODER_LINES : INTEGER := 4;
    
    SIGNAL sl_clk            : STD_LOGIC := '0';
    SIGNAL sl_rst            : STD_LOGIC := '0';
    SIGNAL slv_value         : STD_LOGIC_VECTOR(31 DOWNTO 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(0,32));
    SIGNAL slv_upper_hys    : STD_LOGIC_VECTOR(31 DOWNTO 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(105,32));
    SIGNAL slv_lower_hys    : STD_LOGIC_VECTOR(31 DOWNTO 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(95,32));
    SIGNAL sl_interrupt_low : STD_LOGIC := '0';
    SIGNAL sl_interrupt_up  : STD_LOGIC := '0';
            
BEGIN 

    --## Unit Under Test Instantiation
    u_gen : irq_gen
        GENERIC MAP(
            i_bus_width => 32
        )
		PORT MAP(
			isl_clk           => sl_clk,
			isl_reset         => sl_rst,
			islv_value        => slv_value,
			islv_upper_hys    => slv_upper_hys,
			islv_lower_hys    => slv_lower_hys,
			osl_interrupt_low => sl_interrupt_low,
			osl_interrupt_up  => sl_interrupt_up
		);
    
    -- Clock generation process
    clock_gen : PROCESS
    BEGIN
        WHILE TRUE LOOP
            sl_clk <= NOT sl_clk AFTER T_CLOCK_PERIOD / 2;
            WAIT FOR T_CLOCK_PERIOD;
        END LOOP;
    END PROCESS clock_gen;
    
   
    -- Validation processes
    valdation_rst : PROCESS
    VARIABLE num_errors : INTEGER := 0;
    BEGIN
        REPORT "This is a manual test bench" SEVERITY NOTE;
        WAIT;
        
        IF num_errors = 0 THEN 
            REPORT "Simulation without errors" SEVERITY NOTE;
        ELSE 
            REPORT "SIMULATION WITH ERRORS" SEVERITY FAILURE; 
        END IF; -- Stop Simulation
        ASSERT FALSE REPORT "End of simulation" SEVERITY FAILURE;
    END PROCESS valdation_rst;
    
   
END ARCHITECTURE sim;