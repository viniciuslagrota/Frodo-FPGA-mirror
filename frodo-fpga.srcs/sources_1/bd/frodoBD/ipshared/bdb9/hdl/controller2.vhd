----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2020 09:46:16 PM
-- Design Name: 
-- Module Name: controller2 - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller2 is
    generic (
		S00_REQ_BITS_LEN        : integer   := 9;
		S01_REQ_BITS_LEN        : integer   := 12;
		S02_REQ_BITS_LEN        : integer   := 11
    );
    port(
        clk                 : in std_logic;        
        aresetn             : in std_logic;
        start               : in std_logic;
        s00_sop             : in std_logic;
        s00_eop             : in std_logic;
        s01_sop             : in std_logic;
        s01_eop             : in std_logic;  
        s02_ready           : in std_logic;      
        enable_mult         : out std_logic;
        s00_req_addr        : out unsigned (S00_REQ_BITS_LEN-1 downto 0);
        s01_req_addr        : out unsigned (S01_REQ_BITS_LEN-1 downto 0);
        s02_req_addr        : out unsigned (S02_REQ_BITS_LEN-1 downto 0);
        reset_sum           : out std_logic;
        valid_data_to_s02   : out std_logic;
        busy                : out std_logic        
    );
end controller2;

architecture Behavioral of controller2 is

    signal s_s00_eop_locked     : std_logic;
    signal s_s01_eop_locked     : std_logic;
    signal s_enable_mult        : std_logic; 
    signal s_enable_mult_vec    : std_logic_vector(5 downto 0);
    signal s_column_counter     : unsigned (2 downto 0);
    signal s_s00_req_addr       : unsigned (S00_REQ_BITS_LEN-1 downto 0);   
    signal s_s01_req_addr       : unsigned (S01_REQ_BITS_LEN-1 downto 0);   
    signal s_s02_req_addr       : unsigned (S02_REQ_BITS_LEN-1 downto 0); 
    signal s_busy               : std_logic;    
       
begin

    enable_mult <= s_enable_mult;
    s00_req_addr <= s_s00_req_addr;
    s01_req_addr <= s_s01_req_addr;
    s02_req_addr <= s_s02_req_addr;
    reset_sum <= '1' when (s_s00_req_addr = "000000100") else '0';
    valid_data_to_s02 <= '1' when ((s_enable_mult_vec(5) = '1' and s_s00_req_addr = "000000101") or (s_enable_mult_vec(5) = '1' and s_enable_mult_vec(4) = '0')) else '0';
    busy <= s_busy;
    
    -- EOP locked
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_s00_eop_locked <= '0';
                s_s01_eop_locked <= '0';
            else
                if(s00_eop = '1') then
                    s_s00_eop_locked <= '1';
                elsif((s_s00_req_addr = x"13F" and s_column_counter = x"7") or (start = '0')) then --319
                    s_s00_eop_locked <= '0';
                end if;                                                         
                
                if(s01_eop = '1') then
                    s_s01_eop_locked <= '1';
--                elsif(s_s01_req_addr = x"9FF") then --2559
                elsif(start = '0') then --2559
                    s_s01_eop_locked <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- Column counter
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_column_counter <= (others => '0');
            else
                if(s00_sop = '1') then
                    s_column_counter <= (others => '0');
                elsif(s_s00_req_addr = x"13F") then
                    s_column_counter <= s_column_counter + 1;
                else
                    s_column_counter <= s_column_counter;
                end if;
            end if;
        end if;
    end process;
    
    -- Enable mult
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_enable_mult <= '0';
            else
                if(s_s00_req_addr = x"13F" and s_column_counter = x"7") then --319
                    s_enable_mult <= '0';
                elsif(s_s00_eop_locked = '1' and s_s01_eop_locked = '1') then
                    s_enable_mult <= '1';
                else
                    s_enable_mult <= s_enable_mult;
                end if;
            end if;
        end if;
    end process;
    
    -- Enable mult reg
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_enable_mult_vec <= (others => '0');
            else
                s_enable_mult_vec <= s_enable_mult_vec(4 downto 0) & s_enable_mult;
            end if;
        end if;
    end process;
    
    -- Request address S00
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_s00_req_addr <= (others => '0');
            else
                if(s_enable_mult = '1') then
                    if(s_s00_req_addr = x"13F") then -- leitura de cada memória.                  
                        s_s00_req_addr <= (others => '0');
                    else
                        s_s00_req_addr <= s_s00_req_addr + 1;
                    end if;
                else
                    s_s00_req_addr <= (others => '0');
                end if;
            end if;
        end if;
    end process;    
    
    -- Request address S01
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_s01_req_addr <= (others => '0');
            else
                if(s_enable_mult = '1') then
                    if(s_s01_req_addr = x"9FF") then -- leitura de cada memória.                  
                        s_s01_req_addr <= (others => '0');
                    else
                        s_s01_req_addr <= s_s01_req_addr + 1;
                    end if;
                else
                    s_s01_req_addr <= (others => '0');
                end if;
            end if;
        end if;
    end process;    
    
    -- Request address S02
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_s02_req_addr <= (others => '0');
            else
                if(start = '0') then
                    s_s02_req_addr <= (others => '0');
                elsif((s_enable_mult_vec(5) = '1' and s_s00_req_addr = "000000101") or (s_enable_mult_vec(5) = '1' and s_enable_mult_vec(4) = '0')) then -- the same as valid_data_to_s02
                    if(s_s02_req_addr = x"4ff") then
                        s_s02_req_addr <= (others => '0');
                    else
                        s_s02_req_addr <= s_s02_req_addr + 1;
                    end if;
                else
                    s_s02_req_addr <= s_s02_req_addr;
                end if;
            end if;
        end if;
    end process;
    
    -- Busy
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_busy <= '0';
            else
                if(s00_sop = '1' or s01_sop = '1') then
                    s_busy <= '1';
                elsif(s_enable_mult_vec(2) = '0' and s_enable_mult_vec(3) = '1') then
                    s_busy <= '0';
                else
                    s_busy <= s_busy;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

