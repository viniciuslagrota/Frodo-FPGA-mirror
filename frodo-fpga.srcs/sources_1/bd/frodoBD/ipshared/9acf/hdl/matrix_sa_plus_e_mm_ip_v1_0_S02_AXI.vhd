library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use IEEE.std_logic_unsigned.all;

entity matrix_sa_plus_e_mm_ip_v1_0_S02_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 15
	);
	port (
		-- Users to add ports here
        start           : in std_logic;  
        data_0          : in std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        valid_data      : in std_logic;
        req_addr        : in unsigned(12 downto 0); 
        ready           : out std_logic;
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
end matrix_sa_plus_e_mm_ip_v1_0_S02_AXI;

architecture arch_imp of matrix_sa_plus_e_mm_ip_v1_0_S02_AXI is

    -- Constant
--    constant slv_reg_max     : integer := 8191;
--    constant slv_reg_max     : integer := 2560; 
    constant MEM_SIZE        : integer := 5120;
    constant WORD_SIZE       : integer := 16;
    constant MEM_SIZE_DIV_2  : integer := MEM_SIZE/2;

	-- AXI4LITE signals
	signal axi_awaddr	     : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	     : std_logic;
	signal axi_wready	     : std_logic;
	signal axi_bresp	     : std_logic_vector(1 downto 0);
	signal axi_bvalid	     : std_logic;
	signal axi_araddr	     : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	     : std_logic;
	signal axi_rdata	     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	     : std_logic_vector(1 downto 0);
	signal axi_rvalid	     : std_logic;
	signal start_locked      : std_logic;
	signal valid_vec         : std_logic_vector(1 downto 0);

	signal s_addra           : std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);
	signal s_addra_reg       : std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);
	signal s_addrb           : std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);	
	signal s_addrb_reg       : std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);	
	
	
	signal web_line          : std_logic;
	signal s_web_line        : std_logic;
	
--	type data_line is array (7 downto 0) of std_logic_vector(WORD_SIZE-1 downto 0);
	signal s_dib             : std_logic_vector(WORD_SIZE-1 downto 0); 
	signal s_doa             : std_logic_vector(WORD_SIZE-1 downto 0);
	signal s_dob             : std_logic_vector(WORD_SIZE-1 downto 0);   
	
	signal data              : std_logic_vector(WORD_SIZE-1 downto 0);
	signal data_reg          : std_logic_vector(WORD_SIZE-1 downto 0);
	
	signal s_select_ram      : unsigned(2 downto 0);      
    signal select_ram        : unsigned(2 downto 0); 
    
    signal s_eop             : std_logic;        
	                          
	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32) + 1;
	constant OPT_MEM_ADDR_BITS : integer := 11;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 64
--	type slv_reg_type is array (slv_reg_max downto 0) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--	signal slv_reg_write       : slv_reg_type; -- from ARM to FPGA
--	signal slv_reg_read        : slv_reg_type; -- from FPGA to ARM
	
	signal slv_reg_rden	       : std_logic;
	signal slv_reg_wren	       : std_logic;
	signal reg_data_out	       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	       : integer;
	signal aw_en	           : std_logic;
	
--	signal s_eop        : std_logic; -- detect when package is completely received.
--	signal slv_addr_write      : unsigned(OPT_MEM_ADDR_BITS downto 0);
--	signal slv_addr_read       : unsigned(OPT_MEM_ADDR_BITS downto 0);
	
	signal s_start_reg         : std_logic;
	signal s_start_rising_edge : std_logic;
	
	component true_dual_bram is
    generic(
        MEM_SIZE    : integer;
        WORD_SIZE   : integer
    );
    port(
        clka    : in std_logic;
        clkb    : in std_logic;
        ena     : in std_logic;
        enb     : in std_logic;
        wea     : in std_logic;
        web     : in std_logic;
        addra   : in std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);
        addrb   : in std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);
        dia     : in std_logic_vector(WORD_SIZE-1 downto 0);
        dib     : in std_logic_vector(WORD_SIZE-1 downto 0);
        doa     : out std_logic_vector(WORD_SIZE-1 downto 0);
        dob     : out std_logic_vector(WORD_SIZE-1 downto 0)
    );
    end component true_dual_bram;

begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	    <= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
--	S_AXI_RDATA	    <= axi_rdata;
	S_AXI_RRESP	    <= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
--	eop             <= s_eop;
    s_start_rising_edge <= start and not s_start_reg;    
    data <= data_0;
    
    ready <= not start_locked;
    eop <= s_eop;
    
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

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

--	process (S_AXI_ACLK)
--	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
--	begin
--	  if rising_edge(S_AXI_ACLK) then 
--	    if S_AXI_ARESETN = '0' then
--	       for i in 0 to slv_reg_max loop
--	           slv_reg_write(i) <= (others => '0');
--	       end loop;
--	    else
--	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
--	      if (slv_reg_wren = '1') then
--            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--              if ( S_AXI_WSTRB(byte_index) = '1' ) then
--                -- Respective byte enables are asserted as per write strobes                   
--                -- slave registor 0
--                slv_reg_write(to_integer(unsigned(loc_addr)))(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--              end if;
--            end loop;            	      
--	      end if;
--	    end if;
--	  end if;                   
--	end process; 

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
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

--	process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, slv_reg10, slv_reg11, slv_reg12, slv_reg13, slv_reg14, slv_reg15, slv_reg16, slv_reg17, slv_reg18, slv_reg19, slv_reg20, slv_reg21, slv_reg22, slv_reg23, slv_reg24, slv_reg25, slv_reg26, slv_reg27, slv_reg28, slv_reg29, slv_reg30, slv_reg31, slv_reg32, slv_reg33, slv_reg34, slv_reg35, slv_reg36, slv_reg37, slv_reg38, slv_reg39, slv_reg40, slv_reg41, slv_reg42, slv_reg43, slv_reg44, slv_reg45, slv_reg46, slv_reg47, slv_reg48, slv_reg49, slv_reg50, slv_reg51, slv_reg52, slv_reg53, slv_reg54, slv_reg55, slv_reg56, slv_reg57, slv_reg58, slv_reg59, slv_reg60, slv_reg61, slv_reg62, slv_reg63, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
--    process (slv_reg_write)
--	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
--	begin
--	    -- Address decoding for reading registers
--	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
--	    reg_data_out <= slv_reg_write(to_integer(unsigned(loc_addr)));    	    
--	end process; 	
    
    -- Registered data
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then            
                s_start_reg <= '0';
                start_locked <= '0';
                data_reg <= (others => '0');
                valid_vec <= (others => '0');

                 s_addra_reg <= (others => '0');  
            else
                s_start_reg <= start;
                
                if(conv_integer(s_addrb_reg) = MEM_SIZE-1) then
                    start_locked <= '0';
                elsif(start = '1' and s_start_reg = '0') then
                    start_locked <= '1';
                else
                    start_locked <= start_locked;
                end if;
                
                data_reg <= data;
                
                valid_vec <= valid_vec(0) & valid_data;
                
                 s_addra_reg <= s_addra;
            end if;
        end if;
    end process;    
    
    -- Selector
--    process(S_AXI_ACLK)
--    begin
--        if(rising_edge(S_AXI_ACLK)) then
--            if(S_AXI_ARESETN = '0') then
--                s_select_ram <= (others => '0');
--            else
--                if(valid_data = '1') then
--                    s_select_ram <= (others => '0');
--                elsif(conv_integer(s_addrb) = MEM_SIZE - 1 and slv_reg_rden = '1') then
--                    s_select_ram <= s_select_ram + 1;
--                else
--                    s_select_ram <= s_select_ram;
--                end if;
                
--                select_ram <= s_select_ram;
--            end if;        
--        end if;
--    end process;
    
    -- RAM process
    process(S_AXI_ACLK)
    begin
        if(rising_edge(S_AXI_ACLK)) then
            if(S_AXI_ARESETN = '0') then
--                    s_addrb_reg(i) <= (others => '0');
                s_addrb_reg <= (others => '0');
--                    s_web_line(i) <= '0';       
                s_web_line <= '0';                     
                s_dib <= (others => '0');
            else
                if(start_locked = '1' and conv_integer(s_addrb_reg) < MEM_SIZE-1) then
                    s_addrb_reg <= std_logic_vector(to_unsigned(conv_integer(s_addrb_reg) + 1, s_addrb_reg'length));
                 elsif(valid_vec(1) = '1') then
                    s_addrb_reg <= s_addra_reg;
                else
                    s_addrb_reg <= (others => '0');                                              
                end if;
                
                if(start_locked = '1' and conv_integer(s_addrb_reg) < MEM_SIZE-1) then
                    s_dib <= (others => '0');
                elsif(valid_vec(0) = '1') then
                    s_dib <= std_logic_vector(to_unsigned(conv_integer(s_doa) + conv_integer(data_reg), s_dib'length));
                    s_web_line <= '1';  
                else
                    s_dib <= (others => '0');
                    s_web_line <= '0';   
                end if;
            end if;        
        end if;
    end process;
    
    s_addra <= std_logic_vector(req_addr);
    
    web_line <= s_web_line or start_locked;
    
    s_addrb <= std_logic_vector(to_unsigned(conv_integer(S_AXI_ARADDR(13 downto 2)) mod MEM_SIZE_DIV_2, s_addrb'length - 1)) & '0' when S_AXI_ARVALID = '1' and axi_arready = '0' else
               std_logic_vector(to_unsigned(conv_integer(S_AXI_ARADDR(13 downto 2)) mod MEM_SIZE_DIV_2, s_addrb'length - 1)) & '1' when S_AXI_ARVALID = '1' and axi_arready = '1' else
               s_addrb_reg;
                  
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
                    
                    axi_rdata(WORD_SIZE - 1 downto 0) <= s_dob;              
                end if;   
            end if;
        end if;
    end process;
    
    process( S_AXI_ACLK ) is
	begin
	   if (rising_edge (S_AXI_ACLK)) then
	       if ( S_AXI_ARESETN = '0' ) then
	           s_eop  <= '0';
	       else
	           if(s_addrb = x"13ff" and slv_reg_rden = '1') then
	               s_eop  <= '1';   
	           else
	               s_eop  <= '0';
	           end if;
	       end if;
       end if;
   end process;
    
    S_AXI_RDATA <= axi_rdata(WORD_SIZE - 1 downto 0) & s_dob(WORD_SIZE - 1 downto 0);
    
    -- Block ram
    true_dual_bram_line_inst : true_dual_bram
    generic map(
        MEM_SIZE => MEM_SIZE,
        WORD_SIZE => WORD_SIZE        
    )
    port map (        
        clka    => S_AXI_ACLK, 
        clkb    => S_AXI_ACLK,
        ena     => '1',
        enb     => '1',
        wea     => '0',
        web     => web_line,
        addra   => s_addra,
        addrb   => s_addrb,
        dia     => x"0000",
        dib     => s_dib,
        doa     => s_doa,
        dob     => s_dob       
    );

end arch_imp;
