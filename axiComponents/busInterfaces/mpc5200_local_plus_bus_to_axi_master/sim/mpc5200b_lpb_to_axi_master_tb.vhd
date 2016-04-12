-------------------------------------------------------------------------------
--     ____  _____          __    __    ________    _______
--    |    | \    \        |   \ |  |  |__    __|  |   __  \
--    |____|  \____\       |    \|  |     |  |     |  |__>  ) 
--     ____   ____         |  |\ \  |     |  |     |   __  <
--    |    | |    |        |  | \   |     |  |     |  |__>  )
--    |____| |____|        |__|  \__|     |__|     |_______/
--
--    NTB University of Applied Sciences in Technology
--
--    Campus Buchs - Werdenbergstrasse 4 - 9471 Buchs - Switzerland
--    Campus Waldau - Schoenauweg 4 - 9013 St. Gallen - Switzerland
--
--    Web http://www.ntb.ch        Tel. +41 81 755 33 11
--
-------------------------------------------------------------------------------
-- Copyright 2013 NTB University of Applied Sciences in Technology
-------------------------------------------------------------------------------
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance witdh the License.
-- You may obtain a copy of the License at
-- 
-- http://www.apache.org/licenses/LICENSE-2.0
--   
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- witdhOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

USE work.fLink_definitions.ALL;
USE work.mpc5200b_to_axi_master_pkg.ALL;

ENTITY mpc5200b_lpb_to_axi_master_tb IS
END ENTITY mpc5200b_lpb_to_axi_master_tb;

ARCHITECTURE sim OF mpc5200b_lpb_to_axi_master_tb IS
	
	CONSTANT main_period : TIME := 8 ns; -- 125MHz
	CONSTANT c_lpb_cs_width : INTEGER := 1;
	
	SIGNAL axi_aclk 		: STD_LOGIC := '0';
	SIGNAL axi_areset_n 	: STD_LOGIC := '0';
	SIGNAL axi_awid 		: STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0) := (OTHERS =>'0'); 
	SIGNAL axi_awaddr 		: STD_LOGIC_VECTOR(c_address_width-1 downto 0) := (OTHERS =>'0');
	SIGNAL axi_awlen 		: STD_LOGIC_VECTOR(7 downto 0) := (OTHERS =>'0');
	SIGNAL axi_awsize 		: STD_LOGIC_VECTOR(2 downto 0) := (OTHERS =>'0');
	SIGNAL axi_awburst 		: STD_LOGIC_VECTOR(1 downto 0) := (OTHERS =>'0');
	SIGNAL axi_awvalid   	: STD_LOGIC := '0';
	SIGNAL axi_wdata 		: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0) := (OTHERS =>'0');
	SIGNAL axi_awready 		: STD_LOGIC  := '0';
	SIGNAL axi_wstrb 		: STD_LOGIC_VECTOR(3 downto 0) := (OTHERS =>'0');
	SIGNAL axi_wvalid 		: STD_LOGIC  := '0';
	SIGNAL axi_wready 		: STD_LOGIC  := '0';
	SIGNAL axi_araddr 		: STD_LOGIC_VECTOR(c_address_width-1 downto 0) := (OTHERS =>'0');
	SIGNAL axi_arvalid 		: STD_LOGIC  := '0';
	SIGNAL axi_arready		: STD_LOGIC := '0';
	SIGNAL axi_arid 		: STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0) := (OTHERS =>'0');
	SIGNAL axi_arlen 		: STD_LOGIC_VECTOR(7 downto 0) := (OTHERS =>'0');
	SIGNAL axi_arsize 		: STD_LOGIC_VECTOR(2 downto 0) := (OTHERS =>'0');
	SIGNAL axi_arburst 		: STD_LOGIC_VECTOR(1 downto 0) := (OTHERS =>'0');
	SIGNAL axi_rdata 		: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0):= (OTHERS =>'0');
	SIGNAL axi_rresp 		: STD_LOGIC_VECTOR(1 downto 0):= (OTHERS =>'0');
	SIGNAL axi_rvalid 		: STD_LOGIC:= '0';
	SIGNAL axi_rready 		: STD_LOGIC := '0';
	SIGNAL axi_rid 			: STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0):= (OTHERS =>'0');
	SIGNAL axi_rlast 		: STD_LOGIC:= '0';
	SIGNAL axi_bresp 		: STD_LOGIC_VECTOR(1 downto 0):= (OTHERS =>'0');
	SIGNAL axi_bvalid 		: STD_LOGIC:= '0';
	SIGNAL axi_bready 		: STD_LOGIC := '0';
	SIGNAL axi_bid 			: STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0):= (OTHERS =>'0');
	
	SIGNAL lpb_ad			: STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0):= (OTHERS =>'Z');
	SIGNAL lpb_cs_n			: STD_LOGIC_VECTOR(c_lpb_cs_width-1 downto 0):= (OTHERS =>'1');
	SIGNAL lpb_oe_n			: STD_LOGIC := '1';
	SIGNAL lpb_ack_n		: STD_LOGIC := '0';
	SIGNAL lpb_ale_n		: STD_LOGIC := '1';
	SIGNAL lpb_rdwr_n		: STD_LOGIC := '1';
	SIGNAL lpb_ts_n			: STD_LOGIC := '1';
	
	SIGNAL read_data : STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0) := (OTHERS =>'1');
	
BEGIN

	--create component
	my_unit_under_test : lpb_mpc5200b_to_axi_master 
	GENERIC MAP(
		LPBADDRWIDTH 	=> c_fLink_avs_data_width,
		LPBDATAWIDTH	=> c_fLink_avs_data_width,
		LPBCSWIDTH		=> c_lpb_cs_width,
		LPBTSIZEWIDTH 	=> 3,
		LPBBANKWIDTH	=> 2
	)
	PORT MAP(
			clk => axi_aclk,
			reset_n => axi_areset_n,

			-- Write Address Channel
			axi_awid => axi_awid,
			axi_awaddr => axi_awaddr,
			axi_awlen => axi_awlen,
			axi_awsize => axi_awsize,
			axi_awburst => axi_awburst,
			axi_awvalid  => axi_awvalid,
			axi_awready  => axi_awready,

			-- Write Data Channel
			axi_wdata  => axi_wdata,
			axi_wstrb  => axi_wstrb,
			axi_wvalid => axi_wvalid,
			axi_wready => axi_wready,
			-- Read Address Channel
			axi_araddr => axi_araddr,
			axi_arvalid  =>  axi_arvalid,
			axi_arready => axi_arready,
			axi_arid => axi_arid,
			axi_arlen => axi_arlen,
			axi_arsize => axi_arsize,
			axi_arburst => axi_arburst,
			-- Read Data Channel
			axi_rdata => axi_rdata,
			axi_rresp => axi_rresp,
			axi_rvalid => axi_rvalid,
			axi_rready => axi_rready,
			axi_rid => axi_rid,
			axi_rlast => axi_rlast,
			-- Write Response Channel
			axi_bresp => axi_bresp,
			axi_bvalid => axi_bvalid,
			axi_bready => axi_bready,
			axi_bid => axi_bid,
			
			-- LocalPlus signals
			lpb_ad => lpb_ad,
			lpb_cs_n => lpb_cs_n,
			lpb_oe_n => lpb_oe_n,
			lpb_ack_n => lpb_ack_n,
			lpb_ale_n => lpb_ale_n,
			lpb_rdwr_n => lpb_rdwr_n,
			lpb_ts_n => lpb_ts_n
	);
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	axi_aclk 		<= NOT axi_aclk after main_period/2;
	
	tb_main_proc : PROCESS
	
	
	PROCEDURE  lpb_read(address : IN INTEGER) IS
		BEGIN
				lpb_ale_n <= '1';
				
			WAIT FOR 2*main_period;
				lpb_ad <= STD_LOGIC_VECTOR(to_unsigned(address,c_fLink_avs_data_width));
			WAIT FOR main_period;	
				lpb_ale_n <= '0';
			WAIT FOR main_period;
				lpb_ale_n <= '1';
			WAIT FOR main_period;
				lpb_cs_n(0) <= '0';
				lpb_oe_n <= '0';
				lpb_ts_n <= '0'; 	
			WAIT FOR main_period;	
				lpb_ts_n <= '1'; 
				lpb_ad <= (OTHERS =>'Z');
				WHILE (lpb_ack_n /= '0') LOOP
					WAIT FOR 1*main_period;
				END LOOP;
				read_data <= lpb_ad;
				lpb_cs_n(0) <= '1';
				lpb_oe_n <= '1';
	END PROCEDURE lpb_read;
	
	BEGIN
			axi_areset_n	<=	'0';	
		WAIT FOR 100*main_period;
			axi_areset_n	<=	'1';
		WAIT FOR 100*main_period;
		WAIT FOR main_period/2;
			lpb_read(10);
		WAIT FOR 100*main_period;
			lpb_read(10);	
		WAIT FOR 100*main_period;
			ASSERT false REPORT "End of simulation" SEVERITY FAILURE;
	END PROCESS tb_main_proc;
	
	
	
	axi_bus_read_address_sim : PROCESS
	BEGIN
		IF(axi_arvalid = '1') THEN
			axi_arready <= '1';
		ELSE
			axi_arready <= '0';
		END IF;
		
		
		WAIT FOR 1*main_period;
		IF(axi_arready = '1') THEN
			axi_rvalid <= '1';
			axi_rdata <= STD_LOGIC_VECTOR(to_unsigned(456234,c_fLink_avs_data_width));
		ELSE
			axi_rvalid <= '0';
			axi_rdata <= STD_LOGIC_VECTOR(to_unsigned(0,c_fLink_avs_data_width));
		END IF;	
		
		
		
		
		
		
	
	END PROCESS axi_bus_read_address_sim;
	

END ARCHITECTURE sim;


