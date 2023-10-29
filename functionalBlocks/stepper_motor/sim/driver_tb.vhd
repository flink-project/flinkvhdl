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
--  Title             : driver_tb.vhd
--  Project           : FLINK
--  Description       : Testbenc for driver modul
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  25.08.2023 GOOP :	Initial version
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE work.driver_pgk.ALL;


ENTITY driver_tb IS 
END ENTITY driver_tb;

ARCHITECTURE sim OF driver_tb IS
    CONSTANT I_CLOCK_MULTIPLIER : INTEGER := 100; -- Multiplier of Base clock 1ns
    CONSTANT T_CLOCK_PERIOD : TIME := 1 ns * I_CLOCK_MULTIPLIER;
    
    SIGNAL sl_clk  : STD_LOGIC := '0';
    SIGNAL sl_rst  : STD_LOGIC := '1';
    SIGNAL sl_forward : STD_LOGIC := '0';
    SIGNAL sl_fullstep : STD_LOGIC := '0';
    SIGNAL sl_two_phase : STD_LOGIC := '0';
    SIGNAL slv4_motor : STD_LOGIC_VECTOR (3 DOWNTO 0);
    
    SIGNAL b_stop_simulation : BOOLEAN := FALSE;
    
    
    FUNCTION CheckAndReport(s_error_msg : STRING; i_num_errors : INTEGER; slv4_motor: STD_LOGIC_VECTOR (3 DOWNTO 0); slv4_check : STD_LOGIC_VECTOR (3 DOWNTO 0)) RETURN NATURAL IS
    BEGIN
        IF NOT (slv4_motor = slv4_check) THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
BEGIN 

    --## Unit Under Test Instantiation
    u_driver : driver PORT MAP ( 
        isl_trigger =>  sl_clk,
        isl_rst => sl_rst,
        isl_forward => sl_forward,
        isl_fullstep => sl_fullstep,
        isl_two_phase => sl_two_phase,
        oslv4_motor => slv4_motor
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
    BEGIN
    
        -- check rst
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Reset 1", num_errors, slv4_motor, "1001");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Reset 2", num_errors, slv4_motor, "1001");
        WAIT UNTIL falling_edge(sl_clk); 
        num_errors := CheckAndReport( "Fail Reset 3", num_errors, slv4_motor, "1001");
        
        -- Test half step forwards
        sl_rst <= '0';
        sl_forward <= '1';
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards Half Step 1", num_errors, slv4_motor, "1000");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards Half Step 2", num_errors, slv4_motor, "1010");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards Half Step 3", num_errors, slv4_motor, "0010");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards Half Step 4", num_errors, slv4_motor, "0110");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards Half Step 5", num_errors, slv4_motor, "0100");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards Half Step 6", num_errors, slv4_motor, "0101");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards Half Step 7", num_errors, slv4_motor, "0001");
        WAIT UNTIL falling_edge(sl_clk); -- Overflow Check
        num_errors := CheckAndReport( "Fail Forwards Half Step 0", num_errors, slv4_motor, "1001");
        
        -- Test half step backwards
        sl_forward <= '0';
        sl_two_phase <= '1'; -- check if two phase doen't depend to half step
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 7", num_errors, slv4_motor, "0001");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 6", num_errors, slv4_motor, "0101");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 5", num_errors, slv4_motor, "0100");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 4", num_errors, slv4_motor, "0110");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 3", num_errors, slv4_motor, "0010");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 2", num_errors, slv4_motor, "1010");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 1", num_errors, slv4_motor, "1000"); 
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards Half Step 0", num_errors, slv4_motor, "1001");
        WAIT UNTIL falling_edge(sl_clk); -- Overflow Check
        num_errors := CheckAndReport( "Fail Backwards Half Step 7", num_errors, slv4_motor, "0001");
        
        -- Test full step, one phase, forwards
        WAIT UNTIL falling_edge(sl_clk); -- go fist in a even half step to check the init of this mode
        sl_forward <= '1';
        sl_fullstep <= '1';
        sl_two_phase <= '0';
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, One Phase, Full Step 3", num_errors, slv4_motor, "0001");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, One Phase, Full Step 0", num_errors, slv4_motor, "1000");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, One Phase, Full Step 1", num_errors, slv4_motor, "0010");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, One Phase, Full Step 2", num_errors, slv4_motor, "0100");
        WAIT UNTIL falling_edge(sl_clk); -- Overflow Check
        num_errors := CheckAndReport( "Fail Forwards, One Phase, Full Step 3", num_errors, slv4_motor, "0001");
        
        -- Test full step, one phase, backwards
        sl_fullstep <= '0';
        WAIT UNTIL falling_edge(sl_clk); -- go fist in a even half step to check the init of this mode
        sl_forward <= '0';
        sl_fullstep <= '1';
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, One Phase, Full Step 3", num_errors, slv4_motor, "0001");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, One Phase, Full Step 2", num_errors, slv4_motor, "0100");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, One Phase, Full Step 1", num_errors, slv4_motor, "0010");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, One Phase, Full Step 0", num_errors, slv4_motor, "1000");
        WAIT UNTIL falling_edge(sl_clk); -- Overflow Check
        num_errors := CheckAndReport( "Fail Backwards, One Phase, Full Step 3", num_errors, slv4_motor, "0001");
        
        -- Test full step, two phase, forwards
        -- here it is already in a odd half step
        sl_forward <= '1';
        sl_fullstep <= '1';
        sl_two_phase <= '1';
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, Two Phase, Full Step 0", num_errors, slv4_motor, "1001");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, Two Phase, Full Step 1", num_errors, slv4_motor, "1010");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, Two Phase, Full Step 2", num_errors, slv4_motor, "0110");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Forwards, Two Phase, Full Step 3", num_errors, slv4_motor, "0101");
        WAIT UNTIL falling_edge(sl_clk); -- Overflow Check
        num_errors := CheckAndReport( "Fail Forwards, Two Phase, Full Step 0", num_errors, slv4_motor, "1001");
        
        -- Test full step, two phase, backwards
        sl_fullstep <= '0';
        WAIT UNTIL falling_edge(sl_clk); -- go fist in a odd half step to check the init of this mode
        sl_forward <= '0';
        sl_fullstep <= '1';
        sl_two_phase <= '1';
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, Two Phase, Full Step 0", num_errors, slv4_motor, "1001");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, Two Phase, Full Step 3", num_errors, slv4_motor, "0101");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, Two Phase, Full Step 2", num_errors, slv4_motor, "0110");
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Backwards, Two Phase, Full Step 1", num_errors, slv4_motor, "1010");
        WAIT UNTIL falling_edge(sl_clk); -- Overflow Check
        num_errors := CheckAndReport( "Fail Backwards, Two Phase, Full Step 0", num_errors, slv4_motor, "1001");
        
        -- check reset from a other step
        WAIT UNTIL falling_edge(sl_clk);
        WAIT UNTIL falling_edge(sl_clk); -- ensure that step is not resetstep
        num_errors := CheckAndReport( "Precheck Reset 3", num_errors, slv4_motor, "0110");
        sl_rst <= '1';
        WAIT UNTIL falling_edge(sl_clk);
        num_errors := CheckAndReport( "Fail Reset 3", num_errors, slv4_motor, "1001");
        
        IF num_errors = 0 THEN 
            REPORT "Simulation without errors" SEVERITY NOTE; 
        ELSE 
            REPORT "SIMULATION WITH ERRORS" SEVERITY FAILURE; 
        END IF; -- Stop Simulation
        ASSERT FALSE REPORT "End of simulation" SEVERITY FAILURE;
    END PROCESS validate;
END ARCHITECTURE sim;




