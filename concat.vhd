library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity concat is
  port (
    input1 : in std_logic_vector(27 downto 0);
    input2 : in std_logic_vector(3 downto 0);
    output : out std_logic_vector(31 downto 0)
  );
end concat;

architecture bhv of concat is
begin
  output(31 downto 28) <= input2;
  output(27 downto 0) <= input1;

end architecture;
