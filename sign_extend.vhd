library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is
  generic(WIDTH : integer := 16);
  port (
    input : in std_logic_vector(WIDTH-1 downto 0);
    isSigned : in std_logic;
    output : out std_logic_vector((WIDTH*2)-1 downto 0)
  );
end sign_extend;

architecture bhv of sign_extend is
begin

  process(input, isSigned)
  begin
    if (isSigned = '1') then
      output <= std_logic_vector(resize(signed(input), WIDTH*2));
    else
      output <= std_logic_vector(resize(unsigned(input), WIDTH*2));
    end if;
  end process;
end architecture;
