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
--  Title             : stepperMotorDevice_S00_AXI.vhd
--  Project           : FLINK
--  Description       : Avalon MM interface for stepper motors  
---------------------------------------------------------------------------------------------
--  Copyright(C) 2023 : Fachhochschule Ostschweiz
--  All rights reserved.
---------------------------------------------------------------------------------------------
--  History
--  23.09.2023 GOOP :    Initial version
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.flink_definitions.all;
USE work.prescale_register_ctrl_pkg.ALL;
use work.speedcontroll_pkg.all;

entity stepperMotorDevice_v1_0_S00_AXI is
    generic (
        -- Users to add parameters here
            unique_id : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
            base_clk : INTEGER := 100000000;--clock frequency which is used on the clock input signal of this block
            number_of_motors: INTEGER RANGE 0 TO 64 := 1;
            i_clock_frequency_divider : INTEGER := 1000; -- prescale external 100MHz clock to internal 100kHz clock
        -- User parameters ends
        -- Do not modify the parameters beyond this line

        -- Width of ID for for write address, write data, read address and read data
        C_S_AXI_ID_WIDTH    : integer    := 1;
        -- Width of S_AXI data bus
        C_S_AXI_DATA_WIDTH    : integer    := 32;
        -- Width of S_AXI address bus
        C_S_AXI_ADDR_WIDTH    : integer    := 12
    );
    port (
        -- Users to add ports here
            oslv_interrupts : OUT STD_LOGIC_VECTOR(number_of_motors-1 DOWNTO 0);
            oslv_motors : OUT STD_LOGIC_VECTOR (number_of_motors*4-1 DOWNTO 0);
        -- User ports ends
        -- Do not modify the ports beyond this line

        -- Global Clock Signal
        S_AXI_ACLK    : in std_logic;
        -- Global Reset Signal. This Signal is Active LOW
        S_AXI_ARESETN    : in std_logic;
        -- Write Address ID
        S_AXI_AWID    : in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        -- Write address
        S_AXI_AWADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        -- Burst length. The burst length gives the exact number of transfers in a burst
        S_AXI_AWLEN    : in std_logic_vector(7 downto 0);
        -- Burst size. This signal indicates the size of each transfer in the burst
        S_AXI_AWSIZE    : in std_logic_vector(2 downto 0);
        -- Burst type. The burst type and the size information, 
        -- determine how the address for each transfer within the burst is calculated.
        S_AXI_AWBURST    : in std_logic_vector(1 downto 0);
        
        -- Write address valid. This signal indicates that
        -- the channel is signaling valid write address and
        -- control information.
        S_AXI_AWVALID    : in std_logic;
        -- Write address ready. This signal indicates that
        -- the slave is ready to accept an address and associated
        -- control signals.
        S_AXI_AWREADY    : out std_logic;
        -- Write Data
        S_AXI_WDATA    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        -- Write strobes. This signal indicates which byte
        -- lanes hold valid data. There is one write strobe
        -- bit for each eight bits of the write data bus.
        S_AXI_WSTRB    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        -- Write last. This signal indicates the last transfer
        -- in a write burst.
        S_AXI_WLAST    : in std_logic;
        -- Write valid. This signal indicates that valid write
        -- data and strobes are available.
        S_AXI_WVALID    : in std_logic;
        -- Write ready. This signal indicates that the slave
        -- can accept the write data.
        S_AXI_WREADY    : out std_logic;
        -- Response ID tag. This signal is the ID tag of the
        -- write response.
        S_AXI_BID    : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        -- Write response. This signal indicates the status
        -- of the write transaction.
        S_AXI_BRESP    : out std_logic_vector(1 downto 0);
        -- Write response valid. This signal indicates that the
        -- channel is signaling a valid write response.
        S_AXI_BVALID    : out std_logic;
        -- Response ready. This signal indicates that the master
        -- can accept a write response.
        S_AXI_BREADY    : in std_logic;
        -- Read address ID. This signal is the identification
        -- tag for the read address group of signals.
        S_AXI_ARID    : in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        -- Read address. This signal indicates the initial
        -- address of a read burst transaction.
        S_AXI_ARADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        -- Burst length. The burst length gives the exact number of transfers in a burst
        S_AXI_ARLEN    : in std_logic_vector(7 downto 0);
        -- Burst size. This signal indicates the size of each transfer in the burst
        S_AXI_ARSIZE    : in std_logic_vector(2 downto 0);
        -- Burst type. The burst type and the size information, 
        -- determine how the address for each transfer within the burst is calculated.
        S_AXI_ARBURST    : in std_logic_vector(1 downto 0);
        -- Write address valid. This signal indicates that
        -- the channel is signaling valid read address and
        -- control information.
        S_AXI_ARVALID    : in std_logic;
        -- Read address ready. This signal indicates that
        -- the slave is ready to accept an address and associated
        -- control signals.
        S_AXI_ARREADY    : out std_logic;
        -- Read ID tag. This signal is the identification tag
        -- for the read data group of signals generated by the slave.
        S_AXI_RID    : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
        -- Read Data
        S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        -- Read response. This signal indicates the status of
        -- the read transfer.
        S_AXI_RRESP    : out std_logic_vector(1 downto 0);
        -- Read last. This signal indicates the last transfer
        -- in a read burst.
        S_AXI_RLAST    : out std_logic;
        -- Read valid. This signal indicates that the channel
        -- is signaling the required read data.
        S_AXI_RVALID    : out std_logic;
        -- Read ready. This signal indicates that the master can
        -- accept the read data and response information.
        S_AXI_RREADY    : in std_logic
    );
end stepperMotorDevice_v1_0_S00_AXI;

architecture arch_imp of stepperMotorDevice_v1_0_S00_AXI is

    -- AXI4FULL signals
    signal axi_awaddr    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_awready    : std_logic;
    signal axi_wready    : std_logic;
    signal axi_bvalid    : std_logic;
    signal axi_araddr    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_arready    : std_logic;
    signal axi_rdata    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal axi_rlast    : std_logic;
    signal axi_rvalid    : std_logic;
    -- aw_wrap_en determines wrap boundary and enables wrapping
    signal  aw_wrap_en : std_logic; 
    -- ar_wrap_en determines wrap boundary and enables wrapping
    signal  ar_wrap_en : std_logic;
    -- aw_wrap_size is the size of the write transfer, the
    -- write address wraps to a lower address if upper address
    -- limit is reached
    signal aw_wrap_size : integer;
    -- ar_wrap_size is the size of the read transfer, the
    -- read address wraps to a lower address if upper address
    -- limit is reached
    signal ar_wrap_size : integer;
    -- The axi_awv_awr_flag flag marks the presence of write address valid
    signal axi_awv_awr_flag    : std_logic;
    --The axi_arv_arr_flag flag marks the presence of read address valid
    signal axi_arv_arr_flag    : std_logic;
    -- The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
    signal axi_awlen_cntr      : std_logic_vector(7 downto 0);
    --The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
    signal axi_arlen_cntr      : std_logic_vector(7 downto 0);
    signal axi_arburst      : std_logic_vector(2-1 downto 0);
    signal axi_awburst      : std_logic_vector(2-1 downto 0);
    signal axi_arlen      : std_logic_vector(8-1 downto 0);
    signal axi_awlen      : std_logic_vector(8-1 downto 0);
    --local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    --ADDR_LSB is used for addressing 32/64 bit registers/memories
    --ADDR_LSB = 2 for 32 bits (n downto 2) 
    --ADDR_LSB = 3 for 42 bits (n downto 3)

    constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
    constant OPT_MEM_ADDR_BITS : integer := 3;
    constant USER_NUM_MEM: integer := 1;
    constant low : std_logic_vector (C_S_AXI_ADDR_WIDTH - 1 downto 0) := (OTHERS => '0');
    
    CONSTANT c_resolution : INTEGER := 4096;
    
    CONSTANT c_usig_typdef_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_typdef_address*4, C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_mem_size_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_mem_size_address*4, C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_number_of_channels_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_channels_address*4, C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_unique_id_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_unique_id_address*4, C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_global_configuration_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_configuration_address*4, C_S_AXI_ADDR_WIDTH));
    
    CONSTANT c_int_nof_motors_reg: INTEGER := number_of_motors / C_S_AXI_DATA_WIDTH;
    
    CONSTANT c_usig_base_clk_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_std_registers*4,C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_local_configuration_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_base_clk_address) + 4);
    CONSTANT c_usig_local_set_configuration_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_local_configuration_address) + 4*number_of_motors);
    CONSTANT c_usig_local_reset_configuration_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_local_set_configuration_address) + 4*number_of_motors);
    CONSTANT c_usig_prescaler_start_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_local_reset_configuration_address) + 4*number_of_motors);
    CONSTANT c_usig_prescaler_top_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_prescaler_start_address) + 4*number_of_motors);
    CONSTANT c_usig_acceleration_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_prescaler_top_address) + 4*number_of_motors);
    CONSTANT c_usig_steps_to_do_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_acceleration_address) + 4*number_of_motors);
    CONSTANT c_usig_steps_have_done_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_steps_to_do_address) + 4*number_of_motors);
    CONSTANT c_usig_max_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_steps_have_done_address) + 4*number_of_motors);

    CONSTANT id : STD_LOGIC_VECTOR(15 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(21, 16)); --todo change back to flink definition c_fLink_stepper_motor_id (it couldent found yet??)
    CONSTANT subtype_id : STD_LOGIC_VECTOR(7 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, 8));
    CONSTANT interface_version : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    
    TYPE t_generic_reg IS ARRAY(number_of_motors -1 DOWNTO 0) OF STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
    SIGNAL motor_reset : STD_LOGIC := '0';
    SIGNAL slv_start_reset_bit : STD_LOGIC_VECTOR(number_of_motors-1 DOWNTO 0);
    
    -- r/w regs
    TYPE t_internal_reg IS RECORD
        slv_global_conf_reg   : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
        t_local_conf_reg      : t_generic_reg;
        t_merged_conf_reg     : t_generic_reg;
        t_prescaler_start_reg      : t_generic_reg;
        t_prescaler_top_reg      : t_generic_reg;
        t_acceleration_reg      : t_generic_reg;
        t_steps_to_do_reg      : t_generic_reg;
    END RECORD;
    
    CONSTANT INTERNAL_REG_RESET : t_internal_reg := (
        slv_global_conf_reg => (OTHERS=>'0'),
        t_local_conf_reg => (OTHERS=> (OTHERS=>'0')),
        t_merged_conf_reg => (OTHERS=> (OTHERS=>'0')),
        t_prescaler_start_reg => (OTHERS=> (OTHERS=>'0')),
        t_prescaler_top_reg => (OTHERS=> (OTHERS=>'0')),
        t_acceleration_reg => (OTHERS=> (OTHERS=>'0')),
        t_steps_to_do_reg => (OTHERS=> (OTHERS=>'0'))
    );
    
    SIGNAL ri, ri_next : t_internal_reg := INTERNAL_REG_RESET;
    
    -- r only regs
    SIGNAL t_steps_have_done_reg : t_generic_reg := ((OTHERS=> (OTHERS=>'0')));
    
    -- outputs

    
begin
    -- I/O Connections assignments
    S_AXI_AWREADY    <= axi_awready;
    S_AXI_WREADY    <= axi_wready;
    S_AXI_BRESP    <= (OTHERS => '0');
    S_AXI_BVALID    <= axi_bvalid;
    S_AXI_ARREADY    <= axi_arready;
    S_AXI_RDATA    <= axi_rdata;
    S_AXI_RRESP    <= (OTHERS => '0');
    S_AXI_RLAST    <= axi_rlast;
    S_AXI_RVALID    <= axi_rvalid;
    S_AXI_BID <= S_AXI_AWID;
    S_AXI_RID <= S_AXI_ARID;
    aw_wrap_size <= ((C_S_AXI_DATA_WIDTH)/8 * to_integer(unsigned(axi_awlen))); 
    ar_wrap_size <= ((C_S_AXI_DATA_WIDTH)/8 * to_integer(unsigned(axi_arlen))); 
    aw_wrap_en <= '1' when (((axi_awaddr AND std_logic_vector(to_unsigned(aw_wrap_size,C_S_AXI_ADDR_WIDTH))) XOR std_logic_vector(to_unsigned(aw_wrap_size,C_S_AXI_ADDR_WIDTH))) = low) else '0';
    ar_wrap_en <= '1' when (((axi_araddr AND std_logic_vector(to_unsigned(ar_wrap_size,C_S_AXI_ADDR_WIDTH))) XOR std_logic_vector(to_unsigned(ar_wrap_size,C_S_AXI_ADDR_WIDTH))) = low) else '0';

    -- Implement axi_awready generation

    -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    -- de-asserted when reset is low.

    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_awready <= '0';
          axi_awv_awr_flag <= '0';
        else
          if (axi_awready = '0' and S_AXI_AWVALID = '1' and axi_awv_awr_flag = '0' and axi_arv_arr_flag = '0') then
            -- slave is ready to accept an address and
            -- associated control signals
            axi_awv_awr_flag  <= '1'; -- used for generation of bresp() and bvalid
            axi_awready <= '1';
          elsif (S_AXI_WLAST = '1' and axi_wready = '1') then 
          -- preparing to accept next address after current write burst tx completion
            axi_awv_awr_flag  <= '0';
          else
            axi_awready <= '0';
          end if;
        end if;
      end if;         
    end process; 
    -- Implement axi_awaddr latching

    -- This process is used to latch the address when both 
    -- S_AXI_AWVALID and S_AXI_WVALID are valid. 

    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_awaddr <= (others => '0');
          axi_awburst <= (others => '0'); 
          axi_awlen <= (others => '0'); 
          axi_awlen_cntr <= (others => '0');
        else
          if (axi_awready = '0' and S_AXI_AWVALID = '1' and axi_awv_awr_flag = '0') then
          -- address latching 
            axi_awaddr <= S_AXI_AWADDR(C_S_AXI_ADDR_WIDTH - 1 downto 0);  ---- start address of transfer
            axi_awlen_cntr <= (others => '0');
            axi_awburst <= S_AXI_AWBURST;
            axi_awlen <= S_AXI_AWLEN;
          elsif((axi_awlen_cntr <= axi_awlen) and axi_wready = '1' and S_AXI_WVALID = '1') then     
            axi_awlen_cntr <= std_logic_vector (unsigned(axi_awlen_cntr) + 1);

            case (axi_awburst) is
              when "00" => -- fixed burst
                -- The write address for all the beats in the transaction are fixed
                axi_awaddr     <= axi_awaddr;       ----for awsize = 4 bytes (010)
              when "01" => --incremental burst
                -- The write address for all the beats in the transaction are increments by awsize
                
                IF(S_AXI_AWSIZE = "000") THEN
                    axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 1);
                ELSIF(S_AXI_AWSIZE = "001") THEN
                    axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 2);
                ELSIF(S_AXI_AWSIZE = "010") THEN
                    axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 4);
                ELSIF(S_AXI_AWSIZE = "011") THEN
                    axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 8);
                ELSIF(S_AXI_AWSIZE = "100") THEN
                    axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 16);
                ELSE
                     axi_awaddr     <= axi_awaddr;
                END IF;
                
              when "10" => --Wrapping burst
                -- The write address wraps when the address reaches wrap boundary 
                if (aw_wrap_en = '1') then
                  axi_awaddr <= std_logic_vector (unsigned(axi_awaddr) - (to_unsigned(aw_wrap_size,C_S_AXI_ADDR_WIDTH)));                
                else 
                  axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB)) + 1);--awaddr aligned to 4 byte boundary
                  axi_awaddr(ADDR_LSB-1 downto 0)  <= (others => '0');  ----for awsize = 4 bytes (010)
                end if;
              when others => --reserved (incremental burst for example)
                axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB)) + 1);--for awsize = 4 bytes (010)
                axi_awaddr(ADDR_LSB-1 downto 0)  <= (others => '0');
            end case;        
          end if;
        end if;
      end if;
    end process;
    -- Implement axi_wready generation

    -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
    -- de-asserted when reset is low. 

    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_wready <= '0';
        else
          if (axi_wready = '0' and S_AXI_WVALID = '1' and axi_awv_awr_flag = '1') then
            axi_wready <= '1';
            -- elsif (axi_awv_awr_flag = '0') then
          elsif (S_AXI_WLAST = '1' and axi_wready = '1') then 

            axi_wready <= '0';
          end if;
        end if;
      end if;         
    end process; 
    -- Implement write response logic generation

    -- The write response and response valid signals are asserted by the slave 
    -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
    -- This marks the acceptance of address and indicates the status of 
    -- write transaction.

    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_bvalid  <= '0';
        else
          if (axi_awv_awr_flag = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0' and S_AXI_WLAST = '1' ) then
            axi_bvalid <= '1';
          elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then  
          --check if bready is asserted while bvalid is high)
            axi_bvalid <= '0';                      
          end if;
        end if;
      end if;         
    end process; 
    -- Implement axi_arready generation

    -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
    -- S_AXI_ARVALID is asserted. axi_awready is 
    -- de-asserted when reset (active low) is asserted. 
    -- The read address is also latched when S_AXI_ARVALID is 
    -- asserted. axi_araddr is reset to zero on reset assertion.

    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_arready <= '0';
          axi_arv_arr_flag <= '0';
        else
          if (axi_arready = '0' and S_AXI_ARVALID = '1' and axi_awv_awr_flag = '0' and axi_arv_arr_flag = '0') then
            axi_arready <= '1';
            axi_arv_arr_flag <= '1';
          elsif (axi_rvalid = '1' and S_AXI_RREADY = '1' and (axi_arlen_cntr = axi_arlen)) then 
          -- preparing to accept next address after current read completion
            axi_arv_arr_flag <= '0';
          else
            axi_arready <= '0';
          end if;
        end if;
      end if;         
    end process; 
    -- Implement axi_araddr latching

    --This process is used to latch the address when both 
    --S_AXI_ARVALID and S_AXI_RVALID are valid. 
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          axi_araddr <= (others => '0');
          axi_arburst <= (others => '0');
          axi_arlen <= (others => '0'); 
          axi_arlen_cntr <= (others => '0');
          axi_rlast <= '0';
        else
          if (axi_arready = '0' and S_AXI_ARVALID = '1' and axi_arv_arr_flag = '0') then
            -- address latching 
            axi_araddr <= S_AXI_ARADDR(C_S_AXI_ADDR_WIDTH - 1 downto 0); ---- start address of transfer
            axi_arlen_cntr <= (others => '0');
            axi_rlast <= '0';
            axi_arburst <= S_AXI_ARBURST;
            axi_arlen <= S_AXI_ARLEN;
          elsif((axi_arlen_cntr <= axi_arlen) and axi_rvalid = '1' and S_AXI_RREADY = '1') then     
            axi_arlen_cntr <= std_logic_vector (unsigned(axi_arlen_cntr) + 1);
            axi_rlast <= '0';      
         
            case (axi_arburst) is
              when "00" =>  -- fixed burst
                -- The read address for all the beats in the transaction are fixed
                axi_araddr     <= axi_araddr;      ----for arsize = 4 bytes (010)
              when "01" =>  --incremental burst
                -- The read address for all the beats in the transaction are increments by awsize
                    IF(S_AXI_ARSIZE = "000") THEN
                        axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 1);
                    ELSIF(S_AXI_ARSIZE = "001") THEN
                        axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 2);
                    ELSIF(S_AXI_ARSIZE = "010") THEN
                        axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 4);
                    ELSIF(S_AXI_ARSIZE = "011") THEN
                        axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 8);
                    ELSIF(S_AXI_ARSIZE = "100") THEN
                        axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto 0)) + 16);
                    ELSE
                        axi_araddr  <= axi_araddr;
                    END IF;
              when "10" =>  --Wrapping burst
                -- The read address wraps when the address reaches wrap boundary 
                if (ar_wrap_en = '1') then   
                  axi_araddr <= std_logic_vector (unsigned(axi_araddr) - (to_unsigned(ar_wrap_size,C_S_AXI_ADDR_WIDTH)));
                else 
                  axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB)) + 1); --araddr aligned to 4 byte boundary
                  axi_araddr(ADDR_LSB-1 downto 0)  <= (others => '0');  ----for awsize = 4 bytes (010)
                end if;
              when others => --reserved (incremental burst for example)
                axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto ADDR_LSB)) + 1);--for arsize = 4 bytes (010)
              axi_araddr(ADDR_LSB-1 downto 0)  <= (others => '0');
            end case;         
          elsif((axi_arlen_cntr = axi_arlen) and axi_rlast = '0' and axi_arv_arr_flag = '1') then  
            axi_rlast <= '1';
          elsif (S_AXI_RREADY = '1') then  
            axi_rlast <= '0';
          end if;
        end if;
      end if;
    end  process;  
    -- Implement axi_arvalid generation

    -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
    -- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
    -- data are available on the axi_rdata bus at this instance. The 
    -- assertion of axi_rvalid marks the validity of read data on the 
    -- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    -- is deasserted on reset (active low). axi_rresp and axi_rdata are 
    -- cleared to zero on reset (active low).  

    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_rvalid <= '0';
        else
          if (axi_arv_arr_flag = '1' and axi_rvalid = '0') then
            axi_rvalid <= '1';
          elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
            axi_rvalid <= '0';
          end  if;      
        end if;
      end if;
    end  process;

    --read data
    process( axi_rvalid,axi_araddr,ri ) is
    begin
        if (axi_rvalid = '1') then
        -- output the read data
            -- device header regs
            IF (axi_araddr = c_usig_typdef_address) THEN
                axi_rdata(31 DOWNTO 16) <= id;
                axi_rdata(15 DOWNTO 8) <= subtype_id;
                axi_rdata(7 DOWNTO 0) <= interface_version;
            ELSIF (axi_araddr = c_usig_mem_size_address) THEN
                axi_rdata <= (others => '0');
                axi_rdata(C_S_AXI_ADDR_WIDTH) <= '1';
            ELSIF (axi_araddr = c_usig_number_of_channels_address) THEN
                axi_rdata <= std_logic_vector(to_unsigned(number_of_motors, axi_rdata'length));
            ELSIF (axi_araddr = c_usig_unique_id_address) THEN
                axi_rdata <= unique_id;
            ELSIF (axi_araddr = c_usig_global_configuration_address) THEN
                axi_rdata <= ri.slv_global_conf_reg;  
            
            -- device specific regs  
            ELSIF(axi_araddr = c_usig_base_clk_address) THEN
                axi_rdata <= STD_LOGIC_VECTOR(to_unsigned(base_clk/i_clock_frequency_divider, axi_rdata'length));
            ELSIF (axi_araddr >= c_usig_local_configuration_address AND axi_araddr < c_usig_prescaler_start_address) THEN 
                axi_rdata <= ri.t_local_conf_reg(to_integer(unsigned(axi_araddr) - unsigned(c_usig_local_configuration_address)) / 4);
            ELSIF (axi_araddr >= c_usig_prescaler_start_address AND axi_araddr < c_usig_prescaler_top_address) THEN 
                axi_rdata <= ri.t_prescaler_start_reg(to_integer(unsigned(axi_araddr) - unsigned(c_usig_prescaler_start_address)) / 4);
            ELSIF (axi_araddr >= c_usig_prescaler_top_address AND axi_araddr < c_usig_acceleration_address) THEN 
                axi_rdata <= ri.t_prescaler_top_reg(to_integer(unsigned(axi_araddr) - unsigned(c_usig_prescaler_top_address)) / 4);
            ELSIF (axi_araddr >= c_usig_acceleration_address AND axi_araddr < c_usig_steps_to_do_address) THEN 
                axi_rdata <= ri.t_acceleration_reg(to_integer(unsigned(axi_araddr) - unsigned(c_usig_acceleration_address)) / 4);
            ELSIF (axi_araddr >= c_usig_steps_to_do_address AND axi_araddr < c_usig_steps_have_done_address) THEN 
                axi_rdata <= ri.t_steps_to_do_reg(to_integer(unsigned(axi_araddr) - unsigned(c_usig_steps_to_do_address)) / 4);
            ELSIF (axi_araddr >= c_usig_steps_have_done_address AND axi_araddr < c_usig_max_address) THEN 
                axi_rdata <= t_steps_have_done_reg(to_integer(unsigned(axi_araddr) - unsigned(c_usig_steps_have_done_address)) / 4);
            ELSE
                axi_rdata <= (others => '0');
            END IF;
        else
            axi_rdata <= (others => '0');
        end if;  
    end process;

    --write and other control structures
    process( axi_wready,S_AXI_WVALID,S_AXI_WDATA,axi_awaddr,S_AXI_WSTRB,ri,S_AXI_ARESETN) 
    VARIABLE vi: t_internal_reg := INTERNAL_REG_RESET;
    VARIABLE reg_number: INTEGER RANGE 0 TO c_int_nof_motors_reg := 0;
    VARIABLE temp_input: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
    BEGIN
        vi := ri;
        IF(axi_wready = '1') THEN
            -- device header regs
            IF(axi_awaddr = c_usig_global_configuration_address) THEN
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        vi.slv_global_conf_reg((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
                
            -- device specific regs  
            ELSIF (axi_awaddr >= c_usig_local_configuration_address AND axi_awaddr < c_usig_local_set_configuration_address) THEN 
                reg_number := (to_integer(unsigned(axi_awaddr)) - to_integer(UNSIGNED(c_usig_local_configuration_address)))/4;
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        vi.t_local_conf_reg(reg_number)((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
            ELSIF (axi_awaddr >= c_usig_local_set_configuration_address AND axi_awaddr < c_usig_local_reset_configuration_address) THEN 
                reg_number := (to_integer(unsigned(axi_awaddr)) - to_integer(UNSIGNED(c_usig_local_set_configuration_address)))/4;
                temp_input := (OTHERS => '0');
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        temp_input((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
                vi.t_local_conf_reg(reg_number) := ri.t_local_conf_reg(reg_number) OR temp_input;
            ELSIF (axi_awaddr >= c_usig_local_reset_configuration_address AND axi_awaddr < c_usig_prescaler_start_address) THEN 
                reg_number := (to_integer(unsigned(axi_awaddr)) - to_integer(UNSIGNED(c_usig_local_reset_configuration_address)))/4;
                temp_input := (OTHERS => '0');
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        temp_input((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
                vi.t_local_conf_reg(reg_number) := ri.t_local_conf_reg(reg_number) AND (NOT temp_input);
            ELSIF (axi_awaddr >= c_usig_prescaler_start_address AND axi_awaddr < c_usig_prescaler_top_address) THEN 
                reg_number := (to_integer(unsigned(axi_awaddr)) - to_integer(UNSIGNED(c_usig_prescaler_start_address)))/4;
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        vi.t_prescaler_start_reg(reg_number)((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
            ELSIF (axi_awaddr >= c_usig_prescaler_top_address AND axi_awaddr < c_usig_acceleration_address) THEN 
                reg_number := (to_integer(unsigned(axi_awaddr)) - to_integer(UNSIGNED(c_usig_prescaler_top_address)))/4; 
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        vi.t_prescaler_top_reg(reg_number)((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
            ELSIF (axi_awaddr >= c_usig_acceleration_address AND axi_awaddr < c_usig_steps_to_do_address) THEN 
                reg_number := (to_integer(unsigned(axi_awaddr)) - to_integer(UNSIGNED(c_usig_acceleration_address)))/4;
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        vi.t_acceleration_reg(reg_number)((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
            ELSIF (axi_awaddr >= c_usig_steps_to_do_address AND axi_awaddr < c_usig_steps_have_done_address) THEN 
                reg_number := (to_integer(unsigned(axi_awaddr)) - to_integer(UNSIGNED(c_usig_steps_to_do_address)))/4;
                FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                    IF(S_AXI_WSTRB(i) = '1')THEN
                        vi.t_steps_to_do_reg(reg_number)((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                    END IF;
                END LOOP;
            END IF;
        END IF;
                   
        -- merge of local and global config register except full reset and autoreset of startbit
        FOR i IN 0 TO number_of_motors-1 LOOP
            IF slv_start_reset_bit(i) = '1' THEN
                vi.t_local_conf_reg(i)(I_START) := '0';
            END IF;
            
            vi.t_merged_conf_reg(i) := vi.t_local_conf_reg(i);
            --vi.t_merged_conf_reg(i)(I_RESET_STEPCOUNTER) := vi.t_local_conf_reg(i)(I_RESET_STEPCOUNTER) OR  vi.slv_global_conf_reg(1); -- merge of step reset
        END LOOP;
   
        IF(S_AXI_ARESETN = '0' OR vi.slv_global_conf_reg(0) = '1' )THEN
            vi := INTERNAL_REG_RESET;
            motor_reset <= '1';
        ELSE
            motor_reset <= '0';
        END IF;
   
        ri_next <= vi;
    END PROCESS;
    
    
    --create component
    gen_motor: FOR i IN 0 TO number_of_motors-1 GENERATE
        gen_prescale : prescale_register_ctrl 
        GENERIC MAP(
            i_base_clk => base_clk,
            i_bus_with => C_S_AXI_DATA_WIDTH,
            i_clock_frequency_divider => i_clock_frequency_divider
        )
        PORT MAP( 
            isl_clk => S_AXI_ACLK,
            isl_rst => motor_reset,
            islv8_config => ri.t_local_conf_reg(i)(7 DOWNTO 0),
            iusig_prescaler_top_speed => UNSIGNED(ri.t_prescaler_top_reg(i)),
            iusig_prescaler_start_speed => UNSIGNED(ri.t_prescaler_start_reg(i)),
            iusig_acceleration => UNSIGNED(ri.t_acceleration_reg(i)),
            iusig_steps => UNSIGNED(ri.t_steps_to_do_reg(i)),
            oslv4_motor => oslv_motors((i+1)*4-1 DOWNTO i*4),
            osl_interrupt => oslv_interrupts(i),
            osl_reset_start_bit => slv_start_reset_bit(i), -- only used in step mode
            STD_LOGIC_VECTOR(ousig_nof_steps) => t_steps_have_done_reg(i)
        );
    END GENERATE gen_motor;
    
    reg_proc : PROCESS (S_AXI_ACLK)
    BEGIN
        IF rising_edge(S_AXI_ACLK) THEN
            ri <= ri_next;
        END IF;
    END PROCESS reg_proc;

end arch_imp;
