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
--  Title             : irq_generator_tb.vhd
--  Project           : FLINK
--  Description       : Testbench IRQ Generator for GPIO's
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  18.10.2023 GOOP :	Initial version
--  19.10.2023 GOOP :   Final version
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE work.irq_generator_pgk.ALL;


ENTITY driver_tb IS 
END ENTITY driver_tb;

ARCHITECTURE sim OF driver_tb IS
    CONSTANT I_CLOCK_MULTIPLIER : INTEGER := 10; -- Multiplier of Base clock 1ns
    CONSTANT T_CLOCK_PERIOD : TIME := 1 ns * I_CLOCK_MULTIPLIER;
    
    SIGNAL sl_clk  : STD_LOGIC := '0';
    SIGNAL sl_rst  : STD_LOGIC := '1';
    SIGNAL sl_direction : STD_LOGIC := '0';
    SIGNAL sl_value : STD_LOGIC := '0';
    SIGNAL sl_isr_falling : STD_LOGIC := '0';
    SIGNAL sl_isr_rising : STD_LOGIC := '0';
    SIGNAL debounce : STD_LOGIC_VECTOR (31 DOWNTO 0) := STD_LOGIC_VECTOR(TO_UNSIGNED(10,32));
    
    SIGNAL b_stop_simulation : BOOLEAN := FALSE;
    
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
    u_driver : irq_generator 
    GENERIC MAP(
        i_bus_width => 32
    )
    PORT MAP( 
        isl_clk              => sl_clk,
        isl_rst              => sl_rst,
        islv_irq_debounce    => debounce,
        isl_direction        => sl_direction,
        isl_value            => sl_value,
        osl_irq_rising_edge  => sl_isr_rising,
        osl_irq_falling_edge => sl_isr_falling
    );

    
    -- Clock generation process
    clock_gen : PROCESS
    BEGIN
        WHILE NOT b_stop_simulation LOOP
            sl_clk <= NOT sl_clk AFTER T_CLOCK_PERIOD / 2;
            WAIT FOR T_CLOCK_PERIOD;
        END LOOP;
    END PROCESS clock_gen;



    validate : PROCESS
        VARIABLE num_errors : INTEGER := 0;
        VARIABLE temp : STD_LOGIC_VECTOR(0 DOWNTO 0);
    BEGIN
        -- check changes in reset mode
            WAIT UNTIL falling_edge(sl_clk); -- sync
            sl_rst <= '1';
            sl_value <= '0';
            WAIT FOR 300ns;
            FOR i IN 0 TO 1 LOOP
                temp := STD_LOGIC_VECTOR(TO_UNSIGNED(i,1));
                sl_direction <= temp(0);
                WAIT FOR 20ns;
                sl_value <= '1';
                WAIT UNTIL falling_edge(sl_clk);
                num_errors := ErrorIfUnEqual("Reset error" & integer'image(i), num_errors, sl_isr_rising, '0');
                num_errors := ErrorIfUnEqual("Reset error" & integer'image(i), num_errors, sl_isr_falling, '0');
                WAIT FOR 300ns; -- debounce time
                sl_value <= '0';
                WAIT UNTIL falling_edge(sl_clk);
                num_errors := ErrorIfUnEqual("Reset error" & integer'image(i), num_errors, sl_isr_rising, '0');
                num_errors := ErrorIfUnEqual("Reset error" & integer'image(i), num_errors, sl_isr_falling, '0');
                WAIT UNTIL falling_edge(sl_clk);
            END LOOP;
            
        -- check when pin is configured as output
            sl_rst <= '0';
            sl_value <= '0';
            sl_direction <= '1';
            WAIT FOR 300ns;
            sl_value <= '1';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt fired while pin is configiured as Output 1", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Interrupt fired while pin is configiured as Output 2", num_errors, sl_isr_falling, '0');
            WAIT FOR 300ns; -- debounce time
            sl_value <= '0';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt fired while pin is configiured as Output 3", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Interrupt fired while pin is configiured as Output 4", num_errors, sl_isr_falling, '0');
            WAIT UNTIL falling_edge(sl_clk);
            
        -- check if irqs rising
            sl_rst <= '0';
            sl_value <= '0';
            sl_direction <= '0';
            WAIT FOR 300ns;
            sl_value <= '1';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 1", num_errors, sl_isr_rising, '1');
            num_errors := ErrorIfUnEqual("Interrupt is fired 1", num_errors, sl_isr_falling, '0');
            WAIT FOR 300ns; -- debounce time
            sl_value <= '0';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt is fired 1", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 2", num_errors, sl_isr_falling, '1');
            WAIT UNTIL falling_edge(sl_clk);
            
        -- check debouncing
            sl_rst <= '0';
            sl_value <= '0';
            sl_direction <= '0';
            WAIT FOR 300ns;
            sl_value <= '1';  -- try to rise a bouncing interrupt after a rising interrupt
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 3", num_errors, sl_isr_rising, '1');
            num_errors := ErrorIfUnEqual("Interrupt is fired 3", num_errors, sl_isr_falling, '0');
            WAIT UNTIL falling_edge(sl_clk);
            sl_value <= '0';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Bouncing 1.1", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Bouncing 1.2", num_errors, sl_isr_falling, '0');
            WAIT UNTIL falling_edge(sl_clk);
            sl_value <= '1';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Bouncing 1.3", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Bouncing 1.4", num_errors, sl_isr_falling, '0');
            WAIT UNTIL falling_edge(sl_clk);
            
            WAIT FOR 300ns;
            sl_value <= '0';  -- try to rise a bouncing interrupt after a falling interrupt
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt is fired 4", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 4", num_errors, sl_isr_falling, '1');
            WAIT UNTIL falling_edge(sl_clk);
            sl_value <= '1';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Bouncing 2.1", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Bouncing 2.2", num_errors, sl_isr_falling, '0');
            WAIT UNTIL falling_edge(sl_clk);
            sl_value <= '0';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Bouncing 2.3", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Bouncing 2.4", num_errors, sl_isr_falling, '0');
            WAIT UNTIL falling_edge(sl_clk);
            
        -- test if a interrupt is rised after the bouncing time
        -- when the signal was rising and inside the periodic time 
        -- is reset to permamnet '0'
            sl_rst <= '0';
            sl_value <= '0';
            sl_direction <= '0';
            WAIT FOR 300ns;
            sl_value <= '1';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 5", num_errors, sl_isr_rising, '1');
            num_errors := ErrorIfUnEqual("Interrupt is fired 5", num_errors, sl_isr_falling, '0');
            WAIT UNTIL falling_edge(sl_clk);
            sl_value <= '0';
            FOR i IN 0 TO 8 LOOP
                WAIT UNTIL falling_edge(sl_clk); -- wait for an exact amount of clk's
                num_errors := ErrorIfUnEqual("Waiting error a:" & integer'image(i), num_errors, sl_isr_rising, '0');
                num_errors := ErrorIfUnEqual("Waiting error a:" & integer'image(i), num_errors, sl_isr_falling, '0');
            END LOOP;
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt is fired 6", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 6", num_errors, sl_isr_falling, '1');
            
            WAIT FOR 300ns;
            sl_value <= '1';
            WAIT FOR 300ns;
            sl_value <= '0';
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt is fired 7", num_errors, sl_isr_rising, '0');
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 7", num_errors, sl_isr_falling, '1');
            WAIT UNTIL falling_edge(sl_clk);
            sl_value <= '1';
            FOR i IN 0 TO 8 LOOP
                WAIT UNTIL falling_edge(sl_clk); -- wait for an exact amount of clk's
                num_errors := ErrorIfUnEqual("Waiting error b:" & integer'image(i), num_errors, sl_isr_rising, '0');
                num_errors := ErrorIfUnEqual("Waiting error b:" & integer'image(i), num_errors, sl_isr_falling, '0');
            END LOOP;
            WAIT UNTIL falling_edge(sl_clk);
            num_errors := ErrorIfUnEqual("Interrupt isn't fired 8", num_errors, sl_isr_rising, '1');
            num_errors := ErrorIfUnEqual("Interrupt is fired 8", num_errors, sl_isr_falling, '0');
    
    
        IF num_errors = 0 THEN 
            REPORT "Simulation without errors" SEVERITY NOTE; 
        ELSE 
            REPORT "SIMULATION WITH ERRORS" SEVERITY FAILURE; 
        END IF; -- Stop Simulation
        ASSERT FALSE REPORT "End of simulation" SEVERITY FAILURE;
    END PROCESS validate;
END ARCHITECTURE sim;




