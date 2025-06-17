`timescale 1ns / 1ps

module car_sys(
	input CLK,
	input US_F,
	input US_R,
	input FA,
	input [3:0] pass,
	output [7:0] prox,
	output buzz
);

	parameter IDLE = 3'd0,
				 WAIT = 3'd1,
				 DENIED = 3'd2,
				 GRANTED = 3'd3,
				 STOP = 3'd4,
				 EMERGENCY = 3'd5;

	reg [2:0] state = IDLE, nextState;
	
	
	always @(posedge CLK or negedge RST) begin	
		
		case(state)
		
		IDLE: begin
			
			if(FA)
			
			
		end
		
	end
	
endmodule