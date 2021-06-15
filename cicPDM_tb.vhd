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
	constant stages			: integer := 1;
	constant deciRateHalf	: integer := 1;
	
	signal clk		: std_logic;	--High rate clock
	signal clkL		: std_logic; 	--Low rate clock
	signal reset	: std_logic;
	signal input 	: std_logic;
	signal outputI	: integer;
	signal output	: std_logic_vector (WOut-1 downto 0);
	
	component CombPDM
		
	end component;
	
	
	subtype SInternal is unsigned (WInternal-1 downto 0);
	type AInternalT is array (0 to stages) of SInternal;
	signal AInternal : AInternalT;
	
	type testVector is record
		input : std_logic;
		reset : std_logic;
	end record;
	
	type testVectorArray is array (natural range <>) of testVector;
   constant testVectors : testVectorArray := (
		('0','1'),('1','0'),('0','0'),('1','0'),('0','0'),('1','0'),('1','0'),('0','0'),('1','0'),('1','0'),
		('1','0'),('1','0'),('0','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),
		('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),
		('1','0'),('1','0'),('1','0'),('1','0'),('0','0'),('1','0'),('1','0'),('1','0'),('1','0'),('1','0'),
		('1','0'),('0','0'),('1','0'),('1','0'),('0','0'),('1','0'),('1','0'),('0','0'),('1','0'),('0','0'),
		('1','0'),('0','0'),('1','0'),('0','0'),('0','0'),('1','0'),('0','0'),('0','0'),('1','0'),('0','0'),
		('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('1','0'),('0','0'),('0','0'),('0','0'),('0','0'),
		('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),
		('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('0','0'),('1','0'),('0','0'),('0','0'),
		('0','0'),('0','0'),('1','0'),('0','0'),('0','0'),('1','0'),('0','0'),('1','0'),('0','0'),('1','0')
	);
	
begin
	UUTQ: entity work.cicPDM 
	generic map (WInternal=>WInternal, WOut=>WOut, delays=>delays, stages=>stages, deciRateHalf=>deciRateHalf) 
	port map (clk=>clk, clkL=>clkL, reset=>reset, input=>input, output=>output);
	
	outputI <= to_integer(signed(output));

	process
		variable half_period : time := 5ns;
	begin
		for I in testVectors'range loop
			reset <= testVectors(I).reset;
			input <= testVectors(I).input;
			
			clk <= '0';
			wait for half_period;
			clk <= '1';
			reset <= '0';
			wait for half_period;
		end loop;
		
		wait;
		
	end process;
end tb;