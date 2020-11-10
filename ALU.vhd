library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
  generic (WIDTH : integer := 32);
  port(
    input1, input2 : in std_logic_vector(WIDTH-1 downto 0);
    ir10_6  : in std_logic_vector(4 downto 0);
    OPCODE  : in std_logic_vector(7 downto 0);

    bt  : out std_logic;
    Result  : out std_logic_vector(WIDTH-1 downto 0);
    Result_Hi : out std_logic_vector(WIDTH-1 downto 0)
  );
end ALU;

architecture BHV of ALU is
  -- USING RANDOM OPCODES FOR WEEK 1



begin
  process(input1, input2, OPCODE, ir10_6)
    variable Mult_temp  : std_logic_vector((WIDTH*2)-1 downto 0);
  begin
    	-- Default Values
	Result <= (others => '0');
	Result_Hi <= (others => '0');
	bt <= '0';
	Mult_temp := (others => '0');
    case OPCODE is
      -- 0x21 add unsigned
      when x"21" =>
        Result <= std_logic_vector(unsigned(input1) + unsigned(input2));
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      -- 0x23 => Subtract unsigned
      when x"23" =>
        Result <= std_logic_vector(unsigned(input1) - unsigned(input2));
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      -- 0x19 => Mult unsigned
      when x"19" =>
        Mult_temp := std_logic_vector(unsigned(input1)*unsigned(input2));
        Result <= Mult_temp(WIDTH-1 downto 0);
        Result_Hi <= Mult_temp((WIDTH*2)-1 downto WIDTH);
        bt <= '0';
      -- 0x18 => Mult signed
      when x"18" =>
        Mult_temp := std_logic_vector(signed(input1)*signed(input2));
        Result <= Mult_temp(WIDTH-1 downto 0);
        Result_Hi <= Mult_temp((WIDTH*2)-1 downto WIDTH);
        bt <= '0';
      -- 0x24 -> And
      when x"24" =>
        Result <= input1 and input2;
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      -- 0x25 => or
      when x"25" =>
        Result <= input1 or input2;
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      -- 0x26 => XOR
      when x"26" =>
        Result <= input1 xor input2;
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      -- 0x02 => srl
      when x"02" =>
        Result <= std_logic_vector(shift_right(unsigned(input2), to_integer(unsigned(ir10_6))));
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      -- 0x00 => sll
      when x"00" =>
        Result <= std_logic_vector(shift_left(unsigned(input2), to_integer(unsigned(ir10_6))));
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      -- 0x03 => sra
      when x"03" =>
        Result <= std_logic_vector(shift_right(signed(input2), to_integer(unsigned(ir10_6))));
        Result_Hi <= (others => '0');
        bt <= '0';
        Mult_temp := (others => '0');
      --  0x2A => slt
      when x"2A" =>
        if (signed(input1) < signed(input2)) then
          Result <= std_logic_vector(to_unsigned(1, WIDTH));
          Result_Hi <= (others => '0');
          bt <= '0';
          Mult_temp := (others => '0');
        else
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          bt <= '0';
          Mult_temp := (others => '0');
        end if;
      -- 0x2B => sltu
      when x"2B" =>
        if (unsigned(input1) <= unsigned(input2)) then
          Result <= std_logic_vector(to_unsigned(1, WIDTH));
          Result_Hi <= (others => '0');
          bt <= '0';
          Mult_temp := (others => '0');
        else
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          bt <= '0';
          Mult_temp := (others => '0');
        end if;
      -- 0x04 beq
      when  x"04" =>
        if (input1 = input2) then
          bt <= '1';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        else
          bt <= '0';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        end if;
      -- 0x05 bne
      when  x"05" =>
        if (input1 = input2) then
          bt <= '0';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        else
          bt <= '1';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        end if;
      --0x06 blez
      when  x"06" =>
        if (to_integer(signed(input1)) <= 0) then
          bt <= '1';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        else
          bt <= '0';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        end if;
      --0x07 bgtz
      when  x"07" =>
        if (to_integer(signed(input1)) > 0) then
          bt <= '1';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        else
          bt <= '0';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        end if;
      --0x01 bltz
      when  x"01" =>
        if (to_integer(signed(input1)) < 0) then
          bt <= '1';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        else
          bt <= '0';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        end if;
      --0x11 bgez
      when  x"11" =>
        if (to_integer(signed(input1)) >= 0) then
          bt <= '1';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        else
          bt <= '0';
          Result <= (others => '0');
          Result_Hi <= (others => '0');
          Mult_temp := (others => '0');
        end if;
      --Jump to RA
      when x"08" =>
        Result <= std_logic_vector(unsigned(input1) - to_unsigned(4, WIDTH));
        bt <= '1';
        Result_Hi <= (others => '0');
        Mult_temp := (others => '0');

	when others => NULL;

      end case;


  end process;


end architecture;
