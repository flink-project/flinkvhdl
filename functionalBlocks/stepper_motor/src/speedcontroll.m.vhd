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
--  Title             : speedcontroller.m.vhd
--  Project           : FLINK
--  Description       : Speedcontroller for driver of stepper motor
---------------------------------------------------------------------------------------------
--  Copyright(C) 2023 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  26.08.2023 GOOP :    Initial version
---------------------------------------------------------------------------------------------

-- konstante in unsigned wandeln

-- Mode Description:
-- Gererell:  
--      It is not recommended to change from STEP MODE to FIX SPEED mode.
--      It is better to stop the engine first and then change the mode.
--
--      However, when changing from one of these two modes to DISABELD 
--      mode, the motor will simply coast to a stop without any braking 
--      effect (all windings will be non-magnetized).
--
--      When resetting the modules, the motor keeps the current step 
--      (The windings are still magnetized).
--
--      Attention: The acceleration is divided by two within the module. 
--      Since the motor accelerates with each trigger edge. Therefore 
--      the LSB is not considered by the acceleration.
--      
-- DISABELD:
--      The motor is freewheeling here. This means that the motor 
--      has no holding torque (all windings are not magnetized).
-- 
-- STEP MODE:
--      The motor moves through the specified number of steps. 
--      It uses a ramp to accelerate up and down.
--
--      changes in the configuration, prescaler and steps registers 
--      are only applied when the motor is at standstill.
--
--      The module sends a signal to reset the start bit (osl_reset_start_bit).
--      When the start bit is manually reset, the motor immediately 
--      ramps down without reaching the number of steps.
-- 
-- FIX SPEED:
--      The motor ramps up to a preset speed. When the command to stop 
--      is given, the ramp is lowered again until it comes to a standstill. 
--
--      Changes in acceleration and starting speed are only applied at 
--      standstill. The maximum speed can be changed at will. Any change 
--      in maximum speed is approached with a ramp.
-- 
-- RESERVED:
--      Not implemented yet.


-- Interrupt:
--      An interrupt is triggered when the motor has completed the shutdown 
--      and changes to the stop state.

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE speedcontroll_pkg IS
    -- configuration register pin assignment
    CONSTANT I_DIRECTION :          INTEGER := 0;
    CONSTANT I_FULL_STEP :          INTEGER := 1;
    CONSTANT I_TWO_PHASE :          INTEGER := 2;
    CONSTANT I_RUN_MODE_0 :         INTEGER := 3;
    CONSTANT I_RUN_MODE_1 :         INTEGER := 4;
    CONSTANT I_START :              INTEGER := 5;
    CONSTANT I_RESET_STEPCOUNTER :  INTEGER := 6;
    
    -- ONLY FOR TESTING ==> Ignore it!!
    TYPE t_states IS (TOP_SPEED, ACCELERATE_UP, ACCELERATE_DOWN, STOP, MIDDLE_SINGLE_STEP); -- State machine to control ramp
    
    COMPONENT speedcontroll IS
        GENERIC (
            i_base_clk : INTEGER := 0;
            i_bus_with : INTEGER := 8;
            i_clock_frequency_divider : INTEGER := 1000 -- prescale external 100MHz clock to internal 100kHz clock
        );
        PORT (
            isl_clk : IN STD_LOGIC;
            isl_rst : IN STD_LOGIC;
            
            -- bit 0: Direction: 1 = forward, 0 = backwards
            -- bit 1: Full Step: 1 = full step, 0 = half step
            -- bit 2: Two Phase: 1 = two phase, 0 = one phase
            -- bit 4..3: Run Mode: 00 = No holding torque,  01 = Step Mode
            -- bit 4..3: Run Mode: 10 = Fixed Speed,        11 = reserved
            -- bit 5: Start: 1 = Running motor, 0 = Stopping motor
            -- bit 6: Reset Stepcounter
            -- bit 7: reserved
            islv8_config : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            -- prescaler for top speed
            iusig_prescaler_top_speed : IN UNSIGNED(i_bus_with - 1 DOWNTO 0);
            -- prescaler for start speed
            iusig_prescaler_start_speed : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
            -- Acceleration when starting or stopping the engine
            -- nof clocks faster after a step
            iusig_acceleration : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
            -- nof Stepps to do in Stepping Mode
            iusig_steps : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
            -- to motor:
            -- order: MSB -> LSB => A,A',B,B'
            oslv4_motor : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            -- Reset Start bit when motor is stopping
            osl_reset_start_bit : OUT STD_LOGIC;
            -- steps which have been taken
            ousig_nof_steps : OUT UNSIGNED (i_bus_with -1 DOWNTO 0);
            
            -- ONLY FOR TESTING ==> Ignore it!!
            ot_state : OUT t_states
        );
    END COMPONENT speedcontroll;
END PACKAGE speedcontroll_pkg;

---------------------------------------------------------------------------------------------
-- ENTITIY
---------------------------------------------------------------------------------------------
LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.driver_pgk.ALL;
USE work.speedcontroll_pkg.ALL;

ENTITY speedcontroll IS
    GENERIC (
        i_base_clk                : INTEGER := 0;
        i_bus_with                : INTEGER := 8;
        i_clock_frequency_divider : INTEGER := 1000 -- prescale external 100MHz clock to internal 100kHz clock

    );
    PORT ( 
        isl_clk                     : IN STD_LOGIC;
        isl_rst                     : IN STD_LOGIC;
        islv8_config                : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        iusig_prescaler_top_speed   : IN UNSIGNED(i_bus_with - 1 DOWNTO 0);
        iusig_prescaler_start_speed : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
        iusig_acceleration          : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
        iusig_steps                 : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
        oslv4_motor                 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        osl_reset_start_bit         : OUT STD_LOGIC;
        ousig_nof_steps             : OUT UNSIGNED (i_bus_with -1 DOWNTO 0);
        ot_state                    : OUT t_states
    );
END ENTITY speedcontroll;

---------------------------------------------------------------------------------------------
-- ARCHITECTURE
---------------------------------------------------------------------------------------------
ARCHITECTURE rtl of speedcontroll is
    SIGNAL usig2_mode : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL slv4_motor : STD_LOGIC_VECTOR (3 DOWNTO 0);

    CONSTANT C_BUS_WITH_MAX_VALUE     : UNSIGNED(i_bus_with -1 DOWNTO 0) := (OTHERS => '1');
    CONSTANT C_EDGE_COUNTER_MAX_VALUE : UNSIGNED(i_bus_with DOWNTO 0) := (OTHERS => '1');
    
    TYPE t_request IS (STOP, START, TO_STOP); -- Request to state machine
    TYPE t_modes IS (DISABELD, STEP_MODE, FIXED_SPEED, RESERVED);
    
    -------------------------------------------------------------------------------
    -- internal registers and reset values
    -------------------------------------------------------------------------------
    -- used in all processes but main use is in statemachine
    -- read in: in all processes
    -- write to: only in statemachine
    TYPE t_registes_statemachine IS RECORD
        usig_prescaler_ramp   : UNSIGNED(i_bus_with - 1 DOWNTO 0);
        sl_trigger            : STD_LOGIC;
        usig_counter          : UNSIGNED(i_bus_with - 1 DOWNTO 0);
        usig_nof_edges        : UNSIGNED(i_bus_with DOWNTO 0); -- the forgotten -1 is NOT an error!! -> for stepping
        usig_nof_edges_while_accelerate : UNSIGNED(i_bus_with DOWNTO 0); -- the forgotten -1 is NOT an error!! -> for stepping
        usig_nof_edges_total  : UNSIGNED(i_bus_with DOWNTO 0); -- total stepcounter is mapped to output ousig_nof_steps
        sl_single_step_done   : STD_LOGIC;
        sl_motor_is_slow_down : STD_LOGIC;
        t_fsm_state : t_states;
        usig_old_prescaler_top_speed : UNSIGNED(i_bus_with - 1 DOWNTO 0);
    END RECORD t_registes_statemachine;
    CONSTANT C_RESET_STATE_MACHINE_REGS : t_registes_statemachine := (
        --usig_prescaler_ramp => iusig_prescaler_start_speed, ==> Wiso wird dies zu 'U' initialisert
        usig_prescaler_ramp   => (OTHERS => '1'),
        sl_trigger            => '0',
        usig_counter          => (OTHERS => '0'),
        usig_nof_edges        => (OTHERS => '0'),
        usig_nof_edges_while_accelerate => (OTHERS => '0'),
        usig_nof_edges_total  => (0 => '1', OTHERS => '0'),
        sl_single_step_done   => '0',
        sl_motor_is_slow_down => '0',
        t_fsm_state           => STOP,
        usig_old_prescaler_top_speed => (OTHERS => '1')
    );
    SIGNAL ri_statemachine, ri_next_statemachine : t_registes_statemachine := C_RESET_STATE_MACHINE_REGS;

    
    -- used in process mode controll and statemachine
    -- read in: both
    -- write to: only in mode controll
    TYPE t_registers_mode_control IS RECORD
        t_request_statechange : t_request;
        slv4_motor            : STD_LOGIC_VECTOR (3 DOWNTO 0);
        t_mode                : t_modes;
        sl_reset_start_bit    : STD_LOGIC;
        sl_nof_steps_odd      : STD_LOGIC;
    END RECORD t_registers_mode_control;
    CONSTANT C_RESET_STATE_REGS : t_registers_mode_control := (
        t_request_statechange => TO_STOP,
        slv4_motor            => "0000",
        t_mode                => DISABELD,
        sl_reset_start_bit    => '0',
        sl_nof_steps_odd      => '0'
    );
    SIGNAL ri_mode_control, ri_next_mode_control : t_registers_mode_control := C_RESET_STATE_REGS;
BEGIN

    -- mode extraction from config register
    usig2_mode(0) <= islv8_config(I_RUN_MODE_0);
    usig2_mode(1) <= islv8_config(I_RUN_MODE_1);
            
    ----------------------------------------------------------------------------------
    -- combinatorial process (Statemachine)
    ----------------------------------------------------------------------------------
    comb_statemachine : PROCESS (ri_mode_control, ri_statemachine)
        VARIABLE v_statemachine : t_registes_statemachine := C_RESET_STATE_MACHINE_REGS;
    BEGIN
        v_statemachine := ri_statemachine;
        CASE ri_statemachine.t_fsm_state IS
            WHEN STOP =>
                IF ri_mode_control.t_request_statechange = START THEN
                    v_statemachine.t_fsm_state := ACCELERATE_UP;
                END IF;
                -- prepare next run
                v_statemachine.usig_prescaler_ramp := iusig_prescaler_start_speed;
                v_statemachine.sl_trigger := '0';
                v_statemachine.usig_counter := iusig_prescaler_start_speed; -- init counter to skip waittime for first stepp
                v_statemachine.usig_nof_edges := (OTHERS => '0');
                v_statemachine.usig_nof_edges_while_accelerate := (OTHERS => '0');
                v_statemachine.sl_single_step_done := '0';
                v_statemachine.sl_motor_is_slow_down := '0';
                v_statemachine.usig_old_prescaler_top_speed := iusig_prescaler_top_speed;
            WHEN ACCELERATE_UP =>
                IF ri_statemachine.usig_prescaler_ramp <= iusig_prescaler_top_speed - 1 THEN
                    v_statemachine.t_fsm_state := TOP_SPEED;
                    v_statemachine.usig_nof_edges_while_accelerate := ri_statemachine.usig_nof_edges;
                    v_statemachine.usig_old_prescaler_top_speed := iusig_prescaler_top_speed;
                ELSIF ri_mode_control.t_request_statechange = STOP THEN
                    IF ri_mode_control.sl_nof_steps_odd = '1' AND usig2_mode = "01" THEN --when steps are odd do a singel step befor slow down only in step mode
                        v_statemachine.t_fsm_state := MIDDLE_SINGLE_STEP;
                        v_statemachine.sl_single_step_done := '0';
                    ELSE
                        v_statemachine.t_fsm_state := ACCELERATE_DOWN;
                    END IF;
                ELSIF ri_mode_control.t_request_statechange = TO_STOP THEN -- Hard Stop, not recommended
                    v_statemachine.t_fsm_state := STOP;
                ELSE 
                    IF ri_statemachine.usig_counter >= (ri_statemachine.usig_prescaler_ramp - 1) THEN
                        v_statemachine.usig_counter := (OTHERS => '0');
                        IF ri_statemachine.sl_trigger = '0' THEN
                            IF ri_statemachine.usig_prescaler_ramp > iusig_acceleration THEN -- Overflow check
                                v_statemachine.usig_prescaler_ramp := ri_statemachine.usig_prescaler_ramp - iusig_acceleration;
                            ELSE
                                v_statemachine.usig_prescaler_ramp := (1 => '1', OTHERS => '0');
                            END IF;
                        END IF;
                        v_statemachine.sl_trigger := NOT ri_statemachine.sl_trigger;
                        v_statemachine.usig_nof_edges := ri_statemachine.usig_nof_edges + 1; -- only for step mode
                        v_statemachine.usig_nof_edges_total := ri_statemachine.usig_nof_edges_total + 1; -- for stepcounter 
                    ELSE
                        IF ri_statemachine.usig_counter < C_BUS_WITH_MAX_VALUE - 2 THEN  -- Overflow check
                            v_statemachine.usig_counter := ri_statemachine.usig_counter + 2;
                        ELSE
                            v_statemachine.usig_counter := (OTHERS => '1');
                        END IF;
                    END IF;
                END IF;
            WHEN TOP_SPEED =>
                IF ri_mode_control.t_request_statechange = STOP THEN
                    v_statemachine.t_fsm_state := ACCELERATE_DOWN;
                    v_statemachine.usig_prescaler_ramp := iusig_prescaler_top_speed;
                    v_statemachine.sl_motor_is_slow_down := '0';
                ELSIF ri_mode_control.t_request_statechange = TO_STOP THEN -- Hard Stop, not recommended
                    v_statemachine.t_fsm_state := STOP;
                ELSIF ri_statemachine.usig_old_prescaler_top_speed > iusig_prescaler_top_speed THEN -- top speed are increased -> speed up again
                    v_statemachine.usig_prescaler_ramp := ri_statemachine.usig_old_prescaler_top_speed;
                    v_statemachine.usig_old_prescaler_top_speed := iusig_prescaler_top_speed;
                    v_statemachine.t_fsm_state := ACCELERATE_UP;
                ELSIF ri_statemachine.usig_old_prescaler_top_speed < iusig_prescaler_top_speed THEN -- top speed are decreased -> speed slows down
                    v_statemachine.usig_prescaler_ramp := ri_statemachine.usig_old_prescaler_top_speed;
                    v_statemachine.usig_old_prescaler_top_speed := iusig_prescaler_top_speed;
                    v_statemachine.t_fsm_state := ACCELERATE_DOWN;
                    v_statemachine.sl_motor_is_slow_down := '1';
                ELSE
                    IF ri_statemachine.usig_counter >= (iusig_prescaler_top_speed - 1) THEN
                        v_statemachine.usig_counter := (OTHERS => '0');
                        v_statemachine.sl_trigger := NOT ri_statemachine.sl_trigger;
                        v_statemachine.usig_nof_edges := ri_statemachine.usig_nof_edges + 1;  -- only for step mode
                        v_statemachine.usig_nof_edges_total := ri_statemachine.usig_nof_edges_total + 1; -- for stepcounter 
                    ELSE
                        IF ri_statemachine.usig_counter < C_BUS_WITH_MAX_VALUE - 2 THEN  -- Overflow check
                            v_statemachine.usig_counter := ri_statemachine.usig_counter + 2;
                        ELSE
                            v_statemachine.usig_counter := (OTHERS => '1');
                        END IF;
                    END IF;
                END IF;
            WHEN ACCELERATE_DOWN =>
                IF ri_statemachine.usig_prescaler_ramp >= iusig_prescaler_start_speed THEN
                    v_statemachine.t_fsm_state := STOP;
                ELSIF ri_mode_control.t_request_statechange = START AND ri_statemachine.sl_motor_is_slow_down = '0' THEN
                    v_statemachine.t_fsm_state := ACCELERATE_UP;
                ELSIF ri_mode_control.t_request_statechange = TO_STOP THEN -- Hard Stop, not recommended
                    v_statemachine.t_fsm_state := STOP;
                ELSIF ri_statemachine.usig_prescaler_ramp >= iusig_prescaler_top_speed AND ri_statemachine.sl_motor_is_slow_down = '1' THEN
                    v_statemachine.t_fsm_state := TOP_SPEED;
                    v_statemachine.usig_old_prescaler_top_speed := iusig_prescaler_top_speed;
                    v_statemachine.sl_motor_is_slow_down := '0';
                ELSE 
                    IF ri_statemachine.usig_counter >= (ri_statemachine.usig_prescaler_ramp - 1) THEN
                        v_statemachine.usig_counter := (OTHERS => '0');
                        IF ri_statemachine.sl_trigger = '0' THEN
                            IF ri_statemachine.usig_prescaler_ramp < C_BUS_WITH_MAX_VALUE - iusig_acceleration THEN  -- Overflow check
                                v_statemachine.usig_prescaler_ramp := ri_statemachine.usig_prescaler_ramp + iusig_acceleration;
                            ELSE
                                v_statemachine.usig_prescaler_ramp := iusig_prescaler_start_speed;
                            END IF;
                        END IF;
                        v_statemachine.sl_trigger := NOT  ri_statemachine.sl_trigger;
                        v_statemachine.usig_nof_edges := ri_statemachine.usig_nof_edges + 1;  -- only for step mode
                        v_statemachine.usig_nof_edges_total := ri_statemachine.usig_nof_edges_total + 1; -- for stepcounter 
                    ELSE
                        IF ri_statemachine.usig_counter < C_BUS_WITH_MAX_VALUE - 2 THEN  -- Overflow check
                            v_statemachine.usig_counter := ri_statemachine.usig_counter + 2;
                        ELSE
                            v_statemachine.usig_counter := (OTHERS => '1');
                        END IF;
                    END IF;
                END IF; 
            WHEN MIDDLE_SINGLE_STEP => -- only used in step mode if stepps are odd
                IF ri_statemachine.sl_single_step_done = '1' THEN
                    v_statemachine.t_fsm_state := ACCELERATE_DOWN;
                ELSE
                    IF ri_statemachine.usig_counter >= (ri_statemachine.usig_prescaler_ramp - 1) THEN
                        v_statemachine.usig_counter := (OTHERS => '0');
                        v_statemachine.sl_trigger := NOT  ri_statemachine.sl_trigger;
                        v_statemachine.usig_nof_edges := ri_statemachine.usig_nof_edges + 1;  -- only for step mode
                        v_statemachine.usig_nof_edges_total := ri_statemachine.usig_nof_edges_total + 1; -- for stepcounter 
                        v_statemachine.sl_single_step_done := ri_statemachine.sl_trigger;
                    ELSE
                        IF ri_statemachine.usig_counter < C_BUS_WITH_MAX_VALUE - 2 THEN  -- Overflow check
                            v_statemachine.usig_counter := ri_statemachine.usig_counter + 2;
                        ELSE
                            v_statemachine.usig_counter := (OTHERS => '1');
                        END IF;
                    END IF;
                END IF;
        END CASE;
        
        -- overflowdedection for total step counter
        IF islv8_config(I_RESET_STEPCOUNTER) = '1' THEN
            v_statemachine.usig_nof_edges_total := (0 => '1', OTHERS => '0');
        END IF;
        
        IF isl_rst = '1' THEN
            v_statemachine := C_RESET_STATE_MACHINE_REGS;
            v_statemachine.sl_trigger := NOT ri_statemachine.sl_trigger; -- Driver has also to react
        END IF;
        ri_next_statemachine <= v_statemachine;
    END PROCESS comb_statemachine;
    
    ----------------------------------------------------------------------------------
    -- combinatorial process (Mode Controll)
    ----------------------------------------------------------------------------------
    comb_mode_ctrl : PROCESS (ri_mode_control, ri_statemachine, isl_clk)
        VARIABLE v : t_registers_mode_control := C_RESET_STATE_REGS;
        VARIABLE usig_nof_triggers : UNSIGNED(i_bus_with - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE usig_nof_triggers_while_accelerate : UNSIGNED(i_bus_with - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        v := ri_mode_control;
            
        -- Avoid restart of motor in step mode
        IF ri_mode_control.sl_reset_start_bit = '1' AND islv8_config(I_START) = '0' THEN
            v.sl_reset_start_bit := '0';
        END IF;
        
        CASE ri_mode_control.t_mode IS
            WHEN DISABELD =>
                IF usig2_mode = "01" THEN -- To step mode
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.sl_reset_start_bit := '1';
                    v.t_mode := STEP_MODE;
                ELSIF usig2_mode = "10" THEN -- To fix speed mode
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.sl_reset_start_bit := '1';
                    v.t_mode := FIXED_SPEED;
                ELSIF usig2_mode = "11" THEN -- To reserved
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.slv4_motor := "0000";
                    v.t_mode := RESERVED;
                ELSE -- what to to in this mode
                    v.slv4_motor := "0000";
                END IF;
            WHEN STEP_MODE =>
                IF usig2_mode = "00" THEN -- To disabeld
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.slv4_motor := "0000";
                    v.t_mode := DISABELD;
                ELSIF usig2_mode = "10" THEN -- To fix speed mode 
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.sl_reset_start_bit := '1';
                    v.t_mode := FIXED_SPEED;
                ELSIF usig2_mode = "11" THEN -- To reserved
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.slv4_motor := "0000";
                    v.t_mode := RESERVED;
                ELSE -- what to to in this mode
                    usig_nof_triggers := ri_statemachine.usig_nof_edges(i_bus_with DOWNTO 1); -- the forgotten -1 is NOT an error!!
                    usig_nof_triggers_while_accelerate := ri_statemachine.usig_nof_edges_while_accelerate(i_bus_with DOWNTO 1); -- the forgotten -1 is NOT an error!!
                    IF islv8_config(I_START) = '1' AND ri_statemachine.t_fsm_state = STOP AND ri_mode_control.sl_reset_start_bit = '0' THEN -- start
                        v.t_request_statechange := START;
                        v.sl_nof_steps_odd := iusig_steps(0);
                    END IF;
                    IF usig_nof_triggers >= iusig_steps THEN -- stops immediately when steps are reached (emergency stop :P )
                        v.t_request_statechange := TO_STOP;
                        v.sl_reset_start_bit := '1';
                    ELSIF ri_statemachine.t_fsm_state = ACCELERATE_UP AND usig_nof_triggers >= iusig_steps/2 THEN -- when half of the steps are reached during startup -> stop
                        v.t_request_statechange := STOP;
                        v.sl_reset_start_bit := '1';
                    ELSIF ri_statemachine.t_fsm_state = TOP_SPEED AND usig_nof_triggers >= iusig_steps - usig_nof_triggers_while_accelerate THEN -- when 2/3 of the steps are reached in top speed -> stop
                        v.t_request_statechange := STOP;
                        v.sl_reset_start_bit := '1';
                    END IF;
                    IF islv8_config(I_START) = '0' THEN -- if user will stop while motor is running
                        v.t_request_statechange := STOP;
                    END IF;
                    v.slv4_motor := slv4_motor;
                END IF;
            WHEN FIXED_SPEED =>
                IF usig2_mode = "00" THEN -- To disabeld
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.slv4_motor := "0000";
                    v.t_mode := DISABELD;
                ELSIF usig2_mode = "01" THEN -- To step mode
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.sl_reset_start_bit := '1';
                    v.t_mode := STEP_MODE;
                ELSIF usig2_mode = "11" THEN -- To reserved
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.slv4_motor := "0000";
                    v.t_mode := RESERVED;
                ELSE -- what to to in this mode
                    IF islv8_config(I_START) = '1' THEN
                        v.t_request_statechange := START;
                    ELSIF islv8_config(I_START) = '0' THEN
                        v.t_request_statechange := STOP;
                    END IF;
                    v.slv4_motor := slv4_motor;
                    v.sl_reset_start_bit := '0';
                END IF;
            WHEN RESERVED =>
                IF usig2_mode = "00" THEN -- To disabeld
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.slv4_motor := "0000";
                    v.t_mode := DISABELD;
                ELSIF usig2_mode = "01" THEN -- To step mode
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.sl_reset_start_bit := '1';
                    v.t_mode := STEP_MODE;
                ELSIF usig2_mode = "10" THEN -- To fix speed mode 
                    v.t_request_statechange := TO_STOP; -- Hard stop
                    v.sl_reset_start_bit := '1';
                    v.t_mode := FIXED_SPEED;
                ELSE -- what to to in this mode
                    v.slv4_motor := "0000";
                END IF;
        END CASE;
        
        IF isl_rst = '1' THEN
            v := C_RESET_STATE_REGS;
            v.slv4_motor := slv4_motor; -- avoid freewheeling
            usig_nof_triggers := (OTHERS => '0');
            usig_nof_triggers_while_accelerate := (OTHERS => '0');
        END IF;
        
        ri_next_mode_control <= v;
    END PROCESS comb_mode_ctrl;
    
    ----------------------------------------------------------------------------------
    -- registered process
    ----------------------------------------------------------------------------------
    mode_control : PROCESS (isl_clk, isl_rst)
    BEGIN
        IF rising_edge(isl_clk) THEN
            ri_mode_control <= ri_next_mode_control;
            ri_statemachine <= ri_next_statemachine;
        END IF;
    END PROCESS mode_control;
    
    ----------------------------------------------------------------------------------
    -- create component
    ----------------------------------------------------------------------------------
    u_driver : driver 
    PORT MAP (
        isl_trigger =>  ri_statemachine.sl_trigger,
        isl_rst => isl_rst,
        isl_forward => islv8_config(I_DIRECTION),
        isl_fullstep => islv8_config(I_FULL_STEP),
        isl_two_phase => islv8_config(I_TWO_PHASE),
        oslv4_motor => slv4_motor
    );
    
    ----------------------------------------------------------------------------------
    -- output assignment 
    ----------------------------------------------------------------------------------
    oslv4_motor <= ri_mode_control.slv4_motor;
    osl_reset_start_bit <= ri_mode_control.sl_reset_start_bit;
    ot_state <= ri_statemachine.t_fsm_state;
    ousig_nof_steps <= ri_statemachine.usig_nof_edges_total(i_bus_with DOWNTO 1); -- the forgotten -1 is NOT an error!!
    
END rtl;