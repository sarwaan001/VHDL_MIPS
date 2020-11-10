library ieee;
use ieee.std_logic_1164.all;

entity ir is
  port (
    clk : in std_logic;
    rst : in std_logic;
    en  : in std_logic;
    d   : in std_logic_vector(31 downto 0);
    ir25_0   : out std_logic_vector(25 downto 0);
    ir31_26  : out std_logic_vector(5 downto 0);
    ir25_21  : out std_logic_vector(4 downto 0);
    ir20_16  : out std_logic_vector(4 downto 0);
    ir15_11  : out std_logic_vector(4 downto 0);
    ir15_0   : out std_logic_vector(15 downto 0)
  );
end ir;

architecture bhv of ir is

  signal ir_all : std_logic_vector(31 downto 0);

begin
  process(clk, rst)
  begin
    if (rst = '1') then
      ir_all <= (others => '0');
    elsif (rising_edge(clk) and en = '1') then
        ir_all <= d;
    end if;
  end process;
  ir25_0 <= ir_all(25 downto 0);
  ir31_26 <= ir_all(31 downto 26);
  ir25_21 <= ir_all(25 downto 21);
  ir20_16 <= ir_all(20 downto 16);
  ir15_11 <= ir_all(15 downto 11);
  ir15_0  <= ir_all(15 downto 0);

end architecture;
