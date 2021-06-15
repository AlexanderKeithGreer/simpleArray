--Implements a CIC for pulse density modulation
--Uses the integrator model defined externally.
--I have done things this way largely to familiarise myself with VHDL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity cicPDM is
	generic (WInternal 		: integer := 24;
			   WOut				: integer := 24;
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

	component intPDM --Interface for the initial integrator block
		generic(	WInt : integer := 16
				  );
		port (	clk 	: in std_logic;
					input	: in std_logic;
					reset	: in std_logic;
					output: out std_logic_vector(WInt-1 downto 0)
			  );
	end component;

	component combPDM --Interface for the comb blocks
		generic (WInternal 	: integer := 16;
					delays		: integer := 2
					);
		port (clk		: in std_logic;	--Low Rate Clock
				reset		: in std_logic;	--Asynchronous reset, should be triggered on startup
				input 	: in std_logic_vector (WInternal-1 downto 0);
				output	: out std_logic_vector (WInternal-1 downto 0)
				);
	end component;
	
	--Integrator - Req stages memory slots
	subtype SInternal is signed (WInternal-1 downto 0);
	subtype VInternal is std_logic_vector(WInternal-1 downto 0);
	type AIntegratorT is array (0 to stages-1) of SInternal;
	signal AIntegrator : AIntegratorT;
	
	--Comb - composed of stages circular buffers of size delay
	type ACombT is array (0 to stages) of VInternal;
	signal AComb : ACombT;
	
	--Clock divisor Counter
	signal clkCount : unsigned (15 downto 0) := to_unsigned(0, 16);
	
	signal toIntegrators : VInternal;
	
begin
	
	--component instatiation for PDM integrators
	INTPDM_COMP: intPDM generic map (WInt=>WInternal)
								port map (clk=>clk, input=>input, reset=>reset, output=>toIntegrators);
	--Connect the final integrator outpt to the first comb input
	AComb(0) <= std_logic_vector(AIntegrator(stages-1));
	--Connect each comb block
	COMB_SECTION:
	for C in 0 to stages-1 generate
		COMBX: combPDM generic map (delays=>delays, WInternal=>WInternal)
							port map (clk=>clkL, reset=>reset,
							input=>AComb(C), output=>AComb(C+1));
	end generate COMB_SECTION;
	
	output <= AComb(stages)(WInternal-1 downto WInternal - WOut);
	
	--Clock Divisor Process
	--This process is likely best implemented via a PLL; leaving for now
	div: process(clk, reset)
	begin
		if reset = '1' then
			clkCount <= to_unsigned(0, 16);
			clkL <= '0';
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
	int: process(clk, reset)
	begin
		if reset = '1' then
			for I in 0 to stages-1 loop	--For each stage except the first
				AIntegrator(I) <= to_signed(0, WInternal); --Zero integrators
			end loop;
		elsif rising_edge(clk) then 
			AIntegrator(0) <= signed(toIntegrators);
			if stages > 1 then
				for I in 0 to stages-2 loop	--For each stage except the first
					AIntegrator(I+1) <= AIntegrator(I+1) + AIntegrator(I);
				end loop;
			end if;
		end if;
	end process int;
	
	
	--Comb Process	
	--comb: process(clkL, reset)
	--	variable total : SInternal := to_signed(0, WInternal); 
	--begin
	--	if reset = '1' then
	--		output <= std_logic_vector(to_signed(0, WOut));
	--	elsif rising_edge(clkL) then
	--		for C in 1 to stages loop
	--			total := total + signed(AComb(C));
	--		end loop;
	--		output <= std_logic_vector(total(WInternal-1 downto WInternal-WOut));
	--	end if;
	--end process comb;
	
end arch;