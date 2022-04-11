// ////////////////////////////////////////////////////////
// audioUART
// This is a serial module, and an incredibly crude one
// Operates at the baseline clock frequency, TX only
// ////////////////////////////////////////////////////////

module audioUART
	(	input wire i_clk,
		input wire i_rst,
		input wire [7:0] i_data,
		input wire i_valid,
		output wire o_ready,
		output wire o_serial
	);

	//10 possible states - Start, Stop/Idle, data[7:0]
	//Increment, remembering that UART is little endian bitwise
	//Integer FSM, I don't need to run this very fast
	localparam  l_START = 9;
	localparam  l_STOP = 8;
	integer r_state = l_START;
	
	reg r_ready;
	reg r_serial;
	reg [7:0] r_data; //Buffer data during process.
	assign o_ready = r_ready;
	assign o_serial = r_serial;


	always @ (posedge i_clk, posedge i_rst)
	begin
		if (i_rst == 1'b1)
		begin
			r_state <= l_STOP;
			r_data <= 8'b00001111;
			r_serial <= 1'b0;
			r_ready <= 1'b0;
		end
		else if (i_clk == 1'b1)
		begin
			case (r_state) //Deals with transitions
				//The Stop bit/idle state
				l_START: if (i_valid == 1'b1  && r_ready == 1'b1)
					begin
						r_ready <= 1'b0;
						r_data <= i_data;
						r_serial <= 1'b0;
						r_state <= 0;
					end

				l_STOP: begin
						r_state <= l_START;
						r_ready <= 1'b1;
						r_serial <= 1'b1;
					end

				default: begin
						r_state <= r_state + 1;
						r_ready <= (r_state == 7) ? 1'b1 : 1'b0;
						r_serial <= r_data[r_state];
					end

			endcase
		end
	end

endmodule
