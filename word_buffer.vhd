library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity word_buffer is
  generic(
    MAX_LEN : natural := 16        -- maximum letters in the buffer
  );
  port (
    clk        : in  STD_LOGIC;
    reset      : in  STD_LOGIC;

    -- input from your segment/motion commit logic
    ascii_in   : in  STD_LOGIC_VECTOR(7 downto 0); -- ASCII of letter to store
    commit     : in  STD_LOGIC;                    -- append when '1'
    clear      : in  STD_LOGIC;                    -- clear the buffer

    -- simple counters/exports (optional)
    count      : out UNSIGNED(7 downto 0);         -- number of stored letters

    -- flattened views of the buffer (optional / for debug/printing)
    word_out   : out STD_LOGIC_VECTOR(8*MAX_LEN-1 downto 0);
    debug_buf  : out STD_LOGIC_VECTOR(8*MAX_LEN-1 downto 0)
  );
end word_buffer;

architecture rtl of word_buffer is
  type buf_t is array (0 to MAX_LEN-1) of STD_LOGIC_VECTOR(7 downto 0);
  signal buf : buf_t := (others => (others => '0'));
  signal idx : integer range 0 to MAX_LEN-1 := 0;
  signal cnt : UNSIGNED(7 downto 0) := (others => '0');
begin
  count <= cnt;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset='1' or clear='1' then
        buf <= (others => (others => '0'));
        idx <= 0;
        cnt <= (others => '0');
      else
        if commit='1' then
          buf(idx) <= ascii_in;
          if idx < MAX_LEN-1 then
            idx <= idx + 1;
            cnt <= cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Export the buffer as a flat vector (buf(0) at the left / MSB side)
  word_out <= buf(0)  & buf(1)  & buf(2)  & buf(3)  &
              buf(4)  & buf(5)  & buf(6)  & buf(7)  &
              buf(8)  & buf(9)  & buf(10) & buf(11) &
              buf(12) & buf(13) & buf(14) & buf(15);

  -- Same as word_out; kept separately so you can probe/print without touching word_out
  debug_buf <= buf(0)  & buf(1)  & buf(2)  & buf(3)  &
               buf(4)  & buf(5)  & buf(6)  & buf(7)  &
               buf(8)  & buf(9)  & buf(10) & buf(11) &
               buf(12) & buf(13) & buf(14) & buf(15);
end rtl;
