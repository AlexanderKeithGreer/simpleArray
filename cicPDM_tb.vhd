--testbench for cicPDM, obviously
--This will be babys first file in/out based testbench, instead of 
--		manual definition. Later though

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cicPDM_tb is
end cicPDM_tb;

architecture tb of cicPDM_tb is
	constant WInternal 		: integer := 16;
	constant WOut				: integer := 16;
	constant delays			: integer := 2;
	constant stages			: integer := 2;
	constant deciRateHalf	: integer := 1;
	signal clk		: std_logic;	--High rate clock
	signal clkL		: std_logic; 	--Low rate clock
	signal reset	: std_logic;
	signal input 	: std_logic;
	signal output	: std_logic_vector (WOut-1 downto 0);
	
begin
	UUTQ: entity work.cicPDM 
	generic map (WInternal=>WInternal, WOut=>WOut, delays=>delays, stages=>stages, deciRateHalf=>deciRateHalf) 
	port map (clk=>clk, clkL=>clkL, reset=>reset, input=>input, output=>output);
	
	process
		variable half_period : time := 5ns;
	begin
		
		reset <= '1';
		input <= '1';
		
		clk <= '0';
		wait for half_period;
		clk <= '1';
		reset <= '0';
		wait for half_period;
		
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;
		
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;
		
		input <= '0';
		clk <= '0';
		wait for half_period;
		clk <= '1';
		wait for half_period;
	end process;
end tb;