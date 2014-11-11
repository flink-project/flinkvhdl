LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--############################################################################
--
-- Änderung : Tristate Buffer Generation auf dieser Ebene, nicht im Top Design
--
--############################################################################

ENTITY lpb_mpc5200b_to_avalon IS
	
	GENERIC
	(
	LPBADDRWIDTH 	: INTEGER := 32;
	LPBDATAWIDTH	: INTEGER := 32;
	LPBTSIZEWIDTH	: INTEGER := 3;
	LPBCSWIDTH		: INTEGER := 2;
	LPBBANKWIDTH	: INTEGER := 2
	);
	PORT
	(
  			-- Avalon Fundametal Signals
			clk			:   IN  STD_LOGIC;
			reset_n		: 	IN  STD_LOGIC;
			waitrequest :  	IN  STD_LOGIC;
			
			-- Avalon Address/Data Interface
			address		:  	OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			
			read		:  	OUT STD_LOGIC;
			readdata	:  	IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			
			write 		:  	OUT STD_LOGIC;
			writedata	:  	OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			
			-- Avalon SIGNAL (OTHERS)
			byteenable	:  	OUT STD_LOGIC_VECTOR (3 DOWNTO 0);			
			
			-- MPC5200 address/data interface
			lpb_ad		: 	INOUT	STD_LOGIC_VECTOR ((LPBDATAWIDTH-1) DOWNTO 0);

    		-- LocalPlus Bus Chip Selects AND other signals
			lpb_cs_n	: 	IN	STD_LOGIC_VECTOR ((LPBCSWIDTH-1) DOWNTO 0);
			lpb_oe_n	: 	IN	STD_LOGIC;
			lpb_ack_n	: 	OUT	STD_LOGIC;
			lpb_ale_n	: 	IN	STD_LOGIC;
			lpb_rdwr_n	: 	IN	STD_LOGIC;
			lpb_ts_n	: 	IN	STD_LOGIC;
						
			-- Interrupt SIGNAL to MPC			
			lpb_int		: 	OUT STD_LOGIC
			);
END lpb_mpc5200b_to_avalon;

---------------------------------------------------------

-- reset SIGNAL einbauen

---------------------------------------------------------

ARCHITECTURE avalon_master OF lpb_mpc5200b_to_avalon IS

SIGNAL lpb_adr_q 			: STD_LOGIC_VECTOR((LPBADDRWIDTH-1) DOWNTO 0);
SIGNAL lpb_data_q			: STD_LOGIC_VECTOR((LPBDATAWIDTH-1) DOWNTO 0);
SIGNAL lpb_tsize_q 			: STD_LOGIC_VECTOR ((LPBTSIZEWIDTH-1) DOWNTO 0);

SIGNAL lpb_data_en			: STD_LOGIC;
SIGNAL lpb_start			: STD_LOGIC;

SIGNAL lpb_rd				: STD_LOGIC;
SIGNAL lpb_wr				: STD_LOGIC;
SIGNAL lpb_ack_i			: STD_LOGIC;

SIGNAL lpb_start_en			: STD_LOGIC;

SIGNAL lpb_ad_o				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL lpb_ad_en			: STD_LOGIC;

type state IS (init, act, rst);
SIGNAL avalonstate 			: state;

BEGIN
--activation of FPGA with only one chip select SIGNAL
lpb_rd <= (NOT lpb_cs_n(0) AND NOT lpb_oe_n);
lpb_wr <= (NOT lpb_cs_n(0) AND NOT lpb_rdwr_n);

-- no interrupt function implemented
lpb_int <= '0';

-- external ack SIGNAL gets internal value
lpb_ack_n <= NOT lpb_ack_i;


-- ############################# MPC interface functions ##############################
-- tristate buffer generation

lpb_data_switching : PROCESS(lpb_ad_o, lpb_ad_en, reset_n)
	BEGIN
		IF reset_n = '0' THEN
			lpb_ad <= (OTHERS => 'Z');
		ELSIF lpb_ad_en = '1' THEN
				lpb_ad <= lpb_ad_o;
		ELSE
				lpb_ad <= (OTHERS => 'Z');
		END IF;
	END PROCESS;


-- mpc_address_latching : necessary because of multiplexed bus system
-- latching of addresses at falling edge of clk

lpb_address_latching : PROCESS (clk, reset_n)

	BEGIN
		IF reset_n = '0' THEN
			lpb_adr_q <= (OTHERS => '0');
			lpb_tsize_q <= (OTHERS => '0');
		ELSIF rising_edge(clk) THEN									
			IF lpb_ale_n = '0' THEN
				lpb_adr_q <= lpb_ad((LPBADDRWIDTH-1) DOWNTO 0);
				lpb_tsize_q   <= lpb_ad((LPBDATAWIDTH-2) DOWNTO (LPBDATAWIDTH-4));
			END IF;	
		END IF;	
		
	END PROCESS lpb_address_latching;

-- lpb_write_data_latching
-- latching of data of the lpb bus at write cycle

lpb_write_data_latching : PROCESS (clk, reset_n)			

	BEGIN
		IF reset_n = '0' THEN
			lpb_data_q <= (OTHERS => '0');
			lpb_data_en <= '0';
			lpb_start <= '0';
		ELSE
			IF rising_edge (clk) THEN
				IF lpb_ts_n = '0' AND lpb_start = '0' THEN
					--lpb_start <= '1';		-- for 66MHz we can start here
					lpb_start_en <= '1';
				ELSE
					--lpb_start <= '0';
					lpb_start_en <= '0';
				END IF;
				
				-- needable for 33MHz support, for 66MHz we can start erlier
				IF lpb_start_en = '1' THEN
					lpb_start <= '1';
				ELSE	
					lpb_start <= '0';
				END IF;
					
				IF lpb_ts_n = '0' AND lpb_rdwr_n = '0' THEN
					lpb_data_en <= '1';				-- wait 1 clock cycle for data ready
				END IF;
			
				IF lpb_data_en = '1' THEN
					lpb_data_q <= lpb_ad;
					lpb_data_en <= '0';				
				END IF;
			END IF;
		END IF;
END PROCESS lpb_write_data_latching;

-- lpb_read_data_switching
-- reading of data of avalon register AND applying at the LPB bus

lpb_read_data_switching : PROCESS (clk, reset_n)

	BEGIN
		IF reset_n = '0' THEN
			lpb_ad_o <= (OTHERS => '0');
			lpb_ad_en <= '0';
		ELSIF rising_edge(clk) THEN
			IF lpb_rd = '1' AND lpb_ack_i = '0' THEN
				CASE lpb_tsize_q IS
					WHEN "001" => lpb_ad_o <= (readdata(7 DOWNTO 0) & readdata(15 DOWNTO 8) & readdata(23 DOWNTO 16) & readdata(31 DOWNTO 24));				
					
					WHEN "010" => lpb_ad_o <= (readdata(15 DOWNTO 0) & readdata(31 DOWNTO 16));
					
					WHEN OTHERS =>	lpb_ad_o  <= readdata;						
				END CASE;
				lpb_ad_en <= '1';								
			ELSE 
				lpb_ad_en <= '0';
			END IF;
		END IF;
	
END PROCESS lpb_read_data_switching;

-- mpc_ack_generation : necessary to shorten the controller cycle of the mpc
-- genaration of ack SIGNAL at falling edge of local plus bus clock

lpb_ack_generation : PROCESS (clk, reset_n)

	BEGIN
		IF reset_n = '0' THEN
			lpb_ack_i <= '0';
		ELSIF rising_edge(clk) THEN
		
			IF avalonstate = act THEN
				lpb_ack_i <= (NOT waitrequest AND NOT lpb_ack_i);							
			ELSE
				lpb_ack_i <= '0';
			END IF;
		END IF;
		
END PROCESS lpb_ack_generation;
	
-- ############################ wishbone read/write state machine ######################

-- state machine for reading/writing avalon bus

lpb_to_avalon : PROCESS (reset_n, clk)

	BEGIN
		IF reset_n = '0' THEN								
				avalonstate <= init;
		ELSIF rising_edge(clk)THEN 	
			CASE avalonstate IS
				WHEN init =>	IF lpb_start = '1' THEN				-- start avalon master statemachine
									avalonstate <= act;
					     		END IF;
				WHEN act =>   	IF waitrequest = '0' THEN			-- wait for no waitrequest 
									avalonstate <= rst;
								END IF;
				WHEN rst =>		avalonstate <= init;
								
				WHEN OTHERS => 	avalonstate <= init;   
			END CASE;				
		END IF;					
END PROCESS lpb_to_avalon;

avalon_bus : PROCESS (reset_n, clk)

	BEGIN
		IF reset_n = '0' THEN
		
		ELSIF rising_edge(clk) THEN	
			IF avalonstate = init AND lpb_start = '1' THEN
				address <= lpb_adr_q;		
				write <= lpb_wr;								-- avalon SIGNAL generation we				
				read <= lpb_rd;

				CASE lpb_tsize_q IS								-- swap bytes for little endian access
					WHEN "100" => byteenable <= "1111";
								  writedata <= lpb_data_q;
					WHEN "010" => CASE lpb_adr_q(1 DOWNTO 0) IS
										WHEN "00" => byteenable <= "0011";
													 writedata(15 DOWNTO 0) <= lpb_data_q(31 DOWNTO 16); 
										WHEN "10" => byteenable <= "1100";
													 writedata <= lpb_data_q;
										WHEN OTHERS => byteenable <= "1111";
													 writedata <= lpb_data_q;
								  END CASE;
					WHEN "001" => CASE lpb_adr_q(1 DOWNTO 0) IS
										WHEN "00" => byteenable <= "0001";
													 writedata(7 DOWNTO 0) <= lpb_data_q(31 DOWNTO 24);
										WHEN "01" => byteenable <= "0010";
													 writedata(15 DOWNTO 8) <= lpb_data_q(31 DOWNTO 24);
										WHEN "10" => byteenable <= "0100";								
													 writedata(23 DOWNTO 16) <= lpb_data_q(31 DOWNTO 24);																										
										WHEN "11" => byteenable <= "1000";					
													 writedata <= lpb_data_q;
								  END CASE;
					WHEN OTHERS =>byteenable <= "1111";
								  writedata <= lpb_data_q;
				END CASE;						
			END IF;
			
			IF avalonstate = act THEN
				--readdata_q <= readdata;
				IF waitrequest = '0' THEN
					read 		<= '0';
					write 		<= '0';
					address   	<= (OTHERS => '0');
					writedata 	<= (OTHERS => '0');
				END IF;		
			END IF;
		END IF;

END PROCESS avalon_bus;

END avalon_master;