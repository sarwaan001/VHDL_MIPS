library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ALUControl is
  port (
    ir5_0 : in std_logic_vector(5 downto 0);

    --ALU OP
    ALUOp : in std_logic_vector(7 downto 0);

    --Output Controls
    HI_en : out std_logic;
    LO_en : out std_logic;
    ALU_LO_HI : out std_logic_vector(1 downto 0);

    --OPSelect
    OPSelect  : out std_logic_vector(7 downto 0);

    --Controller Msc
    Mult_En   : in  std_logic
  );
end entity;

architecture BHV of ALUControl is



begin
  OPSelect <= ("00" & ir5_0) when (ALUOp = x"00") else
                x"23" when (ALUOp = x"10") else
                x"25" when (ALUOp = x"0D") else
                x"21" when (ALUOp = x"09") else
                x"21" when (ALUOp = x"23") else
                x"24" when (ALUOp = x"0C") else
                x"26" when (ALUOp = x"0E") else
                x"2A" when (ALUOp = x"0A") else
                x"2A" when (ALUOp = x"0B") else
                --Branch
                x"04" when (ALUOp = x"04") else
                x"05" when (ALUOp = x"05") else


                --Load/Store
                x"21" when (ALUOp = x"23") else
                x"21" when (ALUOp = x"2B") else x"00";
  HI_en <= '1' when ((((("00" & ir5_0) = x"18") or (("00" & ir5_0) = x"19"))) and (Mult_En = '1')) else '0';
  LO_en <= '1' when ((((("00" & ir5_0) = x"18") or (("00" & ir5_0) = x"19"))) and (Mult_En = '1')) else '0';
  ALU_LO_HI <= "01" when ((("00" & ir5_0) = x"12") and (ALUOp = x"00")) else
                "10" when ((("00" & ir5_0) = x"10") and (ALUOp = x"00")) else
                  "00";

end architecture;
