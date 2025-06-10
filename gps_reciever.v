`timescale 1ns/1ps

module gps_reciever
(
	input wire clk,
	input wire rst,
	input wire uart_rx_pin,
	input wire [3:0] switches,
	output wire [7:0] gps_out,  //8 leds initally
	
	
	output wire [4:0] gps_hr,
	output wire [5:0] gps_min,
	output wire [5:0] gps_sec,
	//output wire [9:0] gps_speed;
	output wire gps_NSR
);


	wire [7:0] uart_rx_d_out;
	wire uart_rx_valid;
	
	//INstantiate the two modules uart_rx and nmea_parse
	
	uart_rx ur1 (
		.clk (clk),
		.rst (rst),
		.rx (uart_rx_pin),
		.d_out (uart_rx_d_out),
		.valid (uart_rx_valid)
	);
	
	nmea_parse np1 (
		.clk (clk),
		.rst (rst),
		.char (uart_rx_d_out),
		.valid (uart_rx_valid),
		.NSR (gps_NSR),
		.hr (gps_hr),
		.min (gps_min),
		.sec (gps_sec)
	);
	
	reg [7:0] led_disp;
	reg gps_NSR_hold;
	
	always @(posedge clk or posedge rst) begin
		
		if (rst) begin
			led_disp <= 8'h00;
			gps_NSR_hold <= 1'b0;
		
		
		end else begin
			if (gps_NSR) gps_NSR_hold <= 1'b1;
		
			if (gps_NSR_hold) begin
			
				case(switches)
					4'b1111: led_disp <= (gps_hr==4) ? 8'hff : 8'h00;
					4'b1000: led_disp <= {3'b000,gps_hr};
					4'b0100: led_disp <= {2'b00,gps_min};
					4'b0010: led_disp <= {2'b00,gps_sec};
					4'b0000: led_disp <= 8'h66;
					default: led_disp <= 8'h00;
				endcase
			end
		end
	end
	
	assign gps_out = led_disp;

endmodule
				
	
	
	
