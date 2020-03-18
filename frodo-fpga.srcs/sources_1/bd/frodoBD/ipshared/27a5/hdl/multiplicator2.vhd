----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2020 08:43:01 PM
-- Design Name: 
-- Module Name: multiplicator2 - Behavioral
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

entity multiplicator2 is
    generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32
		);
    port(
        clk         : in std_logic;
        aresetn     : in std_logic;
        reset_sum   : in std_logic;
        s00_data_0  : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s00_data_1  : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s00_data_2  : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s00_data_3  : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s01_data_0  : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s02_data_0  : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        s02_data_1  : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        s02_data_2  : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0);
        s02_data_3  : out std_logic_vector(C_S_AXI_DATA_WIDTH/2-1 downto 0)
    );
end multiplicator2;

architecture Behavioral of multiplicator2 is

    -- S00 (Input)
    signal s_s00_data_upper_0     : integer;
    signal s_s00_data_lower_0     : integer;
    signal s_s00_data_upper_1     : integer;
    signal s_s00_data_lower_1     : integer;
    signal s_s00_data_upper_2     : integer;
    signal s_s00_data_lower_2     : integer;
    signal s_s00_data_upper_3     : integer;
    signal s_s00_data_lower_3     : integer;
    
    -- S01 (Input)
    signal s_s01_data_upper_0     : integer;
    signal s_s01_data_lower_0     : integer;
    
    -- Multiplication register (Internal)
    signal s_mult_data_upper_0    : integer;
    signal s_mult_data_lower_0    : integer;
    signal s_mult_data_upper_1    : integer;
    signal s_mult_data_lower_1    : integer;
    signal s_mult_data_upper_2    : integer;
    signal s_mult_data_lower_2    : integer;
    signal s_mult_data_upper_3    : integer;
    signal s_mult_data_lower_3    : integer;
    
    -- S02 (Output)
    signal s_s02_data_0     : integer;    
    signal s_s02_data_1     : integer;  
    signal s_s02_data_2     : integer;  
    signal s_s02_data_3     : integer;  
    
begin

    -- S00
    s_s00_data_upper_0 <= conv_integer(s00_data_0(C_S_AXI_DATA_WIDTH-1 downto C_S_AXI_DATA_WIDTH/2));
    s_s00_data_lower_0 <= conv_integer(s00_data_0(C_S_AXI_DATA_WIDTH/2-1 downto 0));
    s_s00_data_upper_1 <= conv_integer(s00_data_1(C_S_AXI_DATA_WIDTH-1 downto C_S_AXI_DATA_WIDTH/2));
    s_s00_data_lower_1 <= conv_integer(s00_data_1(C_S_AXI_DATA_WIDTH/2-1 downto 0));
    s_s00_data_upper_2 <= conv_integer(s00_data_2(C_S_AXI_DATA_WIDTH-1 downto C_S_AXI_DATA_WIDTH/2));
    s_s00_data_lower_2 <= conv_integer(s00_data_2(C_S_AXI_DATA_WIDTH/2-1 downto 0));
    s_s00_data_upper_3 <= conv_integer(s00_data_3(C_S_AXI_DATA_WIDTH-1 downto C_S_AXI_DATA_WIDTH/2));
    s_s00_data_lower_3 <= conv_integer(s00_data_3(C_S_AXI_DATA_WIDTH/2-1 downto 0));
    
    -- S01
    s_s01_data_upper_0 <= conv_integer(s01_data_0(C_S_AXI_DATA_WIDTH-1 downto C_S_AXI_DATA_WIDTH/2));
    s_s01_data_lower_0 <= conv_integer(s01_data_0(C_S_AXI_DATA_WIDTH/2-1 downto 0));  
    
    -- S02
    s02_data_0 <= std_logic_vector(to_unsigned(s_s02_data_0, s02_data_0'length));
    s02_data_1 <= std_logic_vector(to_unsigned(s_s02_data_1, s02_data_1'length));
    s02_data_2 <= std_logic_vector(to_unsigned(s_s02_data_2, s02_data_2'length));
    s02_data_3 <= std_logic_vector(to_unsigned(s_s02_data_3, s02_data_3'length));    

    -- Multiply
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_mult_data_upper_0 <= 0;
                s_mult_data_lower_0 <= 0;
                s_mult_data_upper_1 <= 0;
                s_mult_data_lower_1 <= 0;
                s_mult_data_upper_2 <= 0;
                s_mult_data_lower_2 <= 0;
                s_mult_data_upper_3 <= 0;
                s_mult_data_lower_3 <= 0;
            else
                s_mult_data_upper_0 <= s_s00_data_upper_0 * s_s01_data_upper_0;
                s_mult_data_lower_0 <= s_s00_data_lower_0 * s_s01_data_lower_0;
                s_mult_data_upper_1 <= s_s00_data_upper_1 * s_s01_data_upper_0;
                s_mult_data_lower_1 <= s_s00_data_lower_1 * s_s01_data_lower_0;
                s_mult_data_upper_2 <= s_s00_data_upper_2 * s_s01_data_upper_0;
                s_mult_data_lower_2 <= s_s00_data_lower_2 * s_s01_data_lower_0;
                s_mult_data_upper_3 <= s_s00_data_upper_3 * s_s01_data_upper_0;
                s_mult_data_lower_3 <= s_s00_data_lower_3 * s_s01_data_lower_0;
            end if;
        end if;
    end process;

    -- Sum
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(aresetn = '0') then
                s_s02_data_0 <= 0;
                s_s02_data_1 <= 0;
                s_s02_data_2 <= 0;
                s_s02_data_3 <= 0;
            else
                if(reset_sum = '1') then
                    s_s02_data_0 <= s_mult_data_upper_0 + s_mult_data_lower_0;
                    s_s02_data_1 <= s_mult_data_upper_1 + s_mult_data_lower_1;
                    s_s02_data_2 <= s_mult_data_upper_2 + s_mult_data_lower_2;
                    s_s02_data_3 <= s_mult_data_upper_3 + s_mult_data_lower_3;                  
                else
                    s_s02_data_0 <= s_s02_data_0 + s_mult_data_upper_0 + s_mult_data_lower_0;
                    s_s02_data_1 <= s_s02_data_1 + s_mult_data_upper_1 + s_mult_data_lower_1;
                    s_s02_data_2 <= s_s02_data_2 + s_mult_data_upper_2 + s_mult_data_lower_2;
                    s_s02_data_3 <= s_s02_data_3 + s_mult_data_upper_3 + s_mult_data_lower_3;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
