library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  port (
    clock : in std_logic;
    rst : in std_logic;
    rst_inports : in std_logic;
    --I/O signals
    switch     : in std_logic_vector(31 downto 0);
    Inport0En  : in std_logic;
    Inport1En  : in std_logic;
    WrData     : in std_logic_vector(31 downto 0);

    --Address
    addr  : in std_logic_vector(31 downto 0);

    -- Comb logic
    MemWrite  : in std_logic;

    -- Output
    RdData    : out std_logic_vector(31 downto 0);
    OutPort   : out std_logic_vector(31 downto 0)

  );
end entity;

architecture bhv of memory is
  component reg is
    generic (WIDTH : integer := 32);
    port (
      clk : in std_logic;
      rst : in std_logic;
      en  : in std_logic;
      d   : in std_logic_vector(WIDTH-1 downto 0);
      q   : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component mux3x1_mem is
    generic (WIDTH : integer := 32);
    port (
      input0 : in std_logic_vector(WIDTH-1 downto 0);
      input1 : in std_logic_vector(WIDTH-1 downto 0);
      input2 : in std_logic_vector(WIDTH-1 downto 0);
      sel : in std_logic_vector(1 downto 0);
      output  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component RAM IS
  	PORT
  	(
  		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
  		clock		: IN STD_LOGIC;
  		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
  		wren		: IN STD_LOGIC ;
  		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
  	);
  END component;

  component Memory_Comb_Logic is
    port (
      addr : in std_logic_vector(31 downto 0);
      MemWrite : in std_logic;
      OutportWrEn : out std_logic;
      WrEn : out std_logic;
      Sel : out std_logic_vector(1 downto 0)
    );
  end component;

  signal OutputWrEn : std_logic;
  signal WrEn : std_logic;
  signal sel  : std_logic_vector(1 downto 0);
  signal sel_reg : std_logic_vector(1 downto 0);
  signal inport0out, inport1out : std_logic_vector(31 downto 0);
  signal RAM_out : STD_LOGIC_VECTOR(31 downto 0);

begin
  --INIT I/O
  Inport0_inst : reg generic map (WIDTH => 32) port map (
    clk => clock,
    rst => rst_inports,
    en => Inport0En,
    d => switch,
    q => inport0out
  );
  Inport1_inst : reg generic map (WIDTH => 32) port map (
    clk => clock,
    rst => rst_inports,
    en => Inport1En,
    d => switch,
    q => inport1out
  );
  Outport_inst : reg generic map (WIDTH => 32) port map (
    clk => clock,
    rst => rst,
    en => OutputWrEn,
    d => WrData,
    q => OutPort
  );

  -- RAM
  RAM_inst : RAM port map (
    address => addr(9 downto 2),
    clock => clock,
    data => WrData,
    wren => WrEn,
    q => RAM_out
  );

  -- Memory_Comb_Logic
  Comb_Logic_inst : Memory_Comb_Logic port map (
    addr => addr,
    MemWrite => MemWrite,
    OutportWrEn => OutputWrEn,
    WrEn => WrEn,
    Sel => sel
  );

  -- Sel Register
  Sel_reg_inst : reg generic map (WIDTH => 2) port map (
    clk => clock,
    rst => rst,
    en => '1',
    d => sel,
    q => sel_reg
  );

  -- mux3x1
  mux3x1_inst : mux3x1_mem generic map (WIDTH => 32) port map (
    input0 => RAM_out,
    input1 => inport0out,
    input2 => inport1out,
    sel => sel_reg,
    output => RdData
  );


end architecture;
