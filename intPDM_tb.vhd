--Probably requires a little bit more complicated (ie automated nonvisual verification) test bench, but good enough for now.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity intPDM_tb is
end intPDM_tb;

architecture tb of intPDM_tb is

	component intPDM
	generic(
			  WInt : integer := 16
			  );
	port (	clk 	: in std_logic;
				input	: in std_logic;
				reset	: in std_logic;
				output: out std_logic_vector(WInt-1 downto 0)
		  );
	end component;

	constant WInt : integer := 4;
	signal clk : std_logic;
	signal input : std_logic;
	signal reset : std_logic;
	signal output : std_logic_vector(WInt-1 downto 0);
begin
	UUT: intPDM generic map (WInt=>WInt) port map (clk=>clk, input=>input, reset => reset, output=>output);
		
	TB1: process
		variable half_period : time := 5ns;
	begin
		--Cycle One
		input <= '1';
		reset <= '0';
		
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;		
		
		--Cycle Two
		input <= '1';
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;
		
		--Cycle Three
		input <= '0';
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;

		--Cycle Four
		input <= '0';
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;
		
		--Cycle Five
		input <= '0';
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;
		
		--Cycle Six
		input <= '0';
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;
		wait;
		
		
	end process TB1;
end tb;