library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_left2 is
  generic(WIDTH : integer := 32);
  port (
    input : in std_logic_vector(WIDTH-1 downto 0);
    output : out std_logic_vector(WIDTH-1 downto 0)
  );
end shift_left2;

architecture bhv of shift_left2 is
begin
  output <= std_logic_vector(shift_left(unsigned(input), 2));

end architecture;
