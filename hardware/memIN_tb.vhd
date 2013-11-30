--------------------------------------------------------------------------------
-- Description:
--
-- VHDL Test Bench Created by ISE for module: memsdata
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the
-- post-implementation simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity memIN_tb is
end memIN_tb;

architecture behavior of memIN_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component MemIN
    port(
      addr     : in  std_logic_vector(8 downto 0);
      a,b,c    : out std_logic_vector(7 downto 0);
      steep, xi: out std_logic_vector(7 downto 0);
      clk      : in  std_logic
      );
  end component;


  --Inputs
  signal addr : std_logic_vector(8 downto 0) := (others => '0');
  signal clk  : std_logic                     := '0';

  --Outputs
  signal a, b, c   : std_logic_vector(7 downto 0);
  signal steep, xi : std_logic_vector(7 downto 0);

  -- Clock period definitions
  constant clk_period : time := 20 ns;  -- T = 20 ns, f = 50 MHz

  signal run : std_logic := '0';
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : MemIN port map (
    addr     => addr,
    a => a,
    b => b,
    c => c,
    steep => steep,
    xi => xi,
    clk => clk
    );


-- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100ms.
    wait for 100 ns;
    run <= '1';
    -- insert stimulus here
  end process;

  address_counter : process
  begin
    wait for 20 ns;
    if (run = '1') then
      if addr = "000000100" then
        addr <= "000000000";
      else
        addr <= addr + 1;
      end if;
    end if;
  end process;

end;
