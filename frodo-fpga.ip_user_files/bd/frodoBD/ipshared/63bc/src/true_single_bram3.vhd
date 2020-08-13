----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/10/2020 08:05:04 PM
-- Design Name: 
-- Module Name: true_single_bram3 - Behavioral
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
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity true_single_bram3 is
    generic(
        MEM_SIZE    : integer;
        WORD_SIZE   : integer
    );
    port(
        clk    : in std_logic;
        en     : in std_logic;
        we     : in std_logic;
        addr   : in std_logic_vector(integer(ceil(log2(real(MEM_SIZE))))-1 downto 0);
        di     : in std_logic_vector(WORD_SIZE-1 downto 0);
        do     : out std_logic_vector(WORD_SIZE-1 downto 0)
    );
end true_single_bram3;

architecture Behavioral of true_single_bram3 is

    type ram_type is array (MEM_SIZE-1 downto 0) of std_logic_vector(WORD_SIZE-1 downto 0);
    shared variable RAM : ram_type;
    
begin

    process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '1' then
                do <= RAM(conv_integer(addr));
                if we = '1' then
                    RAM(conv_integer(addr)) := di;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
    