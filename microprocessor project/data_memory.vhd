library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity data_memory is
	port	(
			address_i	: in std_logic_vector (7 downto 0);
			data_in		: in std_logic_vector (7 downto 0);
			write_i		: in std_logic (7 downto 0);
			clk_i		: in std_logic (7 downto 0);
			----outs:
			data_out	: out std_logic_vector (7 downto 0);	
			);

end entity;

architecture arch of data_memory is

type ram_type is array (128 to 223) of std_logic_vector(7 downto 0); 
signal RAM: ram_type := (others => x"00");
signal enable : std_logic;

begin

process	(address_i)
begin 
	if (address_i >= x"80" and address_i <= x"DF") then
		enable <= '1';
	else 
		enable <= '0';
	end if;
end process;

process(clk_i)	
begin 
	if (rising_edge (clk_i)) then
		if (enable = '1' and write_i = '1') then
			RAM (to_integer(unsigned(address_i))) <= data_in;
		elsif (enable = '1' and write_i = '0') then
			data_out <= RAM(to_integer(unsigned(address_i)));
		end if;
	end if;
end process;

end architecture;	

