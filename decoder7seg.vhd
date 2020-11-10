library ieee;
use ieee.std_logic_1164.all;

entity decoder7seg is
port (
	input : in std_logic_vector(3 downto 0);
	output : out std_logic_vector(6 downto 0));
end decoder7seg; 

architecture behave of decoder7seg is
begin
	process(input)
	begin
		case input is
		when "0000" =>
			output <= "1000000";
		when "0001" =>
			output <= "1111001";
		when "0010" =>
			output <= "0100100";
		when "0011" => 
			output <= "0110000";
		when "0100" =>
			output <= "0011001";
		when "0101" =>
			output <= "0010010";
		when "0110" =>
			output <= "0000010";
		when "0111" =>
			output <= "1111000";	
		
		when "1000" =>
			output <= "0000000";
		when "1001" =>
			output <= "0011000";
		when "1010" =>
			output <= "0001000";
		when "1011" => 
			output <= "0000011";
		when "1100" =>
			output <= "1000110";
		when "1101" =>
			output <= "0100001";
		when "1110" =>
			output <= "0000110";
		when "1111" =>
			output <= "0111000";	
			Output <= "0001110";
		when others =>
			NULL;
		
		end case;
	end process;
end behave;