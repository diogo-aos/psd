------------------------------------------------------------------------
-- Company: Digilent RO
-- Engineer: Mircea Dabacan
--
-- Create Date:    12:08:37 10/13/06
-- Design Name:    
-- Module Name:    BramComCtrl - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  Xilinx ISE 9.2 WebPaclk
-- Description:
--
-- This is the design of a simple, asynchronous BRAM controller.
-- All data transfers are synchronized only with the external 
-- EppAstb and EppDstb strobes.
-- The BRAM controller is a client of a Digilent Epp Asynchronous 
-- Interface Module, EppCtrlAsync. It is used in conjunction 
-- with a program running on a PC (a Digilent utility as TransPort or a 
-- user generated application) which in turn uses the APIs provided by  
-- Digilent Adept Suite.
-- The BRAM controller implements a BRAM address register (regBramAdr),
-- pointing the BRAM address for the next byte to be written or read.
-- regBramAdr can be written or read on the falling edge of EppDstb,  
-- when regEppAdr = "xxx00001" (lower byte) or "xxx00010" (higher byte). 
-- The BRAM data byte at address shown by regBramAdr can be written or 
-- read on the falling edge of EppDstb, when regEppAdr is "xxx00000".
-- The rising edge of EppDstb increments regBramAdr by one. This way, 
-- successive BRAM data read or write operations will access successive
-- BRAM addresses (auto address post increment).

-- Resuming, the BRAM controller:
--   - implements the regBramAdr register/counter for BRAM address bus
--   - transparently sends the data bus from EPP controller to the BRAM.
--   - sends to the EppCtrlAsync either BRAM data or regBramAdr content.  
--   - provides inverted EppDstb to be used as BRAM clock
--   - provides Enable signal to BRAM, when regEppAdr is "xxx00000". 
--   - provides Write Enable signal to BRAM, when regEppAdr = "xxx00000"
--     and EPP ctrlWr is active (LOW). 
--
-- Dependencies:
-- 
-- Revision:
--   08/18/2006(MirceaD): created
--   03/06/2008(MirceaD): reference component 
--
-- Additional Comments:
-- 
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BramComCtrl is
    generic(
           constant n: integer := 11);	    --Bram Address Bus size

    Port ( 
     -- Interface to the EppCtrl
           stbData : in std_logic;  -- Epp Data Strobe
           ctrlWr : in std_logic;   -- Epp Address Strobe
           selBram : in std_logic;  -- BramComCtrl select signal 
           busEppIn : in std_logic_vector(7 downto 0);   
			      --input data bus from EppCtrlAsync
           busEppOut : out std_logic_vector(7 downto 0); 
			      --output data bus for EppCtrlAsync
           busEppAdrIn : in std_logic_vector(4 downto 0);
			      -- lower bits of EppAddress register
     -- Interface to Bram
           busBramAdr: out std_logic_vector(n-1 downto 0);
               -- BRAM address bus
           busBramIn : in std_logic_vector(7 downto 0);   
			      --input data bus from BRAM
           busBramOut : out std_logic_vector(7 downto 0); 
			      --output data bus for BRAM
           ctlEnBram : out std_logic;   -- Bram Enable
           ctlWeBram : out std_logic;   -- BRAM Write Enable
           clkBram : out std_logic);    -- BRAM clock


end BramComCtrl;

architecture Behavioral of BramComCtrl is

constant adrBramDB:  std_logic_vector(1 downto 0) := "00"; 
     --  0 Memory control register (read/write)
constant adrBramAdrL:     std_logic_vector(1 downto 0) := "01";
     --  1 Memory address bits 0-7 (read/write)
constant adrBramAdrH:     std_logic_vector(1 downto 0) := "10";
     --  2 Memory address bits 8-15 (read/write)

constant cstGnd: std_logic_vector(16-n-1 downto 0) := (others => '0');

signal carryOutL: std_logic; -- carry for regBramAdr
signal regBramAdr: std_logic_vector(n-1 downto 0):= (others => '0');

begin

-- reading Bram data or Address Register 
  busEppOut <= 
    x"00"                  -- prepared for "OR"-ing
      when selBram = '0' else                -- BramComCtrl not selected
    busBramIn              -- transparent from BRAM 
      when busEppAdrIn(1 downto 0) = adrBramDB else     -- BRAM selected
    regBramAdr(7 downto 0) -- lower address byte
	   when busEppAdrIn(1 downto 0) = adrBramAdrL else --adr low selected
    cstGnd & regBramAdr(n-1 downto 8) --higher addr bits with leading 0s
	   when busEppAdrIn(1 downto 0) = adrBramAdrH else--adr high selected
    x"00";                 -- prepared for "OR"-ing when other address

  -- BramAddress Register/Counter
  process (stbData, ctrlWr, selBram)
    begin
      if selBram = '1' then      -- access to BramComCtrl
        if stbData'event and stbData = '1' then 
		                           -- stbData rising edge (end)
          if busEppAdrIn(1 downto 0) = adrBramDB then  
			                        -- automatic memory cycle
            regBramAdr(7 downto 0) <= regBramAdr(7 downto 0) + 1; 
				                     -- increment address 
          elsif ctrlWr = '0' and -- write
			       busEppAdrIn(1 downto 0) = adrBramAdrL then  
					                  -- to regBramAdr Low
            regBramAdr(7 downto 0) <= busEppIn;     
				                     -- update MemAdrL content
          end if;
        end if;
      end if;

      if selBram = '1' then       -- access to BramComCtrl
        if stbData'event and stbData = '1' then 
		                            -- stbData rising edge (end)
          if busEppAdrIn(1 downto 0) = adrBramDB and  
			                         -- automatic memory cycle
             carryOutL = '1' then -- lower byte rollover
            regBramAdr(n-1 downto 8) <= regBramAdr(n-1 downto 8) + 1; 
				                      -- inc. address 
          elsif ctrlWr = '0' and  -- write
			       busEppAdrIn(1 downto 0) = adrBramAdrH then  
					                   -- to regBramAdr Low
            regBramAdr(n-1 downto 8) <= busEppIn(n-8-1 downto 0);
                                  -- update MemAdrL content
          end if;
        end if;
      end if;

  end process;

    carryOutL <= '1' when regBramAdr(7 downto 0) = x"ff" else 
                 '0';             -- Lower byte carry out

-- BRAM interface
  -- Bram clock
clkBram <= not stbData;

  -- Bram En
ctlEnBram <= 
   '1' when selBram = '1' and   -- BramComCtrl selected
            busEppAdrIn(1 downto 0) = adrBramDB else  --Bram Data access
   '0';

  -- Bram We
ctlWeBram <= 
   '1' when selBram = '1' and   -- BramComCtrl selected
            ctrlWr = '0' and    -- write cycle
	         busEppAdrIn(1 downto 0) = adrBramDB else  --Bram Data access
   '0';
  -- Bram DB
busBramOut <= busEppIn;

  -- Bram Adr
busBramAdr <= regBramAdr;


end Behavioral;
