library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4x1 is
  generic (WIDTH : integer := 32);
  port (
    input0  : in std_logic_vector(WIDTH-1 downto 0);
    input1  : in std_logic_vector(WIDTH-1 downto 0);
    input2  : in std_logic_vector(WIDTH-1 downto 0);
    input3  : in std_logic_vector(WIDTH-1 downto 0);
    sel     : in std_logic_vector(1 downto 0);

    output  : out std_logic_vector(WIDTH-1 downto 0)
  );
end mux4x1;

architecture bhv of mux4x1 is

begin

  output <= input0 when (sel = "00") else
    input1 when (sel = "01") else
    input2 when (sel = "10") else
    input3 when (sel = "11") else input0;


end architecture;
