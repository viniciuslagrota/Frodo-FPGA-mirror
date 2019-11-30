----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2019 10:39:58 PM
-- Design Name: 
-- Module Name: keccak_f1600_core - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keccak_f1600_core is
    generic(
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
end keccak_f1600_core;

architecture Behavioral of keccak_f1600_core is

-- Local parameters
constant w_length : integer := 64;
constant x_length : integer := 5;
constant y_length : integer := 5;

-- Keccak state types
type k_lane_type is  array ((w_length-1) downto 0) of std_logic;   
type k_sheet_type is array ((y_length-1) downto 0) of k_lane_type;  
type k_state_type is array ((x_length-1) downto 0) of k_sheet_type;    
type k_plane_type is array ((x_length-1) downto 0) of k_lane_type;

-- Round constants
type round_constant is array (23 downto 0) of k_lane_type;
signal rc : round_constant := (x"8000000080008008", x"0000000080000001", x"8000000000008080", x"8000000080008081", x"800000008000000A", x"000000000000800A", 
                               x"8000000000000080", x"8000000000008002", x"8000000000008003", x"8000000000008089", x"800000000000008B", x"000000008000808B",
                               x"000000008000000A", x"0000000080008009", x"0000000000000088", x"000000000000008A", x"8000000000008009", x"8000000080008081",
                               x"0000000080000001", x"000000000000808B", x"8000000080008000", x"800000000000808A", x"0000000000008082", x"0000000000000001");
                               
-- Machine States
type state is (load_matrix, theta, rho, pi, chi, iota, store_matrix, done_state);
signal st : state;
type step_type is (step0, step1, step2);
signal step : step_type;

-- Signals
signal upper_word : std_logic;
signal x : integer;
signal y : integer;
signal round : integer;
signal a : k_state_type;
signal a_line : k_state_type;
signal c : k_plane_type;
signal d : k_plane_type;

begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                st <= load_matrix;
                step <= step0;
                ready_o_s <= '1';
                valid_o_s <= '0';
                upper_word <= '0';
                round <= 0;
                done <= '0';
                x <= 0;
                y <= 0;
                
            else
                case(st) is                    
                    when load_matrix =>
                    
                        ready_o_s <= '1';
                        if(valid_i_s = '1') then 
                            
                            if(upper_word = '0') then -- lower part
                                for z in 0 to 31 loop
                                    a(x)(y)(z) <= data_i_s(z);
                                end loop;
                                upper_word <= '1';
                            else -- upper part
                                for z in 0 to 31 loop
                                    a(x)(y)(32 + z) <= data_i_s(z);
                                end loop;     
                                upper_word <= '0';
                                
                                if(x = x_length - 1) then
                                    x <= 0;
                                    if(y = y_length - 1) then
                                        y <= 0;
                                        st <= theta;
                                    else
                                        y <= y + 1;
                                    end if;
                                else
                                    x <= x + 1;
                                end if;
                                                           
                            end if;
                            
                        end if;
                    
                    when theta =>
                    
                        ready_o_s <= '0';
                        case(step) is
                        
                            when step0 =>
                            
                                for x in 0 to 4 loop
                                    for z in 0 to 63 loop
                                        c(x)(z) <= a(x)(0)(z) xor a(x)(1)(z) xor a(x)(2)(z) xor a(x)(3)(z) xor a(x)(4)(z);
                                    end loop;
                                end loop;
                                step <= step1;
                            
                            when step1 =>
                            
                                for x in 1 to 3 loop
                                    d(x)(0) <= c(x-1)(0) xor c(x+1)(63);
                                end loop;
                                d(0)(0) <= c(4)(0) xor c(1)(63);
                                d(4)(0) <= c(3)(0) xor c(0)(63);
                                
                                for z in 1 to 63 loop
                                    for x in 1 to 3 loop
                                        d(x)(z) <= c(x-1)(z) xor c(x+1)(z-1);
                                    end loop;
                                    d(0)(z) <= c(4)(z) xor c(1)(z-1);
                                    d(4)(z) <= c(3)(z) xor c(0)(z-1);
                                end loop;     
                                step <= step2;                               
                                
                            when step2 =>
                            
                                for x in 0 to 4 loop
                                    for y in 0 to 4 loop
                                        for z in 0 to 63 loop
                                            a(x)(y)(z) <= a(x)(y)(z) xor d(x)(z);
                                        end loop;
                                    end loop;
                                end loop;
                                st <= rho;
                                step <= step0;
                        
                        end case;
                                        
                    when rho =>
                    
                        a_line(0)(0)(63 downto 0) <= a(0)(0)(63 downto 0);
                        a_line(1)(0)(63 downto 0) <= a(1)(0)(62 downto 0) & a(1)(0)(63);
                        a_line(2)(0)(63 downto 0) <= a(2)(0)(01 downto 0) & a(2)(0)(63 downto 02);
                        a_line(3)(0)(63 downto 0) <= a(3)(0)(35 downto 0) & a(3)(0)(63 downto 36);
                        a_line(4)(0)(63 downto 0) <= a(4)(0)(36 downto 0) & a(4)(0)(63 downto 37);
                        
                        a_line(0)(1)(63 downto 0) <= a(0)(1)(27 downto 0) & a(0)(1)(63 downto 28);
                        a_line(1)(1)(63 downto 0) <= a(1)(1)(19 downto 0) & a(1)(1)(63 downto 20);
                        a_line(2)(1)(63 downto 0) <= a(2)(1)(57 downto 0) & a(2)(1)(63 downto 58);
                        a_line(3)(1)(63 downto 0) <= a(3)(1)(08 downto 0) & a(3)(1)(63 downto 09);
                        a_line(4)(1)(63 downto 0) <= a(4)(1)(43 downto 0) & a(4)(1)(63 downto 44);
                        
                        a_line(0)(2)(63 downto 0) <= a(0)(2)(60 downto 0) & a(0)(2)(63 downto 61);
                        a_line(1)(2)(63 downto 0) <= a(1)(2)(53 downto 0) & a(1)(2)(63 downto 54);
                        a_line(2)(2)(63 downto 0) <= a(2)(2)(20 downto 0) & a(2)(2)(63 downto 21);
                        a_line(3)(2)(63 downto 0) <= a(3)(2)(38 downto 0) & a(3)(2)(63 downto 39);
                        a_line(4)(2)(63 downto 0) <= a(4)(2)(24 downto 0) & a(4)(2)(63 downto 25);
                        
                        a_line(0)(3)(63 downto 0) <= a(0)(3)(22 downto 0) & a(0)(3)(63 downto 23);
                        a_line(1)(3)(63 downto 0) <= a(1)(3)(18 downto 0) & a(1)(3)(63 downto 19);
                        a_line(2)(3)(63 downto 0) <= a(2)(3)(48 downto 0) & a(2)(3)(63 downto 49);
                        a_line(3)(3)(63 downto 0) <= a(3)(3)(42 downto 0) & a(3)(3)(63 downto 43);
                        a_line(4)(3)(63 downto 0) <= a(4)(3)(55 downto 0) & a(4)(3)(63 downto 56);
                        
                        a_line(0)(4)(63 downto 0) <= a(0)(4)(45 downto 0) & a(0)(4)(63 downto 46);
                        a_line(1)(4)(63 downto 0) <= a(1)(4)(61 downto 0) & a(1)(4)(63 downto 62);
                        a_line(2)(4)(63 downto 0) <= a(2)(4)(02 downto 0) & a(2)(4)(63 downto 03);
                        a_line(3)(4)(63 downto 0) <= a(3)(4)(07 downto 0) & a(3)(4)(63 downto 08);
                        a_line(4)(4)(63 downto 0) <= a(4)(4)(49 downto 0) & a(4)(4)(63 downto 50);
                        
                        st <= pi;
                                            
                    when pi =>
                    
                        for x in 0 to 4 loop
                            for y in 0 to 4 loop
                                for z in 0 to 63 loop
                                    a(x)(y)(z) <= a_line((x + 3*y) mod 5)(x)(z);
                                end loop;
                            end loop;
                        end loop;                        
                        st <= chi;
                    
                    when chi =>
                    
                        for x in 0 to 2 loop
                            for y in 0 to 4 loop
                                for z in 0 to 63 loop
                                    a_line(x)(y)(z) <= a(x)(y)(z) xor (not(a(x+1)(y)(z)) and a(x+2)(y)(z));
                                end loop;
                            end loop;
                        end loop;
                        
                        for y in 0 to 4 loop
                            for z in 0 to 63 loop
                                a_line(3)(y)(z) <= a(3)(y)(z) xor (not(a(4)(y)(z)) and a(0)(y)(z));
                                a_line(4)(y)(z) <= a(4)(y)(z) xor (not(a(0)(y)(z)) and a(1)(y)(z));
                            end loop;
                        end loop;
                        st <= iota;
                    
                    when iota =>
                    
                        case(step) is
                        
                            when step0 =>
                            
                                for x in 0 to 4 loop
                                    for y in 0 to 4 loop
                                        for z in 0 to 63 loop
                                            a(x)(y)(z) <= a_line(x)(y)(z);
                                        end loop;
                                    end loop;
                                end loop;
                                step <= step1;
                            
                            when step1 =>
                            
                                for z in 0 to 63 loop
                                    a(0)(0)(z) <= a(0)(0)(z) xor rc(round)(z);
                                end loop;
                                step <= step0;
                                if(round = 23) then
                                    round <= 0;
                                    st <= store_matrix;
                                else
                                    round <= round + 1;
                                    st <= theta;
                                end if;
                                
                            when others =>
                                
                                step <= step0;
                        
                        end case;
                        
                    when store_matrix =>
                    
                        if(ready_i_s = '1') then
                            upper_word <= upper_word xor '1';
                            valid_o_s <= '1';  
                            if(upper_word = '0') then                                                          
                                data_o_s <= std_logic_vector(a(x)(y)(31 downto 0));
                            else
                                data_o_s <= std_logic_vector(a(x)(y)(63 downto 32));
                                
                                if(x = x_length - 1) then
                                    x <= 0;
                                    if(y = y_length - 1) then
                                        y <= 0;
                                        upper_word <= '0';
                                        st <= done_state;
                                    else
                                        y <= y + 1;
                                    end if;
                                else
                                    x <= x + 1;
                                end if;
                                
                            end if;                          
                                                        
                        else
                            valid_o_s <= '0';
                        end if;  
                        
                    when done_state =>
                    
                        valid_o_s <= '0';
                        if(start = '1') then
                            done <= '1';
                        else
                            done <= '0';
                            st <= load_matrix;
                        end if;
                        
                                        
                end case;
            end if;        
        end if;
        
    end process;


end Behavioral;
