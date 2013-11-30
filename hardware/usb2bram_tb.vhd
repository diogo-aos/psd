LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY usb2bram_tb IS
END usb2bram_tb;
 
ARCHITECTURE behavior OF usb2bram_tb IS 

    COMPONENT usb2bram
    PORT(
         EppAstb : IN  std_logic;
         EppDstb : IN  std_logic;
         EppWr : IN  std_logic;
         EppDB : INOUT  std_logic_vector(7 downto 0);
         EppWait : OUT  std_logic;
         mclk : IN  std_logic;
         btn : IN  std_logic_vector(3 downto 0);
         sw : IN  std_logic_vector(7 downto 0);
         led : OUT  std_logic_vector(7 downto 0);
         an : OUT  std_logic_vector(3 downto 0);
         seg : OUT  std_logic_vector(6 downto 0);
         dp : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal EppAstb : std_logic := '0';
   signal EppDstb : std_logic := '0';
   signal EppWr : std_logic := '0';
   signal mclk : std_logic := '0';
   signal btn : std_logic_vector(3 downto 0) := (others => '0');
   signal sw : std_logic_vector(7 downto 0) := (others => '0');

	--BiDirs
   signal EppDB : std_logic_vector(7 downto 0);

 	--Outputs
   signal EppWait : std_logic;
   signal led : std_logic_vector(7 downto 0);
   signal an : std_logic_vector(3 downto 0);
   signal seg : std_logic_vector(6 downto 0);
   signal dp : std_logic;

   -- Clock period definitions
   constant mclk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: usb2bram PORT MAP (
          EppAstb => EppAstb,
          EppDstb => EppDstb,
          EppWr => EppWr,
          EppDB => EppDB,
          EppWait => EppWait,
          mclk => mclk,
          btn => btn,
          sw => sw,
          led => led,
          an => an,
          seg => seg,
          dp => dp
        );

   -- Clock process definitions
   mclk_process :process
   begin
      mclk <= '0';
      wait for mclk_period/2;
      mclk <= '1';
      wait for mclk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for mclk_period*10;

      -- insert stimulus here 

      wait;
   end process;
   
   btn(0) <= '1' after 5 ns, '0' after 10 ns;
   btn(1) <= '1' after 15 ns, '0' after 30 ns;

END;
