library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity data_path is
	port(
			clk_i		: in std_logic;
			rst_i		: in std_logic;
			IR_Load_i	: in std_logic;	-- Komut register'i yükle kontrol
			MAR_Load_i 	: in std_logic;
			PC_Load_i 	: in std_logic;
			PC_Inc_i    : in std_logic;
			A_Load_i 		: in std_logic;
			B_Load_i 		: in std_logic;
			ALU_Sel_i 	: in std_logic_vector(2 downto 0);
			CCR_Load_i 	: in std_logic;
			BUS1_Sel_i	: in std_logic_vector(1 downto 0);
			BUS2_Sel_i	: in std_logic_vector(1 downto 0);
			from_memory_i: in std_logic_vector(7 downto 0);
			-- Outputs:
			IR_o			: out std_logic_vector(7 downto 0);
			address_o		: out std_logic_vector(7 downto 0);	-- belleðe giden adres bilgisi
			CCR_Result_o	: out std_logic_vector(3 downto 0);	-- NZVC
			to_memory_o	: out std_logic_vector(7 downto 0)	-- belleðe giden veri
		
	);
end data_path;


architecture arch of data_path is

-- ALU:
component ALU is
	port(
			A			: in std_logic_vector(7 downto 0);	-- Signed
			B			: in std_logic_vector(7 downto 0);	-- Signed
			ALU_Sel_i		: in std_logic_vector(2 downto 0);	-- iþlem türü
			-- Output:
			NZVC		: out std_logic_vector(3 downto 0);
			ALU_result	: out std_logic_vector(7 downto 0)
	);
end component;

-- Veri yolu iç sinyalleri:
signal BUS1	 		 : std_logic_vector(7 downto 0);
signal BUS2			 : std_logic_vector(7 downto 0);
signal ALU_result	 : std_logic_vector(7 downto 0);
signal IR_reg		 : std_logic_vector(7 downto 0);
signal MAR 			 : std_logic_vector(7 downto 0);
signal PC 			 : std_logic_vector(7 downto 0);
signal A_reg		 : std_logic_vector(7 downto 0);
signal B_reg		 : std_logic_vector(7 downto 0);
signal CCR_in		 : std_logic_vector(3 downto 0);
signal CCR           : std_logic_vector(3 downto 0);
begin

-- BUS1_Mux:
	BUS1 <= PC	  when BUS1_Sel_i <= "00" else
			A_reg when BUS1_Sel_i <= "01" else
			B_reg when BUS1_Sel_i <= "10" else (others => '0');
			
-- BUS2_Mux:
	BUS2 <= ALU_result  	when BUS2_Sel_i <= "00" else
			BUS1 	    	when BUS2_Sel_i <= "01" else
			from_memory_i   when BUS2_Sel_i <= "10" else (others => '0');

-- Komut Register (IR_o)
	process(clk_i, rst_i)
	begin
		if(rst_i = '1') then
			IR_reg <= (others => '0');
		elsif(rising_edge(clk_i)) then
			if(IR_Load_i = '1') then
				IR_reg <= BUS2;
			end if;
		end if;
	end process;
	IR_o <= IR_reg;

-- Memory Access Register (MAR)
	process(clk_i, rst_i)
	begin
		if(rst_i = '1') then
			MAR <= (others => '0');
		elsif(rising_edge(clk_i)) then
			if(MAR_Load_i = '1') then
				MAR <= BUS2;
			end if;
		end if;
	end process;
	address_o <= MAR;

-- Program Counter (PC)
	process(clk_i, rst_i)
	begin
		if(rst_i = '1') then
			PC <= (others => '0');
		elsif(rising_edge(clk_i)) then
			if(PC_Load_i = '1') then
				PC <= BUS2;
			elsif(PC_Inc_i = '1') then
				PC <= PC + x"01";
			end if;
		end if;
	end process;

-- A Register (A_reg)
	process(clk_i, rst_i)
	begin
		if(rst_i = '1') then
			A_reg <= (others => '0');
		elsif(rising_edge(clk_i)) then
			if(A_Load_i = '1') then
				A_reg <= BUS2;
			end if;
		end if;
	end process;

-- B Register (B_reg)
	process(clk_i, rst_i)
	begin
		if(rst_i = '1') then
			B_reg <= (others => '0');
		elsif(rising_edge(clk_i)) then
			if(B_Load_i = '1') then
				B_reg <= BUS2;
			end if;
		end if;
	end process;

-- ALU
ALU_U: ALU port map
			(	
				A			=> B_reg,		
				B			=> BUS1,	
				ALU_Sel		=> ALU_Sel,
				-- Output:
				NZVC		=> CCR_in,
				ALU_result	=> ALU_result
			);
		
-- CCR Register
	process(clk_i, rst_i)
	begin
		if(rst_i = '1') then
			CCR <= (others => '0');
		elsif(rising_edge(clk_i)) then
			if(CCR_Load_i = '1') then
				CCR <= CCR_in;	-- NZVC flag bilgisi
			end if;
		end if;
	end process;
	CCR_Result_o <= CCR;
	
-- Veri yolundan belleðe gidecek sinyal atamasý:
	to_memory_o <= BUS1;



end architecture;