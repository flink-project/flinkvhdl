library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.irq_generator_pgk.ALL;
USE work.fLink_definitions.ALL;

entity gpioDevice_v1_0_S00_AXI is
    generic (
        -- Users to add parameters here
         base_clk : INTEGER := 100000000;
         number_of_gpios: INTEGER RANGE 1 TO 128 := 1;
         unique_id: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
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
        slv_gpios_io_i : IN STD_LOGIC_VECTOR(number_of_gpios-1 DOWNTO 0);
        slv_gpios_io_o : OUT STD_LOGIC_VECTOR(number_of_gpios-1 DOWNTO 0);
        slv_gpios_io_t : OUT STD_LOGIC_VECTOR(number_of_gpios-1 DOWNTO 0);
        oslv_interrupts_rising  : OUT STD_LOGIC_VECTOR(number_of_gpios-1 DOWNTO 0);
        oslv_interrupts_falling : OUT STD_LOGIC_VECTOR(number_of_gpios-1 DOWNTO 0);
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
        -- Quality of Service, QoS identifier sent for each
    -- read transaction.
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
end gpioDevice_v1_0_S00_AXI;

architecture arch_imp of gpioDevice_v1_0_S00_AXI is

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
    
    CONSTANT c_usig_typdef_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_typdef_address*4,C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_mem_size_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_mem_size_address*4,C_S_AXI_ADDR_WIDTH));
    CONSTANT c_number_of_channels_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_channels_address*4,C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_unique_id_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_unique_id_address*4,C_S_AXI_ADDR_WIDTH));
    CONSTANT c_configuration_reg_address: STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_configuration_address*4,C_S_AXI_ADDR_WIDTH));
    
    CONSTANT c_usig_nof_regs: INTEGER := (number_of_gpios - 1) / C_S_AXI_DATA_WIDTH + 1;   -- nof registers for data and direction bits
    CONSTANT c_int_nof_gpio_reg: INTEGER := number_of_gpios / C_S_AXI_DATA_WIDTH;
    
    CONSTANT c_usig_base_clk_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_number_of_std_registers*4,C_S_AXI_ADDR_WIDTH));
    CONSTANT c_usig_dir_regs_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_base_clk_address) + 4); 
    CONSTANT c_usig_value_regs_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_dir_regs_address) + c_usig_nof_regs * 4);
    CONSTANT c_usig_debounce_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_value_regs_address) + c_usig_nof_regs * 4); 
    CONSTANT c_usig_max_address : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 DOWNTO 0) := STD_LOGIC_VECTOR(unsigned(c_usig_debounce_address) + number_of_gpios * 4); 

    CONSTANT id : STD_LOGIC_VECTOR(15 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(c_fLink_digital_io_id,16));
    CONSTANT subtype_id : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0'); 
    CONSTANT interface_version : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');

    TYPE t_debouncing_counter IS ARRAY(number_of_gpios-1 DOWNTO 0) OF STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 DOWNTO 0);
     
    TYPE t_internal_register IS RECORD
                 conf_reg     : STD_LOGIC_VECTOR(0 DOWNTO 0);
                 dir_reg      : STD_LOGIC_VECTOR(127 DOWNTO 0);
                 value_reg    : STD_LOGIC_VECTOR(127 DOWNTO 0);
                 irq_debounce : t_debouncing_counter;
    END RECORD;
    CONSTANT INTERNAL_REG_RESET : t_internal_register := (
                                   conf_reg=> (OTHERS=>'0'),
                                   dir_reg=> (OTHERS=>'0'),
                                   value_reg=> (OTHERS=>'0'),
                                   irq_debounce=> (OTHERS=>(OTHERS=>'0'))
                                   );
    SIGNAL ri,ri_next : t_internal_register := INTERNAL_REG_RESET;
     
    SIGNAL rst_modul : STD_LOGIC;
    ------------------------------------------------
    ---- Signals for user logic memory space example
    --------------------------------------------------
    signal mem_address : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    signal mem_select : std_logic_vector(USER_NUM_MEM-1 downto 0);
    type word_array is array (0 to USER_NUM_MEM-1) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal mem_data_out : word_array;

    signal i : integer;
    signal j : integer;
    signal mem_byte_index : integer;
    type BYTE_RAM_TYPE is array (0 to 15) of std_logic_vector(7 downto 0);
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
       VARIABLE reg_nr: INTEGER := 0;
    begin
      if (axi_rvalid = '1') then
        -- output the read dada 
        IF(axi_araddr = c_usig_typdef_address) THEN
           axi_rdata(31 DOWNTO 16) <= id;
           axi_rdata(15 DOWNTO 8) <= subtype_id;
           axi_rdata(7 DOWNTO 0) <= interface_version;
        ELSIF(axi_araddr = c_usig_mem_size_address)THEN
           axi_rdata <= (others => '0');
           axi_rdata(C_S_AXI_ADDR_WIDTH) <= '1';
        ELSIF(axi_araddr = c_number_of_channels_address)THEN
           axi_rdata <= std_logic_vector(to_unsigned(number_of_gpios, axi_rdata'length));
        ELSIF(axi_araddr = c_usig_unique_id_address) THEN
            axi_rdata <= unique_id;
        ELSIF(axi_araddr = c_configuration_reg_address) THEN
            axi_rdata <= (others => '0');
            axi_rdata(c_fLink_reset_bit_num) <= ri.conf_reg(c_fLink_reset_bit_num);
        
        ELSIF(axi_araddr = c_usig_base_clk_address) THEN
            axi_rdata <= STD_LOGIC_VECTOR(to_unsigned(base_clk, axi_rdata'length));   
        ELSIF axi_araddr >= c_usig_dir_regs_address AND axi_araddr < c_usig_value_regs_address THEN
            reg_nr := to_integer(unsigned(axi_araddr) - unsigned(c_usig_dir_regs_address)) / 4;
            IF reg_nr < c_int_nof_gpio_reg THEN
                axi_rdata <= ri.dir_reg((reg_nr + 1) * C_S_AXI_DATA_WIDTH - 1 DOWNTO reg_nr * C_S_AXI_DATA_WIDTH);
            ELSE
                axi_rdata <= (OTHERS => '0');
                FOR i IN 0 TO (number_of_gpios mod C_S_AXI_DATA_WIDTH) - 1 LOOP
                    axi_rdata(i) <= ri.dir_reg(i + reg_nr * C_S_AXI_DATA_WIDTH);
                END LOOP;
            END IF;
        ELSIF axi_araddr >= c_usig_value_regs_address AND axi_araddr < c_usig_debounce_address THEN
            reg_nr := to_integer(unsigned(axi_araddr) - unsigned(c_usig_value_regs_address)) / 4;
            IF reg_nr < c_int_nof_gpio_reg THEN
                axi_rdata <= ri.value_reg((reg_nr + 1) * C_S_AXI_DATA_WIDTH - 1 DOWNTO reg_nr * C_S_AXI_DATA_WIDTH);
            ELSE
                axi_rdata <= (OTHERS => '0');
                FOR i IN 0 TO (number_of_gpios mod C_S_AXI_DATA_WIDTH) - 1 LOOP
                    axi_rdata(i) <= ri.value_reg(i + reg_nr * C_S_AXI_DATA_WIDTH);
                END LOOP;
            END IF;
        ELSIF axi_araddr >= c_usig_debounce_address AND axi_araddr < c_usig_max_address THEn
            reg_nr := to_integer(unsigned(axi_araddr) - unsigned(c_usig_debounce_address)) / 4;
            axi_rdata <= ri.irq_debounce(reg_nr);
        ELSE
          axi_rdata <= (others => '0');
        END IF;
      else
        axi_rdata <= (others => '0');
      end if;  
    end process;
    
    process( axi_wready,S_AXI_WVALID,S_AXI_WDATA,axi_awaddr,S_AXI_WSTRB,ri,S_AXI_ARESETN,slv_gpios_io_i)  
       VARIABLE vi: t_internal_register := INTERNAL_REG_RESET;
       VARIABLE reg_nr: INTEGER := 0;
    BEGIN
       vi := ri;
       IF(axi_wready = '1') THEN
          -- Write to config register
          IF axi_awaddr = c_configuration_reg_address THEN
              vi.conf_reg(0) := S_AXI_WDATA(0);
          -- Write to direction registers
          ELSIF axi_awaddr >= c_usig_dir_regs_address AND axi_awaddr < c_usig_value_regs_address THEN
               reg_nr := to_integer(unsigned(axi_awaddr) - unsigned(c_usig_dir_regs_address)) / 4;
               FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                   IF S_AXI_WSTRB(i) = '1' THEN
                       vi.dir_reg(reg_nr * C_S_AXI_DATA_WIDTH + (i + 1) * 8 - 1 DOWNTO reg_nr * C_S_AXI_DATA_WIDTH + i * 8) := S_AXI_WDATA((i + 1) * 8 - 1 DOWNTO i * 8);
                   END IF;
               END LOOP;
           -- Write to value registers
           ELSIF axi_awaddr >= c_usig_value_regs_address AND axi_awaddr < c_usig_debounce_address THEN
               reg_nr := to_integer(unsigned(axi_awaddr) - unsigned(c_usig_value_regs_address)) / 4;
               FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                   IF S_AXI_WSTRB(i) = '1' THEN
                       vi.value_reg(reg_nr * C_S_AXI_DATA_WIDTH + (i + 1) * 8 - 1 DOWNTO reg_nr * C_S_AXI_DATA_WIDTH + i * 8) := S_AXI_WDATA((i + 1) * 8 - 1 DOWNTO i * 8);
                   END IF;
               END LOOP;
            ELSIF axi_awaddr >= c_usig_debounce_address AND axi_awaddr< c_usig_max_address THEN
               reg_nr := to_integer(unsigned(axi_awaddr) - unsigned(c_usig_debounce_address)) / 4;
               FOR i IN 0 TO C_S_AXI_DATA_WIDTH / 8 - 1 LOOP
                   IF S_AXI_WSTRB(i) = '1' THEN
                       vi.irq_debounce(reg_nr)((i+1)*8-1 DOWNTO i*8) := S_AXI_WDATA((i+1)*8-1 DOWNTO i*8);
                   END IF;
               END LOOP;
           END IF;
       END IF;
       
       FOR i IN 0 TO number_of_gpios - 1 LOOP
           IF ri.dir_reg(i) = '1' THEN -- output
               slv_gpios_io_t(i) <= '0';                --  Vermuting: IO Tri-State Control is active low
               slv_gpios_io_o(i) <= ri.value_reg(i);
           ELSE -- input
               slv_gpios_io_t(i) <= '1';                --  Vermuting: IO Tri-State Control is active low
               vi.value_reg(i) := slv_gpios_io_i(i);
           END IF;
       END LOOP;
      
        IF S_AXI_ARESETN = '0' OR  vi.conf_reg(c_fLink_reset_bit_num) = '1' THEN
            vi.conf_reg := (OTHERS =>'0');
            vi.value_reg := (OTHERS =>'0');
            vi.dir_reg := (OTHERS =>'0');
            rst_modul <= '1';
        ELSE
            rst_modul <= '0';
       END IF;

       ri_next <= vi;
       
    END PROCESS;
    
    -- Add user logic here

    --create component
    gen_irqs : FOR i IN 0 TO number_of_gpios-1 GENERATE
        gen_irq : irq_generator 
        GENERIC MAP(
            i_bus_width => C_S_AXI_DATA_WIDTH
        )
        PORT MAP( 
            isl_clk              => S_AXI_ACLK,
            isl_rst              => rst_modul,
            islv_irq_debounce    => ri.irq_debounce(i),
            isl_direction        => ri.dir_reg(i),
            isl_value            => slv_gpios_io_i(i),
            osl_irq_rising_edge  => oslv_interrupts_rising(i),
            osl_irq_falling_edge => oslv_interrupts_falling(i)
        );
    END GENERATE gen_irqs;
    

    reg_proc : PROCESS (S_AXI_ACLK)
    BEGIN
        IF rising_edge(S_AXI_ACLK) THEN
            ri <= ri_next;
        END IF;
    END PROCESS reg_proc;

    -- User logic ends

end arch_imp;
