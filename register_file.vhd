library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port(
        clk : in std_logic;
        rst : in std_logic;
        Read_Reg1 : in std_logic_vector(4 downto 0);
        Read_Reg2 : in std_logic_vector(4 downto 0);
        Write_reg : in std_logic_vector(4 downto 0);
        RegWrite : in std_logic;
        JumpAndLink : in std_logic;
        Write_data : in std_logic_vector(31 downto 0);
        Read_Data1 : out std_logic_vector(31 downto 0);
        Read_Data2 : out std_logic_vector(31 downto 0)
        --Registers : out Register_Array_Type_ent


        );
end register_file;


architecture async_read of register_file is
    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array;
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then

            if (RegWrite = '1') then
                regs(to_integer(unsigned(Write_reg))) <= Write_data;
								regs(0) <= (others => '0');

						elsif (JumpAndLink = '1') then
								regs(31) <= Write_data;
            end if;
        end if;
    end process;

    Read_Data1 <= regs(to_integer(unsigned(Read_Reg1)));
    Read_Data2 <= regs(to_integer(unsigned(Read_Reg2)));
    --Registers <= regs;

end async_read;
