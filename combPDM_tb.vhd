--Last attempt to see if I can remember how this sort of testbench is written:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity combPDM_tb is
end combPDM_tb;

architecture tb of combPDM_tb is
	component combPDM is
		generic (WInternal	: integer := 16; --This is a component
					delays		: integer := 2 --Define as binary
					);
		port (clk			: in std_logic;	--Low Rate Clock
				reset			: in std_logic;	--Asynchronous reset, should be triggered on startup
				input 		: in std_logic_vector (WInternal-1 downto 0);
				outputNext	: out std_logic_vector (WInternal-1 downto 0);
				outputSum	: out std_logic_vector (WInternal-1 downto 0)
				);
	end component;

	constant WInternal 		: integer := 8;
	constant delays			: integer := 1;
	signal clk			: std_logic;	--Low Rate Clock
	signal reset		: std_logic;	--Asynchronous reset, should be triggered on startup
	signal input 		: std_logic_vector (WInternal-1 downto 0);
	signal outputNext	: std_logic_vector (WInternal-1 downto 0);
	signal outputSum	: std_logic_vector (WInternal-1 downto 0);
	
	
begin
	UUT: combPDM 
	generic map (WInternal=>WInternal, delays=>delays) 
	port map (clk=>clk, reset=>reset, input=>input, outputNext=>outputNext, outputSum=>outputSum);
	
	UUT: combPDM 
	generic map (WInternal=>WInternal, delays=>delays) 
	port map (clk=>clk, reset=>reset, input=>input, outputNext=>outputNext, outputSum=>outputSum);
	
	process 
		variable half_period : time := 5ns;
	begin
		--Step 1; Trigger reset, begin
		reset <= '1';
		input <= std_logic_vector(to_signed(0, WInternal));
		
		clk <= '1';
		wait for half_period;
		reset <= '0';
		clk <= '0';
		wait for half_period;
		
		--Step 2; Test with +1, +1, part 1
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 3; Test with +1, +1, part 2
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 4; Wait for the internal buffer to be cleared
		input <= std_logic_vector(to_signed(0, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 5; Wait for the internal buffer to be cleared
		input <= std_logic_vector(to_signed(0, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 6; Test with opposite signed inputs, part 1
		input <= std_logic_vector(to_signed(-1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 7; Test with opposite signed inputs, part 2
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 8; Blank part, end of test
		input <= std_logic_vector(to_signed(0, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
	end process;
end tb;