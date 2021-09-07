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
use IEEE.std_logic_unsigned.all;

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
        s01_data_0  : in std_logic_vector(15 downto 0);
        s01_data_1  : in std_logic_vector(15 downto 0);
        s01_data_2  : in std_logic_vector(15 downto 0);
        s01_data_3  : in std_logic_vector(15 downto 0);
        data_out_0  : out std_logic_vector(15 downto 0)
    );
end multiplicator;

architecture Behavioral of multiplicator is

    signal s_s00_data_0     : integer;
    signal s_s00_data_1     : integer;
    signal s_s00_data_2     : integer;
    signal s_s00_data_3     : integer;
    signal s_s01_data_0     : integer;
    signal s_s01_data_1     : integer;
    signal s_s01_data_2     : integer;
    signal s_s01_data_3     : integer;
    
    signal s_mult_data_0    : integer;
    signal s_mult_data_1    : integer;
    signal s_mult_data_2    : integer;
    signal s_mult_data_3    : integer;
    
    signal s_data_out_0     : integer;    
    
begin

    s_s00_data_0 <= conv_integer(s00_data_0);
    s_s00_data_1 <= conv_integer(s00_data_1);
    s_s00_data_2 <= conv_integer(s00_data_2);
    s_s00_data_3 <= conv_integer(s00_data_3);
    s_s01_data_0 <= conv_integer(s01_data_0);
    s_s01_data_1 <= conv_integer(s01_data_1);
    s_s01_data_2 <= conv_integer(s01_data_2);
    s_s01_data_3 <= conv_integer(s01_data_3);
    
    data_out_0 <= std_logic_vector(to_unsigned(s_data_out_0, data_out_0'length));
    
    -- Multiply
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_mult_data_0 <= 0;
                s_mult_data_1 <= 0;
                s_mult_data_2 <= 0;
                s_mult_data_3 <= 0;
            else
                s_mult_data_0 <= s_s00_data_0 * s_s01_data_0;
                s_mult_data_1 <= s_s00_data_1 * s_s01_data_1;
                s_mult_data_2 <= s_s00_data_2 * s_s01_data_2;
                s_mult_data_3 <= s_s00_data_3 * s_s01_data_3;
            end if;
        end if;
    end process;

    -- Sum
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_data_out_0 <= 0;
            else
                s_data_out_0 <= s_mult_data_0 + s_mult_data_1 + s_mult_data_2 + s_mult_data_3;
            end if;
        end if;
    end process;

end Behavioral;
