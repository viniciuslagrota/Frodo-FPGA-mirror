----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/29/2020 06:41:10 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
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
end controller;

architecture Behavioral of controller is

    signal s_s00_eop_locked     : std_logic;
    signal s_s01_eop_locked     : std_logic;
    signal s_enable_mult        : std_logic; 
    signal s_enable_mult_vec    : std_logic_vector(5 downto 0);
    signal s_s00_req_addr       : unsigned (2 downto 0);   
    signal s_s01_req_addr       : unsigned (9 downto 0);    
    signal s_s02_req_addr       : unsigned (12 downto 0);     
    signal s_busy               : std_logic;     
       
begin

    enable_mult <= s_enable_mult;
    s00_req_addr <= s_s00_req_addr;
    s01_req_addr <= s_s01_req_addr;
    s02_req_addr <= s_s02_req_addr;
    valid_data_to_s02 <= s_enable_mult_vec(3);
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
                elsif(s_s01_req_addr >= x"027F") then --319
                    s_s00_eop_locked <= '0';
                end if;
                
                if(s01_eop = '1') then
                    s_s01_eop_locked <= '1';
                elsif(s_s01_req_addr >= x"027F") then --319
                    s_s01_eop_locked <= '0';
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
                if(s02_ready = '1') then
                    if(s_s00_req_addr >= x"7" and s_s01_req_addr >= x"027F") then --319
                        s_enable_mult <= '0';
                    elsif(s_s00_eop_locked = '1' and s_s01_eop_locked = '1') then
                        s_enable_mult <= '1';
                    else
                        s_enable_mult <= s_enable_mult;
                    end if;
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
                if(s02_ready = '1') then
                    if(s_enable_mult = '1') then
                        if(s_s01_req_addr < x"027F") then                    
                            s_s00_req_addr <= s_s00_req_addr;
                        else
                            s_s00_req_addr <= s_s00_req_addr + 1;
                        end if;
                    else
                        s_s00_req_addr <= (others => '0');
                    end if;
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
                if(s02_ready = '1') then
                    if(s_enable_mult = '1' and s_s01_req_addr < x"027F") then                    
                        s_s01_req_addr <= s_s01_req_addr + 1;
                    else
                        s_s01_req_addr <= (others => '0');
                    end if;
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
                if(s_enable_mult_vec(3) = '1' and s_s02_req_addr < x"13ff") then -- the same as valid_data_to_s02 -- 5119
                    s_s02_req_addr <= s_s02_req_addr + 1;
                else
                    s_s02_req_addr <= (others => '0');
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
                elsif(s_enable_mult_vec(4) = '0' and s_enable_mult_vec(5) = '1') then
                    s_busy <= '0';
                else
                    s_busy <= s_busy;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
