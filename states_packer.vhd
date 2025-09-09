library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity states_packer is
  Port (
    st_thumb : in unsigned(1 downto 0);
    st_index : in unsigned(1 downto 0);
    st_middle: in unsigned(1 downto 0);
    st_ring  : in unsigned(1 downto 0);
    st_pinky : in unsigned(1 downto 0);
    code10   : out std_logic_vector(9 downto 0)
  );
end states_packer;

architecture rtl of states_packer is
begin
  code10 <= std_logic_vector(st_thumb & st_index & st_middle & st_ring & st_pinky);
end rtl;
