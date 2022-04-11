// ////////////////////////////////////////////////////////////////
// Testbench for audioUART module
// Needs to check:
//	That data will be written correctly
//	That continuous streaming (`assign o_ready = i_valid`) is fine
//	That the module can be stalled for a time.
// ////////////////////////////////////////////////////////////////

`timescale 100ns/1ns

module audioUART_tb;

	//Module constants and IO
	reg r_clk;
	localparam l_rstLen = 1;
	localparam l_halfClk	= 100; //ns
	reg r_rst;
	reg [7:0] r_input;
	reg r_valid;
	wire w_serial;
	wire w_ready;

	//File loading declarations!
	integer file;
	integer r = 1;
	reg [7:0] r_cycles;

	//Loading data from file (also clocking)
	initial
	begin
		file = $fopen("C:/Users/Alexander Greer/Documents/simpleArray/input_audioUART.txt", "r");
		while (r > 0) // sfgets returns 0 at EoF
		begin
			//Load the data, number of cycles to run, and r_valid signal
			r = $fscanf(file,"%x %d %b\n", r_input, r_cycles ,r_valid);

			if (r > 0)
			begin
				while (r_cycles > 0)
				begin
					r_cycles = r_cycles - 1;
					r_clk = 1'b0;
					#l_halfClk;
					r_clk = 1'b1;
					#l_halfClk;
				end
			end
		end
		$fclose(file);
	end

	//Startup reset
	initial
	begin
		r_rst = 1'b1;
		#l_rstLen;
		r_rst = 1'b0;
	end

	//component instantiation
	audioUART UUT (.i_clk(r_clk), .i_rst(r_rst), .i_data(r_input), .i_valid(r_valid),
								.o_ready(w_ready), .o_serial(w_serial));


endmodule
