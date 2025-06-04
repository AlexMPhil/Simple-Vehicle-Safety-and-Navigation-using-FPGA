`timescale 1ns/1ps

module uart_rx_tb();

localparam clk_freq = 50000000;
localparam baud_rate = 9600;
localparam CPB = clk_freq/baud_rate;
localparam WT = CPB*20;

reg clk = 0;
reg rst = 0;
reg rx = 1;
wire [7:0] d_out;
wire valid;

uart_rx uut (.clk(clk), .rst(rst), .rx(rx), .d_out(d_out), .valid(valid));

always #10 clk=~clk;


task uart_byte(input [7:0] char);
	
	integer i;
	begin
		
		rx <= 1;
		#WT;
		
		for (i=0;i<8;i=i+1) begin
			rx <= char[i];
			#WT;
		end
		
		rx <= 1;
		#WT;
		
	end
	
endtask

initial begin

	rst = 1;
	#100;
	rst = 0;
	
	uart_byte(8'h46);
	uart_byte(8'h50);
	uart_byte(8'h47);
	uart_byte(8'h41);
	
	#400000;
	
end




endmodule