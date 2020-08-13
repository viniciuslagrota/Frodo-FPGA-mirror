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

entity shake128_core is
    generic (
        C_S_AXI_DATA_WIDTH	: integer	:= 32;
        REQ_BITS_LEN        : integer   := 13
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
end shake128_core;

architecture Behavioral of shake128_core is

    constant rate_cte       : integer := 168;
    constant rate           : unsigned(REQ_BITS_LEN+1 downto 0) := to_unsigned(rate_cte, REQ_BITS_LEN+2);
    constant terminator     : std_logic_vector(C_S_AXI_DATA_WIDTH/4-1 downto 0) := x"1F";
    constant or_x80_data    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := x"80000000";
    
    type st_type is (waiting_ready, request, receiving_data, pre_keccak_absorb, waiting_keccak_absorb, absorb_done, 
                     pre_keccak_squeeze, waiting_keccak_squeeze, squeezing_data, shake_done);
    signal st : st_type;
    
    signal s                : k_state;
    signal row, col         : integer;
    signal valid_in_reg     : std_logic;
    signal nblocks          : integer;
    signal s_count_out      : unsigned(4 downto 0);
    
begin

    s_out_keccak <= s;
    
    -- state
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                st <= waiting_ready;
            else
                case st is
                    when waiting_ready =>
                        if(ready = '1') then
                            st <= request;
                        end if;
                    
                    when request => 
                        st <= receiving_data;
                        
                    when receiving_data =>
                        if(valid_in_reg = '1' and valid_in = '0') then
                            if(last_block = '0') then
                                st <= pre_keccak_absorb;
                            else
                                st <= absorb_done;
                            end if;
                        end if;
                        
                    when pre_keccak_absorb => 
                        st <= waiting_keccak_absorb;
                    
                    when waiting_keccak_absorb => 
                        if(valid_in_keccak = '1') then
                            st <= request;
                        end if;
                        
                    when absorb_done =>
                        st <= pre_keccak_squeeze;
                        
                    when pre_keccak_squeeze => 
                        st <= waiting_keccak_squeeze;
                        
                    when waiting_keccak_squeeze => 
                        if(valid_in_keccak = '1') then
                            st <= squeezing_data; -- check here nrounds
                        end if;
                        
                    when squeezing_data =>
                        if(row = 4 and col = 0) then
                            if(nblocks = 0) then
                                st <= shake_done;
                            else
                                st <= pre_keccak_squeeze;
                            end if;
                        end if;
                        
                    when shake_done => 
                        if(start = '0') then
                            st <= waiting_ready;
                        end if;
                        
                end case;   
            end if;
        end if;
    end process;   
    
    -- valid_req
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                valid_req <= '0';   
            else
                if(st = request) then
                    valid_req <= '1';
                else
                    valid_req <= '0';
                end if;
            end if;
        end if;
    end process;        
    
    -- s
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(st = waiting_ready) then
                for row in 0 to 4 loop
                    for col in 0 to 4 loop
                        for i in 0 to 63 loop
                            s(row)(col)(i) <= '0';
                        end loop;
                    end loop;
                end loop;
            else
                if(valid_in = '1') then
                    for i in 0 to 63 loop
                        s(row)(col)(i) <= s(row)(col)(i) xor m(i);
                    end loop;
                elsif(valid_in_keccak = '1') then
                    s <= s_in_keccak;
                end if;
            end if;
        end if;
    end process;   
    
    -- row and col     
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(st = receiving_data) then
                if(valid_in = '1') then   
                    if(col < 4) then
                        col <= col + 1;
                    else
                        col <= 0;
                        if(row < 4) then
                            row <= row + 1;
                        else
                            row <= 0;
                        end if;
                    end if;                    
                end if;
            elsif(st = squeezing_data) then
                if(col < 4) then
                    col <= col + 1;
                else
                    col <= 0;
                    if(row < 4) then
                        row <= row + 1;
                    else
                        row <= 0;
                    end if;
                end if;  
            else
                row <= 0;
                col <= 0;
            end if;
        end if;
    end process;   
    
    -- valid_in_reg
    process(clk)
    begin
        if(rising_edge(clk)) then
            valid_in_reg <= valid_in;
        end if;
    end process;  

    -- valid_out_keccak    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                valid_out_keccak <= '0';
            else
                if(st = pre_keccak_absorb or st = pre_keccak_squeeze) then
                    valid_out_keccak <= '1';
                else
                    valid_out_keccak <= '0';
                end if;
            end if;
        end if;
    end process;   
    
    -- nblocks
    process(clk)
    begin
        if(rising_edge(clk)) then            
            if(st = request) then
                nblocks <= (to_integer(unsigned(outlen))/rate_cte) + 1;
            elsif(st = pre_keccak_squeeze) then
                nblocks <= nblocks - 1;
            end if;    
        end if;
    end process;     
    
    -- valid_out
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                valid_out <= '0';
            else
                if(st = squeezing_data) then
                    valid_out <= '1';
                else
                    valid_out <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- cipher
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(st = squeezing_data) then
                for i in 0 to 63 loop
                    cipher(i) <= s(row)(col)(i);
                end loop;
            end if;
        end if;
    end process;
    
    -- busy
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset_n = '0') then
                busy <= '0';
            else
                if(st = waiting_ready or st = shake_done) then
                    busy <= '0';
                else
                    busy <= '1';
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
