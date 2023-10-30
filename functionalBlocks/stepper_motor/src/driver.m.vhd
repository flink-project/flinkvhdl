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
--  Title             : driver.m.vhd
--  Project           : FLINK
--  Description       : Driver for stepper motor
---------------------------------------------------------------------------------------------
--  Copyright(C) 2023 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  25.08.2023 GOOP :    Initial version
---------------------------------------------------------------------------------------------

-- Info Bipolar:
-- For the driver, it makes no difference whether it is switched 
-- bi- or uni-polar. When A and A' are at 0, the coil is deactivated. 
-- Otherwise it is positive or negative "magentized".
--
-- _____________________________________________________________________
--      ||||                   Full Step Mode                       ||||
-- -----||||--------------------------------------------------------||||
--      ||||     One Phase Mode       ||||        Two Phase Mode    ||||
-- -----||||--------------------------||||--------------------------||||
--      ||||     Unipolar    ||Bipolar||||     Unipolar    ||Bipolar||||
-- -----||||--------------------------||||--------------------------||||
-- Step |||| A | A' | B | B' || A | B |||| A | A' | B | B' || A | B ||||
-- -----||||---|----|---|----||---|---||||---|----|---|----||---|---||||
--   0  |||| 1 | 0  | 0 | 0  || + | 0 |||| 1 | 0  | 0 | 1  || + | - ||||
--   1  |||| 0 | 0  | 1 | 0  || 0 | + |||| 1 | 0  | 1 | 0  || + | + ||||
--   2  |||| 0 | 1  | 0 | 0  || - | 0 |||| 0 | 1  | 1 | 0  || - | + ||||
--   3  |||| 0 | 0  | 0 | 1  || 0 | - |||| 0 | 1  | 0 | 1  || - | - ||||
-- ---------------------------------------------------------------------
-- 
-- _______________________________________
--      ||||     Half Step Mode       ||||
-- -----||||--------------------------||||
--      ||||     Unipolar    ||Bipolar||||
-- -----||||--------------------------||||
-- Step |||| A | A' | B | B' || A | B ||||
-- -----||||---|----|---|----||---|---||||
--   0  |||| 1 | 0  | 0 | 1  || + | - |||| <-- Two Phase Mode Step 0
--   1  |||| 1 | 0  | 0 | 0  || + | 0 |||| <-- One Phase Mode Step 0
--   2  |||| 1 | 0  | 1 | 0  || + | + |||| <-- Two Phase Mode Step 1
--   3  |||| 0 | 0  | 1 | 0  || 0 | + |||| <-- One Phase Mode Step 1
--   4  |||| 0 | 1  | 1 | 0  || - | + |||| <-- Two Phase Mode Step 2
--   5  |||| 0 | 1  | 0 | 0  || - | 0 |||| <-- One Phase Mode Step 2
--   6  |||| 0 | 1  | 0 | 1  || - | - |||| <-- Two Phase Mode Step 3
--   7  |||| 0 | 0  | 0 | 1  || 0 | - |||| <-- One Phase Mode Step 3
-- ---------------------------------------

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE driver_pgk IS
    COMPONENT driver IS 
        PORT (
            -- trigger
            -- speedcontroll => every rising edge is a step or half step
            isl_trigger : IN STD_LOGIC; 
            -- reset motor
            isl_rst : IN STD_LOGIC;
            -- direction: 1 = forward, 0 = backwards
            isl_forward : IN STD_LOGIC;
            -- Full step: 1 = full step, 0 = half step
            isl_fullstep : IN STD_LOGIC;
            -- two phase (only for full step)
            -- 1 = two phase, 0 = one phase
            isl_two_phase : IN STD_LOGIC;
            -- to motor:
            -- order: MSB -> LSB => A,A',B,B'
            oslv4_motor : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) 
        ); 
    END COMPONENT driver; 
END PACKAGE driver_pgk;

---------------------------------------------------------------------------------------------
-- ENTITIY
---------------------------------------------------------------------------------------------
LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY driver IS
    PORT ( 
            isl_trigger : IN STD_LOGIC; 
            isl_rst : IN STD_LOGIC;
            isl_forward : IN STD_LOGIC;
            isl_fullstep : IN STD_LOGIC;
            isl_two_phase : IN STD_LOGIC;
            oslv4_motor : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY driver;

---------------------------------------------------------------------------------------------
-- ARCHITECTURE
---------------------------------------------------------------------------------------------
ARCHITECTURE rtl of driver is
    
    TYPE t_registes IS RECORD
        usig3_step : UNSIGNED (2 DOWNTO 0);
    END RECORD t_registes;
    CONSTANT C_RESET_REGS : t_registes := (
        usig3_step => (OTHERS => '0')
    );

    SIGNAL r, r_next : t_registes := C_RESET_REGS;
    
BEGIN

    --------------------------------------------
    -- combinatorial process
    --------------------------------------------
    state_controll : PROCESS (isl_trigger)
        VARIABLE v : t_registes;
    BEGIN
        v := r;
        -- state controll
        IF isl_fullstep = '0' THEN -- HALF STEP
            IF isl_forward = '1' THEN
                v.usig3_step := r.usig3_step + 1;
            ELSE 
                v.usig3_step := r.usig3_step - 1;
            END IF;
        ELSIF isl_fullstep = '1' AND isl_two_phase = '1' THEN -- FULL STEP AND TWO PHASE
            IF isl_forward = '1' THEN
                IF r.usig3_step(0) = '1' THEN -- if step is odd bring it to a even number
                    v.usig3_step := r.usig3_step + 1;
                ELSE
                    v.usig3_step := r.usig3_step + 2;
                END IF;
            ELSE
                IF r.usig3_step(0) = '1' THEN -- if step is odd bring it to a even number
                    v.usig3_step := r.usig3_step - 1;
                ELSE
                    v.usig3_step := r.usig3_step - 2;
                END IF;
            END IF;
        ELSIF isl_fullstep = '1' AND isl_two_phase = '0' THEN -- FULL STEP AND ONE PHASE
            IF isl_forward = '1' THEN
                IF r.usig3_step(0) = '0' THEN -- if step is even bring it to a odd number
                    v.usig3_step := r.usig3_step + 1;
                ELSE
                    v.usig3_step := r.usig3_step + 2;
                END IF;
            ELSE
                IF r.usig3_step(0) = '0' THEN -- if step is even bring it to a odd number
                    v.usig3_step := r.usig3_step - 1;
                ELSE
                    v.usig3_step := r.usig3_step - 2;
                END IF;
            END IF;
        END IF;

        -- reset
        IF isl_rst = '1' THEN
            v := C_RESET_REGS;
        END IF;
        
        r_next <= v;
    END PROCESS state_controll;
    
    -----------------------------------------
    --registered process
    -----------------------------------------
    reg_process: PROCESS (isl_trigger)
    BEGIN
        IF rising_edge(isl_trigger) THEN
           r <= r_next;
        END IF;
    END PROCESS reg_process;
        
    -----------------------------------------
    -- output assignment 
    -----------------------------------------
    set_output : PROCESS (r.usig3_step)
    BEGIN
        CASE r.usig3_step IS
            WHEN "000"  => oslv4_motor <= "1001";
            WHEN "001"  => oslv4_motor <= "1000";
            WHEN "010"  => oslv4_motor <= "1010";
            WHEN "011"  => oslv4_motor <= "0010";
            WHEN "100"  => oslv4_motor <= "0110";
            WHEN "101"  => oslv4_motor <= "0100";
            WHEN "110"  => oslv4_motor <= "0101";
            WHEN "111"  => oslv4_motor <= "0001";
            WHEN OTHERS => oslv4_motor <= "0000";
        END CASE;
    END PROCESS set_output;
END rtl;
