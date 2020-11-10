library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory_Comb_Logic is
  port (
    addr : in std_logic_vector(31 downto 0);
    MemWrite : in std_logic;
    OutportWrEn : out std_logic;
    WrEn : out std_logic;
    Sel : out std_logic_vector(1 downto 0)
  );
end entity;

architecture BHV of Memory_Comb_Logic is

begin

  process(MemWrite, addr)
  begin
    if (to_integer(unsigned(addr)) < 1024) then
      if (MemWrite = '1') then
        WrEn <= '1';
        Sel <= "00";
        OutportWrEn <= '0';
      else
        WrEn <= '0';
        Sel <= "00";
        OutportWrEn <= '0';
      end if;
    elsif (addr = x"0000FFF8") then
      WrEn <= '0';
      Sel <= "01";
      OutportWrEn <= '0';
    elsif (addr = x"0000FFFC") then
      WrEn <= '0';
      Sel <= "10";
      OutportWrEn <= '1';
    ---elsif (addr = x"0000FFFC") then
      --WrEn <= '0';
      --Sel <= "00";
      --OutportWrEn <= '1';
		--Added for latches
		else 
			WrEn <= '0';
			Sel <= "--";
			OutportWrEn <= '0';
			
    end if;
  end process;
end architecture;
