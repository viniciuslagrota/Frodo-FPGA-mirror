library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_sa_plus_e_mm_ip_v1_0 is
	generic (
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6;

		-- Parameters of Axi Slave Bus Interface S01_AXI
		C_S01_AXI_DATA_WIDTH	: integer	:= 32;
		C_S01_AXI_ADDR_WIDTH	: integer	:= 13;

		-- Parameters of Axi Slave Bus Interface S02_AXI
		C_S02_AXI_DATA_WIDTH	: integer	:= 32;
		C_S02_AXI_ADDR_WIDTH	: integer	:= 14
	);
	port (
		-- Users to add ports here
        start               : in std_logic;
        busy                : out std_logic;
        enable_total_timer  : out std_logic;
        reset_total_timer   : out std_logic;
        enable_proc_timer   : out std_logic;
        reset_proc_timer    : out std_logic;
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
		s00_axi_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S01_AXI
		s01_axi_aclk	: in std_logic;
		s01_axi_aresetn	: in std_logic;
		s01_axi_awaddr	: in std_logic_vector(C_S01_AXI_ADDR_WIDTH-1 downto 0);
		s01_axi_awprot	: in std_logic_vector(2 downto 0);
		s01_axi_awvalid	: in std_logic;
		s01_axi_awready	: out std_logic;
		s01_axi_wdata	: in std_logic_vector(C_S01_AXI_DATA_WIDTH-1 downto 0);
		s01_axi_wstrb	: in std_logic_vector((C_S01_AXI_DATA_WIDTH/8)-1 downto 0);
		s01_axi_wvalid	: in std_logic;
		s01_axi_wready	: out std_logic;
		s01_axi_bresp	: out std_logic_vector(1 downto 0);
		s01_axi_bvalid	: out std_logic;
		s01_axi_bready	: in std_logic;
		s01_axi_araddr	: in std_logic_vector(C_S01_AXI_ADDR_WIDTH-1 downto 0);
		s01_axi_arprot	: in std_logic_vector(2 downto 0);
		s01_axi_arvalid	: in std_logic;
		s01_axi_arready	: out std_logic;
		s01_axi_rdata	: out std_logic_vector(C_S01_AXI_DATA_WIDTH-1 downto 0);
		s01_axi_rresp	: out std_logic_vector(1 downto 0);
		s01_axi_rvalid	: out std_logic;
		s01_axi_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S02_AXI
		s02_axi_aclk	: in std_logic;
		s02_axi_aresetn	: in std_logic;
		s02_axi_awaddr	: in std_logic_vector(C_S02_AXI_ADDR_WIDTH-1 downto 0);
		s02_axi_awprot	: in std_logic_vector(2 downto 0);
		s02_axi_awvalid	: in std_logic;
		s02_axi_awready	: out std_logic;
		s02_axi_wdata	: in std_logic_vector(C_S02_AXI_DATA_WIDTH-1 downto 0);
		s02_axi_wstrb	: in std_logic_vector((C_S02_AXI_DATA_WIDTH/8)-1 downto 0);
		s02_axi_wvalid	: in std_logic;
		s02_axi_wready	: out std_logic;
		s02_axi_bresp	: out std_logic_vector(1 downto 0);
		s02_axi_bvalid	: out std_logic;
		s02_axi_bready	: in std_logic;
		s02_axi_araddr	: in std_logic_vector(C_S02_AXI_ADDR_WIDTH-1 downto 0);
		s02_axi_arprot	: in std_logic_vector(2 downto 0);
		s02_axi_arvalid	: in std_logic;
		s02_axi_arready	: out std_logic;
		s02_axi_rdata	: out std_logic_vector(C_S02_AXI_DATA_WIDTH-1 downto 0);
		s02_axi_rresp	: out std_logic_vector(1 downto 0);
		s02_axi_rvalid	: out std_logic;
		s02_axi_rready	: in std_logic
	);
end matrix_sa_plus_e_mm_ip_v1_0;

architecture arch_imp of matrix_sa_plus_e_mm_ip_v1_0 is

    signal s00_sop              : std_logic;
    signal s01_sop              : std_logic;
    signal s00_eop              : std_logic;
    signal s01_eop              : std_logic;
    signal s02_ready            : std_logic;   
    signal s02_sending          : std_logic;
    signal enable_mult          : std_logic;
    signal s00_req_addr         : unsigned(2 downto 0); 
    signal s01_req_addr         : unsigned(9 downto 0); 
    signal s02_req_addr         : unsigned(12 downto 0); 
    signal s00_data_0           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s00_data_1           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s00_data_2           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s00_data_3           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s01_data_0           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s01_data_1           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s01_data_2           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s01_data_3           : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal valid_data_to_s02    : std_logic;
    signal s_data_to_s02_0      : std_logic_vector(C_S00_AXI_DATA_WIDTH/2-1 downto 0);
    signal s_busy               : std_logic;

	-- component declaration
	component matrix_sa_plus_e_mm_ip_v1_0_S00_AXI is
		generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
            sop             : out std_logic;
            eop             : out std_logic;
            req_addr        : in unsigned(2 downto 0);
            data_0          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            data_1          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            data_2          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            data_3          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            S_AXI_ACLK	: in std_logic;
            S_AXI_ARESETN	: in std_logic;
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	: out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in std_logic;
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	: out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in std_logic
		);
	end component matrix_sa_plus_e_mm_ip_v1_0_S00_AXI;

	component matrix_sa_plus_e_mm_ip_v1_0_S01_AXI is
		generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 11
		);
		port (
            sop             : out std_logic;
            eop             : out std_logic;
            req_addr        : in unsigned(9 downto 0);
            data_0          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            data_1          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            data_2          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            data_3          : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            S_AXI_ACLK	: in std_logic;
            S_AXI_ARESETN	: in std_logic;
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	: out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in std_logic;
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	: out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in std_logic
		);
	end component matrix_sa_plus_e_mm_ip_v1_0_S01_AXI;

	component matrix_sa_plus_e_mm_ip_v1_0_S02_AXI is
		generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 15
		);
		port (
            start           : in std_logic;  
            data_0          : in std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
            valid_data      : in std_logic;
            req_addr        : in unsigned (12 downto 0);
            ready           : out std_logic;
            sending         : out std_logic;
            S_AXI_ACLK	: in std_logic;
            S_AXI_ARESETN	: in std_logic;
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	: out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in std_logic;
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	: out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in std_logic
		);
	end component matrix_sa_plus_e_mm_ip_v1_0_S02_AXI;
	
	component controller is
        port(
            clk                 : in std_logic;
            aresetn             : in std_logic;
            s00_sop             : in std_logic;
            s00_eop             : in std_logic;
            s01_sop             : in std_logic;
            s01_eop             : in std_logic;
            s02_ready           : in std_logic;  
            enable_mult         : out std_logic;
            s00_req_addr        : out unsigned (2 downto 0);
            s01_req_addr        : out unsigned (9 downto 0);
            s02_req_addr        : out unsigned (12 downto 0);
            valid_data_to_s02   : out std_logic;
            busy                : out std_logic        
        );
    end component controller;
    
    component multiplicator is
        port(
            clk         : in std_logic;
            aresetn     : in std_logic;
            s00_data_0  : in std_logic_vector(15 downto 0);
            s00_data_1  : in std_logic_vector(15 downto 0);
            s00_data_2  : in std_logic_vector(15 downto 0);
            s00_data_3  : in std_logic_vector(15 downto 0);
            s01_data_0  : in std_logic_vector(15 downto 0);
            s01_data_1  : in std_logic_vector(15 downto 0);
            s01_data_2  : in std_logic_vector(15 downto 0);
            s01_data_3  : in std_logic_vector(15 downto 0);
            data_out_0  : out std_logic_vector(15 downto 0)
        );
    end component multiplicator;
    
    component timer_controller is
        port ( 
            clk                 : in std_logic;
            reset_n             : in std_logic;
            busy                : in std_logic;
            sending             : in std_logic;
            enable_mult         : in std_logic;
            enable_total_timer  : out std_logic;
            reset_total_timer   : out std_logic;
            enable_proc_timer   : out std_logic;
            reset_proc_timer    : out std_logic 
        );
    end component timer_controller;

begin

    busy <= s_busy;

-- Instantiation of Axi Bus Interface S00_AXI
matrix_sa_plus_e_mm_ip_v1_0_S00_AXI_inst : matrix_sa_plus_e_mm_ip_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    sop            => s00_sop,
	    eop            => s00_eop,
	    req_addr       => s00_req_addr,
	    data_0         => s00_data_0,
	    data_1         => s00_data_1,
	    data_2         => s00_data_2,
	    data_3         => s00_data_3,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

-- Instantiation of Axi Bus Interface S01_AXI
matrix_sa_plus_e_mm_ip_v1_0_S01_AXI_inst : matrix_sa_plus_e_mm_ip_v1_0_S01_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S01_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S01_AXI_ADDR_WIDTH
	)
	port map (
	    sop            => s01_sop,
	    eop            => s01_eop,
	    req_addr       => s01_req_addr,
	    data_0         => s01_data_0,
	    data_1         => s01_data_1,
	    data_2         => s01_data_2,
	    data_3         => s01_data_3,
		S_AXI_ACLK	=> s01_axi_aclk,
		S_AXI_ARESETN	=> s01_axi_aresetn,
		S_AXI_AWADDR	=> s01_axi_awaddr,
		S_AXI_AWPROT	=> s01_axi_awprot,
		S_AXI_AWVALID	=> s01_axi_awvalid,
		S_AXI_AWREADY	=> s01_axi_awready,
		S_AXI_WDATA	=> s01_axi_wdata,
		S_AXI_WSTRB	=> s01_axi_wstrb,
		S_AXI_WVALID	=> s01_axi_wvalid,
		S_AXI_WREADY	=> s01_axi_wready,
		S_AXI_BRESP	=> s01_axi_bresp,
		S_AXI_BVALID	=> s01_axi_bvalid,
		S_AXI_BREADY	=> s01_axi_bready,
		S_AXI_ARADDR	=> s01_axi_araddr,
		S_AXI_ARPROT	=> s01_axi_arprot,
		S_AXI_ARVALID	=> s01_axi_arvalid,
		S_AXI_ARREADY	=> s01_axi_arready,
		S_AXI_RDATA	=> s01_axi_rdata,
		S_AXI_RRESP	=> s01_axi_rresp,
		S_AXI_RVALID	=> s01_axi_rvalid,
		S_AXI_RREADY	=> s01_axi_rready
	);

-- Instantiation of Axi Bus Interface S02_AXI
matrix_sa_plus_e_mm_ip_v1_0_S02_AXI_inst : matrix_sa_plus_e_mm_ip_v1_0_S02_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S02_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S02_AXI_ADDR_WIDTH
	)
	port map (
	    start          => start,
	    data_0         => s_data_to_s02_0,
	    valid_data     => valid_data_to_s02,
	    req_addr       => s02_req_addr,
	    ready          => s02_ready,
	    sending        => s02_sending,
		S_AXI_ACLK	   => s02_axi_aclk,
		S_AXI_ARESETN	=> s02_axi_aresetn,
		S_AXI_AWADDR	=> s02_axi_awaddr,
		S_AXI_AWPROT	=> s02_axi_awprot,
		S_AXI_AWVALID	=> s02_axi_awvalid,
		S_AXI_AWREADY	=> s02_axi_awready,
		S_AXI_WDATA	    => s02_axi_wdata,
		S_AXI_WSTRB	    => s02_axi_wstrb,
		S_AXI_WVALID	=> s02_axi_wvalid,
		S_AXI_WREADY	=> s02_axi_wready,
		S_AXI_BRESP	    => s02_axi_bresp,
		S_AXI_BVALID	=> s02_axi_bvalid,
		S_AXI_BREADY	=> s02_axi_bready,
		S_AXI_ARADDR	=> s02_axi_araddr,
		S_AXI_ARPROT	=> s02_axi_arprot,
		S_AXI_ARVALID	=> s02_axi_arvalid,
		S_AXI_ARREADY	=> s02_axi_arready,
		S_AXI_RDATA	    => s02_axi_rdata,
		S_AXI_RRESP	    => s02_axi_rresp,
		S_AXI_RVALID	=> s02_axi_rvalid,
		S_AXI_RREADY	=> s02_axi_rready
	);

    controller_inst : controller
    port map(
        clk                 => s00_axi_aclk,
        aresetn             => s00_axi_aresetn,
        s00_sop             => s00_sop,
        s00_eop             => s00_eop,
        s01_sop             => s01_sop,
        s01_eop             => s01_eop,
        s02_ready           => s02_ready,
        enable_mult         => enable_mult,
        s00_req_addr        => s00_req_addr,
        s01_req_addr        => s01_req_addr,
        s02_req_addr        => s02_req_addr,
        valid_data_to_s02   => valid_data_to_s02,
        busy                => s_busy
    );
    
    multiplicator_inst : multiplicator
    port map(
        clk        => s00_axi_aclk,
        aresetn    => s00_axi_aresetn, 
        s00_data_0 => s00_data_0,
        s00_data_1 => s00_data_1,
        s00_data_2 => s00_data_2,
        s00_data_3 => s00_data_3,
        s01_data_0 => s01_data_0,
        s01_data_1 => s01_data_1,
        s01_data_2 => s01_data_2,
        s01_data_3 => s01_data_3,
        data_out_0 => s_data_to_s02_0
    );
    
    timer_controller_inst : timer_controller
    port map(
        clk                => s00_axi_aclk,
        reset_n            => s00_axi_aresetn,
        busy               => s_busy,
        sending            => s02_sending,
        enable_mult        => enable_mult,
        enable_total_timer => enable_total_timer,
        reset_total_timer  => reset_total_timer,
        enable_proc_timer  => enable_proc_timer,
        reset_proc_timer   => reset_proc_timer  
    );
    

end arch_imp;
