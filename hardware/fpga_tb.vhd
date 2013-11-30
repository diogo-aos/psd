LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY fpga_tb IS
END fpga_tb;
 
ARCHITECTURE behavior OF fpga_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fpga
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         done : OUT  std_logic;
         bus_memOUT : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
   
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal done : std_logic;
   signal bus_memOUT : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fpga PORT MAP (
          clk => clk,
          rst => rst,
          done => done,
          bus_memOUT => bus_memOUT
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      rst <= '1';
      wait for 100 ns;	
      rst <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
