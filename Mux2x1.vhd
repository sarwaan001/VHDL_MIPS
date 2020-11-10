library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2x1 is
  generic (WIDTH : integer := 32);
  port (
    input0  : in std_logic_vector(WIDTH-1 downto 0);
    input1  : in std_logic_vector(WIDTH-1 downto 0);
    sel     : in std_logic;

    output  : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture bhv of mux2x1 is

begin

  output <= input0 when (sel = '0') else
    input1 when (sel = '1');


end architecture;
