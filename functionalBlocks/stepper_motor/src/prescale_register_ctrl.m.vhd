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
--  Title             : prescale_register_ctrl.m.vhd
--  Project           : FLINK
--  Description       : Clock prescaler and register controll of Speedcontroller
---------------------------------------------------------------------------------------------
--  Copyright(C) 2023 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  11.10.2023 GOOP :    Initial version
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.speedcontroll_pkg.ALL;

PACKAGE prescale_register_ctrl_pkg IS
        
    COMPONENT prescale_register_ctrl IS
        GENERIC (
            i_base_clk : INTEGER := 0;
            i_bus_with : INTEGER := 8;
            i_clock_frequency_divider : INTEGER := 1000 -- prescale external 100MHz clock to internal 100kHz clock
        );
        PORT (
            isl_clk : IN STD_LOGIC;
            isl_rst : IN STD_LOGIC;

            islv8_config                : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            iusig_prescaler_top_speed   : IN UNSIGNED(i_bus_with - 1 DOWNTO 0);
            iusig_prescaler_start_speed : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
            iusig_acceleration          : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
            iusig_steps                 : IN UNSIGNED(i_bus_with -1 DOWNTO 0);
            oslv4_motor                 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            osl_interrupt               : OUT STD_LOGIC;
            osl_reset_start_bit         : OUT STD_LOGIC;
            ousig_nof_steps             : OUT UNSIGNED (i_bus_with -1 DOWNTO 0);
            
            -- ONLY FOR TESTING ==> Ignore it!!
            ot_state : OUT t_states
        );
    END COMPONENT prescale_register_ctrl;
END PACKAGE prescale_register_ctrl_pkg;

---------------------------------------------------------------------------------------------
-- ENTITIY
---------------------------------------------------------------------------------------------
LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.driver_pgk.ALL;
USE work.speedcontroll_pkg.ALL;

ENTITY prescale_register_ctrl IS
    GENERIC (
        i_base_clk : INTEGER := 0;
        i_bus_with : INTEGER := 8;
        i_clock_frequency_divider : INTEGER := 1000 -- prescale external 100MHz clock to internal 100kHz clock

    );
    PORT ( 
        isl_clk :                       IN STD_LOGIC;
        isl_rst :                       IN STD_LOGIC;
        islv8_config :                  IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        iusig_prescaler_top_speed :     IN UNSIGNED(i_bus_with -1 DOWNTO 0);
        iusig_prescaler_start_speed :   IN UNSIGNED(i_bus_with -1 DOWNTO 0);
        iusig_acceleration :            IN UNSIGNED(i_bus_with -1 DOWNTO 0);
        iusig_steps :                   IN UNSIGNED(i_bus_with -1 DOWNTO 0);
        oslv4_motor :                   OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        osl_interrupt :                 OUT STD_LOGIC;
        osl_reset_start_bit :           OUT STD_LOGIC;
        ousig_nof_steps :               OUT UNSIGNED (i_bus_with -1 DOWNTO 0);
        ot_state :                      OUT t_states
    );
END ENTITY prescale_register_ctrl;

---------------------------------------------------------------------------------------------
-- ARCHITECTURE
---------------------------------------------------------------------------------------------
ARCHITECTURE rtl of prescale_register_ctrl is

    -- submodul clock generation
    SIGNAL sl_submodul_clock : STD_LOGIC := '0';
    SIGNAL usig_clock_cycle_counter : UNSIGNED(i_bus_with-1 DOWNTO 0) := (OTHERS => '0');
    CONSTANT slv_clock_frequency_divider : UNSIGNED(i_bus_with-1 DOWNTO 0) := TO_UNSIGNED(i_clock_frequency_divider, i_bus_with);
    CONSTANT usig_clock_ratio : UNSIGNED(i_bus_with-1 DOWNTO 0) := slv_clock_frequency_divider/2;
    
    SIGNAL t_fsm_state : t_states;
    SIGNAL t_old_fsm_state : t_states;

    -- input registers
    TYPE t_registers IS RECORD
        slv8_config : STD_LOGIC_VECTOR (7 DOWNTO 0);
        usig_prescaler_top_speed : UNSIGNED(i_bus_with - 1 DOWNTO 0);
        usig_prescaler_start_speed : UNSIGNED(i_bus_with -1 DOWNTO 0);
        usig_acceleration : UNSIGNED(i_bus_with -1 DOWNTO 0);
        usig_steps : UNSIGNED(i_bus_with -1 DOWNTO 0);
        sl_rst : STD_LOGIC;
        sl_last_submodul_clk : STD_LOGIC;
    END RECORD;
    CONSTANT C_RESET_REGISTERS : t_registers := (
        slv8_config => (OTHERS => '0'),
        usig_prescaler_top_speed => (OTHERS => '1'),
        usig_prescaler_start_speed => (OTHERS => '1'),
        usig_acceleration => (OTHERS => '1'),
        usig_steps => (OTHERS => '0'),
        sl_rst => '1',
        sl_last_submodul_clk => '0'
    );
    SIGNAL ri, ri_next : t_registers := C_RESET_REGISTERS;
BEGIN

    ----------------------------------------------------------------------
    -- Clock prescaler for speedcontroller
    ----------------------------------------------------------------------
    -- Based on the PWM block of Marco Tinner from the AirBotOne project
    clock_gen : PROCESS (isl_clk)
    BEGIN
    IF rising_edge(isl_clk) THEN
        IF slv_clock_frequency_divider = 1 THEN
            sl_submodul_clock <= isl_clk;
            usig_clock_cycle_counter <= (OTHERS => '0');
        ELSIF usig_clock_cycle_counter >= slv_clock_frequency_divider THEN
            sl_submodul_clock <= '0';
            usig_clock_cycle_counter <= (OTHERS => '0');
        ELSIF usig_clock_cycle_counter < usig_clock_ratio THEN
            sl_submodul_clock <= '1';
            usig_clock_cycle_counter <= usig_clock_cycle_counter + 1;
        ELSE
            sl_submodul_clock <= '0';
            usig_clock_cycle_counter <= usig_clock_cycle_counter + 1;
        END IF;
    END IF;
    END PROCESS clock_gen;

    ----------------------------------------------------------------------
    -- combinatorial process
    ----------------------------------------------------------------------
    -- define in which states changes are allowed
    -- buffering of signals which only have a pulse length of one cycle in the fast cycle
    comb_proc : PROCESS (ri, isl_rst, isl_clk)
    VARIABLE v : t_registers := C_RESET_REGISTERS;
    BEGIN
       v := ri;
       -- signals for which updating is not always allowed
       CASE t_fsm_state IS
            WHEN STOP =>
                v.slv8_config := islv8_config;
                v.slv8_config(I_RESET_STEPCOUNTER) := ri.slv8_config(I_RESET_STEPCOUNTER); -- special case (this value is processed below)
                v.usig_prescaler_top_speed := iusig_prescaler_top_speed;
                v.usig_prescaler_start_speed := iusig_prescaler_start_speed;
                v.usig_acceleration := iusig_acceleration;
                v.usig_steps := iusig_steps;
            WHEN TOP_SPEED =>
                IF (islv8_config(I_RUN_MODE_0) = '0')AND(islv8_config(I_RUN_MODE_1) = '1') THEN -- Fixed speed
                    v.usig_prescaler_top_speed := iusig_prescaler_top_speed;
                    v.usig_acceleration := iusig_acceleration;
                END IF;
            WHEN OTHERS =>
        END CASE;
        -- signals for which updating is always allowd
         v.slv8_config(I_RUN_MODE_0)        := islv8_config(I_RUN_MODE_0);
         v.slv8_config(I_RUN_MODE_1)        := islv8_config(I_RUN_MODE_1);
         v.slv8_config(I_START)             := islv8_config(I_START);
        
        -- Signal buffering (synchronisation) between both frequencies. (mostly reset's)
        -- hold old value until submodul clock has a rising edge
        IF islv8_config(I_RESET_STEPCOUNTER) = '1' THEN
            v.slv8_config(I_RESET_STEPCOUNTER) := '1';
        END IF;
        IF isl_rst = '1' THEN
            v.sl_rst := '1';
        END IF;
        -- reset values by a rising edge of submodul clock
        IF ((sl_submodul_clock = '1') AND (ri.sl_last_submodul_clk = '0')) THEN
            v.slv8_config(I_RESET_STEPCOUNTER) := islv8_config(I_RESET_STEPCOUNTER);
            v.sl_rst := isl_rst;
        END IF;
        v.sl_last_submodul_clk := sl_submodul_clock;
        
        IF isl_rst = '1' THEN
            v := C_RESET_REGISTERS;
        END IF;
        
        ri_next <= v;
    END PROCESS comb_proc;
    
    ----------------------------------------------------------------------
    -- registered process 1: register controll
    ----------------------------------------------------------------------
    reg_input_proc : PROCESS (isl_clk)
    BEGIN
        IF rising_edge(isl_clk) THEN
            ri <= ri_next;
        END IF;
    END PROCESS reg_input_proc;
    
    ----------------------------------------------------------------------
    -- registerd process 2: Interuppt trigger 
    ----------------------------------------------------------------------
    interrupt_controll : PROCESS (isl_clk)
    BEGIN
        IF rising_edge(isl_clk) THEN
            IF t_old_fsm_state = ACCELERATE_DOWN AND t_fsm_state = STOP THEN
                osl_interrupt <= '1';
            ELSE
                osl_interrupt <= '0';
            END IF;
            t_old_fsm_state  <= t_fsm_state;
        END IF;
    END PROCESS interrupt_controll;
    
    ----------------------------------------------------------------------
    -- create component
    ----------------------------------------------------------------------
    gen_speedcontroll : speedcontroll
        GENERIC MAP(
            i_base_clk => i_base_clk,
            i_bus_with => i_bus_with
        )
        PORT MAP( 
            isl_clk => sl_submodul_clock,
            isl_rst => ri.sl_rst,
            islv8_config => ri.slv8_config,
            iusig_prescaler_top_speed => ri.usig_prescaler_top_speed,
            iusig_prescaler_start_speed => ri.usig_prescaler_start_speed,
            iusig_acceleration => ri.usig_acceleration,
            iusig_steps => ri.usig_steps,
            oslv4_motor => oslv4_motor,
            osl_reset_start_bit => osl_reset_start_bit,
            ousig_nof_steps => ousig_nof_steps,
            ot_state => t_fsm_state
        );
    
    ----------------------------------------------------------------------
    -- output assignment 
    ----------------------------------------------------------------------
    ot_state <= t_fsm_state; -- only for testing
END rtl;