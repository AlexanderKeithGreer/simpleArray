--Implements a CIC for pulse density modulation
--Uses the integrator model defined externally.
--I have done things this way largely to familiarise myself with VHDL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cicPDM is
	generic (WInternal 		: integer := 16;
			   WOut				: integer := 16;
				delays			: integer := 2;
				stages			: integer := 2;
				deciRateHalf	: integer := 20 --half cycle of decimation rate; 
			   );
	port (clk		: in std_logic;	--High rate clock
			clkL		: inout std_logic; 	--Low rate clock
			reset		: in std_logic;
			input 	: in std_logic;
			output	: out std_logic_vector (WOut-1 downto 0)
			);
end cicPDM;

--This is going to be fucking annoying
architecture arch of cicPDM is
	subtype SInternal is signed (WInternal-1 downto 0);
	--internal integrator section - make 2 longer than needed for 
	--											easy input/output management
	
	--internal delayline section - bleh
	--internal comb section - make 2 longer than needed for easy 
	--									input/output management
	signal clkCount : unsigned (15 downto 0) := to_unsigned(0, 16);
begin
	
	--component instatiation for PDM integrator
	
	--Dataflow modeling for connections
	
	--Clock Divisor Process
	div: process(clk)
	begin
		if rising_edge(clk) then
			clkCount <= clkCount + 1;
			if clkCount = to_unsigned(deciRateHalf, 16) then
				clkL <= not clkL;
			end if;
		end if;
	end process div;
	
	--Integration process
	int: process(clk)
	begin
		if rising_edge(clk) then
		end if;
	end process int;
	--Comb Process	
	
	
end arch;