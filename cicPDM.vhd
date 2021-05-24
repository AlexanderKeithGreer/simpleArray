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

	subtype SInternal is signed (WInternal-1 downto 0);
	--internal integrator section - make 1 longer than needed for 
	--											easy input/output management
	
	type AIntegratorT is array (0 to stages-1) of SInternal;
	-- -1, see above, one stage is already done
	
	--internal delayline section - bleh
	--internal comb section - make 1 longer than needed for easy 
	--									input/output management
	signal clkCount : unsigned (15 downto 0) := to_unsigned(0, 16);
	signal AIntegrator : AIntegratorT;
begin
	
	--component instatiation for PDM integrators
	INTPDM_COMP: intPDM generic map (WInt=>WInternal)
								port map (clk=>clk, input=>input, reset=>reset, signed(output)=>AIntegrator(0));
	--Dataflow modeling for connections
	output <= std_logic_vector(AIntegrator(stages-1)(WInternal-1 downto WInternal-WOut));
	
	--Clock Divisor Process
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
		elsif rising_edge(clk) then
			--I'll do this later
		end if;
	end process int;
	--Comb Process	
	
	
end arch;