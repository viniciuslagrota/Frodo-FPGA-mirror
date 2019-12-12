library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak_f1600_ip_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_AXI_PACKET_SIZE       : integer;
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		data_o : out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		valid_o : out std_logic;
		empty_o : out std_logic;
		ready_i : in std_logic;	
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end keccak_f1600_ip_v1_0_S00_AXIS;

architecture arch_imp of keccak_f1600_ip_v1_0_S00_AXIS is
	
	-- Total number of input data.
	constant NUMBER_OF_INPUT_WORDS  : integer := C_AXI_PACKET_SIZE; -- Must be the exactly size of the packege.	
	         
	-- Signal ready                
	signal axis_tready	: std_logic;
	-- FIFO write enable
	signal fifo_wren : std_logic;
	-- FIFO write enable
	signal fifo_rden : std_logic;	
	-- FIFO write done
	signal fifo_wr_done : std_logic;
	-- FIFO write pointer
    signal write_pointer : integer range 0 to NUMBER_OF_INPUT_WORDS;
	-- FIFO type
	type BYTE_FIFO_TYPE is array (0 to (NUMBER_OF_INPUT_WORDS-1)) of std_logic_vector(((C_S_AXIS_TDATA_WIDTH)-1)downto 0);
	-- FIFO signal
    signal stream_data_fifo : BYTE_FIFO_TYPE;

begin
        
    -- Ready signal
    axis_tready <= '0' when fifo_wr_done = '1' else '1';
    -- FIFO write enable
    fifo_wren <= '1' when S_AXIS_TVALID = '1' and axis_tready = '1' else '0';
    -- FIFO read enable
    fifo_rden <= '1' when fifo_wr_done = '1' and ready_i = '1' and write_pointer /= 0 else '0';
    -- FIFO is empty output signal
    empty_o <= '1' when write_pointer = 0 and fifo_wr_done = '0' else '0';
    -- Ready output signal
    S_AXIS_TREADY <= axis_tready;
    
    -- FIFO data manage
	process(S_AXIS_ACLK)
	begin
	   if(rising_edge(S_AXIS_ACLK)) then
	       if(S_AXIS_ARESETN = '0') then
	           write_pointer <= 0;
	       else
	           if(fifo_wren = '1') then -- write data
	               write_pointer <= write_pointer + 1;
	               stream_data_fifo(write_pointer) <= S_AXIS_TDATA;	               
               elsif(fifo_rden = '1') then -- read data	    
                    write_pointer <= write_pointer - 1;           
                    for j in 1 to NUMBER_OF_INPUT_WORDS-1 loop
                        stream_data_fifo(j-1) <= stream_data_fifo(j);                       
                    end loop;
                    stream_data_fifo(NUMBER_OF_INPUT_WORDS-1) <= (others => 'U');
               else
                    write_pointer <= write_pointer;    
	           end if;
	       end if;
	   end if;
	end process;
	
	-- FIFO write done control
	process(S_AXIS_ACLK)
	begin	
        if(rising_edge(S_AXIS_ACLK)) then
            if(S_AXIS_ARESETN = '0') then
                fifo_wr_done <= '0';
            else
                if(write_pointer = NUMBER_OF_INPUT_WORDS-1 and fifo_wren = '1') then
                    fifo_wr_done <= '1';
                elsif(write_pointer = 0) then
                    fifo_wr_done <= '0';
                else
                    fifo_wr_done <= fifo_wr_done;
                end if;
            end if;
        end if;
	end process;
	
	-- Output data
	process(S_AXIS_ACLK)
	begin
	   if(rising_edge(S_AXIS_ACLK)) then
	       if(S_AXIS_ARESETN = '0') then	       
	       else	           
	           if(fifo_rden = '1') then
	               data_o <= stream_data_fifo(0);
	               valid_o <= '1';
               else
                   data_o <= (others => '0');
	               valid_o <= '0';
	           end if;
	       end if;
	   end if;
	end process;	

-- Stream mode --
--architecture arch_imp of aes_axi_crypto_ip_v1_0_S00_AXIS is

--	-- Total number of input data.
--	constant NUMBER_OF_INPUT_WORDS  : integer := 8;
	         
--	-- Signal ready                
--	signal axis_tready	: std_logic;
--	-- FIFO write enable
--	signal fifo_wren : std_logic;
--	-- FIFO write enable
--	signal fifo_rden : std_logic;	
--	-- FIFO write pointer
--    signal write_pointer : integer range 0 to NUMBER_OF_INPUT_WORDS;
--	-- FIFO type
--	type BYTE_FIFO_TYPE is array (0 to (NUMBER_OF_INPUT_WORDS-1)) of std_logic_vector(((C_S_AXIS_TDATA_WIDTH)-1)downto 0);
--	-- FIFO signal
--    signal stream_data_fifo : BYTE_FIFO_TYPE;

--begin
        
--    -- Ready signal
--    axis_tready <= '0' when write_pointer >= NUMBER_OF_INPUT_WORDS else '1';
--    -- FIFO write enable
--    fifo_wren <= '1' when S_AXIS_TVALID = '1' and axis_tready = '1' else '0';
--    -- FIFO read enable
--    fifo_rden <= '1' when S_AXIS_TVALID = '0' and ready_i = '1' and write_pointer /= 0 else '0';
--    -- FIFO is empty output signal
--    empty_o <= '1' when write_pointer = 0 else '0';
--    -- Ready output signal
--    S_AXIS_TREADY <= axis_tready;
    
--    -- FIFO data manage
--	process(S_AXIS_ACLK)
--	begin
--	   if(rising_edge(S_AXIS_ACLK)) then
--	       if(S_AXIS_ARESETN = '0') then
--	           write_pointer <= 0;
--	       else
--	           if(fifo_wren = '1') then -- write data
--	               write_pointer <= write_pointer + 1;
--	               stream_data_fifo(write_pointer) <= S_AXIS_TDATA;
--               elsif(fifo_rden = '1') then -- read data	    
--                    write_pointer <= write_pointer - 1;           
--                    for j in 1 to NUMBER_OF_INPUT_WORDS-1 loop
--                        stream_data_fifo(j-1) <= stream_data_fifo(j);                       
--                    end loop;
--                    stream_data_fifo(NUMBER_OF_INPUT_WORDS-1) <= (others => 'U');
--               else
--                    write_pointer <= write_pointer;    
--	           end if;
--	       end if;
--	   end if;
--	end process;	
	
--	-- Output data
--	process(S_AXIS_ACLK)
--	begin
--	   if(rising_edge(S_AXIS_ACLK)) then
--	       if(S_AXIS_ARESETN = '0') then	       
--	       else	           
--	           if(fifo_rden = '1') then
--	               data_o <= stream_data_fifo(0);
--	               valid_o <= '1';
--               else
--                   data_o <= (others => '0');
--	               valid_o <= '0';
--	           end if;
--	       end if;
--	   end if;
--	end process;	


end arch_imp;
