library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity quantizer is
  Port (
    clk     : in  STD_LOGIC;
    reset   : in  STD_LOGIC;
    adc_val : in  unsigned(11 downto 0);  -- 12-bit sample (0..4095)
    t1      : in  unsigned(11 downto 0);  -- threshold 1 (ext?mid)
    t2      : in  unsigned(11 downto 0);  -- threshold 2 (mid?bent)
    state2  : out unsigned(1 downto 0)    -- "00"=extended, "01"=mid, "10"=bent
  );
end quantizer;

architecture rtl of quantizer is
  signal s : unsigned(1 downto 0) := "00";
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset='1' then
        s <= "00";
      else
        case s is
          when "00" =>  -- extended
            if adc_val > t1 then s <= "01"; end if;
          when "01" =>  -- mid
            if adc_val < (t1 - 20) then
              s <= "00";
            elsif adc_val > t2 then
              s <= "10";
            end if;
          when "10" =>  -- bent
            if adc_val < (t2 - 20) then
              s <= "01";
            end if;
          when others =>
            s <= "00";
        end case;
      end if;
      state2 <= s;
    end if;
  end process;
end rtl;
