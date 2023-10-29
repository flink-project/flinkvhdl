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
--  Title             : prescale_register_ctrl_tb.vhd
--  Project           : FLINK
--  Description       : Testbench for the whole Stepper motor stack
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  25.08.2023 GOOP :	Initial version
---------------------------------------------------------------------------------------------


-- ==========================================================================================
-- This is a long testbench, which requires approximately 11.4 minutes 
-- on a Intel i9 13th gen to simulate the 6,780 milliseconds. The peak memory usage is 2.6GB.
-- ==========================================================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL;
USE work.prescale_register_ctrl_pkg.ALL;
USE work.speedcontroll_pkg.ALL;


ENTITY prescale_register_ctrl_tb IS 
END ENTITY prescale_register_ctrl_tb;

ARCHITECTURE sim OF prescale_register_ctrl_tb IS
    CONSTANT I_CLOCK_MULTIPLIER : INTEGER := 10; -- Multiplier of Base clock ==> 100MHz
    CONSTANT T_CLOCK_PERIOD : TIME := 1 ns * I_CLOCK_MULTIPLIER;
    CONSTANT I_BUS_WITH : INTEGER := 32;
    CONSTANT i_clock_frequency_divider : INTEGER := 1000; -- submodul runns with a clock of 100kHz

    
    SIGNAL sl_clk  : STD_LOGIC := '0';
    SIGNAL sl_rst  : STD_LOGIC := '0';
    SIGNAL sl_forward : STD_LOGIC := '0';
    SIGNAL sl_fullstep : STD_LOGIC := '0';
    SIGNAL sl_two_phase : STD_LOGIC := '0';
    SIGNAL sl_reset_start_bit : STD_LOGIC;
    SIGNAL usig_nof_steps : UNSIGNED (i_bus_with -1 DOWNTO 0);
    
    SIGNAL slv8_config : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00101001";
    SIGNAL usig_prescaler_top_speed : UNSIGNED(I_BUS_WITH - 1 DOWNTO 0) :=   TO_UNSIGNED((100000/100),I_BUS_WITH); -- 100Hz
    SIGNAL usig_prescaler_start_speed : UNSIGNED(I_BUS_WITH -1 DOWNTO 0) := TO_UNSIGNED((100000/10),I_BUS_WITH); -- 10Hz
    SIGNAL usig_acceleration : UNSIGNED(I_BUS_WITH -1 DOWNTO 0) := TO_UNSIGNED((TO_INTEGER(usig_prescaler_start_speed-usig_prescaler_top_speed)/10),I_BUS_WITH); -- 10 stepps
    SIGNAL usig_steps : UNSIGNED(i_bus_with -1 DOWNTO 0) := TO_UNSIGNED(50,I_BUS_WITH);
    SIGNAL sl_interrupt : STD_LOGIC;
    
    -- this signals has to be checked after test!! Further information at the right position on test
    SIGNAL indicator : STD_LOGIC; -- just an indiactor for wafeform
    SIGNAL slv4_motor : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL t_state : t_states := STOP;
    SIGNAL CHECK_VALUES_ON_WAFEFORM : STD_LOGIC := '0';
    SIGNAL indicator2 : STD_LOGIC; -- just an indiactor for wafeform
    
    
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
    FUNCTION ErrorIfSmaller(s_error_msg : STRING; i_num_errors : INTEGER; vector_to_check: UNSIGNED; vector_should_be : UNSIGNED) RETURN NATURAL IS
    BEGIN
        IF vector_to_check < vector_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
    FUNCTION ErrorIfUnEqual(s_error_msg : STRING; i_num_errors : INTEGER; to_check: t_states; value_should_be : t_states) RETURN NATURAL IS
    BEGIN
        IF to_check /= value_should_be THEN
            REPORT s_error_msg SEVERITY ERROR;
            RETURN i_num_errors + 1;
        END IF; 
        RETURN i_num_errors; 
    END FUNCTION;
BEGIN 

    --## Unit Under Test Instantiation
    u_prescale : prescale_register_ctrl 
        GENERIC MAP(
        i_base_clk => 0,
        i_bus_with => I_BUS_WITH,
        i_clock_frequency_divider => i_clock_frequency_divider
    )
    PORT MAP( 
        isl_clk => sl_clk,
        isl_rst => sl_rst,
        islv8_config => slv8_config,
        iusig_prescaler_top_speed => usig_prescaler_top_speed,
        iusig_prescaler_start_speed => usig_prescaler_start_speed,
        iusig_acceleration => usig_acceleration,
        iusig_steps => usig_steps,
        oslv4_motor => slv4_motor,
        osl_interrupt => sl_interrupt,
        osl_reset_start_bit => sl_reset_start_bit,
        ousig_nof_steps => usig_nof_steps,
        ot_state => t_state
    );
    
    -- Clock generation process
    clock_gen : PROCESS
    BEGIN
        WHILE TRUE LOOP
            sl_clk <= NOT sl_clk AFTER T_CLOCK_PERIOD / 2;
            WAIT FOR T_CLOCK_PERIOD /2;
        END LOOP;
    END PROCESS clock_gen;



    validate : PROCESS
        VARIABLE num_errors : INTEGER := 0;
    BEGIN
        -- check disabeld case
            sl_rst <= '0';
            slv8_config <= (others => '0');
            WAIT FOR 60us;
            FOR i IN 0 TO 7 LOOP  -- check all combinations of the first three bits => should have no effect to motor, interrupt and reset
                slv8_config(2 downto 0) <= std_logic_vector(to_unsigned(i, 3));
                WAIT FOR 20us;
                num_errors := ErrorIfUnEqual("Disabled Motor Error: " & integer'image(i), num_errors, slv4_motor, "0000");
                num_errors := ErrorIfUnEqual("Disabled Interrupt Error: " & integer'image(i), num_errors, sl_interrupt, '0');
                num_errors := ErrorIfUnEqual("Disabled StartBit Error: " & integer'image(i), num_errors, sl_reset_start_bit, '0');
            END LOOP;
        -- reset check
            sl_rst <= '1';
            slv8_config <= (others => '0');
            WAIT FOR 60us;
            FOR i IN 0 TO 2**6-1 LOOP  -- check all combinations of the first 6 bits => should have no effect to motor, interrupt and reset
                slv8_config(5 downto 0) <= std_logic_vector(to_unsigned(i, 6));
                WAIT FOR 20us;
                num_errors := ErrorIfEqual("Reset Motor Error: " & integer'image(i), num_errors, slv4_motor, "0000");
                num_errors := ErrorIfUnEqual("Reset Interrupt Error: " & integer'image(i), num_errors, sl_interrupt, '0');
                num_errors := ErrorIfUnEqual("Reset StartBit Error: " & integer'image(i), num_errors, sl_reset_start_bit, '0');
            END LOOP;
            
        -- check reserved mode (same as disabled)
            sl_rst <= '0';
            slv8_config <= (I_RUN_MODE_0 => '1', I_RUN_MODE_1 => '1', others => '0');
            WAIT FOR 60us;
            FOR i IN 0 TO 7 LOOP  -- check all combinations of the first three bits => should have no effect to motor, interrupt and reset
                slv8_config(2 downto 0) <= std_logic_vector(to_unsigned(i, 3));
                WAIT FOR 20us;
                num_errors := ErrorIfUnEqual("Disabled Motor Error: " & integer'image(i), num_errors, slv4_motor, "0000");
                num_errors := ErrorIfUnEqual("Disabled Interrupt Error: " & integer'image(i), num_errors, sl_interrupt, '0');
                num_errors := ErrorIfUnEqual("Disabled StartBit Error: " & integer'image(i), num_errors, sl_reset_start_bit, '0');
            END LOOP;
            
        -- check step mode 
        -- ==> Important: Tester has here to check the speedup and slows down of the motor when the signal CHECK_VALUES_ON_WAFEFORM is high.
        -- Do not count teh steps. This is check automatic. Only check that the distance between two steps are increasing, decreasing or same depend on the state.
        -- first time CHECK_VALUES_ON_WAFEFORM high, it should immediately accelerate down from accelerating up
        -- second time up, it should accelerate from up to TOP_SPEED and then accelerate down
            -- even steps without top speed
            sl_rst <= '0';
            slv8_config <= "00001011"; -- enable Interrupt, disable start, use step mode, one phase, full step and forwards
            usig_steps <= TO_UNSIGNED(10,I_BUS_WITH); -- once for even stepps
            WAIT FOR 40us;
            CHECK_VALUES_ON_WAFEFORM <= '1';
            slv8_config(I_START) <= '1';
            WAIT UNTIL rising_edge(sl_reset_start_bit);
            slv8_config(I_START) <= '0';
            WAIT UNTIL rising_edge(sl_interrupt);
            CHECK_VALUES_ON_WAFEFORM <= '0';
            num_errors := ErrorIfUnEqual("Wrong Stepps 1", num_errors, usig_steps, usig_nof_steps);

            
            -- Please check here that the speedup happen to the motor
            --REPORT "Manual checkup here" SEVERITY FAILURE; 
            
            -- odd steps without top speed
            usig_steps <= TO_UNSIGNED(11,I_BUS_WITH);
            slv8_config(I_RESET_STEPCOUNTER) <= '1'; -- reset internal stepcounter
            WAIT FOR 40us;
            slv8_config(I_RESET_STEPCOUNTER) <= '0';
            slv8_config(I_START) <= '1';
            WAIT FOR 40us;
            usig_steps <= TO_UNSIGNED(30,I_BUS_WITH); -- a change after start shouldn't have any effect
            WAIT UNTIL rising_edge(sl_reset_start_bit);
            slv8_config(I_START) <= '0';
            WAIT UNTIL rising_edge(sl_interrupt);
            num_errors := ErrorIfUnEqual("Wrong Stepps 2", num_errors, usig_nof_steps, TO_UNSIGNED(11,I_BUS_WITH));

            
            -- even steps with top speed
            usig_steps <= TO_UNSIGNED(24,I_BUS_WITH); -- once for even stepps
            slv8_config(I_RESET_STEPCOUNTER) <= '1'; -- reset internal stepcounter
            WAIT FOR 40us;
            slv8_config(I_RESET_STEPCOUNTER) <= '0';
            CHECK_VALUES_ON_WAFEFORM <= '1';
            slv8_config(I_START) <= '1';
            WAIT UNTIL rising_edge(sl_reset_start_bit);
            slv8_config(I_START) <= '0';
            WAIT UNTIL rising_edge(sl_interrupt);
            CHECK_VALUES_ON_WAFEFORM <= '0';
            num_errors := ErrorIfUnEqual("Wrong Stepps 3", num_errors, usig_nof_steps, usig_steps);

            
            -- Please check here that the speedup happen to the motor
            --REPORT "Manual checkup here" SEVERITY FAILURE; 
            
            -- odd steps with top speed
            usig_steps <= TO_UNSIGNED(25,I_BUS_WITH);
            slv8_config(I_RESET_STEPCOUNTER) <= '1'; -- reset internal stepcounter
            WAIT FOR 40us;
            slv8_config(I_RESET_STEPCOUNTER) <= '0';
            slv8_config(I_START) <= '1';
            WAIT FOR 400us;
            usig_steps <= TO_UNSIGNED(30,I_BUS_WITH); -- a change after start shouldn't have any effect
            WAIT UNTIL rising_edge(sl_reset_start_bit);
            slv8_config(I_START) <= '0';
            WAIT UNTIL rising_edge(sl_interrupt);
            num_errors := ErrorIfUnEqual("Wrong Stepps 4", num_errors, usig_nof_steps, TO_UNSIGNED(25,I_BUS_WITH));

        
        -- check run mode
            -- check stop while starting
            slv8_config <= "00010100"; -- enable Interrupt, enable start, use run mode, two phase, half step and backwards
            slv8_config(I_RESET_STEPCOUNTER) <= '1'; -- reset internal stepcounter
            WAIT FOR 40us;
            slv8_config(I_RESET_STEPCOUNTER) <= '0';
            slv8_config(I_START) <= '1';
            WAIT FOR 400ms;
            num_errors := ErrorIfUnEqual("Wrong state 1.0", num_errors, t_state, ACCELERATE_UP);
            slv8_config(I_START) <= '0';
            WAIT FOR 60us;
            num_errors := ErrorIfUnEqual("Wrong state 1.1", num_errors, t_state, ACCELERATE_DOWN);
            WAIT UNTIL rising_edge(sl_interrupt);
            num_errors := ErrorIfUnEqual("Wrong state 1.2", num_errors, t_state, STOP);
            num_errors := ErrorIfSmaller("Motor didn't any step in run mode 1", num_errors, usig_nof_steps, TO_UNSIGNED(10,I_BUS_WITH));
            
            
            -- check stop in TOP_SPEED
            slv8_config(I_RESET_STEPCOUNTER) <= '1'; -- reset internal stepcounter
            WAIT FOR 40us;
            slv8_config(I_RESET_STEPCOUNTER) <= '0';
            slv8_config(I_START) <= '1';
            WAIT FOR 600ms;
            num_errors := ErrorIfUnEqual("Wrong state 2.0", num_errors, t_state, TOP_SPEED);
            slv8_config(I_START) <= '0';
            WAIT FOR 80us;
            num_errors := ErrorIfUnEqual("Wrong state 2.1", num_errors, t_state, ACCELERATE_DOWN);
            WAIT UNTIL rising_edge(sl_interrupt);
            num_errors := ErrorIfUnEqual("Wrong state 2.2", num_errors, t_state, STOP);
            num_errors := ErrorIfSmaller("Motor didn't any step in run mode 2", num_errors, usig_nof_steps, TO_UNSIGNED(10,I_BUS_WITH));

            
            -- check a change of top speed while running
            slv8_config(I_RESET_STEPCOUNTER) <= '1'; -- reset internal stepcounter
            WAIT FOR 40us;
            slv8_config(I_RESET_STEPCOUNTER) <= '0';
            slv8_config(I_START) <= '1';
            WAIT FOR 600ms;
            num_errors := ErrorIfUnEqual("Wrong state 3.0", num_errors, t_state, TOP_SPEED);
            usig_prescaler_top_speed <=  TO_UNSIGNED((100000/20),I_BUS_WITH); -- 50Hz
            WAIT FOR 1ms;
            num_errors := ErrorIfUnEqual("Wrong state 3.1", num_errors, t_state, ACCELERATE_DOWN);
            WAIT FOR 150ms;
            num_errors := ErrorIfUnEqual("Wrong state 3.2", num_errors, t_state, TOP_SPEED);
            usig_prescaler_top_speed <= TO_UNSIGNED((100000/100),I_BUS_WITH); -- 100Hz
            WAIT FOR 1ms;
            num_errors := ErrorIfUnEqual("Wrong state 3.3", num_errors, t_state, ACCELERATE_UP);
            WAIT FOR 150ms;
            num_errors := ErrorIfUnEqual("Wrong state 3.4", num_errors, t_state, TOP_SPEED);
            slv8_config(I_START) <= '0';
            WAIT UNTIL rising_edge(sl_interrupt);
            WAIT FOR 400us;
            num_errors := ErrorIfSmaller("Motor didn't any step in run mode 3", num_errors, usig_nof_steps, TO_UNSIGNED(20,I_BUS_WITH));
            
        IF num_errors = 0 THEN 
            REPORT "Simulation without errors" SEVERITY NOTE; 
        ELSE 
            REPORT "SIMULATION WITH ERRORS" SEVERITY FAILURE; 
        END IF; -- Stop Simulation
        ASSERT FALSE REPORT "End of simulation" SEVERITY FAILURE;
    END PROCESS validate;
END ARCHITECTURE sim;
