----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2020 06:02:15 PM
-- Design Name: 
-- Module Name: keccak_f1600_mm_core_fast - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library xil_defaultlib;
use xil_defaultlib.keccak_global.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keccak_f1600_mm_core_fast is
    generic(
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
end keccak_f1600_mm_core_fast;

architecture Behavioral of keccak_f1600_mm_core_fast is

--    constant num_plane          : integer := 5;
--    constant num_sheet          : integer := 5;
--    constant logD               : integer :=4;
--    constant N                  : integer := 64;
    
--    --types
--    type k_lane                 is  array ((N-1) downto 0)  of std_logic;    
--    type k_plane                is array ((num_sheet-1) downto 0)  of k_lane;    
--    type k_state                is array ((num_plane-1) downto 0)  of k_plane; 
    
    -- Round constant
    type round_constant is array (23 downto 0) of k_lane;
    signal rc : round_constant := (x"8000000080008008", x"0000000080000001", x"8000000000008080", x"8000000080008081", x"800000008000000A", x"000000000000800A", 
                               x"8000000000000080", x"8000000000008002", x"8000000000008003", x"8000000000008089", x"800000000000008B", x"000000008000808B",
                               x"000000008000000A", x"0000000080008009", x"0000000000000088", x"000000000000008A", x"8000000000008009", x"8000000080008081",
                               x"0000000080000001", x"000000000000808B", x"8000000080008000", x"800000000000808A", x"0000000000008082", x"0000000000000001");
     
    signal round_in, round_out  : k_state;
    signal theta_in, theta_out  : k_state;
    signal pi_in, pi_out        : k_state;
    signal rho_in, rho_out      : k_state;
    signal chi_in, chi_out      : k_state;
    signal iota_in, iota_out    : k_state;
    signal sum_sheet            : k_plane;
    
    signal upper_word : std_logic;
    signal x : integer;
    signal y : integer;
    signal round : integer := 0;
    signal s_valid_i_mm : std_logic;
    signal s_ready_o_mm : std_logic;

begin

    ready_o_mm <= s_ready_o_mm;

    process(clk)
    begin
        if(rising_edge(clk)) then
            s_valid_i_mm <= valid_i_mm;
        end if;
    end process;     
    
    -- Round
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                round <= 0;
            else
                if(start = '0' or s_valid_i_mm = '1' or s_ready_o_mm = '1') then
                    round <= 0;
                else
                    if(round = 23) then
                        round <= round;
                    else
                        round <= round + 1;
                    end if;
                end if;                
            end if;
        end if;
    end process;       


    -- TODO: passar para o S00. Tentar eliminar os registradores de lá e já ir salvando tudo no round_in.
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                for x in 0 to 4 loop
                    for y in 0 to 4 loop
                        round_in(y)(x)(63 downto 0) <= (others => '0');
                    end loop;
                end loop;
                upper_word <= '0';
                x <= 0;
                y <= 0;
                s_ready_o_mm <= '1';
            else
                if(start = '0') then
                    x <= 0;
                    y <= 0;
                    s_ready_o_mm <= '1';
                else   
                    if(valid_i_mm = '0' and s_valid_i_mm = '1') then
                        s_ready_o_mm <= '0';
                    end if;                    
                           
                    if(valid_i_mm = '1') then
                        if(upper_word = '0') then -- lower part
                            for z in 0 to 31 loop
                                round_in(y)(x)(z) <= data_i_mm(z);
                            end loop;
                            upper_word <= '1';
                        else -- upper part
                            for z in 0 to 31 loop
                                round_in(y)(x)(32 + z) <= data_i_mm(z);
                            end loop;     
                            upper_word <= '0';
                            
                            if(x = num_plane - 1) then
                                x <= 0;
                                if(y = num_sheet - 1) then
                                    y <= 0;                                    
                                else
                                    y <= y + 1;
                                end if;
                            else
                                x <= x + 1;
                            end if;
                            
                        end if; 
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                for x in 0 to 4 loop
                    for y in 0 to 4 loop
                        round_out(y)(x)(63 downto 0) <= (others => '0');
                    end loop;
                end loop;
            else
                round_out <= iota_out;
            end if;
        end if;
   end process;    
    
    -- Data between stages
    theta_in <= round_in when round = 0 else round_out;
    rho_in <= theta_out;
    pi_in <= rho_out;
    chi_in <= pi_out;
    iota_in <= chi_out;
--    round_out <= iota_out;

    -- Theta
    i0101: for x in 0 to 4 generate
        i0102: for i in 0 to 63 generate
            sum_sheet(x)(i)<=theta_in(0)(x)(i) xor theta_in(1)(x)(i) xor theta_in(2)(x)(i) xor theta_in(3)(x)(i) xor theta_in(4)(x)(i);	
        end generate;	
    end generate;    
    
    i0200: for y in 0 to 4 generate
        i0201: for x in 1 to 3 generate
            theta_out(y)(x)(0)<=theta_in(y)(x)(0) xor sum_sheet(x-1)(0) xor sum_sheet(x+1)(63);
            i0202: for i in 1 to 63 generate
                theta_out(y)(x)(i)<=theta_in(y)(x)(i) xor sum_sheet(x-1)(i) xor sum_sheet(x+1)(i-1);
            end generate;	
        end generate;
    end generate;
    
    i2001: for y in 0 to 4 generate
        theta_out(y)(0)(0)<=theta_in(y)(0)(0) xor sum_sheet(4)(0) xor sum_sheet(1)(63);
        i2021: for i in 1 to 63 generate
            theta_out(y)(0)(i)<=theta_in(y)(0)(i) xor sum_sheet(4)(i) xor sum_sheet(1)(i-1);
        end generate;	    
    end generate;
    
    i2002: for y in 0 to 4 generate
        theta_out(y)(4)(0)<=theta_in(y)(4)(0) xor sum_sheet(3)(0) xor sum_sheet(0)(63);
        i2022: for i in 1 to 63 generate
            theta_out(y)(4)(i)<=theta_in(y)(4)(i) xor sum_sheet(3)(i) xor sum_sheet(0)(i-1);
        end generate;	    
    end generate;
    
    -- Rho
    
    i4001: for i in 0 to 63 generate
	   rho_out(0)(0)(i)<=rho_in(0)(0)(i);
    end generate;	
    i4002: for i in 0 to 63 generate
        rho_out(0)(1)(i)<=rho_in(0)(1)((i-1)mod 64);
    end generate;
    i4003: for i in 0 to 63 generate
        rho_out(0)(2)(i)<=rho_in(0)(2)((i-62)mod 64);
    end generate;
    i4004: for i in 0 to 63 generate
        rho_out(0)(3)(i)<=rho_in(0)(3)((i-28)mod 64);
    end generate;
    i4005: for i in 0 to 63 generate
        rho_out(0)(4)(i)<=rho_in(0)(4)((i-27)mod 64);
    end generate;
    
    i4011: for i in 0 to 63 generate
        rho_out(1)(0)(i)<=rho_in(1)(0)((i-36)mod 64);
    end generate;	
    i4012: for i in 0 to 63 generate
        rho_out(1)(1)(i)<=rho_in(1)(1)((i-44)mod 64);
    end generate;
    i4013: for i in 0 to 63 generate
        rho_out(1)(2)(i)<=rho_in(1)(2)((i-6)mod 64);
    end generate;
    i4014: for i in 0 to 63 generate
        rho_out(1)(3)(i)<=rho_in(1)(3)((i-55)mod 64);
    end generate;
    i4015: for i in 0 to 63 generate
        rho_out(1)(4)(i)<=rho_in(1)(4)((i-20)mod 64);
    end generate;
    
    i4021: for i in 0 to 63 generate
        rho_out(2)(0)(i)<=rho_in(2)(0)((i-3)mod 64);
    end generate;	
    i4022: for i in 0 to 63 generate
        rho_out(2)(1)(i)<=rho_in(2)(1)((i-10)mod 64);
    end generate;
    i4023: for i in 0 to 63 generate
        rho_out(2)(2)(i)<=rho_in(2)(2)((i-43)mod 64);
    end generate;
    i4024: for i in 0 to 63 generate
        rho_out(2)(3)(i)<=rho_in(2)(3)((i-25)mod 64);
    end generate;
    i4025: for i in 0 to 63 generate
        rho_out(2)(4)(i)<=rho_in(2)(4)((i-39)mod 64);
    end generate;
    
    i4031: for i in 0 to 63 generate
        rho_out(3)(0)(i)<=rho_in(3)(0)((i-41)mod 64);
    end generate;	
    i4032: for i in 0 to 63 generate
        rho_out(3)(1)(i)<=rho_in(3)(1)((i-45)mod 64);
    end generate;
    i4033: for i in 0 to 63 generate
        rho_out(3)(2)(i)<=rho_in(3)(2)((i-15)mod 64);
    end generate;
    i4034: for i in 0 to 63 generate
        rho_out(3)(3)(i)<=rho_in(3)(3)((i-21)mod 64);
    end generate;
    i4035: for i in 0 to 63 generate
        rho_out(3)(4)(i)<=rho_in(3)(4)((i-8)mod 64);
    end generate;
    
    i4041: for i in 0 to 63 generate
        rho_out(4)(0)(i)<=rho_in(4)(0)((i-18)mod 64);
    end generate;	
    i4042: for i in 0 to 63 generate
        rho_out(4)(1)(i)<=rho_in(4)(1)((i-2)mod 64);
    end generate;
    i4043: for i in 0 to 63 generate
        rho_out(4)(2)(i)<=rho_in(4)(2)((i-61)mod 64);
    end generate;
    i4044: for i in 0 to 63 generate
        rho_out(4)(3)(i)<=rho_in(4)(3)((i-56)mod 64);
    end generate;
    i4045: for i in 0 to 63 generate
        rho_out(4)(4)(i)<=rho_in(4)(4)((i-14)mod 64);
    end generate;
    
    -- Pi
    i3001: for y in 0 to 4 generate
        i3002: for x in 0 to 4 generate
            i3003: for i in 0 to 63 generate
                pi_out((2*x+3*y) mod 5)(0*x+1*y)(i)<=pi_in(y) (x)(i);
            end generate;	
        end generate;
    end generate;
    
    -- Chi
    i0000: for y in 0 to 4 generate
        i0001: for x in 0 to 2 generate
            i0002: for i in 0 to 63 generate
                chi_out(y)(x)(i)<=chi_in(y)(x)(i) xor ( not(chi_in (y)(x+1)(i))and chi_in (y)(x+2)(i));            
            end generate;	
        end generate;
    end generate;

	i0011: for y in 0 to 4 generate
		i0021: for i in 0 to 63 generate
			chi_out(y)(3)(i)<=chi_in(y)(3)(i) xor ( not(chi_in (y)(4)(i))and chi_in (y)(0)(i));		
		end generate;	
	end generate;
	
	i0012: for y in 0 to 4 generate
		i0022: for i in 0 to 63 generate
			chi_out(y)(4)(i)<=chi_in(y)(4)(i) xor ( not(chi_in (y)(0)(i))and chi_in (y)(1)(i));		
		end generate;	
	end generate;
	
	--iota
    i5001: for y in 1 to 4 generate
        i5002: for x in 0 to 4 generate
            i5003: for i in 0 to 63 generate
                iota_out(y)(x)(i)<=iota_in(y)(x)(i);
            end generate;	
        end generate;
    end generate;

	i5012: for x in 1 to 4 generate
		i5013: for i in 0 to 63 generate
			iota_out(0)(x)(i)<=iota_in(0)(x)(i);
		end generate;	
    end generate;  
    
    i5103: for i in 0 to 63 generate
        iota_out(0)(0)(i)<=iota_in(0)(0)(i) xor rc(round)(i);
    end generate;	


end Behavioral;
