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
		port (clk		: in std_logic;	--Low Rate Clock
				reset		: in std_logic;	--Asynchronous reset, should be triggered on startup
				input 	: in std_logic_vector (WInternal-1 downto 0);
				output	: out std_logic_vector (WInternal-1 downto 0)
				);
	end component;
	
	--Constants
	constant WInternal: integer := 8;
	constant delayD1	: integer := 1;
	constant delayD2	: integer := 2;
	--Inputs
	signal clk			: std_logic;	--Low Rate Clock
	signal reset		: std_logic;	--Asynchronous reset, should be triggered on startup
	signal input 		: std_logic_vector (WInternal-1 downto 0);
	
	--Outputs
	signal output	: std_logic_vector (WInternal-1 downto 0);

begin
	UUT_D1: combPDM 
	generic map (WInternal=>WInternal, delays=>delayD1)
	port map (clk=>clk, reset=>reset, input=>input, output=>output);
	
	UUT_D2: combPDM 
	generic map (WInternal=>WInternal, delays=>delayD2) 
	port map (clk=>clk, reset=>reset, input=>input, output=>output);
	
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
		
		--Step 2; Test with +1, +1, +1 part 1
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 3; Test with +1, +1, +1, part 2
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 4; Test with +1, +1, +1, part 3
		input <= std_logic_vector(to_signed(1, WInternal));
		
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
		
		--Step 6; Wait for the internal buffer to be cleared
		input <= std_logic_vector(to_signed(0, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
			--Step 7; Wait for the internal buffer to be cleared
		input <= std_logic_vector(to_signed(0, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 8; Test with wave f=fs/2, part 1
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 9; Test with wave f=fs/2, part 2
		input <= std_logic_vector(to_signed(-1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 10; Test with wave f=fs/2, part 3
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 11; Test with wave f=fs/2, part 4
		input <= std_logic_vector(to_signed(-1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 12; Test with wave f=fs/2, part 5
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
		--Step 13; Test with wave f=fs/2, part 6 - induce cancellation
		input <= std_logic_vector(to_signed(1, WInternal));
		
		clk <= '1';
		wait for half_period;
		clk <= '0';
		wait for half_period;
		
	end process;
end tb;