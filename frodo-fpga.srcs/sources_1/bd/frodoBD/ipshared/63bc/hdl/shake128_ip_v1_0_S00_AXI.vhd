library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity shake128_ip_v1_0_S00_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 15;
		-- Request address length
		REQ_BITS_LEN        : integer   := 13
	);
	port (
		-- Users to add ports here
		start           : in std_logic;
		inlen           : in std_logic_vector(REQ_BITS_LEN+1 downto 0);
		outlen          : in std_logic_vector(REQ_BITS_LEN+1 downto 0);
        ready           : out std_logic;	
        valid_req       : in std_logic;
        valid_out       : out std_logic;
        m               : out std_logic_vector(64-1 downto 0); 
        last_block      : out std_logic;
        valid_in        : in std_logic;
        cipher          : in std_logic_vector(64-1 downto 0); 
        busy            : out std_logic;
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
end shake128_ip_v1_0_S00_AXI;

architecture arch_imp of shake128_ip_v1_0_S00_AXI is

    -- Constant
    constant MEM_SIZE       : integer := 2583; -- 168 * 123
	constant WORD_SIZE      : integer := 64;    
	constant N_MEMORIES     : integer := 1;  

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32) + 1;
	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH - 3;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	constant constant_80   : std_logic_vector(64-1 downto 0) := x"8000000000000000";
	
	signal aw_en	       : std_logic;
		
	signal s_m             : std_logic_vector(64-1 downto 0);
	
    signal s_di            : std_logic_vector(64-1 downto 0);
    signal s_data_mem      : std_logic_vector(64-1 downto 0);    
    signal addr_ram        : std_logic_vector(REQ_BITS_LEN-2 downto 0);     
    signal s_we            : std_logic;
    
    type st_type is (cleaning_memory, wait_start, receiving_data, reg_inlen, processing, pre_waiting_to_send, waiting_to_send, shake_done);
	signal st : st_type;
	
	signal count_data          : unsigned(REQ_BITS_LEN-1 downto 0); 
	
	signal s_addr_counter      : unsigned(REQ_BITS_LEN-2 downto 0);
	signal s_addr_read         : unsigned(REQ_BITS_LEN-2 downto 0); 
	signal s_addr_general      : unsigned(REQ_BITS_LEN-2 downto 0);	
		
	signal s_valid_out         : std_logic;
	signal s_valid_out_reg     : std_logic;
	
	signal s_valid_req_lock    : std_logic;
		
	signal sub_signal          : unsigned(REQ_BITS_LEN+1 downto 0);
	
	signal upper_word          : std_logic;
	signal reg_data_in         : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	
	signal s_inlen             : unsigned(REQ_BITS_LEN+1 downto 0);
	
	signal cmp                 : std_logic;
	
	signal constant_1f         : std_logic_vector(64-1 downto 0);
	
	signal s_last_block        : std_logic;
		
	signal n_bytes_out         : unsigned(REQ_BITS_LEN+1 downto 0);
    signal sub                 : unsigned(REQ_BITS_LEN+1 downto 0); 
    signal mask                : std_logic_vector(64-1 downto 0); 
    
	component true_single_bram3 is
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
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	last_block      <= s_last_block;
	valid_out       <= s_valid_out_reg;
	m               <= s_m xor constant_1f when s_inlen < 8 else s_m;
	busy            <= '1' when st = cleaning_memory else '0';
	
	constant_1f <= x"000000000000001f" when s_inlen(2 downto 0) = "000" else
                   x"0000000000001f00" when s_inlen(2 downto 0) = "001" else
                   x"00000000001f0000" when s_inlen(2 downto 0) = "010" else
                   x"000000001f000000" when s_inlen(2 downto 0) = "011" else
                   x"0000001f00000000" when s_inlen(2 downto 0) = "100" else
                   x"00001f0000000000" when s_inlen(2 downto 0) = "101" else
                   x"001f000000000000" when s_inlen(2 downto 0) = "110" else
                   x"1f00000000000000";
                   
    sub <= (unsigned(outlen) - n_bytes_out);
    mask <= x"00000000000000ff" when (sub = 1) else
            x"000000000000ffff" when (sub = 2) else
            x"0000000000ffffff" when (sub = 3) else
            x"00000000ffffffff" when (sub = 4) else
            x"000000ffffffffff" when (sub = 5) else
            x"0000ffffffffffff" when (sub = 6) else
            x"00ffffffffffffff" when (sub = 7) else
            x"ffffffffffffffff";
	
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
    
    -- upper_word
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                upper_word <= '0';
            else                
                if(axi_bvalid = '1' or axi_rvalid = '1') then
                    upper_word <= upper_word xor '1';
                elsif(st = cleaning_memory or st = processing) then
                    upper_word <= '0';
                end if;                    
            end if;
        end if;
    end process;
    
    -- reg_data_in
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if(axi_bvalid = '1' and upper_word = '0') then
                reg_data_in <= S_AXI_WDATA;
            end if;  
        end if;
    end process;
    
    -- Counter memory
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                s_addr_general <= (others => '0');
            else                
                if(st = cleaning_memory) then
					if(s_addr_general <= MEM_SIZE - 2) then
						s_addr_general <= s_addr_general + 1;
					else
						s_addr_general <= (others => '0');
					end if;     
                elsif(st = receiving_data) then
                    if(upper_word = '1' and axi_bvalid = '1') then
                        s_addr_general <= s_addr_general + 1;
                    end if;   
                elsif(st = processing) then                
                    if(valid_in = '1') then
                        s_addr_general <= s_addr_general + 1;
                    end if;
                elsif(st = waiting_to_send) then
                    if(axi_rvalid = '1' and upper_word = '1') then
                        s_addr_general <= s_addr_general + 1;
                    end if;
                else
                    s_addr_general <= (others => '0');
                end if;
            end if;
        end if;
    end process;  
    
    -- Lock sending data
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                s_valid_req_lock <= '0';
            else                
                if(valid_req = '1') then
                    s_valid_req_lock <= '1';
                elsif(s_addr_counter = 21-1) then
                    s_valid_req_lock <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- s_addr_counter
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                s_addr_counter <= (others => '0');
            else                
                if(s_valid_req_lock = '1') then
                    s_addr_counter <= s_addr_counter + 1;
                else
                    s_addr_counter <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
    -- s_addr_read
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                s_addr_read <= (others => '0');
            else                
                if(start = '0') then
                    s_addr_read <= (others => '0');
                else
                    if(s_valid_req_lock = '1') then
                        s_addr_read <= s_addr_read + 1;
                    else
                        s_addr_read <= s_addr_read;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- Valid out
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                s_valid_out <= '0';
                s_valid_out_reg <= '0';
            else               
                s_valid_out <= s_valid_req_lock;
                s_valid_out_reg <= s_valid_out;
            end if;
        end if;
    end process;
    
    -- s_inlen
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if(st = wait_start) then
                s_inlen <= (others => '0');
            else
                if(axi_bvalid = '1') then
                    s_inlen <= s_inlen + 4; -- 4 bytes   
                elsif(st = reg_inlen) then
                    s_inlen <= unsigned(inlen);
                elsif(s_valid_out_reg = '1') then
                    s_inlen <= s_inlen - 8; -- 8 bytes
                end if;
            end if;
        end if;
    end process;
    
    -- last_block
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if(s_inlen < 168 and valid_req = '1') then
                s_last_block <= '1';
            elsif(st /= processing) then
                s_last_block <= '0';
            end if;
        end if;
    end process;   
    
    -- Register data 
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if(s_last_block = '1' and s_addr_counter = 21) then
                s_m <= s_data_mem xor constant_80; 
            else
                s_m <= s_data_mem;
            end if;
        end if;
    end process;
    
    -- State
    sub_signal <= (others => '0') when inlen(1) = '1' or inlen(0) = '1' else (0 => '1', others => '0');
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                st <= cleaning_memory;
            else   
                case (st) is
                    when cleaning_memory =>
                        if(s_addr_general = MEM_SIZE - 1) then
                            st <= wait_start;
                        end if;                       
                    
                    when wait_start => 
                        if(start = '1') then
                            st <= receiving_data;
                        end if;
                            
                    when receiving_data => 
                        if(count_data = unsigned(inlen(REQ_BITS_LEN+1 downto 2)) - sub_signal and axi_bvalid = '1') then
                            st <= reg_inlen;
                        end if;
                        
                    when reg_inlen => 
                        st <= processing;
                        
                    when processing =>
                        if(n_bytes_out >= unsigned(outlen) and valid_in = '0') then
                            st <= pre_waiting_to_send;
                        end if; 
                        
                    when pre_waiting_to_send =>
                        st <= waiting_to_send;
                    
                    when waiting_to_send =>
                        if(start = '0') then
                            st <= shake_done;
                        end if;
                        
                    when shake_done => 
                        st <= cleaning_memory;
                        
                end case;
            end if;
        end if;
    end process;
    
    -- Counter receive data
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                count_data <= (others => '0');
            else              
                if(axi_bvalid = '1') then
                    count_data <= count_data + 1;
                elsif(start = '0') then
                    count_data <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
    -- Ready
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                ready <= '0';
            else              
                if(st = processing) then
                    ready <= '1';
                else
                    ready <= '0';
                end if;
            end if;
        end if;
    end process;
            
    -- axi_rdata
    process( S_AXI_ACLK )
    begin
        if(rising_edge( S_AXI_ACLK )) then
            if ( S_AXI_ARESETN = '0' ) then
                axi_rdata <= (others => '0');
            else            
                if(upper_word = '0') then
                    axi_rdata <= s_data_mem(31 downto 0);
                else
                    axi_rdata <= s_data_mem(63 downto 32);
                end if;                  
            end if;
        end if;
    end process;

    n_bytes_out <= s_addr_general & "000";
    
    addr_ram <= std_logic_vector(s_addr_general) when st = cleaning_memory or st = receiving_data or valid_in = '1' or st = waiting_to_send else
                std_logic_vector(s_addr_read);  
      
    cmp <= '1' when s_inlen + 4 >= unsigned(inlen) else '0';
    s_we <= '1' when st = cleaning_memory or ((axi_bvalid = '1' and upper_word = '1') or (axi_bvalid = '1' and upper_word = '0' and cmp = '1')) or (valid_in = '1' and n_bytes_out < unsigned(outlen) and st = processing) else '0';
                    
    s_di <= (others => '0') when st = cleaning_memory else
            S_AXI_WDATA & reg_data_in when axi_bvalid = '1' and upper_word = '1' else
            x"00000000" & S_AXI_WDATA when axi_bvalid = '1' and upper_word = '0' and cmp = '1' else
            cipher and mask;
                
    true_single_bram3_s01_inst : true_single_bram3
    generic map(
        MEM_SIZE  => MEM_SIZE,
        WORD_SIZE => WORD_SIZE
    )            
    port map(      
        clk       => S_AXI_ACLK,
        en        => '1',
        we        => s_we,
        addr      => addr_ram,
        di        => s_di,
        do        => s_data_mem
    );

end arch_imp;
