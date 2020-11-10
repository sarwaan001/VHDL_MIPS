library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library work;

entity controller is
  port (
    --Clock
    clk     : in std_logic;

    --Restart
    rst     : in std_logic;

    --Input Register
    ir31_26 : in std_logic_vector(5 downto 0);

    --Controls
    PCWrite         : out std_logic;
    PCWriteCond     : out std_logic;
    IorD            : out std_logic;
    MemRead         : out std_logic;
    MemWrite        : out std_logic;
    MemToReg        : out std_logic;
    IRWrite         : out std_logic;
    JumpAndLink     : out std_logic;
    IsSigned        : out std_logic;
    PCSource        : out std_logic_vector(1 downto 0);
    ALUOp           : out std_logic_vector(7 downto 0);
    ALUSrcA         : out std_logic;
    ALUSrcB         : out std_logic_vector(1 downto 0);
    RegWrite        : out std_logic;
    RegDst          : out std_logic;

		--ALU Controls
		Mult_En					: out std_logic
  );
end entity;

architecture bhv of controller is
	type state_type is (Start, Inst_fetch_1, Inst_fetch_2, Inst_fetch_3,
    Decode,

    --LW
    LW_1, LW_2, LW_3, LW_Complete,

    --SW
    SW_1, SW_2, SW_Complete,

    --R type
    R_1, R_2, R_Complete,

    --I isSigned = '0'
    I_zero_1, I_zero_2, I_zero_3, I_zero_4,

    --I isSigned = '1'
    I_one_1, I_one_2, I_one_3, I_one_4,

		J_1,

		JL_1, JL_2,

		Branch_1, Branch_2,

    Halt

    );

  signal state, next_state  : state_type;

begin
  -- state register
  process (clk, rst)
  begin
    if (rst = '1')  then
      state  <= Start;
    elsif (rising_edge(clk)) then
      state <= next_state;
    end if;
  end process;

  process(ir31_26, state)
  begin
    --defaults
    PCWrite <= '0';
    PCWriteCond <= '0';
    IorD <= '0';
    MemRead <= '1';
    MemWrite <= '0';
	 MemToReg <= '0';
    IRWrite <= '0';
    JumpAndLink <= '0';
    IsSigned <= '0';
    PCSource <= "00";
    ALUOp <= x"23";
    ALUSrcA <= '0';
    ALUSrcB <= "01";
    RegWrite <= '0';
    RegDst <= '0';

		Mult_En <= '0';


    case(state) is

      when Start =>
        next_state <= Inst_fetch_2;


      --when Inst_fetch_1 =>


        --IorD            <= '0';
        --MemWrite        <= '0';

        --next_state <= Inst_fetch_2;

      --when Inst_fetch_2 =>
        --IRWrite <= '1';
        --ALUSrcA <= '0';
        --ALUSrcB <= "01";
        --PCSource <= "00";
        --PCWrite <= '1';

        --next_state <= Decode;

			--Increment PC
			when Inst_fetch_1 =>
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				PCSource <= "00";
				PCWrite <= '1';
				next_state <= Inst_fetch_2;

			--Fetch  Memory
			when Inst_fetch_2 =>
				IorD <= '0';

				next_state <= Inst_fetch_3;

			--Get Instructions
			when Inst_fetch_3 =>
				IorD <= '0';
				IRWrite <= '1';

				next_state <= Decode;




			when Decode =>
        ALUSrcA <= '0';
        ALUSrcB <= "01";
        ALUOp  <= x"23";

        case( ir31_26 ) is
          --LW
          when std_logic_vector(to_unsigned(16#23#, 6)) =>
            next_state <= LW_1;

          --SW
          when std_logic_vector(to_unsigned(16#2b#,  6)) =>
            next_state <= SW_1;

          when std_logic_vector(to_unsigned(16#00#, 6)) =>
            next_state <= R_1;

          when std_logic_vector(to_unsigned(16#0C#, 6)) =>
            next_state <= I_zero_1;

          when std_logic_vector(to_unsigned(16#0D#, 6)) =>
            next_state <= I_zero_1;

          when std_logic_vector(to_unsigned(16#0E#, 6)) =>
            next_state <= I_zero_1;

          when std_logic_vector(to_unsigned(16#09#, 6)) =>
            next_state <= I_one_1;

          when std_logic_vector(to_unsigned(16#10#, 6)) =>
            next_state <= I_one_1;
          when std_logic_vector(to_unsigned(16#0A#, 6)) =>
            next_state <= I_one_1;
          when std_logic_vector(to_unsigned(16#0B#, 6)) =>
              next_state <= I_one_1;
					when std_logic_vector(to_unsigned(16#02#, 6)) =>
							next_state <= J_1;
					when std_logic_vector(to_unsigned(16#03#, 6)) =>
							next_state <= JL_1;

					when std_logic_vector(to_unsigned(16#04#, 6)) =>
							next_state <= Branch_1;

					when std_logic_vector(to_unsigned(16#05#, 6)) =>
							next_state <= Branch_1;

					when std_logic_vector(to_unsigned(16#06#, 6)) =>
							next_state <= Branch_1;

					when std_logic_vector(to_unsigned(16#07#, 6)) =>
							next_state <= Branch_1;

          when std_logic_vector(to_unsigned(16#3F#, 6)) =>
              next_state <= Halt;
          when std_logic_vector(to_unsigned(16#FC#, 6)) =>
              next_state <= Halt;

          when others => NULL;

        end case;

      when LW_1 =>
        ALUSrcA <= '1';
        ALUSrcB <= "10";
				isSigned <= '0';
        ALUOp <= x"23";

        next_state <= LW_2;

      when LW_2 =>
        IorD <= '1';
        MemRead <=  '1';
        ALUSrcA <= '1';
        ALUSrcB <= "10";
				isSigned <= '0';
        ALUOp <= x"23";

        next_state <= LW_3;

      when LW_3 =>
        IorD <= '1';
        MemRead <= '1';
        ALUSrcA <= '1';
        ALUSrcB <= "10";
        ALUOp <= x"23";

        next_state <= LW_Complete;

      when LW_Complete =>


        MemToReg <= '1';
        RegDst <= '0';
        RegWrite <= '1';

        next_state <= Inst_fetch_1;



			when SW_1 =>
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				isSigned <= '0';
				ALUOp <= x"2B";

				next_state <= SW_2;

			when SW_2 =>
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				isSigned <= '0';
				ALUOp <= x"2B";

				IorD <= '1';
				MemWrite <= '1';
				next_state <= SW_Complete;

			when  SW_Complete =>
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				isSigned <= '0';
				ALUOp <= x"2B";

				IorD <= '1';
				MemWrite <= '1';
				next_state <= Inst_fetch_1;

      --when R_1 =>
        --ALUSrcA <= '1';
        --ALUSrcB <= "00";
        --ALUOp <= (others => '0');
				--MemToReg <= '0';
				--RegDst <= '1';

				--Mult_En <= '1';

        --next_state <= R_Complete;

      --when R_Complete =>
        --MemToReg <= '0';
				--ALUSrcA <= '1';
        --ALUSrcB <= "00";
        --RegDst <= '1';
        --RegWrite <= '1';

				--Mult_En <= '0';

        --next_state <= Inst_fetch_1;

			when R_1 =>
        ALUSrcA <= '1';
        ALUSrcB <= "00";
				ALUOp <= (others => '0');
				MemToReg <= '0';
				RegDst <= '1';

				Mult_En <= '1';

				--try
				PCWriteCond <= '1';

        next_state <= R_2;

			when R_2 =>
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				ALUOp <= (others => '0');
				RegDst <= '1';
				MemToReg <= '0';
				RegWrite <= '1';

				--try
				PCWriteCond <='1';

				next_state <= Inst_fetch_1;

			--when R_Complete =>
				--ALUSrcA <= '1';
				--ALUSrcB <= "00";
				--ALUOp <= (others => '0');
				--RegDst <= '1';
				--MemToReg <= '0';
				--IRWrite <= '1';

				--next_state <= Inst_fetch_1;

			when I_zero_1 =>
        ALUSrcA <= '1';
        isSigned <= '0';
        ALUSrcB <= "10";
				ALUOp <= ("00" & ir31_26);
        next_state <= I_zero_2;

      when I_zero_2 =>
				ALUSrcA <= '1';
				isSigned <= '0';
				ALUSrcB <= "10";
				ALUOp <= ("00" & ir31_26);
        IorD <= '1';

        next_state <= I_zero_4;

			when I_zero_3 =>
				ALUSrcA <= '1';
				isSigned <= '0';
				ALUSrcB <= "10";
				ALUOp <= ("00" & ir31_26);
				IorD <= '1';

				next_state <= I_zero_4;

			when I_zero_4 =>
				MemToReg <= '0';
				RegDst <= '0';
				RegWrite <= '1';

				next_state <= Inst_fetch_1;

			when I_one_1 =>
        ALUSrcA <= '1';
        isSigned <= '1';
        ALUSrcB <= "10";
				ALUOp <= ("00" & ir31_26);
        next_state <= I_one_2;

      when I_one_2 =>
				ALUSrcA <= '1';
				isSigned <= '1';
				ALUSrcB <= "10";
				ALUOp <= ("00" & ir31_26);
        IorD <= '1';

        next_state <= I_one_4;

			when I_one_3 =>
				ALUSrcA <= '1';
				isSigned <= '1';
				ALUSrcB <= "10";
				ALUOp <= ("00" & ir31_26);
				IorD <= '1';

				next_state <= I_one_4;

			when I_one_4 =>
				MemToReg <= '0';
				RegDst <= '0';
				RegWrite <= '1';

				next_state <= Inst_fetch_1;

      --when I_one_1 =>
        --ALUSrcA <= '1';
        --isSigned <= '1';
        --ALUSrcB <= "10";
				--ALUOp <= ("00" & ir31_26);
        --next_state <= I_zero_2;

      --when I_one_2 =>
				--ALUSrcA <= '1';
				--isSigned <= '1';
				--ALUSrcB <= "10";
				--ALUOp <= ("00" & ir31_26);
        --IorD <= '1';

        --next_state <= I_one_3;

			--when I_one_3 =>
				--ALUSrcA <= '1';
				--isSigned <= '1';
				--ALUSrcB <= "10";
				--ALUOp <= ("00" & ir31_26);
				--IorD <= '1';

				--next_state <= I_one_4;

			--when I_one_4 =>
				--MemToReg <= '0';
				--RegWrite <= '1';
				--RegDst <= '0';

				--next_state <= Inst_fetch_1;



			when J_1 =>
				PCSource <= "10";
				PCWrite <= '1';

				--next_state <= Inst_fetch_1;
				next_state <= Inst_fetch_2;

			when JL_1 =>
				ALUSrcA <= '0';
				ALUSrcB <= "01";

				next_state <= JL_2;

			when JL_2 =>
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				MemToReg <= '0';
				JumpAndLink <= '1';
				PCSource <= "10";
				PCWrite <= '1';

				next_state <= Inst_fetch_2;

			when  Branch_1 =>
				ALUSrcA <= '0';
				isSigned <= '1';
				ALUSrcB <= "11";
				ALUOp <= x"23";
				next_state <= Branch_2;

			when Branch_2 =>
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				ALUOp <= ("00" & ir31_26);
				PCWriteCond <= '1';
				PCSource <= "01";
				next_state <= Inst_fetch_1;


      when Halt =>
        next_state <=  Halt;
        PCWrite <= '0';
        PCWriteCond <= '0';





      when others => null;
    end case;


  end process;


end architecture;
