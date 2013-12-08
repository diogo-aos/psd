library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
	 qTree : in std_logic
  );
end datapath;

architecture Behavioral of datapath is
  -- sinais freq count
  type freq_count_type is array (0 to FREQ_SIZE-1) of std_logic_vector(FREQ_WIDTH-1 downto 0);
  signal freqcount : freq_count_type := (others => (others => '0'));
  signal result, freq : std_logic_vector(FREQ_WIDTH-1 downto 0);
  signal freq_seeker : std_logic_vector(7 downto 0);
  signal freq_adr : integer;
  
  -- queue node
  type queue_node_type is
  record
		char : std_logic_vector(6 downto 0);
		freq : std_logic_vector(12 downto 0);
		left_adr : std_logic_vector(7 downto 0);
		right_adr : std_logic_vector(7 downto 0);
		queued : std_logic;
  end record;

  -- queue node
  type tree_seek_type is
  record
		freq : std_logic_vector(12 downto 0);
		adr : std_logic_vector(7 downto 0);
  end record;

  -- sinais queue
  type queue_type is array (0 to QUEUE_SIZE - 1) of queue_node_type;
  signal queue : queue_type;
  signal queue_adr,qend : integer := 0;
  signal queue_read_data, queue_write_data : queue_node_type;
  signal s_queue_ram_wenable : std_logic;
  
  signal min1,min2 : tree_seek_type;
  
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
  
  s_queue_ram_wenable <= queue_ram_wenable when (freq > "0000000000000") else
								 '0';
  qAddFinish <= '1' when (freq_seeker = "01111111") else
                '0';
    -- queue
  process(clk)

  begin
    if rising_edge(clk) then
	   if queue_ram_enable = '1' and s_queue_ram_wenable = '1' then
			queue_adr <= queue_adr + 1;
			qend <= qend + 1;
		end if;
    end if;
  end process;
  
	
	queue_write_data.char <= freq_seeker-1;
	queue_write_data.freq <= freq;
	queue_write_data.left_adr <= (others => '0');
	queue_write_data.right_adr <= (others => '0');
	queue_write_data.queued <= '1';
	
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
  variable min1 : tree_seek_type := (others => '1');--std_logic_vector(20 downto 0);
  variable min2 : tree_seek_type := (others => '1');
  begin
	 if queue_read_data.freq < min1.freq then
	   minf.freq := min1.freq;
		min2.addr := min1.addr;
		min1.freq := queue_read_data.freq;
		min1.addr := queue_addr-1;
	 end if;
  end process;

end Behavioral;
