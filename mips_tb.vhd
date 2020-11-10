library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_tb is
end entity;

architecture tb of mips_tb is

  component mips is
    port (
      clk        : in std_logic;
      rst        : in std_logic;
      switch     : in std_logic_vector(31 downto 0);
      Inport0En  : in std_logic;
      Inport1En  : in std_logic;
      OutPort    : out std_logic_vector(31 downto 0);

			-- Debugging
      --Registers  : out Register_Array_Type_ent;
			RegA_output: out std_logic_vector(31 downto 0);
			RegB_output: out std_logic_vector(31 downto 0);
			pc_counter:  out std_logic_vector(31 downto 0);
			OPSelect_output	:	out std_logic_vector(7  downto 0);
			ir31_26_out : out std_logic_vector(5 downto 0);
			ALU_output : out std_logic_vector(31 downto 0);
			ir15_0_out : out std_logic_vector(15 downto 0);
			sign_extend_output : out std_logic_vector(31 downto 0);
			HI_output		: out std_logic_vector(31 downto 0);
			LO_output		: out std_logic_vector(31 downto 0);
			ALU_LO_HI_out	: out std_logic_vector(1 downto 0);
			BT_output				: out std_logic
    );
  end component;

  signal clk        : std_logic := '1';
  signal rst        : std_logic;
  signal switch     : std_logic_vector(31 downto 0);
  signal Inport0En  : std_logic;
  signal Inport1En  : std_logic;
  signal OutPort    : std_logic_vector(31 downto 0);
  --signal Registers  : Register_Array_Type_ent;
	signal RegA_output, RegB_output, pc_counter : std_logic_vector(31 downto 0);
	signal OPSelect_output	:	std_logic_vector(7 downto 0);
	signal  ir31_26_out : std_logic_vector(5 downto 0);
	signal ALU_output : std_logic_vector(31 downto 0);
	signal sign_extend_output : std_logic_vector(31 downto  0);
	signal ir15_0_out : std_logic_vector(15 downto 0);
	signal HI_output		:  std_logic_vector(31 downto 0);
	signal LO_output		:  std_logic_vector(31 downto 0);
	signal ALU_LO_HI_out: std_logic_vector(1 downto 0);
	signal BT_output		: std_logic;

begin

  UUT : mips port map (
    clk  => clk,
    rst => rst,
    switch => switch,
    Inport0En => Inport0En,
    Inport1En =>  Inport1En,
    OutPort => OutPort,
    --Registers => Registers,
		RegA_output => RegA_output,
		RegB_output => RegB_output,
		HI_output => HI_output,
		LO_output => LO_output,
		pc_counter => pc_counter,
		OPSelect_output => OPSelect_output,
		ir31_26_out => ir31_26_out,
		ALU_output => ALU_output,
		sign_extend_output => sign_extend_output,
		ir15_0_out => ir15_0_out,
		ALU_LO_HI_out	=> ALU_LO_HI_out,
		BT_output => BT_output
  );

  clk <= not clk after 10 ns;

  process
  begin
    rst <= '1';
    wait for 5 ns;
	switch <= "00000000000000000000000111111111";

    rst <= '0';
    Inport0En <= '1';
    Inport1En <= '0';
    --switch <= (others  => '0');
    wait for 20 ns;
	Inport0En <= '0';
	Inport1En <= '0';

    wait for 1000000 ns;
    assert FALSE Report "SImulation Finished" severity FAILURE;







  end process;

end architecture;
