library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips is
  port (
    clk        : in std_logic;
    rst        : in std_logic;
    rst_inports : in std_logic;
    switch     : in std_logic_vector(31 downto 0);
    Inport0En  : in std_logic;
    Inport1En  : in std_logic;
    OutPort    : out std_logic_vector(31 downto 0);

		--Debugging
    --Registers  : out Register_Array_Type_ent;
		RegA_output : out std_logic_vector(31  downto 0);
		RegB_output	: out  std_logic_vector(31 downto 0);
		HI_output		: out std_logic_vector(31 downto 0);
		LO_output		: out std_logic_vector(31 downto 0);
		pc_counter : out std_logic_vector(31 downto 0);
		OPSelect_output	:	out std_logic_vector(7  downto 0);
		ir31_26_out : out std_logic_vector(5 downto 0);
		ir15_0_out	: out std_logic_vector(15 downto 0);
		sign_extend_output	: out std_logic_vector(31 downto 0);
		ALU_output : out std_logic_vector(31 downto 0);
		ALU_LO_HI_out	: out std_logic_vector(1 downto 0);
		BT_output								: out std_logic
  );
end entity;

architecture bhv of mips is

  component controller is
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
  end component;

  component DataPath is
    port (
      --Global Clock
      clk         : in std_logic;
	rst		:	in std_logic;
  rst_inports : in std_logic;
      --PC
      PCWriteCond : in std_logic;
      PCWrite     : in std_logic;

      --PCtoMUX
      IorD        : in std_logic;

      --Memory inputs
      switch  : in std_logic_vector(31 downto 0);
      Inport0En : in std_logic;
      Inport1En : in std_logic;

      MemRead   : in std_logic;
      MemWrite  : in std_logic;

      --Intruction Register
      IRWrite   : in std_logic;
      ir31_26  : out std_logic_vector(5 downto 0);

      --PRE RF MUX
      RegDst  : in std_logic;
      MemToReg : in std_logic;

      --Register File
      RegWrite : in std_logic;
      JumpAndLink : in std_logic;

      --Sign Extension
      isSigned : in std_logic;

      --ALUSrcA MUX
      ALUSrcA : in std_logic;

      ALUSrcB : in std_logic_vector(1 downto 0);

      -- OP sel
      OPSelect : in std_logic_vector(7 downto 0);

      HI_en : in std_logic;
      LO_en : in std_logic;

      PCSource : in std_logic_vector(1 downto 0);
      ir5_0  : out std_logic_vector(5 downto 0);

      ALU_LO_HI : in std_logic_vector(1 downto 0);
      outport : out std_logic_vector(31 downto 0);


			--Troubleshooting
			--Registers : out Register_Array_Type_ent;
			RegA_output : out std_logic_vector(31  downto 0);
			RegB_output	: out  std_logic_vector(31 downto 0);
			HI_output		: out std_logic_vector(31 downto 0);
			LO_output		: out std_logic_vector(31 downto 0);
			pc_counter : out std_logic_vector(31 downto 0);
			ALU_output : out std_logic_vector(31 downto 0);
			sign_extend_output : out std_logic_vector(31 downto 0);
			ALU_LO_HI_out	: out std_logic_vector(1 downto 0);
			ir15_0_out  : out std_logic_vector(15 downto 0);
			BT_output			: out std_logic
    );
  end component;

  component ALUControl is
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
  end component;

  --Signals
  --Input Register
  signal ir31_26         : std_logic_vector(5 downto 0);

  --Controls
  signal PCWrite         : std_logic;
  signal PCWriteCond     : std_logic;
  signal IorD            : std_logic;
  signal MemRead         : std_logic;
  signal MemWrite        : std_logic;
  signal MemToReg        : std_logic;
  signal IRWrite         : std_logic;
  signal JumpAndLink     : std_logic;
  signal IsSigned        : std_logic;
  signal PCSource        : std_logic_vector(1 downto 0);
  signal ALUOp           : std_logic_vector(7 downto 0);
  signal ALUSrcA         : std_logic;
  signal ALUSrcB         : std_logic_vector(1 downto 0);
  signal RegWrite        : std_logic;
  signal RegDst          : std_logic;

  signal HI_en : std_logic;
  signal LO_en : std_logic;
  signal ALU_LO_HI : std_logic_vector(1 downto 0);

  --OPSelect
  signal OPSelect  : std_logic_vector(7 downto 0);
  signal ir5_0	: std_logic_vector(5 downto 0);

	--For Mult
	signal Mult_En 	: std_logic;



begin

  DataPath_inst: DataPath port map (
    clk         => clk,
	rst => rst,
  rst_inports => rst_inports,
    --PC
    PCWriteCond => PCWriteCond,
    PCWrite     => PCWrite,

    --PCtoMUX
    IorD        => IorD,

    --Memory inputs
    switch  => switch,
    Inport0En => Inport0En,
    Inport1En => Inport1En,

    MemRead   => MemRead,
    MemWrite  => MemWrite,

    --Intruction Register
    IRWrite   => IRWrite,
    ir31_26  => ir31_26,

    --PRE RF MUX
    RegDst  => RegDst,
    MemToReg => MemToReg,

    --Register File
    RegWrite => RegWrite,
    JumpAndLink => JumpAndLink,

    --Sign Extension
    isSigned => isSigned,

    --ALUSrcA MUX
    ALUSrcA => ALUSrcA,

    ALUSrcB => ALUSrcB,

    -- OP sel
    OPSelect => OPSelect,

    HI_en => HI_en,
    LO_en => LO_en,

    PCSource => PCSource,

    ALU_LO_HI => ALU_LO_HI,
    ir5_0 => ir5_0,
    outport => outport,

    --Registers => Registers,
		RegA_output => RegA_output,
		RegB_output => RegB_output,
		HI_output		=> HI_output,
		LO_output		=> LO_output,
		pc_counter => pc_counter,
		ALU_output => ALU_output,
		sign_extend_output => sign_extend_output,
		ir15_0_out => ir15_0_out,
		ALU_LO_HI_out	=> ALU_LO_HI_out,
		BT_output => BT_output
  );

  ALUControl_inst: ALUControl port map (
    ir5_0 => ir5_0,

    --ALU OP
    ALUOp => ALUOp,

    --Output Controls
    HI_en => HI_en,
    LO_en => LO_en,
    ALU_LO_HI => ALU_LO_HI,

    --OPSelect
    OPSelect  => OPSelect,

		--Mult Enable
		Mult_En 	=> Mult_En
  );

  controller_inst: controller port map (
    clk     => clk,

    --Restart
    rst     => rst,

    --Input Register
    ir31_26 => ir31_26,

    --Controls
    PCWrite         => PCWrite,
    PCWriteCond     => PCWriteCond,
    IorD            => IorD,
    MemRead         => MemRead,
    MemWrite        => MemWrite,
    MemToReg        => MemToReg,
    IRWrite         => IRWrite,
    JumpAndLink     => JumpAndLink,
    IsSigned        => isSigned,
    PCSource        => PCSource,
    ALUOp           => ALUOp,
    ALUSrcA         => ALUSrcA,
    ALUSrcB         => ALUSrcB,
    RegWrite        => RegWrite,
    RegDst          => RegDst,

		Mult_En					=> Mult_En
  );
	OPSelect_output <= OPSelect;
	ir31_26_out <= ir31_26;

end architecture;
