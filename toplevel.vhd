library ieee;
use ieee.std_logic_1164.all;

entity toplevel is
    port (
        clk50MHz : in  std_logic;
        --rst      : in  std_logic;
        switch   : in  std_logic_vector(9 downto 0);
        button   : in  std_logic_vector(1 downto 0);
        led0     : out std_logic_vector(6 downto 0);
        led1     : out std_logic_vector(6 downto 0);
        led2     : out std_logic_vector(6 downto 0);
        led3     : out std_logic_vector(6 downto 0);
        led4     : out std_logic_vector(6 downto 0);
        led5     : out std_logic_vector(6 downto 0)
        );
end toplevel;

architecture STR of toplevel is

    component decoder7seg
        port (
            input  : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0));
    end component;

    component mips
      port (
        clk        : in std_logic;
        rst        : in std_logic;
        rst_inports : in std_logic;
        switch     : in std_logic_vector(31 downto 0);
        Inport0En  : in std_logic;
        Inport1En  : in std_logic;
        OutPort    : out std_logic_vector(31 downto 0);
        --Debugging
        --Registers  : out Register_Array_Type_ent;
        --leave  all below open
        RegA_output : out std_logic_vector(31  downto 0);
        RegB_output	: out  std_logic_vector(31 downto 0);
        HI_output		: out std_logic_vector(31 downto 0);
        LO_output		: out std_logic_vector(31 downto 0);
        pc_counter : out std_logic_vector(31 downto 0);
        OPSelect_output	:	out std_logic_vector(7  downto 0);
        ir31_26_out : out std_logic_vector(5 downto 0);
        ir15_0_out	: out std_logic_vector(15 downto 0);
        sign_extend_output	: out std_logic_vector(31 downto 0);
        ALU_output : out std_logic_vector(31 downto 0);
        ALU_LO_HI_out	: out std_logic_vector(1 downto 0);
        BT_output								: out std_logic
      );
    end component;

    signal zero_extended_switches : std_logic_vector(31 downto 0);
    signal Inport0En  : std_logic;
    signal Inport1En  : std_logic;
    signal OutPort : std_logic_vector(31 downto 0);
    signal notButtons : std_logic;

begin  -- STR

    Inport0En <= '1' when (switch(9) = '0' and button(1) = '0') else '0';
    Inport1En <= '1' when (switch(9) = '1' and button(1) = '0') else '0';
    zero_extended_switches <= "00000000000000000000000" & switch(8 downto 0);
    notButtons <= (not button(1)) and (not button(0));
    MIPS_INST : mips port map (
      clk => clk50MHz,
      rst => not button(0),
      rst_inports => notButtons,
      switch => zero_extended_switches,
      Inport0En  =>  Inport0En,
      Inport1En  => Inport1En,
      OutPort   => OutPort,

      RegA_output => open,
      RegB_output	=> open,
      HI_output		=> open,
      LO_output		=> open,
      pc_counter => open,
      OPSelect_output	=> open,
      ir31_26_out => open,
      ir15_0_out	=> open,
      sign_extend_output	=> open,
      ALU_output => open,
      ALU_LO_HI_out	=> open,
      BT_output => open

    );

    U_LED5 : decoder7seg port map (
        input  => OutPort(23 downto 20),
        output => led5);

    U_LED4 : decoder7seg port map (
        input  => OutPort(19 downto 16),
        output => led4);

    U_LED3 : decoder7seg port map (
        input  => OutPort(15 downto 12),
        output => led3);

    U_LED2 : decoder7seg port map (
        input  => OutPort(11 downto 8),
        output => led2);

    U_LED1 : decoder7seg port map (
        input  => OutPort(7 downto 4),
        output => led1);

    U_LED0 : decoder7seg port map (
        input  => OutPort(3 downto 0),
        output => led0);

end STR;
