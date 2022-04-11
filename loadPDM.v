////////////////////////
//  	loadPDM         //
////////////////////////
// 2 delay, parameterised stage CIC, with custom
// Output clock is half the internal clock frequency


module loadPDM #(
	parameter p_width = 8,
	parameter p_mode = 1,
	parameter p_stages = 2
	) (
   input wire i_data,
   input wire i_clk,          //Clock assoc with internal FF
   input wire i_reset,
	input wire i_strobe,
   output wire o_clk,         //Clock to microphone
   output wire [p_width-1:0] o_dataR, //Data clocked on rising edge
   output wire [p_width-1:0] o_dataF, //Data clocked on falling edge
	output wire [p_width-1:0] o_debugR,  //This one's harder...?
	output wire [p_width-1:0] o_debugF  //This one's harder...?
   );


	/*

		Eg: 2 stage, 2 delay...

		----(+)----+---(+)----+---[/.]----+---->{-}---+-----{-}-->
			  |	  |    |	    |           |      |\   |      |\
			  |	  |    | 	 |           |      |    |      |
			  +-[Z]-+  	 +-[Z]-+			    +-Z--Z-+    +-Z--Z-+


	*/

   reg r_polarity = 1'b0;

	//Define an array to hold all our data:
	reg [p_width-1:0] r_integR[p_stages-1:0];
	reg [p_width-1:0] r_combR [p_stages:0][2:0];

	reg [p_width-1:0] r_integF[p_stages-1:0];
	reg [p_width-1:0] r_combF [p_stages:0][2:0];

	reg [p_width-1:0] r_outBufferR;
	reg [p_width-1:0] r_outBufferF;

	integer R; //Loop variable -- stage
	integer D; //Loop variable -- delay

	//Literally just wiggle the output clock and parse it.
	always @ (posedge i_clk, posedge i_reset)
	begin
		if (i_reset == 1'b1)
			r_polarity <= 1'b0;
		else
			r_polarity <= !r_polarity;
	end

	assign o_clk = r_polarity;
	assign o_dataR = r_outBufferR;
	assign o_dataF = r_outBufferF;
	assign o_debugR = r_combR[0][0];
	assign o_debugF = r_combF[0][0];


	//Meaningful part of the CIC
	//Grumble at me to split this up!
	always @(posedge i_clk, posedge i_reset)
	begin
		if (i_reset == 1'b1)
		begin
			for (R=0; R < p_stages; R=R+1)
			begin
				r_integR[R] <= 0;
				r_integF[R] <= 0;
			end
		end
		else if (r_polarity)
		begin
			//Integrator for rise
			r_integR[0] <= i_data ? r_integR[0] + 'h1 : r_integR[0];
			for (R= 1; R < p_stages; R=R+1)
				r_integR[R] <= r_integR[R-1];
		end
		else
		begin
			//Integrator for fall
			r_integF[0] <= i_data ? r_integF[0] + 'h1 : r_integF[0];
			for (R= 1; R < p_stages; R=R+1)
				r_integF[R] <= r_integF[R-1];

		end
	end

	//Meaningful part of the CIC
	//Grumble at me to split this up!
	always @(posedge i_clk, posedge i_reset)
	begin
		if (i_reset == 1'b1)
		begin
			for (R=0; R <= p_stages; R=R+1)
			begin
					r_combR[R][0] <= 0;
					r_combF[R][0] <= 0;
					r_combR[R][1] <= 0;
					r_combF[R][1] <= 0;
					r_combR[R][2] <= 0;
					r_combF[R][2] <= 0;
			end
		end
		else
		begin

			//These two lines may want to be assigns
			//	but it's fine so long as strobe is not held down
			r_combR[0][0] <= r_integR[p_stages-1];
			r_combF[0][0] <= r_integF[p_stages-1];

			if (i_strobe == 1'b1)
			begin
				r_combR[0][2] <= r_combR[0][1];
				r_combF[0][2] <= r_combF[0][1];
				r_combR[0][1] <= r_combR[0][0];
				r_combF[0][1] <= r_combF[0][0];

				for (R = 1; R <= p_stages; R = R+1)
				begin
					r_combR[R][2] <= r_combR[R][1]; //In theory I could generalise the delays,
					r_combF[R][2] <= r_combF[R][1]; //	in practice, I want to minimise complexity
					r_combR[R][1] <= r_combR[R][0]; //Let the compiler optimise away the redundant final
					r_combF[R][1] <= r_combF[R][0]; //	delay section
					r_combR[R][0] <= r_combR[R-1][0] - r_combR[R-1][2];
					r_combF[R][0] <= r_combF[R-1][0] - r_combF[R-1][2];

				end
			end
			//Comb section end
		end
	end


	always @ (posedge i_clk )
	begin
		if (i_reset == 1'b1)
		begin
			r_outBufferR <= 0;
			r_outBufferF <= 0;
		end
		else if (i_clk == 1'b1)
		begin
			if (i_strobe == 1'b1)
			begin
				r_outBufferR <= r_combR[p_stages][0];
				if (p_mode == 1)
					r_outBufferF <= r_combF[p_stages][0];
			end
		end

	end


endmodule
