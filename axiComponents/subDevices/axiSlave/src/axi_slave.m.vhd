-------------------------------------------------------------------------------
--  _________     _____      _____    ____  _____    ___  ____               --
-- |_   ___  |  |_   _|     |_   _|  |_   \|_   _|  |_  ||_  _|              --
--   | |_  \_|    | |         | |      |   \ | |      | |_/ /                --
--   |  _|        | |   _     | |      | |\ \| |      |  __'.                --
--  _| |_        _| |__/ |   _| |_    _| |_\   |_    _| |  \ \_              --
-- |_____|      |________|  |_____|  |_____|\____|  |____||____|             --
--                                                                           --
-------------------------------------------------------------------------------
--                                                                           --
-- Avalon MM interface for PWM                                               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright 2014 NTB University of Applied Sciences in Technology           --
--                                                                           --
-- Licensed under the Apache License, Version 2.0 (the "License");           --
-- you may not use this file except in compliance with the License.          --
-- You may obtain a copy of the License at                                   --
--                                                                           --
-- http://www.apache.org/licenses/LICENSE-2.0                                --
--                                                                           --
-- Unless required by applicable law or agreed to in writing, software       --
-- distributed under the License is distributed on an "AS IS" BASIS,         --
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  --
-- See the License for the specific language governing permissions and       --
-- limitations under the License.                                            --
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

USE work.fLink_definitions.ALL;

PACKAGE axi_slave_pkg IS
	CONSTANT c_axi_id_width	: INTEGER := 1;
	CONSTANT c_burst_type_fixed	: STD_LOGIC_VECTOR := "00";
	CONSTANT c_burst_type_incr	: STD_LOGIC_VECTOR := "01";
	CONSTANT c_burst_type_wrap	: STD_LOGIC_VECTOR := "10";
	
	
	COMPONENT axi_slave IS
			GENERIC (
				axi_device_address_width	: INTEGER := 8;
				id : INTEGER := 0;
				subtype_id : INTEGER := 0; 
				interface_version : INTEGER := 0;
				number_of_channels : INTEGER := 0;
				unique_id : STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0) := (OTHERS=>'0')
			);
			
			PORT (
				-- Clock and Reset
				axi_aclk 			: IN STD_LOGIC;
				axi_areset_n 		: IN STD_LOGIC;
				-- Write Address Channel
				axi_awid 			: IN STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Write Address ID
				axi_awaddr 			: IN STD_LOGIC_VECTOR(axi_device_address_width-1 downto 0); -- Write address
				axi_awlen 			: IN STD_LOGIC_VECTOR(7 downto 0); -- Burst length. The burst length gives the exact number of transfers in a burst
				axi_awsize 			: IN STD_LOGIC_VECTOR(2 downto 0); -- Burst size. This signal indicates the size of each transfer in the burst
				axi_awburst 		: IN STD_LOGIC_VECTOR(1 downto 0); -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
				axi_awvalid 		: IN STD_LOGIC; -- Write address valid. This signal indicates that the channel is signaling valid write address and control information.
				axi_awready 		: OUT STD_LOGIC; -- Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.

				-- Write Data Channel
				axi_wdata 			: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0); -- Write Data
				axi_wstrb 			: IN STD_LOGIC_VECTOR(3 downto 0); -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
				axi_wvalid 			: IN STD_LOGIC; -- Write valid. This signal indicates that valid write data and strobes are available.
				axi_wready 			: OUT STD_LOGIC; -- Write ready. This signal indicates that the slave can accept the write data.
				-- Read Address Channel
				axi_araddr 			: IN STD_LOGIC_VECTOR(axi_device_address_width-1 downto 0); -- Read address. This signal indicates the initial address of a read burst transaction.
				axi_arvalid 		: IN STD_LOGIC; -- Read address valid. This signal indicates that the channel is signaling valid read address and control information.
				axi_arready			: OUT STD_LOGIC; -- Read address ready. This signal indicates that the slave is ready to accept an address and associated  control signals.
				axi_arid 			: IN STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Read address ID. This signal is the identification tag for the read address group of signals.
				axi_arlen 			: IN STD_LOGIC_VECTOR(7 downto 0); -- Burst length. The burst length gives the exact number of transfers in a burst
				axi_arsize 			: IN STD_LOGIC_VECTOR(2 downto 0); -- Burst size. This signal indicates the size of each transfer in the burst
				axi_arburst 		: IN STD_LOGIC_VECTOR(1 downto 0); -- Burst type. The burst type and the size information,  determine how the address for each transfer within the burst is calculated.
				-- Read Data Channel
				axi_rdata 			: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0); -- Read Data
				axi_rresp 			: OUT STD_LOGIC_VECTOR(1 downto 0); -- Read response. This signal indicates the status of the read transfer.
				axi_rvalid 			: OUT STD_LOGIC; -- Read valid. This signal indicates that the channel is signaling the required read data.
				axi_rready 			: IN STD_LOGIC; -- Read ready. This signal indicates that the master can accept the read data and response information
				axi_rid 			: OUT STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
				axi_rlast 			: OUT STD_LOGIC; -- Read last. This signal indicates the last transfer in a read burst.
				-- Write Response Channel
				axi_bresp 			: OUT STD_LOGIC_VECTOR(1 downto 0); -- Write response. This signal indicates the status of the write transaction.
				axi_bvalid 			: OUT STD_LOGIC; -- Write response valid. This signal indicates that the channel is signaling a valid write response.
				axi_bready 			: IN STD_LOGIC;	-- Response ready. This signal indicates that the master can accept a write response.
				axi_bid 			: OUT STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Response ID tag. This signal is the ID tag of the write response.
				--signals used for register access
				oslv_read_address	: OUT UNSIGNED(axi_device_address_width-1 downto 0);
				islv_read_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0);
				osl_write_valid		: OUT STD_LOGIC;
				oslv_write_address	: OUT UNSIGNED(axi_device_address_width-1 downto 0);
				oslv_write_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0)
			);
	END COMPONENT;
	
	
	
	
	
END PACKAGE axi_slave_pkg;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE work.axi_slave_pkg.ALL;
USE work.fLink_definitions.ALL;

ENTITY axi_slave IS
	GENERIC (
				axi_device_address_width	: INTEGER := 8;
				id : INTEGER := 0;
				subtype_id : INTEGER := 0; 
				interface_version : INTEGER := 0;
				number_of_channels : INTEGER := 0;
				unique_id : STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0) := (OTHERS=>'0')
			);
	PORT (
		-- Clock and Reset
		axi_aclk 		: IN STD_LOGIC;
		axi_areset_n 	: IN STD_LOGIC;
		-- Write Address Channel
		axi_awid 		: IN STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Write Address ID
		axi_awaddr 		: IN STD_LOGIC_VECTOR(axi_device_address_width-1 downto 0); -- Write address
		axi_awlen 		: IN STD_LOGIC_VECTOR(7 downto 0); -- Burst length. The burst length gives the exact number of transfers in a burst
		axi_awsize 		: IN STD_LOGIC_VECTOR(2 downto 0); -- Burst size. This signal indicates the size of each transfer in the burst
		axi_awburst 	: IN STD_LOGIC_VECTOR(1 downto 0); -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
		axi_awvalid 	: IN STD_LOGIC; -- Write address valid. This signal indicates that the channel is signaling valid write address and control information.
		axi_awready 	: OUT STD_LOGIC; -- Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.

		-- Write Data Channel
		axi_wdata 		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0); -- Write Data
		axi_wstrb 		: IN STD_LOGIC_VECTOR(3 downto 0); -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
		axi_wvalid 		: IN STD_LOGIC; -- Write valid. This signal indicates that valid write data and strobes are available.
		axi_wready 		: OUT STD_LOGIC; -- Write ready. This signal indicates that the slave can accept the write data.
		-- Read Address Channel
		axi_araddr 		: IN STD_LOGIC_VECTOR(axi_device_address_width-1 downto 0); -- Read address. This signal indicates the initial address of a read burst transaction.
		axi_arvalid 	: IN STD_LOGIC; -- Read address valid. This signal indicates that the channel is signaling valid read address and control information.
		axi_arready		: OUT STD_LOGIC; -- Read address ready. This signal indicates that the slave is ready to accept an address and associated  control signals.
		axi_arid 		: IN STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Read address ID. This signal is the identification tag for the read address group of signals.
		axi_arlen 		: IN STD_LOGIC_VECTOR(7 downto 0); -- Burst length. The burst length gives the exact number of transfers in a burst
		axi_arsize 		: IN STD_LOGIC_VECTOR(2 downto 0); -- Burst size. This signal indicates the size of each transfer in the burst
		axi_arburst 	: IN STD_LOGIC_VECTOR(1 downto 0); -- Burst type. The burst type and the size information,  determine how the address for each transfer within the burst is calculated.
		-- Read Data Channel
		axi_rdata 		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0); -- Read Data
		axi_rresp 		: OUT STD_LOGIC_VECTOR(1 downto 0); -- Read response. This signal indicates the status of the read transfer.
		axi_rvalid 		: OUT STD_LOGIC; -- Read valid. This signal indicates that the channel is signaling the required read data.
		axi_rready 		: IN STD_LOGIC; -- Read ready. This signal indicates that the master can accept the read data and response information
		axi_rid 		: OUT STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
		axi_rlast 		: OUT STD_LOGIC; -- Read last. This signal indicates the last transfer in a read burst.
		-- Write Response Channel
		axi_bresp 		: OUT STD_LOGIC_VECTOR(1 downto 0); -- Write response. This signal indicates the status of the write transaction.
		axi_bvalid 		: OUT STD_LOGIC; -- Write response valid. This signal indicates that the channel is signaling a valid write response.
		axi_bready 		: IN STD_LOGIC;	-- Response ready. This signal indicates that the master can accept a write response.
		axi_bid 		: OUT STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0); -- Response ID tag. This signal is the ID tag of the write response.
		--signals used for register access
		oslv_read_address	: OUT UNSIGNED(axi_device_address_width-1 downto 0);
		islv_read_data		: IN STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0);
		oslv_write_address	: OUT UNSIGNED(axi_device_address_width-1 downto 0);
		osl_write_valid		: OUT STD_LOGIC;
		oslv_write_data		: OUT STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0)
	);

END ENTITY axi_slave;

ARCHITECTURE rtl OF axi_slave IS

	TYPE t_internal_register IS RECORD
		  axi_awready 	: STD_LOGIC;
		  axi_wready 	: STD_LOGIC;
		  axi_arready 	: STD_LOGIC;
		  axi_rresp 	: STD_LOGIC_VECTOR(1 downto 0);
		  axi_rvalid 	: STD_LOGIC;
		  axi_bresp 	: STD_LOGIC_VECTOR(1 downto 0);
		  axi_bvalid 	: STD_LOGIC;
		  axi_bid		: STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0);
		  axi_rid 		: STD_LOGIC_VECTOR(c_axi_id_width-1 downto 0);
		  axi_rlast		: STD_LOGIC;
		  read_address  : UNSIGNED(axi_device_address_width-1 downto 0);
		  read_burst_len_cnt : UNSIGNED(7 downto 0);
		  write_address  : UNSIGNED(axi_device_address_width-1 downto 0);
		  write_burst_len_cnt : UNSIGNED(7 downto 0);
		  write_data : STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0);
		  sl_write_valid : STD_LOGIC;
		  axi_rdata : STD_LOGIC_VECTOR(c_fLink_avs_data_width-1 downto 0);
	END RECORD;

	
	CONSTANT INTERNAL_REG_RESET : t_internal_register := (
							  axi_awready => '0',
                              axi_wready => '0',
                              axi_arready => '0',
                              axi_rresp => (OTHERS=>'0'),
							  axi_rvalid => '0',
							  axi_bresp => (OTHERS=>'0'),
							  axi_bvalid => '0',
							  axi_bid => (OTHERS=>'0'),
							  axi_rid => (OTHERS=>'0'),
							  axi_rlast => '0',
							  read_address => (OTHERS=>'0'),
							  read_burst_len_cnt => (OTHERS=>'0'),
							  write_address => (OTHERS=>'0'),
							  write_burst_len_cnt => (OTHERS=>'0'),
							  write_data => (OTHERS=>'0'),
							  sl_write_valid => '0',
							  axi_rdata => (OTHERS=>'0')
							  );
	
	
	CONSTANT c_usig_typdef_address			: UNSIGNED(axi_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_typdef_address*4,axi_device_address_width);
	CONSTANT c_usig_mem_size_address 		: UNSIGNED(axi_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_mem_size_address*4,axi_device_address_width);
	CONSTANT c_number_of_channels_address	: UNSIGNED(axi_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_number_of_channels_address*4,axi_device_address_width);
	CONSTANT c_usig_unique_id_address 		: UNSIGNED(axi_device_address_width-1 DOWNTO 0) := to_unsigned(c_fLink_unique_id_address*4,axi_device_address_width);
	
	SIGNAL ri : t_internal_register := INTERNAL_REG_RESET;
	SIGNAL ri_next : t_internal_register := INTERNAL_REG_RESET;
BEGIN

	-- combinatorial process
	comb_proc : PROCESS (ri,axi_areset_n,
						axi_awid,axi_awaddr,axi_awlen,axi_awsize,axi_awburst,axi_awvalid,
						axi_wdata,axi_wstrb,axi_wvalid,
						axi_araddr,axi_arvalid,axi_arlen,axi_arsize,axi_arburst,axi_arid,
						axi_rready,
						axi_bready,
						islv_read_data
						)
		VARIABLE vi : t_internal_register := INTERNAL_REG_RESET;
		VARIABLE increment : UNSIGNED(7 DOWNTO 0);
	BEGIN
		-- keep variables stable
		vi := ri;	
		
		--read channels
		IF (vi.axi_arready = '0' and axi_arvalid = '1' ) THEN
	        vi.axi_arready := '1';
			vi.read_address :=  UNSIGNED(axi_araddr);
			vi.read_burst_len_cnt := (OTHERS =>'0');
			vi.axi_rlast := '0';
		ELSIF(vi.read_burst_len_cnt < UNSIGNED(axi_arlen) AND axi_arvalid = '1' AND axi_rready = '1') THEN
			 vi.axi_rvalid := '1';
			 vi.read_burst_len_cnt := vi.read_burst_len_cnt + 1;
			 IF(axi_arburst = c_burst_type_fixed) THEN
				vi.read_address :=  vi.read_address;
			 ELSE
				 CASE (axi_arsize) IS
					WHEN "000" =>
						vi.read_address :=  vi.read_address + 1;
					WHEN "001" =>
						vi.read_address :=  vi.read_address + 2;
					WHEN "010" =>
						vi.read_address :=  vi.read_address + 4;
					WHEN "011" =>
						vi.read_address :=  vi.read_address + 8;
					WHEN "100" =>
						vi.read_address :=  vi.read_address + 16;
					WHEN "101" =>
						vi.read_address :=  vi.read_address + 32;
					WHEN "110" =>
						vi.read_address :=  vi.read_address + 64;
					WHEN "111" =>
						vi.read_address :=  vi.read_address + 128;
					WHEN others =>
						vi.read_address :=  vi.read_address + 1;
				END CASE;
			 END IF;
		ELSIF vi.read_burst_len_cnt = UNSIGNED(axi_arlen) AND axi_arvalid = '1' THEN
			vi.axi_rvalid := '1';
			vi.axi_rlast := '1';
		ELSIF axi_arvalid = '0' THEN
			vi.axi_rlast := '0';
			vi.axi_arready := '0';
			vi.axi_rvalid := '0';
		END IF;
		
		--flink read std registers
		CASE vi.read_address IS
			WHEN c_usig_typdef_address =>
				vi.axi_rdata((c_fLink_interface_version_length + c_fLink_subtype_length + c_fLink_id_length - 1) DOWNTO (c_fLink_interface_version_length + c_fLink_subtype_length)) := STD_LOGIC_VECTOR(to_unsigned(id,c_fLink_id_length));
				vi.axi_rdata((c_fLink_interface_version_length + c_fLink_subtype_length - 1) DOWNTO c_fLink_interface_version_length) := STD_LOGIC_VECTOR(to_unsigned(subtype_id,c_fLink_subtype_length));
				vi.axi_rdata(c_fLink_interface_version_length-1 DOWNTO 0) :=  STD_LOGIC_VECTOR(to_unsigned(interface_version,c_fLink_interface_version_length));
			WHEN c_usig_mem_size_address => 
				vi.axi_rdata := (OTHERS =>'0');
				vi.axi_rdata(axi_device_address_width) := '1';
			WHEN c_number_of_channels_address =>
				vi.axi_rdata := STD_LOGIC_VECTOR(to_unsigned(number_of_channels,c_fLink_avs_data_width));
			WHEN c_usig_unique_id_address => 
				vi.axi_rdata := unique_id;
			WHEN OTHERS => 
				vi.axi_rdata := islv_read_data;
		END CASE;
		
		
		--write channels 
		IF (vi.axi_awready = '0' and axi_awvalid = '1' ) THEN
	        vi.axi_awready := '1';
			vi.write_address :=  UNSIGNED(axi_awaddr);
			vi.write_burst_len_cnt := (OTHERS =>'0');
			vi.axi_wready := '1';
		ELSIF(vi.write_burst_len_cnt < UNSIGNED(axi_awlen) AND axi_awvalid = '1' AND vi.axi_wready = '1') THEN
			vi.write_burst_len_cnt := vi.write_burst_len_cnt + 1;
			 IF(axi_awburst = c_burst_type_fixed) THEN
				vi.write_address :=  vi.write_address;
			 ELSE
				 CASE (axi_awsize) IS
					WHEN "000" =>
						vi.write_address :=  vi.write_address + 1;
					WHEN "001" =>
						vi.write_address :=  vi.write_address + 2;
					WHEN "010" =>
						vi.write_address :=  vi.write_address + 4;
					WHEN "011" =>
						vi.write_address :=  vi.write_address + 8;
					WHEN "100" =>
						vi.write_address :=  vi.write_address + 16;
					WHEN "101" =>
						vi.write_address :=  vi.write_address + 32;
					WHEN "110" =>
						vi.write_address :=  vi.write_address + 64;
					WHEN "111" =>
						vi.write_address :=  vi.write_address + 128;
					WHEN others =>
						vi.write_address :=  vi.write_address + 1;
				END CASE;
			 END IF;
		ELSIF(vi.write_burst_len_cnt = UNSIGNED(axi_awlen) AND 	 vi.axi_wready = '1') THEN
			vi.write_burst_len_cnt := vi.write_burst_len_cnt + 1;
			vi.axi_wready := '1';
		ELSE
			vi.axi_wready := '0';
			vi.axi_awready := '0';
		END IF;

		
		vi.write_data := axi_wdata;
		IF (vi.axi_wready = '1' AND axi_wvalid = '1') THEN
			vi.sl_write_valid := '1';
			vi.axi_bvalid := '1';
		ELSE
			vi.sl_write_valid := '0';
			vi.axi_bvalid := '0';
		END IF;
	
		
		
		
		
		
		--forward ids
		vi.axi_bid := axi_awid;
		vi.axi_rid := axi_arid;
		
		IF (axi_areset_n = '0') THEN
			vi 	:= INTERNAL_REG_RESET;
		END IF;
		
		ri_next <= vi;
	
	END PROCESS comb_proc;
	
	
	reg_proc : PROCESS (axi_aclk)
	BEGIN
		IF rising_edge(axi_aclk) THEN
			ri <= ri_next;
		END IF;
	END PROCESS reg_proc;
	oslv_write_address <= ri.write_address;
	oslv_read_address <= ri.read_address;
	axi_awready <= ri.axi_awready; 	 
	axi_wready <= ri.axi_wready;
	axi_arready <= ri.axi_arready; 	
	axi_rdata <= ri.axi_rdata; 	
	axi_rresp <= ri.axi_rresp; 	
	axi_rvalid <= ri.axi_rvalid;	
	axi_bresp <= ri.axi_bresp; 	
	axi_bvalid <= ri.axi_bvalid; 
	axi_bid <= ri.axi_bid;
	axi_rid <= ri.axi_rid;
	axi_rlast <= ri.axi_rlast;
	oslv_write_data <= ri.write_data;
	osl_write_valid <= ri.sl_write_valid;
	

	
	
END rtl;
