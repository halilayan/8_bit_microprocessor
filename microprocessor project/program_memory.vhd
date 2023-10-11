library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity program_memory is
	port (
			clk_i		: in std_logic;
			address_i	: in std_logic_vector (7 downto 0);
			---outputs:
			data_out: out std_logic_vector(7 downto 0)	
	);
end entity;

architecture arch of program_memory is

--B�T�N KOMUTLAR

--Kaydet/Y�kle komutlar�
constant YUKLE_A_SBT 	: std_logic_vector (7 downto 0) := x"86";
constant YUKLE_A		: std_logic_vector (7 downto 0) := x"87";
constant YUKLE_B_SBT	: std_logic_vector (7 downto 0) := x"88";
constant YUKLE_B		: std_logic_vector (7 downto 0) := x"89";
constant KAYDET_A		: std_logic_vector (7 downto 0) := x"96";
constant KAYDET_B		: std_logic_vector (7 downto 0) := x"97";

--ALU komutlar�
constant TOPLA_AB		: std_logic_vector (7 downto 0) := x"42";
constant CIKART_AB		: std_logic_vector (7 downto 0) := x"43";
constant AND_AB			: std_logic_vector (7 downto 0) := x"44";
constant OR_AB			: std_logic_vector (7 downto 0) := x"45";
constant ARTTIR_A		: std_logic_vector (7 downto 0) := x"46";
constant ARTTIR_B		: std_logic_vector (7 downto 0) := x"47";
constant AZALT_A		: std_logic_vector (7 downto 0) := x"48";
constant AZALT_B		: std_logic_vector (7 downto 0) := x"49";

--Atlama komutlar�
constant ATLA					: std_logic_vector (7 downto 0) := x"20";
constant ATLA_NEGATIFSE			: std_logic_vector (7 downto 0) := x"21";
constant ATLA_POZITIFSE			: std_logic_vector (7 downto 0) := x"22";
constant ATLA_ESISTE_SIFIRA		: std_logic_vector (7 downto 0) := x"23";
constant ATLA_DEGILSE_SIFIR		: std_logic_vector (7 downto 0) := x"24";
constant ATLA_OVERFLOW_VARSA	: std_logic_vector (7 downto 0) := x"25";
constant ATLA_OVERFLOW_YOKSA	: std_logic_vector (7 downto 0) := x"26";
constant ATLA_ELDE_VARSA		: std_logic_vector (7 downto 0) := x"27";
constant ATLA_ELDE_YOKSA		: std_logic_vector (7 downto 0) := x"28";

type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
	constant ROM : rom_type := (	
                                	0	=> YUKLE_A_SBT,
									1	=> x"0F",
									2	=> YUKLE_B_SBT,
									3	=> x"41",
									4	=> TOPLA_AB,
									5	=> KAYDET_A,
									6   => x"80",
									7   => ATLA,
									8   => x"00",									
									others 	=> x"00"
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