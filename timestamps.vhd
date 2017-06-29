-- A sliding time-stamps component
-- The output ts contains the i^th time-stamp in an M long trace-cycle, 
-- the time-stamps are repeated again after the M clock-cycles


--- libs
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timestamps is 
  generic(
  m : integer := 1024
  );
  port (
  clk :  in std_ulogic;
 rst :  in std_ulogic;
  --ts  :  out std_logic_vector((m-1) downto 0)
 ts  :  out std_logic_vector(31 downto 0)
  );
end;

architecture timestamps_comp of timestamps is 

  type csa is array ((m-1) downto 0) of std_logic_vector(31 downto 0);
  constant ts_array : csa := (
"00000000000000000000000000000001",
"00000000000000000000000000000010",
"00000000000000000000000000000011",
"00000000000000000000000000000100",
"00000000000000000000000000000101",
"00000000000000000000000000000110",
"00000000000000000000000000000111",
"00000000000000000000000000001000",
"00000000000000000000000000001001",
"00000000000000000000000000001010",
"00000000000000000000000000001011",
"00000000000000000000000000001100",
"00000000000000000000000000001101",
"00000000000000000000000000001110",
"00000000000000000000000000001111",
"00000000000000000000000000010000",
"00000000000000000000000000010001",
"00000000000000000000000000010010",
"00000000000000000000000000010011",
"00000000000000000000000000010100",
"00000000000000000000000000010101",
"00000000000000000000000000010110",
"00000000000000000000000000010111",
"00000000000000000000000000011000",
"00000000000000000000000000011001",
"00000000000000000000000000011010",
"00000000000000000000000000011011",
"00000000000000000000000000011100",
"00000000000000000000000000011101",
"00000000000000000000000000011110",
"00000000000000000000000000011111",
"00000000000000000000000000100000",
"00000000000000000000000000100001",
"00000000000000000000000000100010",
"00000000000000000000000000100011",
"00000000000000000000000000100100",
"00000000000000000000000000100101",
"00000000000000000000000000100110",
"00000000000000000000000000100111",
"00000000000000000000000000101000",
"00000000000000000000000000101001",
"00000000000000000000000000101010",
"00000000000000000000000000101011",
"00000000000000000000000000101100",
"00000000000000000000000000101101",
"00000000000000000000000000101110",
"00000000000000000000000000101111",
"00000000000000000000000000110000",
"00000000000000000000000000110001",
"00000000000000000000000000110010",
"00000000000000000000000000110011",
"00000000000000000000000000110100",
"00000000000000000000000000110101",
"00000000000000000000000000110110",
"00000000000000000000000000110111",
"00000000000000000000000000111000",
"00000000000000000000000000111001",
"00000000000000000000000000111010",
"00000000000000000000000000111011",
"00000000000000000000000000111100",
"00000000000000000000000000111101",
"00000000000000000000000000111110",
"00000000000000000000000000111111",
"00000000000000000000000001000000",
"00000000000000000000000001000001",
"00000000000000000000000001000010",
"00000000000000000000000001000011",
"00000000000000000000000001000100",
"00000000000000000000000001000101",
"00000000000000000000000001000110",
"00000000000000000000000001000111",
"00000000000000000000000001001000",
"00000000000000000000000001001001",
"00000000000000000000000001001010",
"00000000000000000000000001001011",
"00000000000000000000000001001100",
"00000000000000000000000001001101",
"00000000000000000000000001001110",
"00000000000000000000000001001111",
"00000000000000000000000001010000",
"00000000000000000000000001010001",
"00000000000000000000000001010010",
"00000000000000000000000001010011",
"00000000000000000000000001010100",
"00000000000000000000000001010101",
"00000000000000000000000001010110",
"00000000000000000000000001010111",
"00000000000000000000000001011000",
"00000000000000000000000001011001",
"00000000000000000000000001011010",
"00000000000000000000000001011011",
"00000000000000000000000001011100",
"00000000000000000000000001011101",
"00000000000000000000000001011110",
"00000000000000000000000001011111",
"00000000000000000000000001100000",
"00000000000000000000000001100001",
"00000000000000000000000001100010",
"00000000000000000000000001100011",
"00000000000000000000000001100100",
"00000000000000000000000001100101",
"00000000000000000000000001100110",
"00000000000000000000000001100111",
"00000000000000000000000001101000",
"00000000000000000000000001101001",
"00000000000000000000000001101010",
"00000000000000000000000001101011",
"00000000000000000000000001101100",
"00000000000000000000000001101101",
"00000000000000000000000001101110",
"00000000000000000000000001101111",
"00000000000000000000000001110000",
"00000000000000000000000001110001",
"00000000000000000000000001110010",
"00000000000000000000000001110011",
"00000000000000000000000001110100",
"00000000000000000000000001110101",
"00000000000000000000000001110110",
"00000000000000000000000001110111",
"00000000000000000000000001111000",
"00000000000000000000000001111001",
"00000000000000000000000001111010",
"00000000000000000000000001111011",
"00000000000000000000000001111100",
"00000000000000000000000001111101",
"00000000000000000000000001111110",
"00000000000000000000000001111111",
"00000000000000000000000010000000",
"00000000000000000000000010000001",
"00000000000000000000000010000010",
"00000000000000000000000010000011",
"00000000000000000000000010000100",
"00000000000000000000000010000101",
"00000000000000000000000010000110",
"00000000000000000000000010000111",
"00000000000000000000000010001000",
"00000000000000000000000010001001",
"00000000000000000000000010001010",
"00000000000000000000000010001011",
"00000000000000000000000010001100",
"00000000000000000000000010001101",
"00000000000000000000000010001110",
"00000000000000000000000010001111",
"00000000000000000000000010010000",
"00000000000000000000000010010001",
"00000000000000000000000010010010",
"00000000000000000000000010010011",
"00000000000000000000000010010100",
"00000000000000000000000010010101",
"00000000000000000000000010010110",
"00000000000000000000000010010111",
"00000000000000000000000010011000",
"00000000000000000000000010011001",
"00000000000000000000000010011010",
"00000000000000000000000010011011",
"00000000000000000000000010011100",
"00000000000000000000000010011101",
"00000000000000000000000010011110",
"00000000000000000000000010011111",
"00000000000000000000000010100000",
"00000000000000000000000010100001",
"00000000000000000000000010100010",
"00000000000000000000000010100011",
"00000000000000000000000010100100",
"00000000000000000000000010100101",
"00000000000000000000000010100110",
"00000000000000000000000010100111",
"00000000000000000000000010101000",
"00000000000000000000000010101001",
"00000000000000000000000010101010",
"00000000000000000000000010101011",
"00000000000000000000000010101100",
"00000000000000000000000010101101",
"00000000000000000000000010101110",
"00000000000000000000000010101111",
"00000000000000000000000010110000",
"00000000000000000000000010110001",
"00000000000000000000000010110010",
"00000000000000000000000010110011",
"00000000000000000000000010110100",
"00000000000000000000000010110101",
"00000000000000000000000010110110",
"00000000000000000000000010110111",
"00000000000000000000000010111000",
"00000000000000000000000010111001",
"00000000000000000000000010111010",
"00000000000000000000000010111011",
"00000000000000000000000010111100",
"00000000000000000000000010111101",
"00000000000000000000000010111110",
"00000000000000000000000010111111",
"00000000000000000000000011000000",
"00000000000000000000000011000001",
"00000000000000000000000011000010",
"00000000000000000000000011000011",
"00000000000000000000000011000100",
"00000000000000000000000011000101",
"00000000000000000000000011000110",
"00000000000000000000000011000111",
"00000000000000000000000011001000",
"00000000000000000000000011001001",
"00000000000000000000000011001010",
"00000000000000000000000011001011",
"00000000000000000000000011001100",
"00000000000000000000000011001101",
"00000000000000000000000011001110",
"00000000000000000000000011001111",
"00000000000000000000000011010000",
"00000000000000000000000011010001",
"00000000000000000000000011010010",
"00000000000000000000000011010011",
"00000000000000000000000011010100",
"00000000000000000000000011010101",
"00000000000000000000000011010110",
"00000000000000000000000011010111",
"00000000000000000000000011011000",
"00000000000000000000000011011001",
"00000000000000000000000011011010",
"00000000000000000000000011011011",
"00000000000000000000000011011100",
"00000000000000000000000011011101",
"00000000000000000000000011011110",
"00000000000000000000000011011111",
"00000000000000000000000011100000",
"00000000000000000000000011100001",
"00000000000000000000000011100010",
"00000000000000000000000011100011",
"00000000000000000000000011100100",
"00000000000000000000000011100101",
"00000000000000000000000011100110",
"00000000000000000000000011100111",
"00000000000000000000000011101000",
"00000000000000000000000011101001",
"00000000000000000000000011101010",
"00000000000000000000000011101011",
"00000000000000000000000011101100",
"00000000000000000000000011101101",
"00000000000000000000000011101110",
"00000000000000000000000011101111",
"00000000000000000000000011110000",
"00000000000000000000000011110001",
"00000000000000000000000011110010",
"00000000000000000000000011110011",
"00000000000000000000000011110100",
"00000000000000000000000011110101",
"00000000000000000000000011110110",
"00000000000000000000000011110111",
"00000000000000000000000011111000",
"00000000000000000000000011111001",
"00000000000000000000000011111010",
"00000000000000000000000011111011",
"00000000000000000000000011111100",
"00000000000000000000000011111101",
"00000000000000000000000011111110",
"00000000000000000000000011111111",
"00000000000000000000000100000000",
"00000000000000000000000100000001",
"00000000000000000000000100000010",
"00000000000000000000000100000011",
"00000000000000000000000100000100",
"00000000000000000000000100000101",
"00000000000000000000000100000110",
"00000000000000000000000100000111",
"00000000000000000000000100001000",
"00000000000000000000000100001001",
"00000000000000000000000100001010",
"00000000000000000000000100001011",
"00000000000000000000000100001100",
"00000000000000000000000100001101",
"00000000000000000000000100001110",
"00000000000000000000000100001111",
"00000000000000000000000100010000",
"00000000000000000000000100010001",
"00000000000000000000000100010010",
"00000000000000000000000100010011",
"00000000000000000000000100010100",
"00000000000000000000000100010101",
"00000000000000000000000100010110",
"00000000000000000000000100010111",
"00000000000000000000000100011000",
"00000000000000000000000100011001",
"00000000000000000000000100011010",
"00000000000000000000000100011011",
"00000000000000000000000100011100",
"00000000000000000000000100011101",
"00000000000000000000000100011110",
"00000000000000000000000100011111",
"00000000000000000000000100100000",
"00000000000000000000000100100001",
"00000000000000000000000100100010",
"00000000000000000000000100100011",
"00000000000000000000000100100100",
"00000000000000000000000100100101",
"00000000000000000000000100100110",
"00000000000000000000000100100111",
"00000000000000000000000100101000",
"00000000000000000000000100101001",
"00000000000000000000000100101010",
"00000000000000000000000100101011",
"00000000000000000000000100101100",
"00000000000000000000000100101101",
"00000000000000000000000100101110",
"00000000000000000000000100101111",
"00000000000000000000000100110000",
"00000000000000000000000100110001",
"00000000000000000000000100110010",
"00000000000000000000000100110011",
"00000000000000000000000100110100",
"00000000000000000000000100110101",
"00000000000000000000000100110110",
"00000000000000000000000100110111",
"00000000000000000000000100111000",
"00000000000000000000000100111001",
"00000000000000000000000100111010",
"00000000000000000000000100111011",
"00000000000000000000000100111100",
"00000000000000000000000100111101",
"00000000000000000000000100111110",
"00000000000000000000000100111111",
"00000000000000000000000101000000",
"00000000000000000000000101000001",
"00000000000000000000000101000010",
"00000000000000000000000101000011",
"00000000000000000000000101000100",
"00000000000000000000000101000101",
"00000000000000000000000101000110",
"00000000000000000000000101000111",
"00000000000000000000000101001000",
"00000000000000000000000101001001",
"00000000000000000000000101001010",
"00000000000000000000000101001011",
"00000000000000000000000101001100",
"00000000000000000000000101001101",
"00000000000000000000000101001110",
"00000000000000000000000101001111",
"00000000000000000000000101010000",
"00000000000000000000000101010001",
"00000000000000000000000101010010",
"00000000000000000000000101010011",
"00000000000000000000000101010100",
"00000000000000000000000101010101",
"00000000000000000000000101010110",
"00000000000000000000000101010111",
"00000000000000000000000101011000",
"00000000000000000000000101011001",
"00000000000000000000000101011010",
"00000000000000000000000101011011",
"00000000000000000000000101011100",
"00000000000000000000000101011101",
"00000000000000000000000101011110",
"00000000000000000000000101011111",
"00000000000000000000000101100000",
"00000000000000000000000101100001",
"00000000000000000000000101100010",
"00000000000000000000000101100011",
"00000000000000000000000101100100",
"00000000000000000000000101100101",
"00000000000000000000000101100110",
"00000000000000000000000101100111",
"00000000000000000000000101101000",
"00000000000000000000000101101001",
"00000000000000000000000101101010",
"00000000000000000000000101101011",
"00000000000000000000000101101100",
"00000000000000000000000101101101",
"00000000000000000000000101101110",
"00000000000000000000000101101111",
"00000000000000000000000101110000",
"00000000000000000000000101110001",
"00000000000000000000000101110010",
"00000000000000000000000101110011",
"00000000000000000000000101110100",
"00000000000000000000000101110101",
"00000000000000000000000101110110",
"00000000000000000000000101110111",
"00000000000000000000000101111000",
"00000000000000000000000101111001",
"00000000000000000000000101111010",
"00000000000000000000000101111011",
"00000000000000000000000101111100",
"00000000000000000000000101111101",
"00000000000000000000000101111110",
"00000000000000000000000101111111",
"00000000000000000000000110000000",
"00000000000000000000000110000001",
"00000000000000000000000110000010",
"00000000000000000000000110000011",
"00000000000000000000000110000100",
"00000000000000000000000110000101",
"00000000000000000000000110000110",
"00000000000000000000000110000111",
"00000000000000000000000110001000",
"00000000000000000000000110001001",
"00000000000000000000000110001010",
"00000000000000000000000110001011",
"00000000000000000000000110001100",
"00000000000000000000000110001101",
"00000000000000000000000110001110",
"00000000000000000000000110001111",
"00000000000000000000000110010000",
"00000000000000000000000110010001",
"00000000000000000000000110010010",
"00000000000000000000000110010011",
"00000000000000000000000110010100",
"00000000000000000000000110010101",
"00000000000000000000000110010110",
"00000000000000000000000110010111",
"00000000000000000000000110011000",
"00000000000000000000000110011001",
"00000000000000000000000110011010",
"00000000000000000000000110011011",
"00000000000000000000000110011100",
"00000000000000000000000110011101",
"00000000000000000000000110011110",
"00000000000000000000000110011111",
"00000000000000000000000110100000",
"00000000000000000000000110100001",
"00000000000000000000000110100010",
"00000000000000000000000110100011",
"00000000000000000000000110100100",
"00000000000000000000000110100101",
"00000000000000000000000110100110",
"00000000000000000000000110100111",
"00000000000000000000000110101000",
"00000000000000000000000110101001",
"00000000000000000000000110101010",
"00000000000000000000000110101011",
"00000000000000000000000110101100",
"00000000000000000000000110101101",
"00000000000000000000000110101110",
"00000000000000000000000110101111",
"00000000000000000000000110110000",
"00000000000000000000000110110001",
"00000000000000000000000110110010",
"00000000000000000000000110110011",
"00000000000000000000000110110100",
"00000000000000000000000110110101",
"00000000000000000000000110110110",
"00000000000000000000000110110111",
"00000000000000000000000110111000",
"00000000000000000000000110111001",
"00000000000000000000000110111010",
"00000000000000000000000110111011",
"00000000000000000000000110111100",
"00000000000000000000000110111101",
"00000000000000000000000110111110",
"00000000000000000000000110111111",
"00000000000000000000000111000000",
"00000000000000000000000111000001",
"00000000000000000000000111000010",
"00000000000000000000000111000011",
"00000000000000000000000111000100",
"00000000000000000000000111000101",
"00000000000000000000000111000110",
"00000000000000000000000111000111",
"00000000000000000000000111001000",
"00000000000000000000000111001001",
"00000000000000000000000111001010",
"00000000000000000000000111001011",
"00000000000000000000000111001100",
"00000000000000000000000111001101",
"00000000000000000000000111001110",
"00000000000000000000000111001111",
"00000000000000000000000111010000",
"00000000000000000000000111010001",
"00000000000000000000000111010010",
"00000000000000000000000111010011",
"00000000000000000000000111010100",
"00000000000000000000000111010101",
"00000000000000000000000111010110",
"00000000000000000000000111010111",
"00000000000000000000000111011000",
"00000000000000000000000111011001",
"00000000000000000000000111011010",
"00000000000000000000000111011011",
"00000000000000000000000111011100",
"00000000000000000000000111011101",
"00000000000000000000000111011110",
"00000000000000000000000111011111",
"00000000000000000000000111100000",
"00000000000000000000000111100001",
"00000000000000000000000111100010",
"00000000000000000000000111100011",
"00000000000000000000000111100100",
"00000000000000000000000111100101",
"00000000000000000000000111100110",
"00000000000000000000000111100111",
"00000000000000000000000111101000",
"00000000000000000000000111101001",
"00000000000000000000000111101010",
"00000000000000000000000111101011",
"00000000000000000000000111101100",
"00000000000000000000000111101101",
"00000000000000000000000111101110",
"00000000000000000000000111101111",
"00000000000000000000000111110000",
"00000000000000000000000111110001",
"00000000000000000000000111110010",
"00000000000000000000000111110011",
"00000000000000000000000111110100",
"00000000000000000000000111110101",
"00000000000000000000000111110110",
"00000000000000000000000111110111",
"00000000000000000000000111111000",
"00000000000000000000000111111001",
"00000000000000000000000111111010",
"00000000000000000000000111111011",
"00000000000000000000000111111100",
"00000000000000000000000111111101",
"00000000000000000000000111111110",
"00000000000000000000000111111111",
"00000000000000000000001000000000",
"00000000000000000000001000000001",
"00000000000000000000001000000010",
"00000000000000000000001000000011",
"00000000000000000000001000000100",
"00000000000000000000001000000101",
"00000000000000000000001000000110",
"00000000000000000000001000000111",
"00000000000000000000001000001000",
"00000000000000000000001000001001",
"00000000000000000000001000001010",
"00000000000000000000001000001011",
"00000000000000000000001000001100",
"00000000000000000000001000001101",
"00000000000000000000001000001110",
"00000000000000000000001000001111",
"00000000000000000000001000010000",
"00000000000000000000001000010001",
"00000000000000000000001000010010",
"00000000000000000000001000010011",
"00000000000000000000001000010100",
"00000000000000000000001000010101",
"00000000000000000000001000010110",
"00000000000000000000001000010111",
"00000000000000000000001000011000",
"00000000000000000000001000011001",
"00000000000000000000001000011010",
"00000000000000000000001000011011",
"00000000000000000000001000011100",
"00000000000000000000001000011101",
"00000000000000000000001000011110",
"00000000000000000000001000011111",
"00000000000000000000001000100000",
"00000000000000000000001000100001",
"00000000000000000000001000100010",
"00000000000000000000001000100011",
"00000000000000000000001000100100",
"00000000000000000000001000100101",
"00000000000000000000001000100110",
"00000000000000000000001000100111",
"00000000000000000000001000101000",
"00000000000000000000001000101001",
"00000000000000000000001000101010",
"00000000000000000000001000101011",
"00000000000000000000001000101100",
"00000000000000000000001000101101",
"00000000000000000000001000101110",
"00000000000000000000001000101111",
"00000000000000000000001000110000",
"00000000000000000000001000110001",
"00000000000000000000001000110010",
"00000000000000000000001000110011",
"00000000000000000000001000110100",
"00000000000000000000001000110101",
"00000000000000000000001000110110",
"00000000000000000000001000110111",
"00000000000000000000001000111000",
"00000000000000000000001000111001",
"00000000000000000000001000111010",
"00000000000000000000001000111011",
"00000000000000000000001000111100",
"00000000000000000000001000111101",
"00000000000000000000001000111110",
"00000000000000000000001000111111",
"00000000000000000000001001000000",
"00000000000000000000001001000001",
"00000000000000000000001001000010",
"00000000000000000000001001000011",
"00000000000000000000001001000100",
"00000000000000000000001001000101",
"00000000000000000000001001000110",
"00000000000000000000001001000111",
"00000000000000000000001001001000",
"00000000000000000000001001001001",
"00000000000000000000001001001010",
"00000000000000000000001001001011",
"00000000000000000000001001001100",
"00000000000000000000001001001101",
"00000000000000000000001001001110",
"00000000000000000000001001001111",
"00000000000000000000001001010000",
"00000000000000000000001001010001",
"00000000000000000000001001010010",
"00000000000000000000001001010011",
"00000000000000000000001001010100",
"00000000000000000000001001010101",
"00000000000000000000001001010110",
"00000000000000000000001001010111",
"00000000000000000000001001011000",
"00000000000000000000001001011001",
"00000000000000000000001001011010",
"00000000000000000000001001011011",
"00000000000000000000001001011100",
"00000000000000000000001001011101",
"00000000000000000000001001011110",
"00000000000000000000001001011111",
"00000000000000000000001001100000",
"00000000000000000000001001100001",
"00000000000000000000001001100010",
"00000000000000000000001001100011",
"00000000000000000000001001100100",
"00000000000000000000001001100101",
"00000000000000000000001001100110",
"00000000000000000000001001100111",
"00000000000000000000001001101000",
"00000000000000000000001001101001",
"00000000000000000000001001101010",
"00000000000000000000001001101011",
"00000000000000000000001001101100",
"00000000000000000000001001101101",
"00000000000000000000001001101110",
"00000000000000000000001001101111",
"00000000000000000000001001110000",
"00000000000000000000001001110001",
"00000000000000000000001001110010",
"00000000000000000000001001110011",
"00000000000000000000001001110100",
"00000000000000000000001001110101",
"00000000000000000000001001110110",
"00000000000000000000001001110111",
"00000000000000000000001001111000",
"00000000000000000000001001111001",
"00000000000000000000001001111010",
"00000000000000000000001001111011",
"00000000000000000000001001111100",
"00000000000000000000001001111101",
"00000000000000000000001001111110",
"00000000000000000000001001111111",
"00000000000000000000001010000000",
"00000000000000000000001010000001",
"00000000000000000000001010000010",
"00000000000000000000001010000011",
"00000000000000000000001010000100",
"00000000000000000000001010000101",
"00000000000000000000001010000110",
"00000000000000000000001010000111",
"00000000000000000000001010001000",
"00000000000000000000001010001001",
"00000000000000000000001010001010",
"00000000000000000000001010001011",
"00000000000000000000001010001100",
"00000000000000000000001010001101",
"00000000000000000000001010001110",
"00000000000000000000001010001111",
"00000000000000000000001010010000",
"00000000000000000000001010010001",
"00000000000000000000001010010010",
"00000000000000000000001010010011",
"00000000000000000000001010010100",
"00000000000000000000001010010101",
"00000000000000000000001010010110",
"00000000000000000000001010010111",
"00000000000000000000001010011000",
"00000000000000000000001010011001",
"00000000000000000000001010011010",
"00000000000000000000001010011011",
"00000000000000000000001010011100",
"00000000000000000000001010011101",
"00000000000000000000001010011110",
"00000000000000000000001010011111",
"00000000000000000000001010100000",
"00000000000000000000001010100001",
"00000000000000000000001010100010",
"00000000000000000000001010100011",
"00000000000000000000001010100100",
"00000000000000000000001010100101",
"00000000000000000000001010100110",
"00000000000000000000001010100111",
"00000000000000000000001010101000",
"00000000000000000000001010101001",
"00000000000000000000001010101010",
"00000000000000000000001010101011",
"00000000000000000000001010101100",
"00000000000000000000001010101101",
"00000000000000000000001010101110",
"00000000000000000000001010101111",
"00000000000000000000001010110000",
"00000000000000000000001010110001",
"00000000000000000000001010110010",
"00000000000000000000001010110011",
"00000000000000000000001010110100",
"00000000000000000000001010110101",
"00000000000000000000001010110110",
"00000000000000000000001010110111",
"00000000000000000000001010111000",
"00000000000000000000001010111001",
"00000000000000000000001010111010",
"00000000000000000000001010111011",
"00000000000000000000001010111100",
"00000000000000000000001010111101",
"00000000000000000000001010111110",
"00000000000000000000001010111111",
"00000000000000000000001011000000",
"00000000000000000000001011000001",
"00000000000000000000001011000010",
"00000000000000000000001011000011",
"00000000000000000000001011000100",
"00000000000000000000001011000101",
"00000000000000000000001011000110",
"00000000000000000000001011000111",
"00000000000000000000001011001000",
"00000000000000000000001011001001",
"00000000000000000000001011001010",
"00000000000000000000001011001011",
"00000000000000000000001011001100",
"00000000000000000000001011001101",
"00000000000000000000001011001110",
"00000000000000000000001011001111",
"00000000000000000000001011010000",
"00000000000000000000001011010001",
"00000000000000000000001011010010",
"00000000000000000000001011010011",
"00000000000000000000001011010100",
"00000000000000000000001011010101",
"00000000000000000000001011010110",
"00000000000000000000001011010111",
"00000000000000000000001011011000",
"00000000000000000000001011011001",
"00000000000000000000001011011010",
"00000000000000000000001011011011",
"00000000000000000000001011011100",
"00000000000000000000001011011101",
"00000000000000000000001011011110",
"00000000000000000000001011011111",
"00000000000000000000001011100000",
"00000000000000000000001011100001",
"00000000000000000000001011100010",
"00000000000000000000001011100011",
"00000000000000000000001011100100",
"00000000000000000000001011100101",
"00000000000000000000001011100110",
"00000000000000000000001011100111",
"00000000000000000000001011101000",
"00000000000000000000001011101001",
"00000000000000000000001011101010",
"00000000000000000000001011101011",
"00000000000000000000001011101100",
"00000000000000000000001011101101",
"00000000000000000000001011101110",
"00000000000000000000001011101111",
"00000000000000000000001011110000",
"00000000000000000000001011110001",
"00000000000000000000001011110010",
"00000000000000000000001011110011",
"00000000000000000000001011110100",
"00000000000000000000001011110101",
"00000000000000000000001011110110",
"00000000000000000000001011110111",
"00000000000000000000001011111000",
"00000000000000000000001011111001",
"00000000000000000000001011111010",
"00000000000000000000001011111011",
"00000000000000000000001011111100",
"00000000000000000000001011111101",
"00000000000000000000001011111110",
"00000000000000000000001011111111",
"00000000000000000000001100000000",
"00000000000000000000001100000001",
"00000000000000000000001100000010",
"00000000000000000000001100000011",
"00000000000000000000001100000100",
"00000000000000000000001100000101",
"00000000000000000000001100000110",
"00000000000000000000001100000111",
"00000000000000000000001100001000",
"00000000000000000000001100001001",
"00000000000000000000001100001010",
"00000000000000000000001100001011",
"00000000000000000000001100001100",
"00000000000000000000001100001101",
"00000000000000000000001100001110",
"00000000000000000000001100001111",
"00000000000000000000001100010000",
"00000000000000000000001100010001",
"00000000000000000000001100010010",
"00000000000000000000001100010011",
"00000000000000000000001100010100",
"00000000000000000000001100010101",
"00000000000000000000001100010110",
"00000000000000000000001100010111",
"00000000000000000000001100011000",
"00000000000000000000001100011001",
"00000000000000000000001100011010",
"00000000000000000000001100011011",
"00000000000000000000001100011100",
"00000000000000000000001100011101",
"00000000000000000000001100011110",
"00000000000000000000001100011111",
"00000000000000000000001100100000",
"00000000000000000000001100100001",
"00000000000000000000001100100010",
"00000000000000000000001100100011",
"00000000000000000000001100100100",
"00000000000000000000001100100101",
"00000000000000000000001100100110",
"00000000000000000000001100100111",
"00000000000000000000001100101000",
"00000000000000000000001100101001",
"00000000000000000000001100101010",
"00000000000000000000001100101011",
"00000000000000000000001100101100",
"00000000000000000000001100101101",
"00000000000000000000001100101110",
"00000000000000000000001100101111",
"00000000000000000000001100110000",
"00000000000000000000001100110001",
"00000000000000000000001100110010",
"00000000000000000000001100110011",
"00000000000000000000001100110100",
"00000000000000000000001100110101",
"00000000000000000000001100110110",
"00000000000000000000001100110111",
"00000000000000000000001100111000",
"00000000000000000000001100111001",
"00000000000000000000001100111010",
"00000000000000000000001100111011",
"00000000000000000000001100111100",
"00000000000000000000001100111101",
"00000000000000000000001100111110",
"00000000000000000000001100111111",
"00000000000000000000001101000000",
"00000000000000000000001101000001",
"00000000000000000000001101000010",
"00000000000000000000001101000011",
"00000000000000000000001101000100",
"00000000000000000000001101000101",
"00000000000000000000001101000110",
"00000000000000000000001101000111",
"00000000000000000000001101001000",
"00000000000000000000001101001001",
"00000000000000000000001101001010",
"00000000000000000000001101001011",
"00000000000000000000001101001100",
"00000000000000000000001101001101",
"00000000000000000000001101001110",
"00000000000000000000001101001111",
"00000000000000000000001101010000",
"00000000000000000000001101010001",
"00000000000000000000001101010010",
"00000000000000000000001101010011",
"00000000000000000000001101010100",
"00000000000000000000001101010101",
"00000000000000000000001101010110",
"00000000000000000000001101010111",
"00000000000000000000001101011000",
"00000000000000000000001101011001",
"00000000000000000000001101011010",
"00000000000000000000001101011011",
"00000000000000000000001101011100",
"00000000000000000000001101011101",
"00000000000000000000001101011110",
"00000000000000000000001101011111",
"00000000000000000000001101100000",
"00000000000000000000001101100001",
"00000000000000000000001101100010",
"00000000000000000000001101100011",
"00000000000000000000001101100100",
"00000000000000000000001101100101",
"00000000000000000000001101100110",
"00000000000000000000001101100111",
"00000000000000000000001101101000",
"00000000000000000000001101101001",
"00000000000000000000001101101010",
"00000000000000000000001101101011",
"00000000000000000000001101101100",
"00000000000000000000001101101101",
"00000000000000000000001101101110",
"00000000000000000000001101101111",
"00000000000000000000001101110000",
"00000000000000000000001101110001",
"00000000000000000000001101110010",
"00000000000000000000001101110011",
"00000000000000000000001101110100",
"00000000000000000000001101110101",
"00000000000000000000001101110110",
"00000000000000000000001101110111",
"00000000000000000000001101111000",
"00000000000000000000001101111001",
"00000000000000000000001101111010",
"00000000000000000000001101111011",
"00000000000000000000001101111100",
"00000000000000000000001101111101",
"00000000000000000000001101111110",
"00000000000000000000001101111111",
"00000000000000000000001110000000",
"00000000000000000000001110000001",
"00000000000000000000001110000010",
"00000000000000000000001110000011",
"00000000000000000000001110000100",
"00000000000000000000001110000101",
"00000000000000000000001110000110",
"00000000000000000000001110000111",
"00000000000000000000001110001000",
"00000000000000000000001110001001",
"00000000000000000000001110001010",
"00000000000000000000001110001011",
"00000000000000000000001110001100",
"00000000000000000000001110001101",
"00000000000000000000001110001110",
"00000000000000000000001110001111",
"00000000000000000000001110010000",
"00000000000000000000001110010001",
"00000000000000000000001110010010",
"00000000000000000000001110010011",
"00000000000000000000001110010100",
"00000000000000000000001110010101",
"00000000000000000000001110010110",
"00000000000000000000001110010111",
"00000000000000000000001110011000",
"00000000000000000000001110011001",
"00000000000000000000001110011010",
"00000000000000000000001110011011",
"00000000000000000000001110011100",
"00000000000000000000001110011101",
"00000000000000000000001110011110",
"00000000000000000000001110011111",
"00000000000000000000001110100000",
"00000000000000000000001110100001",
"00000000000000000000001110100010",
"00000000000000000000001110100011",
"00000000000000000000001110100100",
"00000000000000000000001110100101",
"00000000000000000000001110100110",
"00000000000000000000001110100111",
"00000000000000000000001110101000",
"00000000000000000000001110101001",
"00000000000000000000001110101010",
"00000000000000000000001110101011",
"00000000000000000000001110101100",
"00000000000000000000001110101101",
"00000000000000000000001110101110",
"00000000000000000000001110101111",
"00000000000000000000001110110000",
"00000000000000000000001110110001",
"00000000000000000000001110110010",
"00000000000000000000001110110011",
"00000000000000000000001110110100",
"00000000000000000000001110110101",
"00000000000000000000001110110110",
"00000000000000000000001110110111",
"00000000000000000000001110111000",
"00000000000000000000001110111001",
"00000000000000000000001110111010",
"00000000000000000000001110111011",
"00000000000000000000001110111100",
"00000000000000000000001110111101",
"00000000000000000000001110111110",
"00000000000000000000001110111111",
"00000000000000000000001111000000",
"00000000000000000000001111000001",
"00000000000000000000001111000010",
"00000000000000000000001111000011",
"00000000000000000000001111000100",
"00000000000000000000001111000101",
"00000000000000000000001111000110",
"00000000000000000000001111000111",
"00000000000000000000001111001000",
"00000000000000000000001111001001",
"00000000000000000000001111001010",
"00000000000000000000001111001011",
"00000000000000000000001111001100",
"00000000000000000000001111001101",
"00000000000000000000001111001110",
"00000000000000000000001111001111",
"00000000000000000000001111010000",
"00000000000000000000001111010001",
"00000000000000000000001111010010",
"00000000000000000000001111010011",
"00000000000000000000001111010100",
"00000000000000000000001111010101",
"00000000000000000000001111010110",
"00000000000000000000001111010111",
"00000000000000000000001111011000",
"00000000000000000000001111011001",
"00000000000000000000001111011010",
"00000000000000000000001111011011",
"00000000000000000000001111011100",
"00000000000000000000001111011101",
"00000000000000000000001111011110",
"00000000000000000000001111011111",
"00000000000000000000001111100000",
"00000000000000000000001111100001",
"00000000000000000000001111100010",
"00000000000000000000001111100011",
"00000000000000000000001111100100",
"00000000000000000000001111100101",
"00000000000000000000001111100110",
"00000000000000000000001111100111",
"00000000000000000000001111101000",
"00000000000000000000001111101001",
"00000000000000000000001111101010",
"00000000000000000000001111101011",
"00000000000000000000001111101100",
"00000000000000000000001111101101",
"00000000000000000000001111101110",
"00000000000000000000001111101111",
"00000000000000000000001111110000",
"00000000000000000000001111110001",
"00000000000000000000001111110010",
"00000000000000000000001111110011",
"00000000000000000000001111110100",
"00000000000000000000001111110101",
"00000000000000000000001111110110",
"00000000000000000000001111110111",
"00000000000000000000001111111000",
"00000000000000000000001111111001",
"00000000000000000000001111111010",
"00000000000000000000001111111011",
"00000000000000000000001111111100",
"00000000000000000000001111111101",
"00000000000000000000001111111110",
"00000000000000000000001111111111",
"00000000000000000000010000000000"
   );
  signal i : integer range 0 to (m-1) := 0;
  begin
    shift: process (rst, clk)
    begin
    if rising_edge(clk) then
     if rst = '1' then                -- sync. reset
        ts <= "00000000000000000000000000000000";
     else
        ts <= ts_array(i);
        i <= i+1;
     end if; -- end of if rst = '1'
    end if; -- end if rising_edge
  end process;
  end;
