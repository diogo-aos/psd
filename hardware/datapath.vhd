library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
  generic (
    FREQ_SIZE : natural := 128;
    FREQ_WIDTH : natural := 13;
    QUEUE_SIZE : natural := 168;
    QUEUE_WIDTH : natural := 72
  );
  port (
    clk : in std_logic;
    datain : in  std_logic_vector (7 downto 0);
    dataout : out  std_logic_vector (7 downto 0);
    finished_reading : out std_logic;
    freq_ram_enable : in std_logic;
    freq_ram_wenable : in std_logic;
    queue_ram_enable : in std_logic;
    queue_ram_wenable : in std_logic;	 
    adding_nodes : in std_logic;
    qAddFinish : out std_logic;
    qTree : in std_logic;
    final_queue : out std_logic
 
  );
end datapath;

architecture Behavioral of datapath is
  -- sinais freq count
  type freq_count_type is array (0 to FREQ_SIZE-1) of std_logic_vector(FREQ_WIDTH-1 downto 0);
  signal freqcount : freq_count_type := (others => (others => '0'));
  signal result, freq : std_logic_vector(FREQ_WIDTH-1 downto 0);
  signal freq_seeker : std_logic_vector(6 downto 0);
  signal freq_adr : integer;
  
  -- queue node
  type queue_node_type is
  record
		char : std_logic_vector(6 downto 0);
		freq : std_logic_vector(12 downto 0);
		--left_adr : std_logic_vector(7 downto 0);
		--right_adr : std_logic_vector(7 downto 0);
		left_adr : integer range 0 to 255;
		right_adr : integer range 0 to 255;
		queued : std_logic;
  end record;

  -- sinais queue
  type queue_type is array (0 to QUEUE_SIZE - 1) of queue_node_type;
  signal queue : queue_type;
  signal queue_adr, qend, queue_adr_add, queue_adr_tree : integer := 0;
  signal queue_read_data, queue_write_data : queue_node_type;
  signal s_queue_ram_wenable: std_logic;
  

  
begin
  -- freq count RAM
  process (clk)
  begin
    if rising_edge(clk) then
      if freq_ram_enable = '1' then
        if freq_ram_wenable = '1' then
          freqcount(freq_adr) <= result;
        end if;
        freq <= freqcount(freq_adr);
      end if;
    end if;
  end process;
  
  freq_adr <= conv_integer(datain(6 downto 0)) when adding_nodes = '0' else 
              conv_integer(freq_seeker);

  result <= freq + '1';
  finished_reading <= '1' when datain = X"FF" else '0';

  -- queue RAM
  process (clk)
  begin
    if rising_edge(clk) then
      if queue_ram_enable = '1' then
        if s_queue_ram_wenable = '1' then
          queue(queue_adr) <= queue_write_data;
        end if;
         queue_read_data <= queue(queue_adr);
      end if;
    end if;
  end process;
  
  s_queue_ram_wenable <=  queue_ram_wenable when (freq /= "0000000000000") else
                          '0';
  queue_adr <= queue_adr_add when (qTree = '0') else
					queue_adr_tree;
  
  qAddFinish <= '1' when (freq_seeker = "1111111") else
                '0';
    -- queue
  process(clk)
  begin
    if rising_edge(clk) then
      if queue_ram_enable = '1' and s_queue_ram_wenable = '1' then
        queue_adr_add <= queue_adr_add + 1;
      end if;

    end if;
  end process;
 
	
  -- increase freq_seeker
  process (clk)
  begin
    if adding_nodes = '0' and qTree = '0' then
	   freq_seeker <= (others => '0');
    elsif rising_edge(clk) and (adding_nodes = '1' or qTree = '1') then --and freq_seeker /= "1111111" then
	   freq_seeker <= freq_seeker + 1;
	 end if;
  end process;

  -- build tree
  process (clk)
    variable t_freq1, t_freq2 : std_logic_vector(12 downto 0) := (others => '1');
    variable t_lastadr1, t_lastadr2, t_adr1, t_adr2 : integer;
  begin
    if qTree = '1' and queue_ram_wenable = '0' then -- ver condicao
      if queue_read_data.freq < t_freq1 then
        t_freq2 := t_freq1;
        t_adr2 := t_adr1;
        t_freq1 := queue_read_data.freq;
        t_adr1 := queue_adr_tree-1;
      elsif queue_read_data.freq < t_freq2 then
        t_freq2 := queue_read_data.freq;
        t_adr2 := queue_adr_tree-1;      
      end if;
      if queue_adr_tree = qend then
        final_queue <= '1';
        queue_adr_tree <= qend;
        qend <= qend + 1;
      end if;
    else 
      t_lastadr1 := t_adr1;
      t_lastadr2 := t_adr2;
      t_freq1  := (others => '1');
      t_freq2  := (others => '1');
      queue_adr_tree <= 0;
      -- falta queued a zeros nos dois selecionados
    end if;
	 
	 if adding_nodes = '1' then
      queue_write_data.char <= freq_seeker-1;
      queue_write_data.freq <= freq;
      --queue_write_data.left_adr <= (others => '0');
      --queue_write_data.right_adr <= (others => '0');
		queue_write_data.left_adr <= 0;
		queue_write_data.right_adr <= 0;
      queue_write_data.queued <= '1';
    elsif qTree = '1' and queue_ram_wenable = '1' then
      queue_write_data.char <= (others => '1');
      queue_write_data.freq <= t_freq1 + t_freq2;
      queue_write_data.left_adr <= t_adr1;
      queue_write_data.right_adr <= t_adr2;
      queue_write_data.queued <= '1';
    end if;
	 
  end process;

end Behavioral;
