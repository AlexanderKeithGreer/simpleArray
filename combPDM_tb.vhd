--Last attempt to see if I can remember how this sort of testbench is written:

entity combPDM_tb is
end combPDM_tb;

architecture tb of combPDM_tb is
	component combPDM is
		generic (WInternal	: integer := 16;
					delays		: integer := 2; --Define as binary
					);
		port (clk			: in std_logic;	--Low Rate Clock
				reset			: in std_logic;	--Asynchronous reset, should be triggered on startup
				input 		: in std_logic_vector (WInternal-1 downto 0);
				outputNext	: out std_logic_vector (WInternal-1 downto 0);
				outputSum	: out std_logic_vector (WInternal-1 downto 0)
				);
	end component;

	constant WInternal 		: integer := 16;
	constant delays			: integer := 2; --Define as binary
	signal clk			: std_logic;	--Low Rate Clock
	signal reset		: std_logic;	--Asynchronous reset, should be triggered on startup
	signal input 		: std_logic_vector (WInternal-1 downto 0);
	signal outputNext	: std_logic_vector (WInternal-1 downto 0);
	signal outputSum	: std_logic_vector (WInternal-1 downto 0);

	
end combPDM;
begin
	UUT: cicPDM 
	generic map (WInternal=>WInternal, delays=>delays) 
	port map (clk=>clk, reset=>reset, input=>input, outputNext=>outputNext, outputSum=>outputSum);
	
	process 
		variable half_period : time := 5ns;
	begin
		
	end process;
end tb;