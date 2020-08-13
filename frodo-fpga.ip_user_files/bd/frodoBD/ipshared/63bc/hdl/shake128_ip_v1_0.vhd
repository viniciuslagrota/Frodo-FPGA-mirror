library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.keccak_global2.all;

entity shake128_ip_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 15;
		REQ_BITS_LEN            : integer   := 13
	);
	port (
		-- Users to add ports here
        start               : in std_logic;
        busy                : out std_logic;   
        inlen               : in std_logic_vector(REQ_BITS_LEN+1 downto 0);         
	    outlen              : in std_logic_vector(REQ_BITS_LEN+1 downto 0);
	    enable_total_timer  : out std_logic;
        reset_total_timer   : out std_logic;
        enable_proc_timer   : out std_logic;
        reset_proc_timer    : out std_logic;
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
end shake128_ip_v1_0;

architecture arch_imp of shake128_ip_v1_0 is

    signal s_s00_ready              		: std_logic;    
    signal s_s00_valid_req          		: std_logic;
    signal s_s00_last_block                 : std_logic;
    signal s_s00_valid_out          		: std_logic;
    signal s_s00_m                  		: std_logic_vector(64-1 downto 0); 
    signal s_s00_valid_in          		    : std_logic;
    signal s_s00_cipher                		: std_logic_vector(64-1 downto 0);
    signal s_valid_out_core_to_keccak     	: std_logic;
    signal s_state_out_core             	: k_state; 
    signal s_valid_in_keccak               	: std_logic;
    signal s_data_in_keccak               	: k_state;    
    signal s_valid_out_keccak              	: std_logic;
    signal s_data_out_keccak              	: k_state;   
    signal s_busy_s00                       : std_logic;
    signal s_busy_shake                 	: std_logic;
    signal s_busy                           : std_logic;
    
	-- component declaration
	component shake128_ip_v1_0_S00_AXI is
		generic (
            C_S_AXI_DATA_WIDTH	: integer	:= C_S00_AXI_DATA_WIDTH;
            C_S_AXI_ADDR_WIDTH	: integer	:= C_S00_AXI_ADDR_WIDTH;
            REQ_BITS_LEN        : integer   := REQ_BITS_LEN
		);
		port (
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
	end component shake128_ip_v1_0_S00_AXI;
	
	component shake128_core is
        generic (
            C_S_AXI_DATA_WIDTH	: integer	:= C_S00_AXI_DATA_WIDTH;
            REQ_BITS_LEN        : integer   := REQ_BITS_LEN
        );
        port ( 
            clk                 : in std_logic;
            reset_n             : in std_logic;
            start               : in std_logic;
            valid_in            : in std_logic;
            m                   : in std_logic_vector(64-1 downto 0);
            inlen               : in std_logic_vector(REQ_BITS_LEN+1 downto 0); 
            outlen              : in std_logic_vector(REQ_BITS_LEN+1 downto 0);
            ready               : in std_logic;
            last_block          : in std_logic;            
            
            valid_req           : out std_logic;
            valid_out_keccak    : out std_logic;
            s_out_keccak        : out k_state;
            
            valid_in_keccak     : in std_logic;
            s_in_keccak         : in k_state;
            
            valid_out           : out std_logic;
            cipher              : out std_logic_vector(64-1 downto 0);
            busy                : out std_logic          
        );
    end component shake128_core;
    
    component keccak_f1600_mm_core_fast2 is
        generic(
            C_S_AXI_DATA_WIDTH	: integer	:= C_S00_AXI_DATA_WIDTH
        );
        port ( 
            clk             : in std_logic;
            reset_n         : in std_logic;
            round_in        : in k_state;
            valid_i_mm      : in std_logic;
            round_out       : out k_state;
            valid_o_mm      : out std_logic
        );
    end component keccak_f1600_mm_core_fast2;
    
    component timer_controller3 is
        port ( 
            clk                 : in std_logic;
            reset_n             : in std_logic;
            start               : in std_logic;
            busy                : in std_logic;
            enable_total_timer  : out std_logic;
            reset_total_timer   : out std_logic;
            enable_proc_timer   : out std_logic;
            reset_proc_timer    : out std_logic 
        );
    end component timer_controller3;

begin

    s_valid_in_keccak <= s_valid_out_core_to_keccak;
    s_data_in_keccak <= s_state_out_core;
    
    s_busy <= s_busy_s00 or s_busy_shake;
    busy <= s_busy;

-- Instantiation of Axi Bus Interface S00_AXI
shake128_mm_ip_v1_0_S00_AXI_inst : shake128_ip_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		REQ_BITS_LEN        => REQ_BITS_LEN
	)
	port map (
	    start           => start,
	    inlen           => inlen,         
        outlen          => outlen,         
        ready           => s_s00_ready,
        valid_req       => s_s00_valid_req,
        valid_out       => s_s00_valid_out,
        m               => s_s00_m,
        last_block      => s_s00_last_block,
        valid_in        => s_s00_valid_in,
        cipher          => s_s00_cipher,
        busy            => s_busy_s00,
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

    shake128_core_inst : shake128_core
    generic map(
        C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
        REQ_BITS_LEN        => REQ_BITS_LEN 
    )
    port map(
        clk                 => s00_axi_aclk,
        reset_n             => s00_axi_aresetn,
        start               => start,
        valid_in            => s_s00_valid_out,
        m                   => s_s00_m,
        inlen               => inlen,
        outlen              => outlen,
        ready               => s_s00_ready,
        last_block          => s_s00_last_block,
        valid_req           => s_s00_valid_req,
        valid_out_keccak    => s_valid_out_core_to_keccak,
        s_out_keccak        => s_state_out_core,  
        valid_in_keccak     => s_valid_out_keccak,
        s_in_keccak         => s_data_out_keccak,
        valid_out           => s_s00_valid_in,
        cipher              => s_s00_cipher,
        busy                => s_busy_shake    
    );
    
    
    keccak_f1600_mm_core_fast2_inst : keccak_f1600_mm_core_fast2
    generic map(
        C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH
    )
    port map(
        clk         => s00_axi_aclk,
        reset_n     => s00_axi_aresetn,
        round_in    => s_data_in_keccak,
        valid_i_mm  => s_valid_in_keccak,
        round_out   => s_data_out_keccak,
        valid_o_mm  => s_valid_out_keccak       
    );    
    
    timer_controller_inst : timer_controller3
    port map(
        clk                => s00_axi_aclk,
        reset_n            => s00_axi_aresetn,
        start              => start,
        busy               => s_busy,
        enable_total_timer => enable_total_timer,
        reset_total_timer  => reset_total_timer,
        enable_proc_timer  => enable_proc_timer,
        reset_proc_timer   => reset_proc_timer  
    );

end arch_imp;
