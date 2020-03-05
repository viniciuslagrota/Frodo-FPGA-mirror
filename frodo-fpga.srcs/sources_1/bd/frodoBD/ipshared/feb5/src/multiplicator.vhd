----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/29/2020 07:43:40 PM
-- Design Name: 
-- Module Name: multiplicator - Behavioral
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

entity multiplicator is
    port(
        clk : in std_logic;
        aresetn     : in std_logic;
        s00_data_0  : in std_logic_vector(15 downto 0);
        s00_data_1  : in std_logic_vector(15 downto 0);
        s00_data_2  : in std_logic_vector(15 downto 0);
        s00_data_3  : in std_logic_vector(15 downto 0);
        s00_data_4  : in std_logic_vector(15 downto 0);
        s00_data_5  : in std_logic_vector(15 downto 0);
        s00_data_6  : in std_logic_vector(15 downto 0);
        s00_data_7  : in std_logic_vector(15 downto 0);
        s01_data_0  : in std_logic_vector(15 downto 0);
        data_out_0  : out std_logic_vector(15 downto 0);
        data_out_1  : out std_logic_vector(15 downto 0);
        data_out_2  : out std_logic_vector(15 downto 0);
        data_out_3  : out std_logic_vector(15 downto 0);
        data_out_4  : out std_logic_vector(15 downto 0);
        data_out_5  : out std_logic_vector(15 downto 0);
        data_out_6  : out std_logic_vector(15 downto 0);
        data_out_7  : out std_logic_vector(15 downto 0)
    );
end multiplicator;

architecture Behavioral of multiplicator is

    signal s_s01_data_0 : integer;
    
begin

    s_s01_data_0 <= to_integer(unsigned(s01_data_0));
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                data_out_0 <= (others => '0');
                data_out_1 <= (others => '0');
                data_out_2 <= (others => '0');
                data_out_3 <= (others => '0');
                data_out_4 <= (others => '0');
                data_out_5 <= (others => '0');
                data_out_6 <= (others => '0');
                data_out_7 <= (others => '0');
            else
                data_out_0 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_0)) * s_s01_data_0, data_out_0'length));
                data_out_1 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_1)) * s_s01_data_0, data_out_1'length));
                data_out_2 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_2)) * s_s01_data_0, data_out_2'length));
                data_out_3 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_3)) * s_s01_data_0, data_out_3'length));
                data_out_4 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_4)) * s_s01_data_0, data_out_4'length));
                data_out_5 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_5)) * s_s01_data_0, data_out_5'length));
                data_out_6 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_6)) * s_s01_data_0, data_out_6'length));
                data_out_7 <= std_logic_vector(to_unsigned(to_integer(unsigned(s00_data_7)) * s_s01_data_0, data_out_7'length));
            end if;
        end if;
    end process;

end Behavioral;
