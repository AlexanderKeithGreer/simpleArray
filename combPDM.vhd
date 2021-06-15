--This is a single section implementation of a comb.
--It gives the output twice to make that accessible 
--	to the general process statements.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity combPDM is
	generic (WInternal 		: integer := 16;
				delays			: integer := 2
			   );
	port (clk		: in std_logic;	--Low Rate Clock
			reset		: in std_logic;	--Asynchronous reset, should be triggered on startup
			input 	: in std_logic_vector (WInternal-1 downto 0);
			output	: out std_logic_vector (WInternal-1 downto 0)
			);
end combPDM;

architecture arch of combPDM is
	subtype SInternal is signed(WInternal-1 downto 0);
	type ACombCircBuffT is array (0 to delays-1) of SInternal;
	signal ACombCircBuff : ACombCircBuffT;
	
	signal index : integer range 0 to delays-1;
begin
	
	comb: process(clk, input, reset)
		variable sum : SInternal := to_signed(0, WInternal);
	begin
		if reset = '1' then
			index <= 0;
			output <= std_logic_vector(to_signed(0, WInternal));
			for I in 0 to delays-1 loop
				ACombCircBuff(I) <= to_signed(0, WInternal);
			end loop;
			
		elsif rising_edge(clk) then
			output <= std_logic_vector(signed(input) - ACombCircBuff(index));
			ACombCircBuff(index) <= signed(input);
			
			if index = (delays-1) then
				index <= 0;
			else
				index <= index + 1;
			end if;
		end if;
	end process comb;
end arch;