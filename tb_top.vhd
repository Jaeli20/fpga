library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity tb_top is
end tb_top;

architecture sim of tb_top is
  -- Clock/reset
  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';

  -- ADC channels (thumb..pinky)
  signal adc_t, adc_i, adc_m, adc_r, adc_p : unsigned(11 downto 0) := (others=>'0');

  -- Quantized states
  signal st_t, st_i, st_m, st_r, st_p : unsigned(1 downto 0);

  -- Packed code, classifier, stability, commit
  signal code10      : std_logic_vector(9 downto 0);
  signal ascii_lut   : std_logic_vector(7 downto 0);
  signal stable      : std_logic;
  signal ascii_seg   : std_logic_vector(7 downto 0);
  signal commit_seg  : std_logic;

  -- Motion FSM
  signal base_I   : std_logic := '0';
  signal down     : std_logic := '0';
  signal hook     : std_logic := '0';
  signal zigzag   : std_logic := '0';
  signal ascii_mo : std_logic_vector(7 downto 0);
  signal commit_mo: std_logic;

  -- Merge: motion has priority
  signal ascii_merged : std_logic_vector(7 downto 0);
  signal commit_any   : std_logic;

  -- Word buffer
  signal clear_word : std_logic := '0';
  signal word_count : unsigned(7 downto 0);
  signal word_flat  : std_logic_vector(8*16-1 downto 0);
  signal dbg_flat   : std_logic_vector(8*16-1 downto 0);

  -- Thresholds and helper levels
  constant T1  : unsigned(11 downto 0) := to_unsigned(1500,12);
  constant T2  : unsigned(11 downto 0) := to_unsigned(3000,12);
  constant EXT : unsigned(11 downto 0) := to_unsigned( 500,12);
  constant MID : unsigned(11 downto 0) := to_unsigned(2200,12);
  constant BEN : unsigned(11 downto 0) := to_unsigned(3700,12);

begin
  -- 100 MHz clock
  clk <= not clk after 5 ns;

  -- Quantizers (instantiate your quantizer.vhd)
  qT: entity work.quantizer port map(clk, reset, adc_t, T1, T2, st_t);
  qI: entity work.quantizer port map(clk, reset, adc_i, T1, T2, st_i);
  qM: entity work.quantizer port map(clk, reset, adc_m, T1, T2, st_m);
  qR: entity work.quantizer port map(clk, reset, adc_r, T1, T2, st_r);
  qP: entity work.quantizer port map(clk, reset, adc_p, T1, T2, st_p);

  -- Pack, classify, stabilize, commit (instantiate your other modules)
  pack: entity work.states_packer
    port map(st_t, st_i, st_m, st_r, st_p, code10);

  clf : entity work.classifier_lut
    port map(code10, ascii_lut);

  stab: entity work.stable_detector
    generic map(N_STABLE => 8)
    port map(clk, reset, code10, stable);

  seg : entity work.segment_fsm
    generic map(COOL_CYCLES => 80)
    port map(clk, reset, ascii_lut, stable, ascii_seg, commit_seg);

  -- Motion FSM (optional dynamic letters)
  mot : entity work.motion_fsm
    port map(clk, reset, base_I, down, hook, zigzag, ascii_mo, commit_mo);

  -- Merge static vs motion: motion wins if active this cycle
  ascii_merged <= ascii_mo when commit_mo='1' else ascii_seg;
  commit_any   <= commit_mo or commit_seg;

  -- Word buffer (concatenation) - instantiate the new word_buffer.vhd
  wb : entity work.word_buffer
    generic map(MAX_LEN => 16)
    port map(
      clk        => clk,
      reset      => reset,
      ascii_in   => ascii_merged,
      commit     => commit_any,
      clear      => clear_word,
      count      => word_count,
      word_out   => word_flat,
      debug_buf  => dbg_flat
    );

  -- Reset
  process
  begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait;
  end process;

  -- Stimulus: drive letters A, B, C, U, V, then J, Z
  stim: process
    variable L : line;
    procedure log(s: in string) is
    begin write(L, s); writeline(output, L); end procedure;

    procedure set_A is  -- "0110101010": T=MID; others=BENT
    begin adc_t<=MID; adc_i<=BEN; adc_m<=BEN; adc_r<=BEN; adc_p<=BEN; end procedure;
    procedure set_B is  -- "1000000000": T=BENT; others=EXT
    begin adc_t<=BEN; adc_i<=EXT; adc_m<=EXT; adc_r<=EXT; adc_p<=EXT; end procedure;
    procedure set_C is  -- "0101010101": all MID
    begin adc_t<=MID; adc_i<=MID; adc_m<=MID; adc_r<=MID; adc_p<=MID; end procedure;
    procedure set_U is  -- "0000001010": T/I/M=EXT; R/P=BENT
    begin adc_t<=EXT; adc_i<=EXT; adc_m<=EXT; adc_r<=BEN; adc_p<=BEN; end procedure;
    procedure set_V is  -- "0000000101": T/I/M=EXT; R/P=MID
    begin adc_t<=EXT; adc_i<=EXT; adc_m<=EXT; adc_r<=MID; adc_p<=MID; end procedure;

  begin
    log("---- Begin stimulus: letters A,B,C,U,V then motion J,Z");

    set_A; wait for 400 us;
    set_B; wait for 400 us;
    set_C; wait for 400 us;
    set_U; wait for 400 us;
    set_V; wait for 400 us;

    -- J (base_I + down then hook)
    base_I<='1';
    down  <='1'; wait for 60 us; down<='0';
    wait for 120 us;
    hook  <='1'; wait for 60 us; hook<='0';
    base_I<='0';
    wait for 400 us;

    -- Z (zigzag flag)
    zigzag <= '1'; wait for 40 us; zigzag <= '0';
    wait for 400 us;

    log("---- End stimulus");
    wait;
  end process;

  -- Console prints: each commit and buffer length
  printer: process(clk)
    variable L : line;
    variable ch: character;
  begin
    if rising_edge(clk) then
      if commit_any='1' then
        ch := character'val(to_integer(unsigned(ascii_merged)));
        write(L, string'("COMMIT: "));
        write(L, ch);
        write(L, string'(" | WORD_LEN="));
        write(L, to_integer(word_count));
        writeline(output, L);
      end if;
    end if;
  end process;

  -- Final word printer (uses dbg_flat to reconstruct the word)
  final_printer: process
    variable word_str : string(1 to 16);
    variable ascii_val: integer;
    variable L : line;
  begin
    wait for 5 ms;  -- allow all commits to happen
    writeline(output, L);  -- blank line
    write(L, string'("------ FINAL WORD OUTPUT ------")); writeline(output, L);

    -- dbg_flat layout = buf(0) & buf(1) & ... & buf(15)
    -- buf(0) is at bits [127:120], buf(15) at [7:0].
    -- We'll print the first 7 stored characters buf(0..6) for ABCUVJZ demo.
    for i in 0 to 6 loop
      ascii_val := to_integer(unsigned(dbg_flat(8*(15-i)+7 downto 8*(15-i))));
      if ascii_val > 0 then
        word_str(i+1) := character'val(ascii_val);
      else
        word_str(i+1) := ' ';
      end if;
    end loop;

    write(L, string'("WORD: ")); 
    for i in 1 to 7 loop write(L, word_str(i)); end loop;
    writeline(output, L);
    wait;
  end process;

end sim;
