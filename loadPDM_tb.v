// loadPDM_tb.v
// This is a testbench to ensure that the loadPDM_tb module is correctly downsampling
//	 	the signals in question
// It is intended to have an associated python script (which should write to a CSV)
//		in order to generate the data and plot the outputs.


`timescale 100ns/1ns


module loadPDM_tb;

	reg r_clk;
	localparam c_halfClk = 0.5;
	localparam c_resetLen = 1;
	localparam c_width = 12;
	reg r_inputR;
	reg r_inputF;
	reg r_input;
	reg r_strobe;
	
	////////////////////////////////////////////////////
	//  This section deals with the loading of data and
	//		and also oscillates the clock
	////////////////////////////////////////////////////
	integer file;
	integer r_no;
	integer r = 1;
	localparam c_n = 4;
	reg [c_n*8-1:0] r_string;
	
	initial 
	begin
		file = $fopen("C:/Users/Alexander Greer/Documents/simpleArray/input_loadPDM.txt", "r");
		while (r > 0) // sfgets returns 0 at EoF
		begin
			r = $fscanf(file,"%b %b %b\n", r_inputR, r_inputF, r_strobe);
			
			if (r > 0)
			begin
				r_input <= r_inputR;
				r_clk = 1'b0;
				#c_halfClk;
				r_clk = 1'b1;
				#c_halfClk;
				r_input <= r_inputF;
				r_clk = 1'b0;
				#c_halfClk;
				r_clk = 1'b1;
				#c_halfClk;
			end
			
		end
		
		$fclose(file);
	end
	
	
	//////////////////////////////////////////////////////
	//  This section deals with the actual interfacing HDL
	//		and also the reset
	//////////////////////////////////////////////////////
	
	reg r_reset;
	wire w_clk;
	wire [c_width-1:0] w_dataR;
	wire [c_width-1:0] w_dataF;
	wire [c_width-1:0] w_debugR;
	wire [c_width-1:0] w_debugF;
		
	//Startup reset
	initial
	begin
		r_reset = 1'b1;
		#c_resetLen;
		r_reset = 1'b0;
	end
	
	loadPDM #(c_width, 1, 1) uut (r_input, r_clk, r_reset, 
				r_strobe, w_clk, w_dataR, w_dataF, w_debugR, w_debugF);	
	
endmodule 