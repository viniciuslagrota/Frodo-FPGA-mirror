library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak_f1600_ip_v1_0 is
	generic (
		-- Users to add parameters here
		
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		start           : in std_logic;
        done            : out std_logic;
        enable_timer    : out std_logic;
        reset_timer     : buffer std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end keccak_f1600_ip_v1_0;

architecture arch_imp of keccak_f1600_ip_v1_0 is

	constant C_AXI_PACKET_SIZE       : integer   := 50; -- 50 words of 32 bits.
	-- constant C_AXI_PACKET_SIZE       : integer   := 4; -- 4 words of 32 bits.

	-- AXI Stream Slave signals
    signal s_data_slave_s : std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_valid_slave_s : std_logic;
	signal s_empty_slave_s : std_logic;
	signal s_ready_slave_s : std_logic;
	
	-- AXI Stream Master signals
	signal s_data_master_s : std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_valid_master_s : std_logic;
	signal s_ready_master_s : std_logic;
	
	-- Control signals
    signal s_start          : std_logic;
    signal s_done           : std_logic;
	
	-- Clock and reset
    signal s_clk            : std_logic;
    signal s_reset_n        : std_logic; 
    
    -- Timer
    signal s_start_reg      : std_logic;

	-- component declaration
	component keccak_f1600_ip_v1_0_S00_AXIS is
		generic (
		C_AXI_PACKET_SIZE       : integer;
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		data_o          : out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		valid_o         : out std_logic;
		empty_o         : out std_logic;
		ready_i         : in std_logic;
		
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component keccak_f1600_ip_v1_0_S00_AXIS;

	component keccak_f1600_ip_v1_0_M00_AXIS is
		generic (
		C_AXI_PACKET_SIZE       : integer;
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		valid_i : in std_logic;
        data_i : in std_logic_vector (C_M_AXIS_TDATA_WIDTH-1 downto 0);
        ready_o : out std_logic;
		
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component keccak_f1600_ip_v1_0_M00_AXIS;
	
	component keccak_f1600_core is
        generic (
            C_S_AXIS_TDATA_WIDTH	: integer	:= 32;
            C_M_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
            clk             : in std_logic;
            reset_n         : in std_logic;
            data_i_s        : in std_logic_vector (C_S_AXIS_TDATA_WIDTH-1 downto 0);
            valid_i_s       : in std_logic;
            empty_i_s       : in std_logic;
            ready_o_s       : out std_logic;
            ready_i_s       : in std_logic;
            data_o_s        : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            valid_o_s       : out std_logic;
            start           : in std_logic;
            done            : out std_logic
		);
	end component;

begin

	s_start         <= start;  
    done            <= s_done;  
    s_clk           <= s00_axis_aclk;
    s_reset_n       <= s00_axis_aresetn;

-- Instantiation of Axi Bus Interface S00_AXIS
keccak_f1600_ip_v1_0_S00_AXIS_inst : keccak_f1600_ip_v1_0_S00_AXIS
	generic map (
		C_AXI_PACKET_SIZE       => C_AXI_PACKET_SIZE,
		C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
	)
	port map (
		data_o          => s_data_slave_s,
	    valid_o         => s_valid_slave_s,
	    empty_o         => s_empty_slave_s,
	    ready_i         => s_ready_slave_s,
		S_AXIS_ACLK		=> s00_axis_aclk,
		S_AXIS_ARESETN	=> s00_axis_aresetn,
		S_AXIS_TREADY	=> s00_axis_tready,
		S_AXIS_TDATA	=> s00_axis_tdata,
		S_AXIS_TSTRB	=> s00_axis_tstrb,
		S_AXIS_TLAST	=> s00_axis_tlast,
		S_AXIS_TVALID	=> s00_axis_tvalid
	);

-- Instantiation of Axi Bus Interface M00_AXIS
keccak_f1600_ip_v1_0_M00_AXIS_inst : keccak_f1600_ip_v1_0_M00_AXIS
	generic map (
		C_AXI_PACKET_SIZE       => C_AXI_PACKET_SIZE,
		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH
	)
	port map (
		valid_i         => s_valid_master_s,
        data_i          => s_data_master_s,
        ready_o         => s_ready_master_s,
		M_AXIS_ACLK		=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY	=> m00_axis_tready
	);
	
keccak_f1600_core_inst : keccak_f1600_core
    generic map
    (
        C_S_AXIS_TDATA_WIDTH    =>   C_S00_AXIS_TDATA_WIDTH,        
        C_M_AXIS_TDATA_WIDTH    =>   C_M00_AXIS_TDATA_WIDTH
    )
    port map
    (
        clk             => s_clk,
        reset_n         => s_reset_n,
        data_i_s        => s_data_slave_s,
        valid_i_s       => s_valid_slave_s,
        empty_i_s       => s_empty_slave_s,
        ready_o_s       => s_ready_slave_s,
        ready_i_s       => s_ready_master_s,
        data_o_s        => s_data_master_s,
        valid_o_s       => s_valid_master_s,
        start           => s_start,
        done            => s_done
    );

    -- s_valid_master_s <= s_valid_slave_s;
    -- s_data_master_s <= s_data_slave_s;
    -- s_ready_slave_s <= s_ready_master_s;
    
     process(s00_axis_aclk)
     begin
        if(rising_edge(s00_axis_aclk)) then       
            if(s00_axis_aresetn = '0') then
                enable_timer <= '0';
                reset_timer <= '0';
                s_start_reg <= '0';
            else
                s_start_reg <= s_start;
                if(s_start = '1' and s_start_reg = '0') then
                    enable_timer <= '0';
                    reset_timer <= '1';
                elsif(s_done = '1') then
                    enable_timer <= '0';
                    reset_timer <= '0';
                else
                    if(reset_timer = '1') then
                        enable_timer <= '1';
                        reset_timer <= '0';
                    end if;
                end if;
            end if;
        end if;        
     end process;

end arch_imp;
