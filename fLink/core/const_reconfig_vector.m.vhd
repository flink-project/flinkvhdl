--------------------------------------------------------------------------------------
--   _     _   _____   _     _____   _____   _____   _____   _       _____   _          __ 
--  | |   / / /  _  \ | |   |_   _| | ____| |  _  \ |  ___| | |     /  _  \ | |        / / 
--  | |  / /  | | | | | |     | |   | |__   | | | | | |__   | |     | | | | | |  __   / /  
--  | | / /   | | | | | |     | |   |  __|  | | | | |  __|  | |     | | | | | | /  | / /   
--  | |/ /    | |_| | | |__   | |   | |___  | |_| | | |     | |___  | |_| | | |/   |/ /    
--  |___/     \_____/ |_____| |_|   |_____| |_____/ |_|     |_____| \_____/ |___/|___/    
--
-------------------------------------------------------------------------------------
--  OCI O'Connor Informatics
--  Allwegmatte 10
--  CH 6372 Ennetmoos, Switzerland
--
-----------------------------------------------------------------------------------
--  Unit    : const_reconfig_vector.m.vhd
--  Author  : Marco Tinner, NTB Buchs
--  Created : July 2012
-----------------------------------------------------------------------------------
--  Copyright(C) 2012: OCI O'Connor Informatics, Switzerland
-----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY const_reconfig_vector IS
	PORT (
		test_out: OUT std_logic_vector(3 DOWNTO 0)
		);
END ENTITY const_reconfig_vector;

ARCHITECTURE rtl OF const_reconfig_vector IS
BEGIN
	test_out <= x"2";
END ARCHITECTURE rtl;