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
	constant stages	: integer := 2;
	--Inputs
	signal clk			: std_logic;	--Low Rate Clock
	signal reset		: std_logic;	--Asynchronous reset, should be triggered on startup
	signal input 		: std_logic_vector (WInternal-1 downto 0);
	
	--Outputs
	signal output	: std_logic_vector (WInternal-1 downto 0);
	
	subtype VInternal is std_logic_vector (WInternal-1 downto 0);
	type AInternalT is array (0 to stages) of VInternal;
	signal AInternal : AInternalT;
	
	type test_vector is record
		input : std_logic_vector (WInternal-1 downto 0);
		reset : std_logic;
   end record;
	
	type testVectorArray is array (natural range <>) of test_vector;
   constant testVectors : testVectorArray := (
		-- a, b, sum , carry   -- positional method is used below
		(std_logic_vector(to_signed( 0, WInternal)), '1'),
		(std_logic_vector(to_signed( 1, WInternal)), '0'),
		(std_logic_vector(to_signed( 1, WInternal)), '0'),
		(std_logic_vector(to_signed( 1, WInternal)), '0'),
		(std_logic_vector(to_signed( 0, WInternal)), '0'),
		(std_logic_vector(to_signed( 0, WInternal)), '0'),
		(std_logic_vector(to_signed( 0, WInternal)), '0'),
		(std_logic_vector(to_signed( 1, WInternal)), '0'),
		(std_logic_vector(to_signed(-1, WInternal)), '0'),
		(std_logic_vector(to_signed( 1, WInternal)), '0'),
		(std_logic_vector(to_signed(-1, WInternal)), '0'),
		(std_logic_vector(to_signed( 1, WInternal)), '0'),
		(std_logic_vector(to_signed( 1, WInternal)), '0')
		);

begin
   ---This is the basic implementation
	--UUT_D1: combPDM 
	--generic map (WInternal=>WInternal, delays=>delayD2)
	--port map (clk=>clk, reset=>reset, input=>input, output=>output);
	
	GEN_COMB:
	for I in 0 to (stages-1) generate
		UUT: combPDM 
		generic map (WInternal=>WInternal, Delays=>DelayD1)
		port map (clk=>clk, reset=>reset, input=>AInternal(I), output=>AInternal(I+1));
	end generate GEN_COMB;
	
	AInternal(0) <= input;
	output <= AInternal(stages);
	
	process 
		variable half_period : time := 5ns;
	begin
	
		for V in testVectors'range loop
			--Set the inputs on the rising edge
			reset <= testVectors(V).reset;
			input <= testVectors(V).input;
			
			clk <= '0';
			wait for half_period;
			clk <= '1';
			--reset <= '0';
			wait for half_period;
		end loop;
		wait;
		
	end process;
end tb;