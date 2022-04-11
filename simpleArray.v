// ////////////////////
// Simple Array
//	  This part needs to deal with:
//		-PLL for main clock
//		-FSM for sampling and UART
//		-UART itself
//		-CIC itself
//		-Eventually some kind of TDM for different CICs
// ////////////////////

// PIN LOCATIONS
//	12 MHZ Clock: 	:	M2
// LED1:				:	M6
// LED2:				:	T4
// LED3:				:  T3
// LED4:				:  R3
// LED5:				:  T2
// LED6:				:  R4
// LED7:				:  N5
// LED8:				:  N3
// Button				:  N6
// Serial Input:	:  R7
// Serial Output:	:  T7
//	Mic CLK 			:  B16
// Mic Data			:  F16
//	Mic VCC 			:	D16
// MIC GND			:  C16

//Microphone is:
//		Data	CLK
//		VCC	GND

module simpleArray (
	input   wire i_button,
	input   wire i_clk,
	input   wire i_microphone,
	input   wire i_serial,
	output  wire o_serial,
	output  wire o_micVCC,
	output  wire o_micGND,
	output  wire o_clk,
	output  wire [7:0] o_led
	);

	localparam l_rate = 9'd150; //Convert 6MHz/2 to 40kHz
	localparam l_width = 16;
	localparam l_mode = 1;
	localparam l_nStages = 2;
	reg [8:0] r_count = 9'd0; //9 bits, to deal with nature of countdown.
	reg r_valid;
	wire w_ready; //Can stall the UART but not the CIC?

	wire w_out;
	wire[7:0] w_open;
	wire w_clk;
	wire [15:0] w_dataR;
	reg r_rst = 1'b0;
	reg r_micVCC = 1'b1;
	reg r_micGND = 1'b0;


	assign o_led[7:0] = w_dataR[15:8];
	assign o_micVCC = r_micVCC;
	assign o_micGND = r_micGND;


	always @ (posedge i_clk)
	begin
		if (r_count == l_rate)
		begin
			r_count <= 9'd0;
			r_valid <= 1'b1;
		end else begin
			r_count <= r_count + 9'd1;
			r_valid <= 1'b0;
		end
	end

	//Component instantiations
	loadPDM #(.p_width(l_width), .p_mode(l_mode), .p_stages(l_nStages))
		sole ( .i_data(i_microphone), .i_clk(w_clk), .i_reset(r_rst),
		 			 .i_strobe(r_valid),
				   .o_clk(o_clk), .o_dataR(w_dataR));

	audioUART out (.i_clk(w_clk), .i_rst(r_rst), .i_data(w_dataR[15:8]),
						.i_valid(r_valid),
						.o_ready(w_ready), .o_serial(o_serial));

	downPLL solePLL(.areset(r_rst), .inclk0(i_clk), .c0(w_clk));

endmodule
