----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2020 05:15:23 PM
-- Design Name: 
-- Module Name: keccak_absorb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.keccak_global2.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keccak_absorb is
    generic (
        C_S_AXI_DATA_WIDTH	: integer	:= 32;
        REQ_BITS_LEN        : integer   := 13
    );
    port ( 
        clk                 : in std_logic;
        reset_n             : in std_logic;
        start               : in std_logic;
        valid_in            : in std_logic;
        m                   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        inlen               : in std_logic_vector(REQ_BITS_LEN+1 downto 0); 
        ready               : in std_logic;
        
        valid_req           : out std_logic;
        n_bytes             : out unsigned(REQ_BITS_LEN+1 downto 0);
        valid_out_keccak    : out std_logic;
        s_out_keccak        : out k_state;
        
        valid_in_keccak     : in std_logic;
        s_in_keccak         : in k_state;
        
        valid_out           : out std_logic;
        done                : out std_logic           
    );
end keccak_absorb;

architecture Behavioral of keccak_absorb is

    constant rate_cte       : integer := 168;
    constant rate           : unsigned(REQ_BITS_LEN+1 downto 0) := to_unsigned(rate_cte, REQ_BITS_LEN+2);
    constant terminator     : std_logic_vector(C_S_AXI_DATA_WIDTH/4-1 downto 0) := x"1F";
    constant or_x80_data    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := x"80000000";
    
    signal s_inlen          : unsigned(REQ_BITS_LEN+1 downto 0); 
    signal s_byte_pos       : unsigned(REQ_BITS_LEN+1 downto 0); 
        
    type st_type is (wait_ready, get_data, wait_keccak, get_remaining_data, terminator_data, or_data, sent_data_out, absorb_finished);
    signal st               : st_type;
    
    signal s                : k_state;               

    signal s_n_bytes        : unsigned(REQ_BITS_LEN+1 downto 0);
    signal s_n_words        : unsigned(REQ_BITS_LEN+1 downto 0);
    signal s_n_word_counter : unsigned(REQ_BITS_LEN-1 downto 0);
    signal s_valid_req      : std_logic;
    signal upper_word       : std_logic;
    signal x, x_term        : integer;
    signal y, y_term        : integer;
    signal div              : integer;
    signal init_pos         : integer;
    
begin
    
    n_bytes <= s_n_bytes;   
    s_out_keccak <= s;
    valid_req <= s_valid_req;
    done <= '1' when st = absorb_finished else '0';
    
    s_byte_pos <= s_inlen - 1;
    div <= to_integer(s_byte_pos(REQ_BITS_LEN+1 downto 3));
    y_term <= 0 when div < 5 else
              1 when div < 10 else
              2 when div < 15 else
              3 when div < 20 else
              4;
    x_term <= div - y*5;    
    init_pos <= to_integer((s_inlen(2 downto 0)-1) & "000");
    
    -- state
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                st <= wait_ready;
                
                s_inlen <= (others => '0');
                s_valid_req <= '0';
                s_n_bytes <= (others => '0');    
                x <= 0;
                y <= 0;
                upper_word <= '0';
                s_n_word_counter <= (others => '0');
                valid_out_keccak <= '0';
                valid_out <= '0';
                
            else
                if(start = '0') then
                    st <= wait_ready;
                else
                    case(st) is
                        -- wait ready from s00
                        when wait_ready =>
                            if(ready = '0') then
                                for y in 0 to num_plane-1 loop
                                    for x in 0 to num_sheet-1 loop
                                        for z in 0 to N-1 loop
                                            s(y)(x)(z) <= '0';
                                        end loop;
                                    end loop;
                                end loop;
                            
                                s_inlen <= unsigned(inlen);
                                s_valid_req <= '0';
                                s_n_bytes <= (others => '0');                                
                                x <= 0;
                                y <= 0;
                                upper_word <= '0';
                                s_n_word_counter <= (others => '0');
                                valid_out_keccak <= '0';
                                valid_out <= '0';
                                
                            else
                                if(s_inlen >= rate) then
                                    s_valid_req <= '1';
                                    s_n_bytes <= to_unsigned(rate_cte, s_n_bytes'length);                                
                                    st <= get_data;
                                else                                    
                                    s_valid_req <= '1';
                                    s_n_bytes <= s_inlen;                                    
                                    st <= get_remaining_data;                                    
                                end if;
                            end if;                            
                        
                        when get_data =>
                            
                            s_valid_req <= '0';                           
                        
                            if(valid_in = '1') then
                                s_n_word_counter <= s_n_word_counter + 1;
                                if(upper_word = '0') then -- lower part
                                    for z in 0 to 31 loop
                                        s(y)(x)(z) <= s(y)(x)(z) xor m(z);
                                    end loop;
                                    upper_word <= '1';                               
                                else -- upper part
                                    for z in 0 to 31 loop
                                        s(y)(x)(32 + z) <= s(y)(x)(32 + z) xor m(z);
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
                            else
                                if(s_n_word_counter = s_n_words and s_valid_req = '0') then
                                    s_n_word_counter <= (others => '0');
                                    s_inlen <= s_inlen - rate;
                                    valid_out_keccak <= '1';
                                    st <= wait_keccak;
                                end if;               
                            end if;
                            
                        when wait_keccak => 
                        
                            valid_out_keccak <= '0';
                            upper_word <= '0';
                            x <= 0;
                            y <= 0;
                            
                            if(valid_in_keccak = '1') then
                                s <= s_in_keccak;
                                if(s_inlen >= rate) then    
                                    s_valid_req <= '1';   
                                    s_n_bytes <= to_unsigned(rate_cte, s_n_bytes'length);                          
                                    st <= get_data;
                                else
                                    s_valid_req <= '1';
                                    s_n_bytes <= s_inlen;                                    
                                    st <= get_remaining_data; 
                                end if;
                            end if;   
                            
                        when get_remaining_data => 
                        
                            s_valid_req <= '0';
                            
                            if(valid_in = '1') then
                                s_n_word_counter <= s_n_word_counter + 1;
                                if(upper_word = '0') then -- lower part
                                    for z in 0 to 31 loop
                                        s(y)(x)(z) <= s(y)(x)(z) xor m(z);
                                    end loop;
                                    upper_word <= '1';                               
                                else -- upper part
                                    for z in 0 to 31 loop
                                        s(y)(x)(32 + z) <= s(y)(x)(32 + z) xor m(z);
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
                            else
                                if(s_n_word_counter = s_n_words and s_valid_req = '0') then
                                    s_n_word_counter <= (others => '0');
                                    s_inlen <= s_inlen + 1; -- position to insert (m xor 0x1f)
                                    st <= terminator_data;
                                end if;               
                            end if;           
                            
                        when terminator_data => 
                        
                            for z in 0 to 7 loop
                                s(y_term)(x_term)(init_pos + z) <= s(y_term)(x_term)(init_pos + z) xor terminator(z);
                            end loop;
                            
                            st <= or_data;
                            
                        when or_data =>                         
                            for z in 0 to 31 loop
                                s(4)(0)(32 + z) <= s(4)(0)(32 + z) xor or_x80_data(z);
                            end loop;
                            valid_out <= '1';
                            st <= sent_data_out;
                            
                        when sent_data_out => 
                            valid_out <= '0';
                            st <= absorb_finished;
                            
                        when absorb_finished => 
                            valid_out <= '0';
                            when others =>
                    
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- s_n_words
    process( clk )
    begin
        if(rising_edge( clk )) then
            if ( reset_n = '0' ) then
                s_n_words <= (others => '0');
            else           
                if(s_n_bytes(0) = '1' or s_n_bytes(1) = '1') then
                    s_n_words <= ("00" & s_n_bytes(REQ_BITS_LEN+1 downto 2)) + 1;
                else
                    s_n_words <= "00" & s_n_bytes(REQ_BITS_LEN+1 downto 2);
                end if;
            end if;
        end if;
    end process;

end Behavioral;
