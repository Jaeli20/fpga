library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity motion_fsm is
  Port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    base_I    : in  std_logic;  -- static shape precondition
    down      : in  std_logic;  -- down stroke detected
    hook      : in  std_logic;  -- hook detected
    zigzag    : in  std_logic;  -- zigzag detected
    ascii_out : out std_logic_vector(7 downto 0);
    commit    : out std_logic
  );
end motion_fsm;

architecture rtl of motion_fsm is
  type gst is (IDLE, J_HOOK);
  signal s : gst := IDLE;
  signal a : std_logic_vector(7 downto 0) := (others=>'0');
  signal c : std_logic := '0';
begin
  ascii_out <= a;
  commit    <= c;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset='1' then s<=IDLE; c<='0'; a<=(others=>'0');
      else
        c <= '0';
        case s is
          when IDLE =>
            if zigzag='1' then a <= x"5A"; c <= '1'; end if;  -- 'Z'
            if base_I='1' and down='1' then s <= J_HOOK; end if;
          when J_HOOK =>
            if hook='1' then a <= x"4A"; c <= '1'; s <= IDLE; end if; -- 'J'
        end case;
      end if;
    end if;
  end process;
end rtl;
