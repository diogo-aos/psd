library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity disp7 is
  port (
   disp4, disp3, disp2, disp1 : in std_logic_vector(3 downto 0);
   clk : in std_logic;
   aceso : in std_logic_vector(4 downto 1);
   en_disp : out std_logic_vector(4 downto 1);
   segm : out std_logic_vector(7 downto 1);
   dp : out std_logic
  );
end disp7;

architecture mixed of disp7 is

  type STATE_TYPE is (S0, S1, S2);
  signal cs, ns : STATE_TYPE;
  signal d1, d2, d3, d4, en, hex : std_logic_vector(3 downto 0);
  signal led : std_logic_vector(7 downto 0);
  signal count : std_logic_vector(1 downto 0);
  signal cnt_en, srg_en, en_oe : std_logic;
  signal srg_out : std_logic_vector(3 downto 0) := "1000";

begin

  d1<=disp1;
  d2<=disp2;
  d3<=disp3;
  d4<=disp4;

-- 2 bit counter
  process (clk)
  begin
    if rising_edge(clk) then
      if cnt_en = '1' then
        count <= count + 1;
      end if;
    end if;
  end process;

-- en rotate
  process (clk)
  begin
    if rising_edge(clk) then
      if srg_en = '1' then
        srg_out <= srg_out(0) & srg_out(3 downto 1);
      end if;
    end if;
  end process;
  en <= srg_out when en_oe='1' else (others=>'0');

-- 4-to-1 Mux
  with count select
    hex <= d4 when "00",
    d3 when "01",
    d2 when "10",
    d1 when others;

-- hex2led (decimal point is MSB)
  with hex select
    led <= "11111001" when "0001",   --1
    "10100100" when "0010",   --2
    "10110000" when "0011",   --3
    "10011001" when "0100",   --4
    "10010010" when "0101",   --5
    "10000010" when "0110",   --6
    "11111000" when "0111",   --7
    "10000000" when "1000",   --8
    "10010000" when "1001",   --9
    "10001000" when "1010",   --A
    "10000011" when "1011",   --b
    "11000110" when "1100",   --C
    "10100001" when "1101",   --d
    "10000110" when "1110",   --E
    "10001110" when "1111",   --F
    "11000000" when others;   --0

-- state machine
  cs <= ns when rising_edge(clk) else cs; 

  process (cs)
  begin
    en_oe <= '0';
    srg_en <= '0';
    cnt_en <= '0';
    case cs is
      when S0 =>
        ns <= S1;
      when S1 =>
        en_oe <= '1';
        ns <= S2;
      when S2 =>
        srg_en <= '1';
        cnt_en <= '1';
        ns <= S0;
      when others =>
        ns <= S0;
    end case;
  end process;

  en_disp(1) <= not(en(0) and aceso(1)); en_disp(2) <= not(en(1) and aceso(2));
  en_disp(3) <= not(en(2) and aceso(3)); en_disp(4) <= not(en(3) and aceso(4));

  segm(1) <= led(0); segm(2) <= led(1); segm(3) <= led(2);
  segm(4) <= led(3); segm(5) <= led(4); segm(6) <= led(5);
  segm(7) <= led(6); dp <= led(7);

end mixed;
