library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity segment_fsm is
  generic( COOL_CYCLES : natural := 50 );
  Port (
    clk       : in  STD_LOGIC;
    reset     : in  STD_LOGIC;
    ascii_in  : in  std_logic_vector(7 downto 0);
    stable    : in  STD_LOGIC;
    ascii_out : out std_logic_vector(7 downto 0);
    commit    : out STD_LOGIC
  );
end segment_fsm;

architecture rtl of segment_fsm is
  type st_t is (IDLE, COOLDOWN);
  signal st    : st_t := IDLE;
  signal cdown : unsigned(15 downto 0) := (others=>'0');
  signal a_l   : std_logic_vector(7 downto 0) := (others=>'0');
  signal cm    : std_logic := '0';
begin
  ascii_out <= a_l;
  commit    <= cm;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset='1' then
        st <= IDLE; cm <= '0'; a_l <= (others=>'0'); cdown <= (others=>'0');
      else
        cm <= '0';
        case st is
          when IDLE =>
            if stable='1' then
              a_l <= ascii_in;
              cm  <= '1';                 -- one-cycle commit
              st  <= COOLDOWN; cdown <= (others=>'0');
            end if;
          when COOLDOWN =>
            if cdown < to_unsigned(COOL_CYCLES, cdown'length) then
              cdown <= cdown + 1;
            else
              st <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;
end rtl;
