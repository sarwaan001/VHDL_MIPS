library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataPath is
  port (
    --Global Clock
    clk         : in std_logic;

		rst					: in std_logic;
    rst_inports	: in std_logic;

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

    ALU_LO_HI : in std_logic_vector(1 downto 0);

    ir5_0  : out std_logic_vector(5 downto 0);


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
		ir15_0_out						: out std_logic_vector(15  downto 0);
		ALU_LO_HI_out					: out std_logic_vector(1 downto 0);
		BT_output								: out std_logic
  );
end DataPath;

architecture BHV of DataPath is

  component reg is
    generic (WIDTH : integer := 32);
    port (
      clk : in std_logic;
			rst : in std_logic;
      en  : in std_logic;
      d   : in std_logic_vector(WIDTH-1 downto 0);
      q   : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component mux2x1 is
    generic (WIDTH : integer := 32);
    port (
      input0  : in std_logic_vector(WIDTH-1 downto 0);
      input1  : in std_logic_vector(WIDTH-1 downto 0);
      sel     : in std_logic;

      output  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component mux3x1 is
    generic (WIDTH : integer := 32);
    port (
      input0  : in std_logic_vector(WIDTH-1 downto 0);
      input1  : in std_logic_vector(WIDTH-1 downto 0);
      input2  : in std_logic_vector(WIDTH-1 downto 0);
      sel     : in std_logic_vector(1 downto 0);

      output  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component mux4x1 is
    generic (WIDTH : integer := 32);
    port (
      input0  : in std_logic_vector(WIDTH-1 downto 0);
      input1  : in std_logic_vector(WIDTH-1 downto 0);
      input2  : in std_logic_vector(WIDTH-1 downto 0);
      input3  : in std_logic_vector(WIDTH-1 downto 0);
      sel     : in std_logic_vector(1 downto 0);

      output  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component memory is
    port (
      clock : in std_logic;
			rst : in std_logic;
      rst_inports : in std_logic;
      --I/O signals
      switch     : in std_logic_vector(31 downto 0);
      Inport0En  : in std_logic;
      Inport1En  : in std_logic;
      WrData     : in std_logic_vector(31 downto 0);

      --Address
      addr  : in std_logic_vector(31 downto 0);

      -- Comb logic
      MemWrite  : in std_logic;

      -- Output
      RdData    : out std_logic_vector(31 downto 0);
      OutPort   : out std_logic_vector(31 downto 0)

    );
  end component;

  component ir is
    port (
      clk : in std_logic;
			rst : in std_logic;
      en  : in std_logic;
      d   : in std_logic_vector(31 downto 0);
      ir25_0   : out std_logic_vector(25 downto 0);
      ir31_26  : out std_logic_vector(5 downto 0);
      ir25_21  : out std_logic_vector(4 downto 0);
      ir20_16  : out std_logic_vector(4 downto 0);
      ir15_11  : out std_logic_vector(4 downto 0);
      ir15_0   : out std_logic_vector(15 downto 0)
    );
  end component;

  component register_file is
    port (
      clk       : in std_logic;
			rst 			: in  std_logic;
      Read_Reg1 : in std_logic_vector(4 downto 0);
      Read_Reg2 : in std_logic_vector(4 downto 0);
      Write_reg : in std_logic_vector(4 downto 0);
      Write_data: in std_logic_vector(31 downto 0);

      --Controller in
      RegWrite  : in std_logic;
      JumpAndLink: in std_logic;

      Read_Data1: out std_logic_vector(31 downto 0);
      Read_Data2: out std_logic_vector(31 downto 0)
      --Registers : out Register_Array_Type_ent
    );
  end component;

  component sign_extend is
    generic(WIDTH : integer := 16);
    port (
      input : in std_logic_vector(WIDTH-1 downto 0);
      isSigned : in std_logic;
      output : out std_logic_vector((WIDTH*2)-1 downto 0)
    );
  end component;

  component shift_left2 is
    generic(WIDTH : integer := 32);
    port (
      input : in std_logic_vector(WIDTH-1 downto 0);
      output : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component concat is
    port (
      input1 : in std_logic_vector(27 downto 0);
      input2 : in std_logic_vector(3 downto 0);
      output : out std_logic_vector(31 downto 0)
    );
  end component;

   component ALU is
    generic (WIDTH : integer := 32);
    port(
      input1, input2 : in std_logic_vector(WIDTH-1 downto 0);
      ir10_6  : in std_logic_vector(4 downto 0);
      OPCODE  : in std_logic_vector(7 downto 0);

      bt  : out std_logic;
      Result  : out std_logic_vector(WIDTH-1 downto 0);
      Result_Hi : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  signal MUX_to_PC   : std_logic_vector(31 downto 0);
  signal Bt_out : std_logic;
  signal PCen: std_logic;
  signal PC_out : std_logic_vector(31 downto 0);
  signal ALU_out: std_logic_vector(31 downto 0);
  signal PC_to_MUX_out : std_logic_vector(31 downto 0);
  signal RegA_out : std_logic_vector(31 downto 0);
  signal RegB_out : std_logic_vector(31 downto 0);
  signal Memory_out : std_logic_vector(31 downto 0);

  signal ir25_0   : std_logic_vector(25 downto 0);
  signal ir25_21  : std_logic_vector(4 downto 0);
  signal ir20_16  : std_logic_vector(4 downto 0);
  signal ir15_11  : std_logic_vector(4 downto 0);
  signal ir15_0   : std_logic_vector(15 downto 0);

  signal Mem_Data_Reg : std_logic_vector(31 downto 0);

  signal MUX_Write_register : std_logic_vector(4 downto 0);
  signal MUX_Write_data     : std_logic_vector(31 downto 0);

  signal ALU_MUX_OUT  : std_logic_vector(31 downto 0);

  signal sign_extend_out : std_logic_vector(31 downto 0);
  signal shift_left2_out : std_logic_vector(31 downto 0);

  signal read_data1 : std_logic_vector(31 downto 0);
  signal read_data2 : std_logic_vector(31 downto 0);

  signal SRCA_MUX   : std_logic_vector(31 downto 0);
  signal SRCB_MUX   : std_logic_vector(31 downto 0);

  signal ir25_0_extended2 : std_logic_vector(27 downto 0);
  signal ir25_0_shift2 :  std_logic_vector(27 downto 0);
  signal ir25_0_Concat  : std_logic_vector(31 downto 0);

  signal ALU_Results : std_logic_vector(31 downto 0);
  signal ALU_Results_Hi : std_logic_vector(31 downto 0);

  signal ALU_LO, ALU_Hi : std_logic_vector(31 downto 0);

begin

  PCen <= ((Bt_out and PCWriteCond) or PCWrite);
  ir25_0_extended2 <= ("00" &  ir25_0);

  PC_inst : reg generic map (WIDTH => 32) port map (
    clk => clk,
		rst => rst,
    en  => PCen,
    d => MUX_to_PC,
    q => PC_out
  );

  PC_to_MUX_inst : mux2x1 generic map (WIDTH => 32) port map (
    input0 => PC_out,
    input1 => ALU_out,
    sel => IorD,
    output => PC_to_MUX_out
  );

  Memory_inst : memory port map (
    clock => clk,
		rst => rst,
    rst_inports => rst_inports,
    switch => switch,
    Inport0En => Inport0En,
    Inport1En => Inport1En,
    WrData => RegB_out,
    addr => PC_to_MUX_out,
    MemWrite => MemWrite,
    RdData => Memory_out,
    OutPort => OutPort
  );

  IR_inst : ir port map (
    clk => clk,
		rst => rst,
    en => IRWrite,
    d => Memory_out,
    ir25_0 => ir25_0,
    ir31_26 => ir31_26,
    ir25_21 => ir25_21,
    ir20_16 => ir20_16,
    ir15_11 => ir15_11,
    ir15_0 => ir15_0
  );

  Mem_Data_Reg_inst : reg generic map (WIDTH => 32) port map (
    clk => clk,
    en => '1', --Check if this is correct
		rst => rst,
    d => Memory_out,
    q => Mem_Data_Reg
  );

  Write_Reg_Mux_inst : mux2x1 generic map (WIDTH => 5) port map (
    input0 => ir20_16,
    input1 => ir15_11,
    sel => RegDst,
    output => MUX_Write_register
  );

  MemToReg_MUX_inst : mux2x1 generic map (WIDTH => 32) port map (
    input0 => ALU_MUX_OUT,
		input1 => Mem_Data_Reg,
    sel => MemToReg,
    output => MUX_Write_data
  );

  Register_File_inst : register_file port map (
    clk => clk,
		rst => rst,
    Read_Reg1 => ir25_21,
    Read_Reg2 => ir20_16,
    Write_reg => MUX_Write_register,
    Write_data => MUX_Write_data,
    RegWrite  => RegWrite,
    JumpAndLink => JumpAndLink,

    Read_Data1 => read_data1,
    Read_Data2 => read_data2
    --Registers => Registers
  );

  sign_extend_inst  : sign_extend generic map (WIDTH => 16) port map (
    input => ir15_0,
    isSigned => isSigned,
    output => sign_extend_out
  );

  shift_left2_inst1 : shift_left2 generic map (WIDTH => 32) port map (
    input => sign_extend_out,
    output => shift_left2_out
  );

  RegA_inst : reg generic map (WIDTH => 32) port map (
    clk => clk,
		rst => rst,
    en  => '1',
    d => read_data1,
    q => RegA_out
  );

  RegB_inst : reg generic map (WIDTH => 32) port map (
    clk => clk,
		rst => rst,
    en  => '1',
    d => read_data2,
    q => RegB_out
  );

  ALUSrcA_inst : mux2x1 generic map (WIDTH => 32) port map (
    input1 => RegA_out,
    input0 => PC_out,
    sel => ALUSrcA,
    output => SRCA_MUX
  );

  ALUSrcB_inst : mux4x1 generic map (WIDTH => 32) port map (
    input0 => RegB_out,
    input1=>std_logic_vector(to_unsigned(4, 32)),
    input2 => sign_extend_out,
    input3 => shift_left2_out,
    sel => ALUSrcB,
    output => SRCB_MUX
  );

  shift_left2_inst12 : shift_left2 generic map (WIDTH => 28) port map (
    input => ir25_0_extended2,
    output => ir25_0_shift2
  );

  concat_inst: concat port map (
     input1 => ir25_0_shift2,
     input2 => PC_out(31 downto 28),
     output => ir25_0_Concat
  );

  ALU_init_inst : ALU generic map (WIDTH => 32) port map (
    input1 => SRCA_MUX,
    input2 => SRCB_MUX,
    OPCODE => OPSelect,
	ir10_6 => ir15_0(10 downto 6),
    bt => Bt_out,
    Result => ALU_Results,
    Result_Hi => ALU_Results_Hi
  );

  ALU_Out_inst : reg generic map (WIDTH => 32) port map (
    clk => clk,
		rst => rst,
    en  => '1',
    d => ALU_Results,
    q => ALU_out
  );

  ALU_LO_inst : reg generic map (WIDTH => 32) port map (
    clk => clk,
		rst => rst,
    en  => LO_en,
    d => ALU_Results,
    q => ALU_LO
  );

  ALU_Hi_inst : reg generic map (WIDTH => 32) port map (
    clk => clk,
		rst => rst,
    en  => HI_en,
    d => ALU_Results_Hi,
    q => ALU_Hi
  );

  MUX_to_PC_final: mux3x1 generic map (WIDTH => 32) port map (
    input0 => ALU_Results,
    input1 => ALU_out,
    input2 => ir25_0_Concat,
    sel => PCSource,
    output => MUX_to_PC
  );

  MUX_to_PC_final2: mux3x1 generic map (WIDTH => 32) port map (
    input0 => ALU_out,
    input1 => ALU_LO,
    input2 => ALU_Hi,
    sel => ALU_LO_HI,
    output => ALU_MUX_OUT
  );
  ir5_0 <= ir15_0(5 downto 0);
	RegA_output <=RegA_out;
	RegB_output <= RegB_out;
	pc_counter <= PC_out;
	ALU_output <= ALU_Results;
	sign_extend_output <= sign_extend_out;
	ir15_0_out <= ir15_0;
	HI_output <= ALU_Hi;
	LO_output <= ALU_LO;
	ALU_LO_HI_out <= ALU_LO_HI;
	BT_output <= Bt_out;
end architecture;
