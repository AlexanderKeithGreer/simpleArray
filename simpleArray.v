

module simpleArray (
	input 	wire i_button,
	input 	wire i_clk,
	output 	wire[7:0] o_led
	);
	
	wire w_out;
	wire[7:0] w_open;
	
	loadPCMCIC #(8,1) (i_button, i_clk, 1'b1, w_out, o_led, w_open);
	
endmodule 