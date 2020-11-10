library ieee;
use ieee.std_logic_1164.all;

entity mux3x1_mem is
  generic (WIDTH : integer := 32);
  port (
    input0 : in std_logic_vector(WIDTH-1 downto 0);
    input1 : in std_logic_vector(WIDTH-1 downto 0);
    input2 : in std_logic_vector(WIDTH-1 downto 0);
    sel : in std_logic_vector(1 downto 0);
    output  : out std_logic_vector(WIDTH-1 downto 0)
  );
end mux3x1_mem;

architecture bhv of mux3x1_mem is
begin
  output <= input0 when sel = "00" else
    input1 when sel = "01" else
    input2;

end architecture;
