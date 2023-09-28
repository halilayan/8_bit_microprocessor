library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity program_memory is
	port (
			clk_i		: in std_logic;
			address_i	: in std_logic_vector (7 downto 0);
			---outputs:
			data_out: out std_logic_vector(7 downto 0);	
	);
end entity;

architecture arch of program_memory is

--BÜTÜN KOMUTLAR

--Kaydet/Yükle komutları
constant YUKLE_A_SBT 	: std_logic_vector (7 downto 0) := "86";
constant YUKLE_A		: std_logic_vector (7 downto 0) := "87";
constant YUKLE_B_SBT	: std_logic_vector (7 downto 0) := "88";
constant YUKLE_B		: std_logic_vector (7 downto 0) := "89";
constant KAYDET_A		: std_logic_vector (7 downto 0) := "96";
constant KAYDET_B		: std_logic_vector (7 downto 0) := "97";

--ALU komutları
constant TOPLA_AB		: std_logic_vector (7 downto 0) := "42";
constant CIKART_AB		: std_logic_vector (7 downto 0) := "43";
constant AND_AB			: std_logic_vector (7 downto 0) := "44";
constant OR_AB			: std_logic_vector (7 downto 0) := "45";
constant ARTTIR_A		: std_logic_vector (7 downto 0) := "46";
constant ARTTIR_B		: std_logic_vector (7 downto 0) := "47";
constant AZALT_A		: std_logic_vector (7 downto 0) := "48";
constant AZALT_B		: std_logic_vector (7 downto 0) := "49";

--Atlama komutları
constant ATLA					: std_logic_vector (7 downto 0) := "20";
constant ATLA_NEGATIFSE			: std_logic_vector (7 downto 0) := "21";
constant ATLA_POZITIFSE			: std_logic_vector (7 downto 0) := "22";
constant ATLA_ESISTE_SIFIRA		: std_logic_vector (7 downto 0) := "23";
constant ATLA_DEGILSE_SIFIR		: std_logic_vector (7 downto 0) := "24";
constant ATLA_OVERFLOW_VARSA	: std_logic_vector (7 downto 0) := "25";
constant ATLA_OVERFLOW_YOKSA	: std_logic_vector (7 downto 0) := "26";
constant ATLA_ELDE_VARSA		: std_logic_vector (7 downto 0) := "27";
constant ATLA_ELDE_YOKSA		: std_logic_vector (7 downto 0) := "28";

type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
	constant ROM : rom_type := (
								0 		=> YUKLE_A_SBT,
								1 		=> x "AA",
								2 		=> KAYDET_A,
								3 		=> x "EO",	
								4 		=> ATLA,	
								5 		=> x "00",
								others  => x "00"
								);

signal enable : std_logic;
begin 

process(address_i)
begin
	if (address_i >= x"00" and address_i <= x"7F") then 
		enable <= '1';
	else 
		enable <= '0';
	end if;
end process;

process (clk_i)
begin 
	if( rising_edge(clk_i)) then
		if (enable = '1') then 
	   data_out <= ROM ( to_integer(unsigned(address_i)));
	   end if;  
   end if;
 end process;  


end architecture;