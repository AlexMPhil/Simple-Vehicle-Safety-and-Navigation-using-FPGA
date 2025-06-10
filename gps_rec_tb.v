`timescale 1ns/1ps

module gps_rec_tb();

	localparam clk_freq = 50000000;
	localparam baud_rate = 9600;
	localparam CPB = clk_freq/baud_rate;
	localparam WT = CPB*20;
	
	reg clk = 0;
	reg rst = 0;
	reg rx = 1;
	reg [3:0] switches;
	wire [7:0] gps_out;
	wire [4:0] gps_hr;
	wire [5:0] gps_min;
	wire [5:0] gps_sec;
	wire gps_NSR;
	
	always #10 clk = ~clk;
	
	gps_reciever gr1 (
		.clk(clk),
      .rst(rst),
      .uart_rx_pin(rx),
      .switches(switches),
      .gps_out(gps_out),
      .gps_hr(gps_hr),
      .gps_min(gps_min),
      .gps_sec(gps_sec),
      .gps_NSR(gps_NSR)
		
	);
	
	task uart_byte(input [7:0] char);
		integer m;
		begin
			rx <= 0;
			#WT;
			for (m=0;m<8;m=m+1) begin
				rx <= char[m];
				#WT;
			end
			rx <= 1;
			#WT;
		end
	endtask
	
	task send_sentence;
		begin
			uart_byte(8'h24); // $
         uart_byte("G");
         uart_byte("P");
         uart_byte("R");
         uart_byte("M");
         uart_byte("C");
         uart_byte(",");

         uart_byte("1"); // UTC time = 12:35:19
         uart_byte("2");
         uart_byte("3");
         uart_byte("5");
         uart_byte("1");
         uart_byte("9");

         uart_byte(","); // end of time field
      end
	endtask
	
	initial begin
		rst = 1;
		#100;
		rst=0;
		
		send_sentence();
		
		wait (gps_hr != 0 || gps_min != 0 || gps_sec != 0);
      $display("----> gps_NSR asserted, data parsed successfully at time = %0t", $time);  // Debug display
      #100;
		  
		switches = 4'b1000; #100; $display("Switch=1000 → gps_hr = %0d, LED = %h", gps_hr, gps_out);
      switches = 4'b0100; #100; $display("Switch=0100 → gps_min = %0d, LED = %h", gps_min, gps_out);
      switches = 4'b0010; #100; $display("Switch=0010 → gps_sec = %0d, LED = %h", gps_sec, gps_out);
      switches = 4'b0000; #100; $display("Switch=0000 → LED = %h", gps_out);
      switches = 4'b1111; #100; $display("Switch=1111 → gps_hr==10? LED = %h", gps_out);	
		
		$stop;
		
	end

endmodule
