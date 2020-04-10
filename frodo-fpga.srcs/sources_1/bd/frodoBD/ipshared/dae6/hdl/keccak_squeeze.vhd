----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2020 08:26:49 PM
-- Design Name: 
-- Module Name: keccak_squeeze - Behavioral
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

entity keccak_squeeze is
    generic (
        C_S_AXI_DATA_WIDTH	: integer	:= 32;
        REQ_BITS_LEN        : integer   := 13
    );
    port ( 
        clk                 : in std_logic;
        reset_n             : in std_logic;
        start               : in std_logic;
        outlen              : in std_logic_vector(REQ_BITS_LEN+1 downto 0); 
        
        valid_in            : in std_logic;
        s_in                : in k_state;
        
        valid_in_keccak     : in std_logic;
        s_in_keccak         : in k_state;
        
        valid_out_keccak    : out std_logic;        
        s_out_keccak        : out k_state;
        
        valid_out           : out std_logic;
        data_out            : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        done                : out std_logic 
    );
end keccak_squeeze;

architecture Behavioral of keccak_squeeze is

    constant rate_cte       : integer := 168;
    
    type st_type is (wait_absorb, process_blocks, wait_keccak_from_blocks, send_data_out_from_blocks, process_remaining, 
                    wait_keccak_from_remaining, send_data_out_from_remaining, squeeze_finished);
    signal st               : st_type;
    
    signal s                : k_state;
    
    signal nblocks          : integer;
    signal data_remaining   : integer;
    
    signal x, y             : integer;
    signal upper_word       : std_logic;

begin

    s_out_keccak <= s;
    done <= '1' when st = squeeze_finished else '0';
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                st <= wait_absorb;
                valid_out_keccak <= '0';
                valid_out <= '0';
                data_out <= (others => '0');
                x <= 0;
                y <= 0;
                upper_word <= '0';
            else
                if(start = '0') then
                    st <= wait_absorb;
                    valid_out_keccak <= '0'; 
                    valid_out <= '0';
                    data_out <= (others => '0');
                    x <= 0;
                    y <= 0;
                    upper_word <= '0';
                else
                    case st is
                        when wait_absorb =>
                            nblocks <= to_integer(unsigned(outlen))/rate_cte;
                            data_remaining <= to_integer(unsigned(outlen));
                            if(valid_in = '1') then
                                s <= s_in;
                                if(nblocks > 0) then
                                    st <= process_blocks;
                                else
                                    st <= process_remaining;
                                end if;
                            else
                                for y in 0 to num_plane-1 loop
                                    for x in 0 to num_sheet-1 loop
                                        for z in 0 to N-1 loop
                                            s(y)(x)(z) <= '0';
                                        end loop;
                                    end loop;
                                end loop;
                            end if;
                            
                        when process_blocks => 
                        
                            x <= 0;
                            y <= 0;
                            upper_word <= '0';
                            valid_out <= '0';
                            valid_out_keccak <= '1';
                            nblocks <= nblocks - 1;
                            data_remaining <= data_remaining - rate_cte;
                            st <= wait_keccak_from_blocks;
                            
                        when wait_keccak_from_blocks => 
                            
                            valid_out_keccak <= '0';
                            if(valid_in_keccak = '1') then
                                st <= send_data_out_from_blocks;
                                s <= s_in_keccak;
                            end if;
                            
                        when send_data_out_from_blocks =>
                        
                            valid_out <= '1';
                            if(upper_word = '0') then -- lower part
                                for z in 0 to 31 loop
                                    data_out(z) <= s(y)(x)(z);
                                end loop;
                                upper_word <= '1';                               
                            else -- upper part
                                for z in 0 to 31 loop
                                    data_out(z) <= s(y)(x)(32 + z);
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
                            
                            if(x = 0 and y = 4 and upper_word = '1') then
                                if(nblocks > 0) then
                                    st <= process_blocks;
                                else
                                    st <= process_remaining;    
                                end if;  
                            end if;                      
                        
                        when process_remaining =>
                        
                            x <= 0;
                            y <= 0;
                            upper_word <= '0';
                            valid_out <= '0';
                            valid_out_keccak <= '1';
                            st <= wait_keccak_from_remaining;
                            
                        when wait_keccak_from_remaining => 
                        
                            valid_out_keccak <= '0';
                            if(valid_in_keccak = '1') then
                                st <= send_data_out_from_remaining;
                                s <= s_in_keccak;
                            end if;
                            
                        when send_data_out_from_remaining =>                        
                            
                            data_remaining <= data_remaining - 4; 
                            if(data_remaining >= 4) then
                                if(upper_word = '0') then -- lower part
                                    for z in 0 to 31 loop
                                        data_out(z) <= s(y)(x)(z);
                                    end loop;
                                    upper_word <= '1';                               
                                else -- upper part
                                    for z in 0 to 31 loop
                                        data_out(z) <= s(y)(x)(32 + z);
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
                            elsif(data_remaining = 3) then
                                if(upper_word = '0') then -- lower part
                                    for z in 0 to 23 loop
                                        data_out(z) <= s(y)(x)(z);
                                    end loop;  
                                    for z in 24 to 31 loop
                                        data_out(z) <= '0';
                                    end loop;                          
                                else -- upper part
                                    for z in 0 to 23 loop
                                        data_out(z) <= s(y)(x)(32 + z);
                                    end loop;
                                    for z in 24 to 31 loop
                                        data_out(z) <= '0';
                                    end loop; 
                                end if;
                            elsif(data_remaining = 2) then
                                if(upper_word = '0') then -- lower part
                                    for z in 0 to 15 loop
                                        data_out(z) <= s(y)(x)(z);
                                    end loop;  
                                    for z in 16 to 31 loop
                                        data_out(z) <= '0';
                                    end loop;                          
                                else -- upper part
                                    for z in 0 to 15 loop
                                        data_out(z) <= s(y)(x)(32 + z);
                                    end loop;
                                    for z in 16 to 31 loop
                                        data_out(z) <= '0';
                                    end loop; 
                                end if;
                            elsif(data_remaining = 1) then
                                if(upper_word = '0') then -- lower part
                                    for z in 0 to 7 loop
                                        data_out(z) <= s(y)(x)(z);
                                    end loop;  
                                    for z in 8 to 31 loop
                                        data_out(z) <= '0';
                                    end loop;                          
                                else -- upper part
                                    for z in 0 to 7 loop
                                        data_out(z) <= s(y)(x)(32 + z);
                                    end loop;
                                    for z in 8 to 31 loop
                                        data_out(z) <= '0';
                                    end loop; 
                                end if;
                            end if;                             
                            
                            if(data_remaining < 4) then
                                valid_out <= '0';
                                st <= squeeze_finished;
                            else
                                valid_out <= '1';
                            end if;     
                            
                        when squeeze_finished =>
                        
                            valid_out <= '0';
                        
                    end case;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
