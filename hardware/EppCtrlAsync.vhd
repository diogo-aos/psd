--------------------------------------------------------------------------------
-- Company: Digilent RO
-- Engineer: Mircea Dabacan
--
-- Create Date:    12:08:37 10/13/06
-- Design Name:    
-- Module Name:    EppCtrlAsync.vhd - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  Xilinx ISE 9.2 WebPaclk
-- Description:
--
-- Digilent Epp Asynchronous Interface Module
-- 
-- This is the design of a simple, asynchronous Epp controller.
-- All data transfers are synchronized only with the external 
-- EppAstb and EppDstb strobes.
-- The Epp controller serves as interface between an Epp compatible port
-- (emulated by the Digilent OnBoard USB circuitry and firmware) and 
-- client components in the user HDL project. It is used in conjunction 
-- with a program running on a PC (a Digilent utility as TransPort or a 
-- user generated application) which in turn uses the APIs provided by  
-- Digilent Adept Suite.
-- The Epp controller implements the Epp address register (regEppAdr),
-- which can be written and read with EppAstb active. regEppAdr is 
-- written on the falling edge of EppAstb, when EppWr is active (LOW).
-- The upper 3 bits are decoded to generate SELECT signals for clients.
-- The lower 5 bits are made available for clients.
-- EppDstb and EppWr are passed to clients.
-- EppWait is asserted inactive (HIGH) asynchronously when either 
-- EppAstb or EppDstb are active (LOW). No Wait states are requested. 
-- The bidirectional EppDB is split in busIn and busOut for clients.
-- busOut always repeats EppDB.
-- EppDB is set HiZ when EppWr is inactive (HIGH).
-- Otherwise, EppDB sends either regEppAdr (when EppAstb is active)
-- or the client busIn (when EppAstb is inactive)  
--
-- Dependencies:
-- 
-- Revision:
--   08/18/2006(MirceaD): created
--   03/06/2008(MirceaD): reference component 
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EppCtrlAsync is
    Port (
-- Epp-like bus signals
      EppAstb: in std_logic;        -- Address strobe
      EppDstb: in std_logic;        -- Data strobe
      EppWr  : in std_logic;        -- Port write signal
      EppDB  : inout std_logic_vector(7 downto 0); -- port data bus
      EppWait: out std_logic;        -- Port wait signal
-- select signals
      sel0, sel2, sel4, sel6: inout std_logic; -- sel signals
      sel8, selA, selC, selE: inout std_logic; -- sel signals
-- EppAdr out for extended selection 
      outEppAdr: out std_logic_vector (4 downto 0); -- lower Epp address
-- data strobe
      stbData: out std_logic;  -- data strobe for clients
      ctlrWr: out std_logic;   -- write control signal for clients
-- application busses
      busIn: in std_logic_vector(7 downto 0);  -- data from clients 
      busOut: out std_logic_vector(7 downto 0) -- data to clients
         );
end EppCtrlAsync;

architecture Behavioral of EppCtrlAsync is

------------------------------------------------------------------------
-- Constant and Signal Declarations
------------------------------------------------------------------------
-- Epp address Register
signal regEppAdr: std_logic_vector(7 downto 0):=x"00"; -- Epp address

signal busEppInternal: std_logic_vector(7 downto 0);
 
------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
    
begin

-- Map basic select and control signals for clients
  outEppAdr <= regEppAdr(4 downto 0);
  stbData <= EppDstb;
  ctlrWr <= EppWr;

-- Map output data bus for clients
  busOut <= EppDB;

-- register select signals for clients
  sel0 <= '1' when regEppAdr(7 downto 5) = "000" else -- Epp address 0x, 1x 
          '0';
  sel2 <= '1' when regEppAdr(7 downto 5) = "001" else -- Epp address 2x, 3x 
          '0';
  sel4 <= '1' when regEppAdr(7 downto 5) = "010" else -- Epp address 4x, 5x 
          '0';
  sel6 <= '1' when regEppAdr(7 downto 5) = "011" else -- Epp address 6x, 7x
          '0';
  sel8 <= '1' when regEppAdr(7 downto 5) = "100" else -- Epp address 8x, 9x
          '0';
  selA <= '1' when regEppAdr(7 downto 5) = "101" else -- Epp address Ax, Bx
          '0';
  selC <= '1' when regEppAdr(7 downto 5) = "110" else -- Epp address Cx, Dx
          '0';
  selE <= '1' when regEppAdr(7 downto 5) = "111" else -- Epp address Ex, Fx
          '0';    
-- Epp signals
   -- Port signals
   EppWait <= '1' when EppAstb = '0' or EppDstb = '0' else '0';
             -- asynchronous Wait asserting (maximal Epp speed)

   -- three state for Epp data bus
   EppDB <= busEppInternal when (EppWr = '1') else "ZZZZZZZZ";

   -- combining client input data bus with reading regEppAdr
   busEppInternal <= 
       regEppAdr when EppAstb = '0' else
       busIn;

  -- EPP Address register
  process (EppAstb)
    begin
      if EppAstb = '0' and EppAstb'Event then  -- EppAstb falling edge
        if EppWr = '0' then            -- Epp Address write cycle
          regEppAdr <= EppDB;          -- Epp Address register update
        end if;
      end if;
    end process;

end Behavioral;

