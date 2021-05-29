--Implements a CIC for pulse density modulation
--Uses the integrator model defined externally.
--I have done things this way largely to familiarise myself with VHDL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity cicPDM is
	generic (WInternal 		: integer := 16;
			   WOut				: integer := 16;
				delays			: integer := 2; --Define as binary
				stages			: integer := 2;
				deciRateHalf	: integer := 20 --half cycle of decimation rate; 
			   );
	port (clk		: in std_logic;	--High rate clock
			clkL		: inout std_logic := '1'; 	--Low rate clock
			reset		: in std_logic;
			input 	: in std_logic;
			output	: out std_logic_vector (WOut-1 downto 0)
			);
end cicPDM;

--This is going to be fucking annoying
architecture arch of cicPDM is

	component intPDM
	generic(	WInt : integer := 16
			  );
	port (	clk 	: in std_logic;
				input	: in std_logic;
				reset	: in std_logic;
				output: out std_logic_vector(WInt-1 downto 0)
		  );
	end component;

	--Integrator - Req stages+1 memory slots
	subtype SInternal is signed (WInternal-1 downto 0);
	type AIntegratorT is array (0 to stages) of SInternal;
	signal AIntegrator : AIntegratorT;
	
	--Comb - composed of stages circular buffers of size delay
	type ACombT is array (0 to stages*delays) of SInternal;
	signal AComb : ACombT;
	signal CombIndex : integer range 2**delays-1 downto 0 := 0;
	
	signal clkCount : unsigned (15 downto 0) := to_unsigned(0, 16);
	
begin
	
	--component instatiation for PDM integrators
	INTPDM_COMP: intPDM generic map (WInt=>WInternal)
								port map (clk=>clk, input=>input, reset=>reset, signed(output)=>AIntegrator(0));
	--Dataflow modeling for connections
	output <= std_logic_vector(AIntegrator(stages-1)(WInternal-1 downto WInternal-WOut));
	
	--Clock Divisor Process
	--This process is likely best implemented via a PLL; leaving for now
	div: process(clk, reset)
	begin
		if reset = '1' then
			clkCount <= to_unsigned(0, 16);
			clkL <= '1';
		elsif rising_edge(clk) then
			if clkCount = to_unsigned(deciRateHalf, 16) then
				--Reset to 1 because this counts as a step!
				clkCount <= to_unsigned(1, 16);
				clkL <= not clkL;
			else
				clkCount <= clkCount + 1;
			end if;
		end if;
	end process div;
	
	
	--Integration process
	int: process(clk)
	begin
		if reset = '1' then
			--I'll do this later!
		elsif rising_edge(clk) and stages > 1 then
			for I in 1 to stages-2 loop	--For each stage except the first
				AIntegrator(I+1) <= AIntegrator(I+1) + AIntegrator(I); --Add own contents to next
			end loop;
		end if;
	end process int;
	
	
	--Comb Process	
	comb: process(clkL)
		variable total 	: SInternal := to_signed(0, WInternal)
		variable combDup 	: SInternal; 
	begin
		for I in 0 to stages-1 loop
			CombDup := Acomb(I);
			total <= total + Acomb(I);
		end loop;
		
		combIndex <= combIndex + 1
	end process comb;
	
end arch;