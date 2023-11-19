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
--  Title             : multiplexer_tb.vhd
--  Project           : FLINK
--  Description       : Testbench for multiplexer
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  14.10.2023 GOOP :	Initial version
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE work.multiplexer_pkg.ALL;

ENTITY multiplexer_tb IS 
END ENTITY multiplexer_tb;

ARCHITECTURE sim OF multiplexer_tb IS
    CONSTANT I_BUS_WITH : INTEGER := 32;
    CONSTANT I_NOF_INPUTS : INTEGER := 20;
    CONSTANT R_RANDOM : REAL := 354.5;
    
    SIGNAL slv_selector   : STD_LOGIC_VECTOR(I_BUS_WITH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL slv_inputs     : STD_LOGIC_VECTOR(I_NOF_INPUTS-1 DOWNTO 0):= "11001101011101001010";
    SIGNAL sl_out         : STD_LOGIC := '0';
    
    FUNCTION ErrorIfUnEqual(s_error_msg : STRING; i_num_errors : INTEGER; bit_to_check: STD_LOGIC; bit_should_be : STD_LOGIC) RETURN NATURAL IS
    BEGIN
        IF bit_to_check /= bit_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
BEGIN 

    --## Unit Under Test Instantiation
    unit_u_test : multiplexer
    GENERIC MAP(
        i_bus_with   => I_BUS_WITH,
        i_nof_inputs => I_NOF_INPUTS
    )
    PORT MAP( 
        islv_selector   => slv_selector,
        islv_inputs     => slv_inputs,
        osl_out         => sl_out
    );

    validate : PROCESS
        VARIABLE num_errors : INTEGER := 0;
    BEGIN
        
        FOR i IN 0 TO I_NOF_INPUTS-1 LOOP
            slv_selector <= STD_LOGIC_VECTOR(TO_UNSIGNED(i,I_BUS_WITH));
            WAIT FOR 1ns;
            num_errors := ErrorIfUnEqual("Error by multiplexing. Bit Nr: " & integer'image(i), num_errors, slv_inputs(i), sl_out);
        END LOOP;
        
        IF num_errors = 0 THEN 
            REPORT "Simulation without errors" SEVERITY NOTE; 
        ELSE 
            REPORT "SIMULATION WITH ERRORS" SEVERITY FAILURE; 
        END IF; -- Stop Simulation
        ASSERT FALSE REPORT "End of simulation" SEVERITY FAILURE;
    END PROCESS validate;
END ARCHITECTURE sim;