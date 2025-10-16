library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flex_led is
    Port (
        clk       : in  STD_LOGIC;
        flex_in   : in  STD_LOGIC;
        led0      : out STD_LOGIC
    );
end flex_led;

architecture Behavioral of flex_led is
begin
    -- Prueba 1: Conexión directa (sin clock)
    led0 <= flex_in;
    
    -- O prueba la inversa:
    -- led0 <= not flex_in;
end Behavioral;