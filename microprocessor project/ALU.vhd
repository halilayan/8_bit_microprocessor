library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ALU is
	port(
			A_i			: in std_logic_vector(7 downto 0);	-- Signed
			B_i			: in std_logic_vector(7 downto 0);	-- Signed
			ALU_Sel_i		: in std_logic_vector(2 downto 0);	-- Ýþlem turu
			-- Output:
			NZVC_o		: out std_logic_vector(3 downto 0);
			ALU_result_o	: out std_logic_vector(7 downto 0)
	);
end ALU;

architecture arch of ALU is

signal sum_unsigned	: std_logic_vector(8 downto 0); -- Carry var mý görmek için
signal alu_signal	: std_logic_vector(7 downto 0);
signal toplama_overflow	: std_logic;	 -- Overflow var mi görmek için (Toplamada)
signal cikartma_overflow	: std_logic;	 -- Carry var mi görmek için (Çýkartmada)

begin

process(ALU_Sel_i, A_i, B_i)
begin
	sum_unsigned <= (others => '0');	-- reset parameter
	
	case ALU_Sel_i is
		when "000" =>	-- Toplama
			alu_signal <= A_i + B_i;
			sum_unsigned <= ('0' & A_i) + ('0' + B_i);
			
		when "001" =>	-- Cikarma
			alu_signal <= A_i - B_i;
			sum_unsigned <= ('0' & A_i) - ('0' + B_i);
			
		when "010" => -- AND
			alu_signal <= A_i and B_i;
		
		when "011" => -- OR
			alu_signal <= A_i or B_i;
			
		when "100" => -- +1 Arttir
			alu_signal <= A_i + x"01";
			
		when "101" => -- -1 Azalt
			alu_signal <= A_i - x"01";
		
		when others =>
			alu_signal <= (others => '0');
			sum_unsigned <= (others => '0');			
	end case;

end process;

ALU_result_o <= alu_signal;

--- NZVC_o	(Negatif, Sifir, Overflow, Carry)

--N:
NZVC_o(3) <= alu_signal(7);

--Z:
NZVC_o(2)	<= '1' when (alu_signal = x"00") else '0';

--V:
toplama_overflow <= (not(A_i(7)) and not(B_i(7)) and alu_signal(7)) or (A_i(7) and B_i(7) and not(alu_signal(7)));
cikartma_overflow <= (not(A_i(7)) and B_i(7) and alu_signal(7)) or (A_i(7) and not(B_i(7)) and not(alu_signal(7)));

NZVC_o(1) <= toplama_overflow when (ALU_Sel_i = "000") else
		   cikartma_overflow when (ALU_Sel_i = "001") else '0';
		   
--C:
NZVC_o(0) <= sum_unsigned(8) when (ALU_Sel_i = "000") else
		   sum_unsigned(8) when (ALU_Sel_i = "001") else '0';
	
end architecture;