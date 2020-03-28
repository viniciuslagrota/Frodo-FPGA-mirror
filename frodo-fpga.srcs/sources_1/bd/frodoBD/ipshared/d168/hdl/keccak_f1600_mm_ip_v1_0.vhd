library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak_f1600_mm_ip_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 8
	);
	port (
		-- Users to add ports here
		start           : in std_logic;
        done            : out std_logic;
        enable_timer    : out std_logic;
        reset_timer     : buffer std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end keccak_f1600_mm_ip_v1_0;

architecture arch_imp of keccak_f1600_mm_ip_v1_0 is

    constant C_AXI_PACKET_SIZE       : integer   := 50; -- 50 words of 32 bits.
	-- constant C_AXI_PACKET_SIZE       : integer   := 4; -- 4 words of 32 bits.

	-- AXI MM Signals
    signal s_data_to_core    : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	signal s_valid_to_core   : std_logic;
	signal s_ready_to_core   : std_logic;
	signal s_data_from_core  : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	signal s_valid_from_core : std_logic;
	signal s_ready_from_core : std_logic;

    -- Control signals
    signal s_start          : std_logic;
    signal s_done           : std_logic;
	
	-- Clock and reset
    signal s_clk            : std_logic;
    signal s_reset_n        : std_logic; 
    
    -- Timer
    signal s_start_reg      : std_logic;

	-- component declaration
	component keccak_f1600_mm_ip_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 8
		);
		port (
		start           : in std_logic;    
		data_o          : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		valid_o         : out std_logic;
		ready_i         : in std_logic;
		data_i          : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        valid_i         : in std_logic;
        ready_o         : out std_logic;		
		S_AXI_ACLK	    : in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	    : out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	    : out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component keccak_f1600_mm_ip_v1_0_S00_AXI;
	
--	component keccak_f1600_mm_core is
--        generic (
--            C_S_AXI_DATA_WIDTH	: integer	:= 32
--		);
--		port (
--            clk             : in std_logic;
--            reset_n         : in std_logic;
--            data_i_mm       : in std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0);
--            valid_i_mm      : in std_logic;
--            ready_o_mm      : out std_logic;
--            ready_i_mm      : in std_logic;
--            data_o_mm       : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--            valid_o_mm      : out std_logic;
--            start           : in std_logic;
--            done            : out std_logic
--		);
--	end component;
	
	component keccak_f1600_mm_core_fast is
        generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32
		);
		port (
            clk             : in std_logic;
            reset_n         : in std_logic;
            data_i_mm       : in std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0);
            valid_i_mm      : in std_logic;
            ready_o_mm      : out std_logic;
            ready_i_mm      : in std_logic;
            data_o_mm       : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            valid_o_mm      : out std_logic;
            start           : in std_logic;
            done            : out std_logic
		);
	end component;

begin

    s_start         <= start;  
    done            <= s_done;  
    s_clk           <= s00_axi_aclk;
    s_reset_n       <= s00_axi_aresetn;

-- Instantiation of Axi Bus Interface S00_AXI
keccak_f1600_mm_ip_v1_0_S00_AXI_inst : keccak_f1600_mm_ip_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH
	)
	port map (
        start           => s_start,
        data_o          => s_data_to_core,
	    valid_o         => s_valid_to_core,
	    ready_i         => s_ready_from_core,
	    data_i          => s_data_from_core,
	    valid_i         => s_valid_from_core,
	    ready_o         => s_ready_to_core,
        S_AXI_ACLK	    => s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	    => s00_axi_wdata,
		S_AXI_WSTRB	    => s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	    => s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	    => s00_axi_rdata,
		S_AXI_RRESP	    => s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);
	
--	keccak_f1600_mm_core_inst : keccak_f1600_mm_core
--    generic map
--    (
--        C_S_AXI_DATA_WIDTH    =>   C_S00_AXI_DATA_WIDTH  
--    )
--    port map
--    (
--        clk             => s_clk,
--        reset_n         => s_reset_n,
--        data_i_mm       => s_data_to_core,
--        valid_i_mm      => s_valid_to_core,
--        ready_o_mm      => s_ready_from_core,
--        ready_i_mm      => s_ready_to_core,
--        data_o_mm       => s_data_from_core,
--        valid_o_mm      => s_valid_from_core,
--        start           => s_start,
--        done            => s_done
--    );

	-- Add user logic here
    process(s00_axi_aclk)
    begin
        if(rising_edge(s00_axi_aclk)) then       
            if(s00_axi_aresetn = '0') then
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
	-- User logic ends
	
	keccak_f1600_mm_core_fast_inst : keccak_f1600_mm_core_fast
    generic map
    (
        C_S_AXI_DATA_WIDTH    =>   C_S00_AXI_DATA_WIDTH  
    )
    port map
    (
        clk             => s_clk,
        reset_n         => s_reset_n,
        data_i_mm       => s_data_to_core,
        valid_i_mm      => s_valid_to_core,
        ready_o_mm      => s_ready_from_core,
        ready_i_mm      => s_ready_to_core,
        data_o_mm       => s_data_from_core,
        valid_o_mm      => s_valid_from_core,
        start           => s_start,
        done            => s_done
    );

end arch_imp;
