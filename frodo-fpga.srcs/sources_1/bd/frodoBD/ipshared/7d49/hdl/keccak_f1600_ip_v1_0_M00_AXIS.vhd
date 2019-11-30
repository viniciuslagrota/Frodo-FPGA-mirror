library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak_f1600_ip_v1_0_M00_AXIS is
	generic (
		-- Users to add parameters here
		C_AXI_PACKET_SIZE       : integer;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		valid_i : in std_logic;
        data_i : in std_logic_vector (C_M_AXIS_TDATA_WIDTH-1 downto 0);
        ready_o : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end keccak_f1600_ip_v1_0_M00_AXIS;

architecture implementation of keccak_f1600_ip_v1_0_M00_AXIS is
	
	-- Total number of output data                                              
	constant NUMBER_OF_OUTPUT_WORDS : integer := C_AXI_PACKET_SIZE;  
	     
     -- FIFO write done
	signal fifo_wr_done : std_logic;
	-- Example design FIFO read pointer                                               
	signal write_pointer : integer range 0 to NUMBER_OF_OUTPUT_WORDS; 
	-- FIFO write enable
	signal fifo_wren : std_logic;
	-- FIFO write enable
	signal fifo_rden : std_logic;
	--streaming data valid
	signal axis_tvalid	: std_logic;
	--Last of the streaming data 
	--signal axis_tlast	: std_logic;
	-- FIFO type
	type BYTE_FIFO_TYPE is array (0 to (NUMBER_OF_OUTPUT_WORDS-1)) of std_logic_vector(((C_M_AXIS_TDATA_WIDTH)-1)downto 0);
	-- FIFO signal
    signal stream_data_fifo : BYTE_FIFO_TYPE;

begin

    -- TVALID signal
    M_AXIS_TVALID <= axis_tvalid;
	-- TLAST signal
	M_AXIS_TLAST <= '1' when write_pointer = 0 and axis_tvalid = '1' else '0';
	-- TSTRB signal
	M_AXIS_TSTRB <= (others => '1');
	
	-- Ready signal
    ready_o <= '0' when fifo_wr_done = '1' else '1';
    -- FIFO write enable
    fifo_wren <= '1' when valid_i = '1' else '0';
    -- FIFO read enable
    fifo_rden <= '1' when fifo_wr_done = '1' and M_AXIS_TREADY = '1' and write_pointer /= 0 else '0';    
	
	-- FIFO data manage     
	process(M_AXIS_ACLK)
	begin
	   if(rising_edge(M_AXIS_ACLK)) then
	       if(M_AXIS_ARESETN = '0') then
	           write_pointer <= 0;
	       else
	           if(fifo_wren = '1') then -- write data
	               write_pointer <= write_pointer + 1;
	               stream_data_fifo(write_pointer) <= data_i;	               
               elsif(fifo_rden = '1') then -- read data	    
                    write_pointer <= write_pointer - 1;           
                    for j in 1 to NUMBER_OF_OUTPUT_WORDS-1 loop
                        stream_data_fifo(j-1) <= stream_data_fifo(j);                       
                    end loop;
                    stream_data_fifo(NUMBER_OF_OUTPUT_WORDS-1) <= (others => 'U');
               else
                    write_pointer <= write_pointer;    
	           end if;
	       end if;
	   end if;
	end process; 
	
	-- FIFO write done control
	process(M_AXIS_ACLK)
	begin	
        if(rising_edge(M_AXIS_ACLK)) then
            if(M_AXIS_ARESETN = '0') then
                fifo_wr_done <= '0';
            else
                if(write_pointer = NUMBER_OF_OUTPUT_WORDS-1 and fifo_wren = '1') then
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
	process(M_AXIS_ACLK)
	begin
	   if(rising_edge(M_AXIS_ACLK)) then
	       if(M_AXIS_ARESETN = '0') then	
	           axis_tvalid <= '0';       
	       else	           
	           if(fifo_rden = '1') then
	               M_AXIS_TDATA <= stream_data_fifo(0);
	               axis_tvalid <= '1';
               else
                   M_AXIS_TDATA <= (others => '0');
	               axis_tvalid <= '0';
	           end if;
	       end if;
	   end if;
	end process;        

	-- Add user logic here

	-- User logic ends

end implementation;
