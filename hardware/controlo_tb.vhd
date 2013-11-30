--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:11:51 04/23/2010
-- Design Name:   
-- Module Name:   C:/users/hcn/vhdl/Basys2/BramCfgRefProj/teste3/controlo_tb.vhd
-- Project Name:  teste3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: controlo
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
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY controlo_tb IS
END controlo_tb;
 
ARCHITECTURE behavior OF controlo_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT controlo
    PORT(
         add1 : OUT  std_logic_vector(10 downto 0);
         add2 : OUT  std_logic_vector(10 downto 0);
         start : IN  std_logic;
         clk : IN  std_logic;
         rst : IN  std_logic;
         executing : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal start : std_logic := '0';
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal add1 : std_logic_vector(10 downto 0);
   signal add2 : std_logic_vector(10 downto 0);
   signal executing : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: controlo PORT MAP (
          add1 => add1,
          add2 => add2,
          start => start,
          clk => clk,
          rst => rst,
          executing => executing
        );

   -- Clock process definitions
   clk_process : process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   rst <= '1' after 10 ns, '0' after 100 ns;
	start <= '1' after 200 ns, '0' after 300 ns;

END;
