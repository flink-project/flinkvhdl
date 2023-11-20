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
--  Title             : multiplexer.m.vhd
--  Project           : FLINK
--  Description       : Single multiplexer. (The selector must be checked in an upper module).
---------------------------------------------------------------------------------------------
--  Copyright(C) 2020 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  14.10.2023 GOOP :	Initial version
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- PACKAGE DEFINITION
---------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE multiplexer_pkg IS
    COMPONENT multiplexer IS
        GENERIC (
            i_bus_with : INTEGER := 32;
            i_nof_inputs : INTEGER := 8
        );
        PORT ( 
            islv_selector   : IN STD_LOGIC_VECTOR(i_bus_with-1 DOWNTO 0);
            islv_inputs     : IN STD_LOGIC_VECTOR(i_nof_inputs-1 DOWNTO 0);
            osl_out         : OUT STD_LOGIC
        );
    END COMPONENT multiplexer;
END PACKAGE multiplexer_pkg;

---------------------------------------------------------------------------------------------
-- ENTITIY
---------------------------------------------------------------------------------------------
LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY multiplexer IS
    GENERIC (
        i_bus_with : INTEGER := 32;
        i_nof_inputs : INTEGER := 8
    );
    PORT ( 
        islv_selector   : IN STD_LOGIC_VECTOR(i_bus_with-1 DOWNTO 0);
        islv_inputs     : IN STD_LOGIC_VECTOR(i_nof_inputs-1 DOWNTO 0);
        osl_out         : OUT STD_LOGIC
    );
END ENTITY multiplexer;

---------------------------------------------------------------------------------------------
-- ARCHITECTURE
---------------------------------------------------------------------------------------------
ARCHITECTURE rtl of multiplexer is
BEGIN
    osl_out <= islv_inputs(TO_INTEGER(UNSIGNED(islv_selector)));
END rtl;

