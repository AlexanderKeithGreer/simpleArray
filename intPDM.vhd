--This is meant to be a basic building block for a CIC.
--The difference is that I want to be able to 
--		1) Get more experience with this
--		2) Learn a lot more about it

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity intPDM is
	generic(
			  WInt : integer := 16
			  );
	port (	clk 	: in std_logic;
				input	: in std_logic;
				reset	: in std_logic;
				output: out std_logic_vector(WInt-1 downto 0)
		  );
end intPDM;


architecture arch of intPDM is
	constant one : unsigned(WInt-1 downto 0) := to_unsigned(1,WInt);
	subtype SInt is unsigned (WInt-1 downto 0); 
	signal integrator : SInt := to_unsigned(1,WInt);
begin
	
	run: process(clk, input, reset)
	begin
		if reset = '1' then
			integrator <= to_unsigned(0, WInt);
		elsif rising_edge(clk) then
			if input = '1' then
				--Input is a high, add
				integrator <= integrator + one;
			else
				integrator <= integrator - one;
			end if;
		end if;
	end process run;
	output <= std_logic_vector(integrator);
	
end arch;