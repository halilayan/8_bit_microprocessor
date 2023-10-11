library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
	port(
			clk_i			: in std_logic;
			rst_i			: in std_logic;
			CCR_Result_i	: in std_logic_vector(3 downto 0);
			IR_i			: in std_logic_vector(7 downto 0);
			-- Outputlar:
			IR_Load_o		: out std_logic;	-- Komut register'i yükle kontrol
			MAR_Load_o 		: out std_logic;
			PC_Load_o 		: out std_logic;
			PC_Inc_o 		: out std_logic;
			A_Load_o 		: out std_logic;
			B_Load_o 		: out std_logic;
			ALU_Sel_o 		: out std_logic_vector(2 downto 0);
			CCR_Load_o	 	: out std_logic;
			BUS1_Sel_o		: out std_logic_vector(1 downto 0);
			BUS2_Sel_o		: out std_logic_vector(1 downto 0);
			write_o			: out std_logic

	);
end control_unit;

architecture arch of control_unit is

type state_type is  (
						S_FETCH_0, S_FETCH_1, S_FETCH_2, S_DECODE_3,
						S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,
						S_LDA_DIR_4, S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8,
						S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6,
						S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7, S_LDB_DIR_8,
						S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,
						S_ADD_AB_4,
						S_BRA_4, S_BRA_5, S_BRA_6,
						S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7
					);
					
signal current_state, next_state : state_type;

-- Tüm komutlar:

-- Kaydet/Yükle komutlarý
constant YUKLE_A_SBT	:std_logic_vector(7 downto 0) := x"86";
constant YUKLE_A		:std_logic_vector(7 downto 0) := x"87";
constant YUKLE_B_SBT	:std_logic_vector(7 downto 0) := x"88";
constant YUKLE_B		:std_logic_vector(7 downto 0) := x"89";
constant KAYDET_A		:std_logic_vector(7 downto 0) := x"96";	
constant KAYDET_B		:std_logic_vector(7 downto 0) := x"97";
-- ALU Komutlarý
constant TOPLA_AB		:std_logic_vector(7 downto 0) := x"42";
constant CIKAR_AB		:std_logic_vector(7 downto 0) := x"43";
constant AND_AB			:std_logic_vector(7 downto 0) := x"44";
constant OR_AB			:std_logic_vector(7 downto 0) := x"45";
constant ARTTIR_A		:std_logic_vector(7 downto 0) := x"46";
constant ARTTIR_B		:std_logic_vector(7 downto 0) := x"47";
constant DUSUR_A		:std_logic_vector(7 downto 0) := x"48";
constant DUSUR_B		:std_logic_vector(7 downto 0) := x"49";
-- Atlama komutlarý (Koþullu/Koþulsuz)
constant ATLA					:std_logic_vector(7 downto 0) := x"20";
constant ATLA_NEGATIFSE			:std_logic_vector(7 downto 0) := x"21";
constant ATLA_POZITIFSE			:std_logic_vector(7 downto 0) := x"22";
constant ATLA_ESITSE_SIFIR		:std_logic_vector(7 downto 0) := x"23";
constant ATLA_DEGILSE_SIFIR		:std_logic_vector(7 downto 0) := x"24";
constant ATLA_OVERFLOW_VARSA	:std_logic_vector(7 downto 0) := x"25";
constant ATLA_OVERFLOW_YOKSA	:std_logic_vector(7 downto 0) := x"26";
constant ATLA_ELDE_VARSA		:std_logic_vector(7 downto 0) := x"27";
constant ATLA_ELDE_YOKSA		:std_logic_vector(7 downto 0) := x"28";

begin

-- Current State Logic
	process (clk_i, rst_i)
	begin
		if(rst_i = '1') then
			current_state <= S_FETCH_0;
		elsif(rising_edge(clk_i)) then
			current_state <= next_state;
		end if;	
	end process;

-- Next State Logic
	process(current_state, IR_i, CCR_Result_i)
	begin
		case current_state is
			when S_FETCH_0  =>
				next_state <= S_FETCH_1;
			when S_FETCH_1  =>
				next_state <= S_FETCH_2;
			when S_FETCH_2  =>
				next_state <= S_DECODE_3;
			when S_DECODE_3  =>
				if(IR_i = YUKLE_A_SBT) then
					next_state <= S_LDA_IMM_4;
				elsif(IR_i = YUKLE_A) then
					next_state <= S_LDA_DIR_4;
				elsif(IR_i = YUKLE_B_SBT) then
					next_state <= S_LDB_IMM_4;
				elsif(IR_i = YUKLE_B) then
					next_state <= S_LDB_DIR_4;
				elsif(IR_i = KAYDET_A) then
					next_state <= S_STA_DIR_4;
				elsif(IR_i = TOPLA_AB) then
					next_state <= S_ADD_AB_4;
				elsif(IR_i = ATLA) then
					next_state <= S_BRA_4;
				elsif(IR_i = ATLA_ESITSE_SIFIR) then
					if(CCR_Result_i(2) = '1') then	--NZVC, Zero bilgisi 2. bitte
						next_state <= S_BEQ_4;
					else	-- Z = '0'
						next_state <= S_BEQ_7;
					end if;
				else
					next_state <= S_FETCH_0;
				end if;
---------------------------------------------------------------
			when S_LDA_IMM_4 =>
				next_state <= S_LDA_IMM_5;
			when S_LDA_IMM_5 =>
				next_state <= S_LDA_IMM_6;
			when S_LDA_IMM_6 =>
				next_state <= S_FETCH_0;
---------------------------------------------------------------		
	
			when S_LDA_DIR_4 =>
				next_state <= S_LDA_DIR_5;
			when S_LDA_DIR_5 =>
				next_state <= S_LDA_DIR_6;
			when S_LDA_DIR_6 =>
				next_state <= S_LDA_DIR_7;
			when S_LDA_DIR_7 =>	
				next_state <= S_LDA_DIR_8;
			when S_LDA_DIR_8 =>
				next_state <= S_FETCH_0;

---------------------------------------------------------------
			when S_LDB_IMM_4 =>
				next_state <= S_LDB_IMM_5;
			when S_LDB_IMM_5 =>
				next_state <= S_LDB_IMM_6;
			when S_LDB_IMM_6 =>
				next_state <= S_FETCH_0;
---------------------------------------------------------------		
	
			when S_LDB_DIR_4 =>
				next_state <= S_LDB_DIR_5;
			when S_LDB_DIR_5 =>
				next_state <= S_LDB_DIR_6;
			when S_LDB_DIR_6 =>
				next_state <= S_LDB_DIR_7;
			when S_LDB_DIR_7 =>	
				next_state <= S_LDB_DIR_8;
			when S_LDB_DIR_8 =>
				next_state <= S_FETCH_0;
---------------------------------------------------------------
				
			when S_STA_DIR_4 =>
				next_state <= S_STA_DIR_5;
			when S_STA_DIR_5 =>
				next_state <= S_STA_DIR_6;
			when S_STA_DIR_6 =>
				next_state <= S_STA_DIR_7;
			when S_STA_DIR_7 =>
				next_state <= S_FETCH_0;
---------------------------------------------------------------

			when S_ADD_AB_4 =>
				next_state <= S_FETCH_0;
---------------------------------------------------------------

			when S_BRA_4 =>
				next_state <= S_BRA_5;
			when S_BRA_5 =>
				next_state <= S_BRA_6;
			when S_BRA_6 =>
				next_state <= S_FETCH_0;	
---------------------------------------------------------------

			when S_BEQ_4 =>
				next_state <= S_BEQ_5;
			when S_BEQ_5 =>
				next_state <= S_BEQ_6;
			when S_BEQ_6 =>
				next_state <= S_FETCH_0;
			when S_BEQ_7 =>	-- Z = '0' durumu, komut bypass
				next_state <= S_FETCH_0;
---------------------------------------------------------------
				
			when others =>
				next_state <= S_FETCH_0;	
				
		end case;	
	end process;

-- Output Logic--

	process(current_state)
	begin
		IR_Load_o <= '0';
		MAR_Load_o <= '0';
		PC_Load_o <= '0';
		PC_Inc_o <= '0';
		A_Load_o <= '0';
	    B_Load_o <= '0';
		ALU_Sel_o <= (others => '0');
		CCR_Load_o <= '0';
		BUS1_Sel_o <= (others => '0');
		BUS2_Sel_o <= (others => '0');
		write_o <= '0';
		
		case current_state is
			when S_FETCH_0  =>
				BUS1_Sel_o <= "00"; -- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_FETCH_1  =>
				PC_Inc_o <= '1';	
			when S_FETCH_2  =>
				BUS2_Sel_o <= "10";		-- from memory
				IR_Load_o <= '1';
			when S_DECODE_3  =>
				-- next state zaten güncellendi, ve ilgili dallanma saðlandý
---------------------------------------------------------------
			when S_LDA_IMM_4 =>
				BUS1_Sel_o <= "00";	-- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_LDA_IMM_5 =>
				PC_Inc_o <= '1';	
			when S_LDA_IMM_6 =>
				BUS2_Sel_o <= "10";		-- from memory
				A_Load_o <= '1';
---------------------------------------------------------------		
	
			when S_LDA_DIR_4 =>
				BUS1_Sel_o <= "00";	-- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_LDA_DIR_5 =>
				PC_Inc_o <= '1';	
			when S_LDA_DIR_6 =>
				BUS2_Sel_o <= "10";		-- from memory
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_LDA_DIR_7 =>	
				-- BOS : Bellekten okuma yapýlmasý bekleniyor.
			when S_LDA_DIR_8 =>
				BUS2_Sel_o <= "10";		-- from memory
				A_Load_o <= '1';
---------------------------------------------------------------
			when S_LDB_IMM_4 =>
				BUS1_Sel_o <= "00";	-- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_LDB_IMM_5 =>
				PC_Inc_o <= '1';	
			when S_LDB_IMM_6 =>
				BUS2_Sel_o <= "10";		-- from memory
				A_Load_o <= '1';
---------------------------------------------------------------		
	
			when S_LDB_DIR_4 =>
				BUS1_Sel_o <= "00";	-- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_LDB_DIR_5 =>
				PC_Inc_o <= '1';	
			when S_LDB_DIR_6 =>
				BUS2_Sel_o <= "10";		-- from memory
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_LDB_DIR_7 =>	
				-- BOS : Bellekten okuma yapýlmasý bekleniyor.
			when S_LDB_DIR_8 =>
				BUS2_Sel_o <= "10";		-- from memory
				A_Load_o <= '1';
---------------------------------------------------------------
				
			when S_STA_DIR_4 =>
				BUS1_Sel_o <= "00";	-- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_STA_DIR_5 =>
				PC_Inc_o <= '1';	
			when S_STA_DIR_6 =>
				BUS2_Sel_o <= "10";		-- from memory
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_STA_DIR_7 =>
				BUS1_Sel_o <= "01";	-- A_reg
				write_o <= '1';
---------------------------------------------------------------

			when S_ADD_AB_4 =>
				BUS1_Sel_o <= "01";	-- A_reg
				BUS2_Sel_o <= "00";	-- ALU result
				ALU_Sel_o <= "000";	-- Toplama kodu ALU'daki
				A_Load_o <= '1';
				CCR_Load_o <= '1';
---------------------------------------------------------------

			when S_BRA_4 =>
				BUS1_Sel_o <= "00";	-- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_BRA_5 =>
				-- BOS
			when S_BRA_6 =>
				BUS2_Sel_o <= "10";		-- from memory
				PC_Load_o <= '1';			-- Program sayaci registerina BUS2 verisini al
---------------------------------------------------------------

			when S_BEQ_4 =>
				BUS1_Sel_o <= "00";	-- PC
				BUS2_Sel_o <= "01"; -- BUS1
				MAR_Load_o <= '1';  -- BUS2 daki program sayacý deðeri MAR'a alýndý
			when S_BEQ_5 =>
				
			when S_BEQ_6 =>
				BUS2_Sel_o <= "10";		-- from memory
				PC_Load_o <= '1';			-- Program sayacý registerýna BUS2 verisini al
			when S_BEQ_7 =>	-- Z = '0' durumu, komut bypass
				PC_Inc_o <= '1';
---------------------------------------------------------------
				
			when others =>
				IR_Load_o	 <= '0';
				MAR_Load_o	 <= '0';
				PC_Load_o	 <= '0';
				A_Load_o 	 <= '0';
			    B_Load_o 	 <= '0';
				ALU_Sel_o	 <= (others => '0');
				CCR_Load_o 	 <= '0';
				BUS1_Sel_o   <= (others => '0');
				BUS2_Sel_o 	 <= (others => '0');
				write_o 	 <= '0';		
				
		end case;
	end process;


end architecture;