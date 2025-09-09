library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stable_detector is
  generic ( N_STABLE : natural := 8 );
  Port (
    clk     : in  STD_LOGIC;
    reset   : in  STD_LOGIC;
    code_in : in  std_logic_vector(9 downto 0);
    stable  : out STD_LOGIC
  );
end stable_detector;

architecture rtl of stable_detector is
  signal prev_code : std_logic_vector(9 downto 0) := (others=>'0');
  signal cnt       : unsigned(7 downto 0) := (others=>'0');
  signal st        : std_logic := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset='1' then
        prev_code <= (others=>'0');
        cnt <= (others=>'0');
        st  <= '0';
      else
        if code_in = prev_code then
          if cnt < to_unsigned(N_STABLE, cnt'length) then
            cnt <= cnt + 1;
          end if;
        else
          prev_code <= code_in;
          cnt <= (others=>'0');
        end if;
        if cnt = to_unsigned(N_STABLE, cnt'length) then st <= '1'; else st <= '0'; end if;
      end if;
    end if;
  end process;
  stable <= st;
end rtl;
