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
--  Title             : prescale_register_ctrl_manual_tb.vhd
--  Project           : FLINK
--  Description       : Manuel testbench for the whole Stepper motor stack
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
USE work.prescale_register_ctrl_pkg.ALL;
USE work.speedcontroll_pkg.ALL;


ENTITY prescale_register_ctrl_manual_tb IS 
END ENTITY prescale_register_ctrl_manual_tb;

ARCHITECTURE sim OF prescale_register_ctrl_manual_tb IS
    CONSTANT I_CLOCK_MULTIPLIER : INTEGER := 10; -- Multiplier of Base clock ==> 100MHz
    CONSTANT T_CLOCK_PERIOD : TIME := 1 ns * I_CLOCK_MULTIPLIER;
    CONSTANT I_BUS_WITH : INTEGER := 32;
    CONSTANT i_clock_frequency_divider : INTEGER := 1000;
    
    SIGNAL sl_clk  : STD_LOGIC := '0';
    SIGNAL sl_rst  : STD_LOGIC := '0';
    SIGNAL sl_forward : STD_LOGIC := '0';
    SIGNAL sl_fullstep : STD_LOGIC := '0';
    SIGNAL sl_two_phase : STD_LOGIC := '0';
    SIGNAL sl_reset_start_bit : STD_LOGIC;
    SIGNAL usig_nof_steps : UNSIGNED (i_bus_with -1 DOWNTO 0);
    SIGNAL usig32_stepcounter : UNSIGNED (31 DOWNTO 0) := X"00000000";
    
    SIGNAL slv8_config : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00110011";
--    SIGNAL usig_prescaler_top_speed : UNSIGNED(I_BUS_WITH - 1 DOWNTO 0) :=   TO_UNSIGNED(500000,I_BUS_WITH);
--    SIGNAL usig_acceleration : UNSIGNED(I_BUS_WITH -1 DOWNTO 0) := TO_UNSIGNED(450000,I_BUS_WITH);
--    SIGNAL usig_prescaler_start_speed : UNSIGNED(I_BUS_WITH -1 DOWNTO 0) := TO_UNSIGNED(5000000,I_BUS_WITH);
    
    SIGNAL usig_prescaler_top_speed : UNSIGNED(I_BUS_WITH - 1 DOWNTO 0) := TO_UNSIGNED((100000/100),I_BUS_WITH);
    SIGNAL usig_prescaler_start_speed : UNSIGNED(I_BUS_WITH -1 DOWNTO 0) := TO_UNSIGNED((100000/10),I_BUS_WITH);
    SIGNAL usig_acceleration : UNSIGNED(I_BUS_WITH -1 DOWNTO 0) := TO_UNSIGNED((TO_INTEGER(usig_prescaler_start_speed-usig_prescaler_top_speed)/10),I_BUS_WITH);
    
    SIGNAL usig_steps : UNSIGNED(i_bus_with -1 DOWNTO 0) := TO_UNSIGNED(50,I_BUS_WITH);
    SIGNAL sl_interrupt : STD_LOGIC;
        
    SIGNAL slv4_motor : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL t_state : t_states := STOP;
    
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
    
    -- stepcount for reference (can have an offset)
    PROCESS (slv4_motor)
    BEGIN
        usig32_stepcounter <= usig32_stepcounter +1;
    END PROCESS;
    
    -- Clock generation process
    clock_gen : PROCESS
    BEGIN
        WHILE TRUE LOOP
            sl_clk <= NOT sl_clk AFTER T_CLOCK_PERIOD / 2;
            WAIT FOR T_CLOCK_PERIOD /2;
        END LOOP;
    END PROCESS clock_gen;

END ARCHITECTURE sim;
