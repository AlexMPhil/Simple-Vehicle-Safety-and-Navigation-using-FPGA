`timescale 1ns/1ps

module uart_rx
(
	input wire clk,
	input wire rst,
	input wire rx,
	output reg [7:0] d_out,
	output reg valid
);

	localparam clk_freq = 50000000;
	localparam baud_rate = 9600;
	localparam CPB = clk_freq/baud_rate;
	localparam HCPB = CPB/2;

parameter IDLE = 3'd0,
          START = 3'd1,
          DATA = 3'd2,
          STOP = 3'd3,
          DONE = 3'd4;
  
  reg [2:0] state = IDLE;
  reg [15:0] count = 0;
  reg [2:0] bit = 0;
  reg [7:0] r_shift = 0;
  
  always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE;
			d_out <= 8'b0;
			valid <= 1'b1;
			count <= 0;
			bit <= 0;
			r_shift <= 0;
		end
		else begin
			case(state)
				IDLE: begin
					valid = 1'b0;
					count <= 0;
					bit <= 0;
					if (rx == 0) state <= START;
				end
				
				START: begin
					if (count == HCPB) begin
							count <= 0;
							state <= DATA;
					end
					else count <= count + 1;
				end
				
				DATA: begin
					if (count == CPB-1) begin
						count <= 0;
						r_shift[bit] <= rx;
						if (bit==7) state <= STOP;
						else bit <= bit + 1;
					end
					else count <= count + 1;
				end
				
				STOP: begin
					if (count == CPB-1) begin
						count <= 0;
						state <= DONE;
					end
					else count <= count + 1;
				end
				
				DONE: begin 
					d_out <= r_shift;
					valid <= 1'b1;
					state <= IDLE;
				end
			
			endcase
		end
	end
endmodule
						
			