`timescale 1ns/1ps

module nmea_parse(
	input wire clk,
	input wire rst,
	input wire [7:0] char,
	input wire valid,
	output reg NSR,
	output reg [4:0] hr,
	output reg [5:0] min,
	output reg [5:0] sec
);
	
	localparam IDLE = 3'd0;
	localparam HEADER = 3'd1;
	localparam CAPTURE = 3'd2;
	localparam PARSER = 3'd3;
	localparam DONE = 3'd4;
	
	localparam [7:0] RMC_HEADER[0:5] = {8'h47, 8'h50, 8'h52, 8'h4D, 8'h43};
	
	reg [2:0] state, next_state;
	
	// Buffers
	
	reg [7:0] nmea_buffer [0:127];
	reg [7:0] time_field [0:9];
	/*reg [7:0] copy_buffer [0:127];
	//reg [7:0] field_buffer1 [0:15];
	//reg [7:0] utime [0:7];
	reg [7:0] speed [0:5];
	reg [7:0] date [0:5];
	*/
	reg [6:0] buff_index;
	reg [3:0] comma_check;
	reg [3:0] t_index;
	reg header_check;
	integer i=0;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end
	
	always @(*) begin
		//next_state <= state;
		case(state)
			IDLE: if (valid && char== 8'h24) next_state = HEADER;
			HEADER: if (header_check) next_state = CAPTURE;
			CAPTURE: if (comma_check == 1) next_state = PARSER;
			PARSER: if (t_index == 6) next_state <= DONE;
			DONE: next_state <= IDLE;
			default: next_state <= IDLE;
		endcase
	end
	
	always @(posedge clk or posedge rst) begin
	$display("TIME=%0t STATE=%0d CHAR=%c VALID=%b", $time, state, char, valid);
		if (rst) begin
			buff_index <= 0;
			comma_check <= 0;
			header_check <= 0;
			t_index <= 0;
			hr <=0;
			min <= 0;
			sec <= 0;
			NSR <=0;
		end else begin
			case(state)
				IDLE: begin
					buff_index <= 0;
					comma_check <= 0;
					header_check <= 0;
					t_index <= 0;
					NSR <= 0;
				end
				
				HEADER: begin
					if (valid && buff_index < 6) begin
						if (char == RMC_HEADER[buff_index]) begin
							buff_index <= buff_index + 1;
							if (buff_index == 5) header_check <= 1;
						end else begin
							buff_index <= 0;
						end
					end
				end
				
				CAPTURE: begin
					if (valid) begin
						$display("char=%c comma=%0d t_index=%0d", char, comma_check, t_index);
						if (char == ",") begin
							comma_check <= comma_check + 1;
						end else if (comma_check == 1 && t_index < 6) begin
							time_field[t_index] <= char;
							t_index <= t_index + 1;
							
							$display("char=%c comma=%d t_index=%d time_field[%0d]=%c", char, comma_check, t_index, t_index, char);

						end
					end
				end
				
				PARSER: begin
					hr <= (time_field[0] - "0") * 10 + (time_field[1] - "0");
					min <= (time_field[2] - "0") * 10 + (time_field[3] - "0");
					sec <= (time_field[4] - "0") * 10 + (time_field[5] - "0");
				end
				
				DONE: begin
					NSR <= 1;
				
				end
			endcase
		end
	end
	
endmodule