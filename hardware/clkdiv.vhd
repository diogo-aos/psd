library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity clkdiv is
  Port (
    clk : in std_logic;
    clk50M, clk10Hz, clk_disp : out std_logic
    );
end clkdiv;

architecture mixed of clkdiv is

  signal clk_i : std_logic;
  signal cnt : std_logic_vector(23 downto 0);

begin

  BUFG_INST1: BUFG port map (I => clk, O => clk_i);
  clk50M <= clk_i;

  -- Divide the master clock (50Mhz) down to an aprox 10Hz frequency.
  process (clk_i)
  begin
    if clk_i = '1' and clk_i'event then
      if cnt = X"4C4B3F" then         -- x4C4B3F = 5000000-1
        cnt <= (others => '0');
      else
        cnt <= cnt + 1;
      end if;
    end if;
  end process;

  -- BUFG: Global Clock Buffer (source by an internal signal)
  -- Xilinx HDL Language Template version 8.1i

  BUFG_INST2: BUFG port map (I => cnt(22), O => clk10Hz);
  BUFG_INST3: BUFG port map (I => cnt(15), O => clk_disp);
  
end mixed;
