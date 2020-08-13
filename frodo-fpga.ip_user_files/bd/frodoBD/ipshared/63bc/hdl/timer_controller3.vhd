----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/13/2020 10:10:17 AM
-- Design Name: 
-- Module Name: timer_controller - Behavioral
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

entity timer_controller3 is
    port ( 
        clk                 : in std_logic;
        reset_n             : in std_logic;
        start               : in std_logic;
        busy                : in std_logic;
        enable_total_timer  : out std_logic;
        reset_total_timer   : out std_logic;
        enable_proc_timer   : out std_logic;
        reset_proc_timer    : out std_logic 
    );
end timer_controller3;

architecture Behavioral of timer_controller3 is

    -- Total and process timer signal
    signal s_start              : std_logic;
    signal s_busy               : std_logic;
    signal s_start_reg          : std_logic;
    signal s_busy_reg           : std_logic;
    signal s_enable_mult        : std_logic;
    signal s_enable_total_timer : std_logic;
    signal s_reset_total_timer  : std_logic;
    signal s_enable_proc_timer  : std_logic;
    signal s_reset_proc_timer   : std_logic;
    
begin

    s_start             <= start;
    s_busy              <= busy;
    enable_total_timer  <= s_enable_total_timer;
    reset_total_timer   <= s_reset_total_timer;
    enable_proc_timer   <= s_enable_proc_timer;
    reset_proc_timer    <= s_reset_proc_timer;

    -- Total timer
    process(clk)
    begin
        if(rising_edge(clk)) then       
            if(reset_n = '0') then
                s_enable_total_timer <= '0';
                s_reset_total_timer <= '0';
                s_start_reg <= '0';
            else
                s_start_reg <= s_start;
                if(s_start = '1' and s_start_reg = '0') then -- rising edge
                    s_enable_total_timer <= '0';
                    s_reset_total_timer <= '1';
                elsif(s_start = '0' and s_start_reg = '1') then -- falling edge
                    s_enable_total_timer <= '0';
                    s_reset_total_timer <= '0';
                else
                    if(s_reset_total_timer = '1') then
                        s_enable_total_timer <= '1';
                        s_reset_total_timer <= '0';
                    end if;
                end if;
            end if;
        end if;        
    end process;
        
    -- Proc timer
    process(clk)
    begin
        if(rising_edge(clk)) then       
            if(reset_n = '0') then
                s_enable_proc_timer <= '0';
                s_reset_proc_timer <= '0';
                s_busy_reg <= '0';
            else
                s_busy_reg <= s_busy;
                if(s_start = '1' and s_busy = '1' and s_busy_reg = '0') then -- rising edge
                    s_enable_proc_timer <= '0';
                    s_reset_proc_timer <= '1';
                elsif(s_start = '1' and s_busy = '0' and s_busy_reg = '1') then -- falling edge
                    s_enable_proc_timer <= '0';
                    s_reset_proc_timer <= '0';
                else
                    if(s_reset_proc_timer = '1') then
                        s_enable_proc_timer <= '1';
                        s_reset_proc_timer <= '0';
                    end if;
                end if;
            end if;
        end if;        
    end process;
        

end Behavioral;
