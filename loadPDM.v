module loadPCMCIC #(
	parameter c_width = 8,
	parameter c_mode = 1,
	parameter c_stages = 2,
	parameter c_delays = 2
	) (
   input wire i_data,
   input wire i_clk,          //Clock assoc with internal FF
   input wire i_reset,
	input wire i_strobe,
   output wire o_clk,         //Clock to microphone
   output wire [c_width-1:0] o_dataR, //Data clocked on rising edge
   output wire [c_width-1:0] o_dataF  //Data clocked on falling edge
   );
	
	
      
	//CIC of with two stages, and comb duration 2
   reg r_polarity = 1'b0;
	
	//Define an array to hold all our data:
	reg [c_width-1:0] r_integR[c_stages-1:0];
	reg [c_width-1:0] r_combR [c_stages-1:0][c_delays-1:0];
	
	reg [c_width-1:0] r_integF[c_stages-1:0];
	reg [c_width-1:0] r_combF [c_stages-1:0][c_delays-1:0];
	
	//Literally just wiggle the output clock and parse it.
	always @ (posedge i_clk, posedge i_reset)
	begin
		if (i_reset == 1'b1)
			r_polarity <= 1'b0;
		else
			r_polarity <= !r_polarity;
	end
	
	//Meaningful part of the CIC
	//Grumble at me to split this up!
	always @(posedge i_clk, posedge i_reset)
	begin
		if (i_reset == 1'b1)
		begin
			integer R; //Loop variables
			integer D;
			for (R=0; R < c_stages; R=R+1)
			begin
				r_integR[R] <= 0;
				r_integF[R] <= 0;
			end
		end
		else if (r_polarity)
		begin
			
			//Integrator for rise
			r_integR[0] <= i_data ? r_integR[0] + 'h1 : r_integR[0];
			for (integer R= 1; R < c_stages; R=R+1)
				r_integR[R] <= r_integR[R-1];
			
		end
		else
		begin	
			//Integrator for fall
			r_integF[0] <= i_data ? r_integF[0] + 'h1 : r_integF[0];
			for (integer R= 1; R < c_stages; R=R+1)
				r_integF[R] <= r_integF[R-1];
			
		end
	end
	
		//Meaningful part of the CIC
	//Grumble at me to split this up!
	always @(posedge i_clk, posedge i_reset)
	begin
		if (i_reset == 1'b1)
		begin
			integer R; //Loop variables
			integer D;
			for (R=0; R < c_stages; R=R+1)
			begin
				
				for (D=0; D < c_delays; D=D+1)
				begin
					r_combR[R][D] <= 0;
					r_combF[R][D] <= 0;
				end
			end
		end
		else
		begin
				
			//Comb section for rise
			if (i_strobe == 1'b0)
			begin
				r_combR[0][0] <= r_integR[c_stages-1];
				r_combF[0][0] <= r_integF[c_stages-1];
				integer R;
				integer D;
				for (R = 1; I < c_stages; i = i+1)
				begin
					r_combR[I][0] <= r_combR[i-1][c_delays-1];
					r_combF[I][0] <= r_combF[i-1][c_delays-1];
					for (D = 1; D < c_delays-1; D=D+1)
					begin
						r_combR[R][D] <= r_combR[R][D-1]
						r_combF[R][D] <= r_combF[R][D-1]
					end
				end
			end
			
			//Comb section end
		end
	end

   
endmodule
