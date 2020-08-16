library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity matrix_as_plus_e_mm_ip_v1_0_S02_AXI is
	generic (
		-- Users to add parameters here
        
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 15;
		-- Request address length
		REQ_BITS_LEN        : integer   := 11
	);
	port (
		-- Users to add ports here
		start           : in std_logic;
        data_0          : in std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        data_1          : in std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        data_2          : in std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        data_3          : in std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        valid_data      : in std_logic;
        req_addr        : in unsigned(REQ_BITS_LEN-1 downto 0); 
        eop             : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end matrix_as_plus_e_mm_ip_v1_0_S02_AXI;

architecture arch_imp of matrix_as_plus_e_mm_ip_v1_0_S02_AXI is

    constant MEM_SIZE        : integer := 1280;
    constant WORD_SIZE       : integer := 16;
    constant N_MEMORIES      : integer := 4;  
    
	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(WORD_SIZE-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;
    
	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 1;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------	
	signal aw_en	       : std_logic;
    signal slv_reg_rden	   : std_logic;

    signal addr_ram        : std_logic_vector(REQ_BITS_LEN-1 downto 0); 
    signal s_en            : std_logic_vector(N_MEMORIES-1 downto 0);
    signal s_en_reg        : std_logic_vector(N_MEMORIES-1 downto 0);
    signal en              : std_logic_vector(N_MEMORIES-1 downto 0);
    
    type type_data_mem is array (N_MEMORIES-1 downto 0) of std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
    signal s_data_mem      : type_data_mem;
    
    type type_data_in is array (3 downto 0) of std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
    signal data : type_data_in;
    
    signal s_addr_ram      : std_logic_vector(REQ_BITS_LEN-1 downto 0); 
    signal s_idx           : integer := 0;
    
    signal s_eop           : std_logic;
    
    component true_single_bram2 is
        generic(
            MEM_SIZE    : integer;
            WORD_SIZE   : integer
        );
        port(
            clk    : in std_logic;
            en     : in std_logic;
            we     : in std_logic;
            addr   : in std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);
            di     : in std_logic_vector(WORD_SIZE-1 downto 0);
            do     : out std_logic_vector(WORD_SIZE-1 downto 0)
        );
    end component;
    
begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	
	data(0) <= data_0;
	data(1) <= data_1;
	data(2) <= data_2;
	data(3) <= data_3;
	
	s_idx <= 0 when s_en_reg = "0001" else
             1 when s_en_reg = "0010" else
             2 when s_en_reg = "0100" else
             3;
             
     eop <= s_eop;
	
--	s_axi_araddr_mod <= S_AXI_ARADDR(3 downto 2);
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	           axi_awready <= '1';
	           aw_en <= '0';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	           aw_en <= '1';
	           axi_awready <= '0';
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
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
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
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
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
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
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
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

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
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);	
	    
    -- Enable read memory process
    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                s_en <= (0 => '1', others => '0');
                s_en_reg <= (others => '0');
            else    
                s_en_reg <= s_en;
                if(start = '0') then
                    s_en <= (0 => '1', others => '0');
                elsif(s_addr_ram(2 downto 0) = "111") then -- last three bits equal to "111" -> mod 8
                    s_en <= s_en(N_MEMORIES-2 downto 0) & s_en(N_MEMORIES-1);
                end if;
            end if;
        end if;
    end process;
    
    -- Enable read memory process
    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                s_addr_ram <= (others => '0');
            else    
                if(start = '0') then
                    s_addr_ram <= (others => '0');
                elsif(s_axi_arvalid = '1') then
                    if(en /= "1000" and s_addr_ram(2 downto 0) = "111") then
                        s_addr_ram <= s_addr_ram - 7;
                    else
                        if(s_addr_ram = x"4ff") then -- 1279
                            s_addr_ram <= (others => '0');
                        else
                            s_addr_ram <= s_addr_ram + 1;
                        end if;
                    end if;
                else
                    s_addr_ram <= s_addr_ram;
                end if;
            end if;
        end if;
    end process;
    
    -- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	   if (rising_edge (S_AXI_ACLK)) then
	       if ( S_AXI_ARESETN = '0' ) then
	           axi_rdata  <= (others => '0');
	       else
                if (slv_reg_rden = '1') then
                    -- When there is a valid read address (S_AXI_ARVALID) with 
                    -- acceptance of read address by the slave (axi_arready), 
                    -- output the read dada 
                    -- Read address mux
                    --	          axi_rdata <= slv_reg_read(loc_addr);
                    
                    axi_rdata(WORD_SIZE - 1 downto 0) <= s_data_mem(s_idx);              
                end if;   
            end if;
        end if;
    end process;
    
    -- EOP
	process( S_AXI_ACLK ) is
	begin
	   if (rising_edge (S_AXI_ACLK)) then
	       if ( S_AXI_ARESETN = '0' ) then
	           s_eop  <= '0';
	       else
	           if(s_axi_araddr = x"27fc" AND axi_rvalid = '1') then
	               s_eop  <= '1';
	           else
	               s_eop  <= '0';
	           end if;
	       end if;
       end if;
   end process;

--    addr_ram <= std_logic_vector(req_addr) when valid_data = '1' else
--                (s_axi_araddr_mod & '0') when s_axi_arvalid = '1' and axi_arready = '0' else
--                (s_axi_araddr_mod & '1');
--    addr_ram <= std_logic_vector(req_addr);
    addr_ram <= std_logic_vector(req_addr) when valid_data = '1' else s_addr_ram;
    
    en <= "1111" when valid_data = '1' else s_en;    
    
    S_AXI_RDATA <= axi_rdata & s_data_mem(s_idx);  
    
	generate_ram : for i in 0 to (N_MEMORIES - 1) generate
        true_single_bram2_s01_inst : true_single_bram2
        generic map(
            MEM_SIZE  => MEM_SIZE,
            WORD_SIZE => WORD_SIZE
        )            
        port map(      
            clk       => S_AXI_ACLK,
            en        => en(i),
            we        => valid_data,
            addr      => addr_ram,
            di        => data(i),
            do        => s_data_mem(i)
        );
    end generate;
end arch_imp;
