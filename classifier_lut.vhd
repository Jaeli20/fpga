library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity classifier_lut is
  Port ( code10 : in  std_logic_vector(9 downto 0);
         ascii  : out std_logic_vector(7 downto 0) );
end classifier_lut;

architecture rtl of classifier_lut is
  constant CODE_A : std_logic_vector(9 downto 0) := "0110101010"; -- demo pattern
  constant CODE_B : std_logic_vector(9 downto 0) := "1000000000";
  constant CODE_C : std_logic_vector(9 downto 0) := "0101010101";
  constant CODE_U : std_logic_vector(9 downto 0) := "0000001010";
  constant CODE_V : std_logic_vector(9 downto 0) := "0000000101";
begin
  process(code10)
  begin
    if    code10 = CODE_A then ascii <= x"41"; -- 'A'
    elsif code10 = CODE_B then ascii <= x"42"; -- 'B'
    elsif code10 = CODE_C then ascii <= x"43"; -- 'C'
    elsif code10 = CODE_U then ascii <= x"55"; -- 'U'
    elsif code10 = CODE_V then ascii <= x"56"; -- 'V'
    else                      ascii <= x"3F"; -- '?'
    end if;
  end process;
end rtl;
