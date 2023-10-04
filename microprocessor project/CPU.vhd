library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity CPU is
	port(
			clk_i	: in std_logic;
			rst_i	: in std_logic;
			from_memory_i	: in std_logic_vector(7 downto 0);
			-- Outputs:
			to_memory_o	: out std_logic_vector(7 downto 0);
			write_o		: out std_logic;
			address_o	: out std_logic_vector(7 downto 0)	
	);
end CPU;

architecture arch of CPU is

-- Control Unit:
component control_unit is
	port(
			clk_i			: in std_logic;
			rst_i			: in std_logic;
			CCR_Result_i	: in std_logic_vector(3 downto 0);
			IR_i			: in std_logic_vector(7 downto 0);
			-- Outputlar:
			IR_Load_o		: out std_logic;	-- Komut register'i yükle kontrol
			MAR_Load_o 		: out std_logic;
			PC_Load_o 		: out std_logic;
			PC_Inc_o		: out std_logic;
			A_Load_o 		: out std_logic;
			B_Load_o 		: out std_logic;
			ALU_Sel_o 		: out std_logic_vector(2 downto 0);
			CCR_Load_o 		: out std_logic;
			BUS1_Sel_o		: out std_logic_vector(1 downto 0);
			BUS2_Sel_o		: out std_logic_vector(1 downto 0);
			write_en_o		: out std_logic

	);
end component;

-- Data Path:
component data_path is
	port(
			clk_i			: in std_logic;
			rst_i			: in std_logic;
			IR_Load_i		: in std_logic;	-- Komut register'i yükle kontrol
			MAR_Load_i 		: in std_logic;
			PC_Load_i 		: in std_logic;
			PC_Inc_i 		: in std_logic;
			A_Load_i		: in std_logic;
			B_Load_i 		: in std_logic;
			ALU_Sel_i 		: in std_logic_vector(2 downto 0);
			CCR_Load_i 		: in std_logic;
			BUS1_Sel_i		: in std_logic_vector(1 downto 0);
			BUS2_Sel_i		: in std_logic_vector(1 downto 0);
			from_memory_i	: in std_logic_vector(7 downto 0);
			-- Outputs:
			IR_o			: out std_logic_vector(7 downto 0);
			address_o		: out std_logic_vector(7 downto 0);	-- belleğe giden adres bilgisi
			CCR_Result_o	: out std_logic_vector(3 downto 0);	-- NZVC
			to_memory_o		: out std_logic_vector(7 downto 0)	-- belleğe giden veri
		
	);
end component;

-- Baglanti Sinyalleri

signal IR_Load		: std_logic;	-- Komut register'i yükle kontrol
signal IR			: std_logic_vector(7 downto 0);
signal MAR_Load 	: std_logic;
signal PC_Load 		: std_logic;
signal PC_Inc 		: std_logic;
signal A_Load 		: std_logic;
signal B_Load 		: std_logic;
signal ALU_Sel 		: std_logic_vector(2 downto 0);
signal CCR_Load 	: std_logic;
signal CCR_Result	: std_logic_vector(3 downto 0);	
signal BUS1_Sel		: std_logic_vector(1 downto 0);
signal BUS2_Sel		: std_logic_vector(1 downto 0);	

begin

-- Control Unit:
control_unit_module: control_unit port map
									(	
										clk_i				=> 	clk_i,
										rst_i			    =>  rst_i,
										CCR_Result_i	    =>  CCR_Result_i,
										IR_i			    =>  IR_i,
										-- Outputlar   
										IR_Load_o		    => IR_Load_o,
										MAR_Load_o 	   	    => MAR_Load_o,
										PC_Load_o 	   	    => PC_Load_o,
										PC_Inc_o 		    => PC_Inc_o,
										A_Load_o 		    => A_Load_o, 	
										B_Load_o 		    => B_Load_o, 	
										ALU_Sel_o 	   	    => ALU_Sel_o, 
										CCR_Load_o 	    	=> CCR_Load_o,
										BUS1_Sel_o	    	=> BUS1_Sel_o,
										BUS2_Sel_o	    	=> BUS2_Sel_o,
										write_o	    		=> write_o
									);


-- Data Path:
data_path_module: data_path port map
							(
								clk_i			=> clk_i,			
								rst_i		    => rst_i,			
								IR_Load_i	    => IR_Load_i,	
								MAR_Load_i 	    => MAR_Load_i,	
								PC_Load_i 	    => PC_Load_i, 	
								PC_Inc_i 	    => PC_Inc_i, 		
								A_Load_i 	    => A_Load_i, 		
								B_Load _i	    => B_Load_i, 		
								ALU_Sel _i	    => ALU_Sel_i, 	
								CCR_Load_i 	    => CCR_Load_i, 	
								BUS1_Sel_i	    => BUS1_Sel_i,	
								BUS2_Sel_i	    => BUS2_Sel_i,	
								from_memory_i   => from_memory_i,	
								-- Outputs:     => -- Outputs:
								IR_o			    => IR_o,			
								address_o		    => address_o,		
								CCR_Result_o	    => CCR_Result_o,	
								to_memory_o	    => to_memory_o	
							);


end architecture;