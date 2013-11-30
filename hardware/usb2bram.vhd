--
-- PrSD 2009/10 - Apoio ao Projecto 3
-- Adapta Projecto BramCfg disponibilizado pela Digilent.
-- Faz upload de ficheiro via usb para porto A da BlockRamIN. p/ placa
-- Faz download de ficheiro via usb do porto A da BlockRamOUT.
-- Permite visualizar conteudo das BlockRamIN e BlockRamOUT quando execucao parada.
-- Execucao inicia-se quando se activa o botao 1.
-- A datapath troca simplesmente os 4-bits menos siginificativos com os 4-bits mais
-- siginificativos do elemento da BlockRamIN e escreve o novo elemento na BlockRamOUT.
--
--------------------------------------------------------------------------------------
--
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:54:41 03/07/2008 
-- Design Name: 
-- Module Name:    BramCfg - Structural 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- This is the Digilent BramCfg reference project. 
-- It is an example for transferring data between a Block RAM and a PC.
-- The BramCfg project instantiates a Block RAM and interfaces it to 
-- an Epp port (the Digilent OnBoard USB circuitry and firmware)
-- It is used in conjunction with a program running on a PC (a Digilent
-- utility as TransPort or a user generated application) which in turn
-- uses the APIs provided by Digilent Adept Suite.
--
-- The BramCfg project connects to Block RAM port A and leaves all 
-- port B signals "open". Port B can be used for extending the project.
--
-- For more details about using the project, see the 
-- Digilent BramCfg Reference Project Manual
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity usb2bram is
  port ( 
-- Epp-like bus signals
    EppAstb: in std_logic;                       -- Address strobe
    EppDstb: in std_logic;                       -- Data strobe
    EppWr  : in std_logic;                       -- Port write signal
    EppDB  : inout std_logic_vector(7 downto 0); -- port data bus
    EppWait: out std_logic;                      -- Port wait signal

    mclk: in std_logic;
    btn: in std_logic_vector(3 downto 0);
    sw: in std_logic_vector(7 downto 0);
    led: out std_logic_vector(7 downto 0);
    an: out std_logic_vector(3 downto 0);
    seg: out std_logic_vector(6 downto 0);
    dp: out std_logic
    );

end usb2bram;

architecture Structural of usb2bram is

-- signals to interconnect the components
  signal BramDataOut   : std_logic_vector (7 downto 0);
  signal BramAdrIn     : std_logic_vector (10 downto 0);
  signal BramDataIn    : std_logic_vector (7 downto 0);
  signal BramWeIn      : std_logic;
  signal BramEnIn      : std_logic;
  signal BramClkIn     : std_logic;
  signal EppBusOut     : std_logic_vector (7 downto 0);
  signal EppBusIn      : std_logic_vector (7 downto 0);
  signal EppAdrOut     : std_logic_vector (4 downto 0);
  signal EppStbDataOut : std_logic;
  signal EppWrOut      : std_logic;
  signal selBramCtrl   : std_logic;

  signal adrB1, adrB2, adrB1cnt, adrB2cnt  : std_logic_vector (10 downto 0);
  signal dataB1, dataB2, dataB2in : std_logic_vector (7 downto 0);

  signal clk_disp7, clk_fast : std_logic;
  signal write_enable, is_executing, not_executing : std_logic;
  
-- component declarations
  component EppCtrlAsync
    port ( EppAstb   : in    std_logic; 
           EppDstb   : in    std_logic; 
           EppWr     : in    std_logic; 
           busIn     : in    std_logic_vector (7 downto 0); 
           sel0      : inout std_logic; 
           sel2      : inout std_logic; 
           sel4      : inout std_logic; 
           sel6      : inout std_logic; 
           sel8      : inout std_logic; 
           selA      : inout std_logic; 
           selC      : inout std_logic; 
           selE      : inout std_logic; 
           EppDB     : inout std_logic_vector (7 downto 0); 
           EppWait   : out   std_logic; 
           stbData   : out   std_logic; 
           ctlrWr    : out   std_logic; 
           outEppAdr : out   std_logic_vector (4 downto 0); 
           busOut    : out   std_logic_vector (7 downto 0));
  end component;
  
  component BramComCtrl
    port ( stbData     : in    std_logic; 
           ctrlWr      : in    std_logic; 
           selBram     : in    std_logic; 
           busEppIn    : in    std_logic_vector (7 downto 0); 
           busEppAdrIn : in    std_logic_vector (4 downto 0); 
           busBramIn   : in    std_logic_vector (7 downto 0); 
           ctlWeBram   : out   std_logic; 
           clkBram     : out   std_logic; 
           busEppOut   : out   std_logic_vector (7 downto 0); 
           busBramAdr  : out   std_logic_vector (10 downto 0); 
           busBramOut  : out   std_logic_vector (7 downto 0); 
           ctlEnBram   : out   std_logic);
  end component;
  
  component BlockRam
    port ( 
      ctlWeA : in    std_logic; 
      busDiA : in    std_logic_vector (7 downto 0); 
      busDoA : out   std_logic_vector (7 downto 0); 
      adrA   : in    std_logic_vector (10 downto 0); 
      ctlEnA : in    std_logic; 
      clkA   : in    std_logic; 
      ctlWeB : in    std_logic; 
      busDiB : in    std_logic_vector (7 downto 0); 
      busDoB : out   std_logic_vector (7 downto 0); 
      adrB   : in    std_logic_vector (10 downto 0); 
      ctlEnB : in    std_logic; 
      clkB   : in    std_logic
     );
  end component;
  
  component disp7
    port(
      disp4 : in std_logic_vector(3 downto 0);
      disp3 : in std_logic_vector(3 downto 0);
      disp2 : in std_logic_vector(3 downto 0);
      disp1 : in std_logic_vector(3 downto 0);
      clk : in std_logic;
      aceso : in std_logic_vector(4 downto 1);          
      en_disp : out std_logic_vector(4 downto 1);
      segm : out std_logic_vector(7 downto 1);
      dp : out std_logic
    );
  end component;

  component clkdiv
    port(
      clk : in std_logic;          
      clk50M  : out std_logic;
      clk10Hz : out std_logic;
      clk_disp : out std_logic
    );
  end component;

  component datapath
    port(
      clk : in std_logic;
      datain : in  std_logic_vector (7 downto 0);
      dataout : out  std_logic_vector (7 downto 0);
      finished_reading : out std_logic;
      freq_ram_enable : in std_logic;
      freq_ram_wenable : in std_logic;
		queue_ram_enable : in std_logic;
		queue_ram_wenable : in std_logic;	 
		adding_nodes : in std_logic;
		qAddFinish : out std_logic
    );
  end component;
  component controlo
    port(
      start, clk, rst : in std_logic;
      add1, add2 : out std_logic_vector(10 downto 0);
      executing : out std_logic;
      finished_reading : in std_logic;
      freq_ram_enable : out std_logic;
      freq_ram_wenable : out std_logic;
	   queue_ram_enable : out std_logic;
	   queue_ram_wenable : out std_logic;	 
	   adding_nodes : out std_logic;
		qAddFinish : in std_logic
    );
  end component;
  
  signal s_freq_ram_wenable, s_freq_ram_enable, s_finished_reading : std_logic;
  signal s_queue_ram_wenable, s_queue_ram_enable, s_adding_nodes, s_qAddFinish : std_logic;
begin

-- component instantiations
  EppCtrlAsyncInst : EppCtrlAsync port map (
    busIn     => EppBusIn,
    EppAstb   => EppAstb,
    EppDstb   => EppDstb,
    EppWr     => EppWr,
    busOut    => EppBusOut,
    ctlrWr    => EppWrOut,
    EppWait   => EppWait,
    outEppAdr => EppAdrOut,
    stbData   => EppStbDataOut,
    EppDB     => EppDB,
    selA      => open,
    selC      => open,
    selE      => open,
    sel0      => selBramCtrl,
    sel2      => open,
    sel4      => open,
    sel6      => open,
    sel8      => open
  );
  
  BramComCtrlInst : BramComCtrl port map (
    busBramIn   => BramDataOut,
    busEppAdrIn => EppAdrOut,
    busEppIn    => EppBusOut,
    ctrlWr      => EppWrOut,
    selBram     => selBramCtrl,
    stbData     => EppStbDataOut,
    busBramAdr  => BramAdrIn,
    busBramOut  => BramDataIn,
    busEppOut   => EppBusIn,
    clkBram     => BramClkIn,
    ctlEnBram   => BramEnIn,
    ctlWeBram   => BramWeIn
  );
  
  BlockRamIN : BlockRam port map (
    adrA   => BramAdrIn,
    adrB   => adrB1,
    busDiA => BramDataIn,
    busDiB => "00000000",
    clkA   => BramClkIn,
    clkB   => clk_fast,
    ctlEnA => BramEnIn,
    ctlEnB => '1',
    ctlWeA => BramWeIn,
    ctlWeB => '0',
    busDoA => open,
    busDoB => dataB1
  );
    
  BlockRamOUT : BlockRam port map (
    adrA   => BramAdrIn,
    adrB   => adrB2,
    busDiA => "00000000",
    busDiB => dataB2in,
    clkA   => BramClkIn,
    clkB   => clk_fast,
    ctlEnA => BramEnIn,
    ctlEnB => '1',
    ctlWeA => '0',
    ctlWeB => write_enable,
    busDoA => BramDataOut,
    busDoB => dataB2
  );

  inst_disp7: disp7 port map(
    disp4 => dataB1(7 downto 4),
    disp3 => dataB1(3 downto 0),
    disp2 => dataB2(7 downto 4),
    disp1 => dataB2(3 downto 0),
    clk => clk_disp7,
    aceso => "1111",
    en_disp => an,
    segm => seg,
    dp => dp
  );

  inst_clkdiv: clkdiv port map(
    clk => mclk,
    clk50m => clk_fast,
    clk10hz => open,
    clk_disp => clk_disp7
  );

  -- 6 leftmost leds show the 6 lower bits of the adress counter.
  led <= adrB1cnt(5 downto 0) & '0' & not_executing;
  
  -- address values are defined by the control during execution
  -- and by the board switches when not executing
  adrB1 <= adrB1cnt;
  adrB2 <= adrB2cnt;
  write_enable <= is_executing;
  not_executing <= not is_executing;
  
  Inst_datapath: datapath port map(
     clk => clk_fast,
     freq_ram_enable => s_freq_ram_enable,
     freq_ram_wenable => s_freq_ram_wenable,
     datain => dataB1,
     dataout => dataB2in,
     finished_reading => s_finished_reading,
	  queue_ram_enable => s_queue_ram_enable,
     queue_ram_wenable => s_queue_ram_wenable,
	  adding_nodes => s_adding_nodes,
	  qAddFinish => s_qAddFinish
  );

  Inst_controlo: controlo port map(
    add1 => adrB1cnt,
    add2 => adrB2cnt,
    start => btn(1),
    clk => clk_fast,
    rst => btn(0),
    executing => is_executing,
    freq_ram_enable => s_freq_ram_enable,
    freq_ram_wenable => s_freq_ram_wenable,
    finished_reading => s_finished_reading,
    queue_ram_enable => s_queue_ram_enable,
    queue_ram_wenable => s_queue_ram_wenable,
	 adding_nodes => s_adding_nodes,
	 qAddFinish => s_qAddFinish
  );
end Structural;
