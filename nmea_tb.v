`timescale 1ns/1ps

module nmea_tb();

    reg clk;
    reg rst;
    reg [7:0] char;
    reg valid;
	 wire NSR;
    wire [4:0] hr;
    wire [5:0] min;
	 wire [5:0] sec;
    

    // Instantiate your DUT (Device Under Test)
    nmea_parse dut (
        .clk(clk),
        .rst(rst),
        .char(char),
        .valid(valid),
        .NSR(NSR),
        .hr(hr),
        .min(min),
        .sec(sec)
    );

    // Clock generator (50MHz)
    initial clk = 0;
	 always #10 clk = ~clk;
	 
	 task send_char(input [7:0] c);
	 begin
		@(posedge clk);
		char <= c;
		valid <= 1;
		@(posedge clk);
		valid <= 0;
	 end
	 endtask

    // Sample GPRMC sentence with UTC time "123519"
    reg [7:0] sentence [0:69];
    integer i;

    initial begin
        // Populate NMEA sentence
        sentence[0]  = "$";
        sentence[1]  = "G";
        sentence[2]  = "P";
        sentence[3]  = "R";
        sentence[4]  = "M";
        sentence[5]  = "C";
        sentence[6]  = ",";
        sentence[7]  = "1";
        sentence[8]  = "2";
        sentence[9]  = "3";
        sentence[10] = "5";
        sentence[11] = "1";
        sentence[12] = "9";
        sentence[13] = ",";
        sentence[14] = "A";
        sentence[15] = ",";
        sentence[16] = "4";
        sentence[17] = "8";
        sentence[18] = "0";
        sentence[19] = "7";
        sentence[20] = ".";
        sentence[21] = "0";
        sentence[22] = "3";
        sentence[23] = "8";
        sentence[24] = ",";
        sentence[25] = "N";
        sentence[26] = ",";
        sentence[27] = "0";
        sentence[28] = "1";
        sentence[29] = "1";
        sentence[30] = "3";
        sentence[31] = "1";
        sentence[32] = ".";
        sentence[33] = "0";
        sentence[34] = "0";
        sentence[35] = "0";
        sentence[36] = ",";
        sentence[37] = "E";
        sentence[38] = ",";
        sentence[39] = "0";
        sentence[40] = "2";
        sentence[41] = "2";
        sentence[42] = ".";
        sentence[43] = "4";
        sentence[44] = ",";
        sentence[45] = "0";
        sentence[46] = "8";
        sentence[47] = "4";
        sentence[48] = ".";
        sentence[49] = "4";
        sentence[50] = ",";
        sentence[51] = "2";
        sentence[52] = "3";
        sentence[53] = "0";
        sentence[54] = "3";
        sentence[55] = "9";
        sentence[56] = "4";
        sentence[57] = ",";
        sentence[58] = "0";
        sentence[59] = "0";
        sentence[60] = "3";
        sentence[61] = ".";
        sentence[62] = "1";
        sentence[63] = ",";
        sentence[64] = "W";
        sentence[65] = "*";
        sentence[66] = "6";
        sentence[67] = "A";
	 	  sentence[68] = "\r"; 
        sentence[69] = "\n";
	 	 
	 end
	 
	 initial begin 
	 // Simulation sequence
        $display("Starting simulation...");
        
		  valid = 0;
		  char = 8'd0;
		  rst = 1;
		  
		  #20;
		  rst = 0;
		  
		  for (i=0; i <= 69; i = i+1) begin
				send_char(sentence[i]);
				#20;
		  end
		 
		  #100;
		  
		  if (NSR == 1 && hr == 12 && min == 35 && sec == 19) begin
				$display ("Test Passed: hr=%0d min=%0d sec=%0d", hr, min, sec);
		  end else begin
				$display ("Test Failed: hr=%0d min=%0d sec=%0d", hr, min, sec);
		  end
		  
		  $finish;
	 end

endmodule