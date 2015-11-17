`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:28:42 11/17/2015
// Design Name:   gaussian_blurrer
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/gaussian_blurrer_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gaussian_blurrer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gaussian_blurrer_tf;

	// Inputs
	reg reset;
	reg clk;
	reg start;
	wire [35:0] read_data;

	// Outputs
	wire done;
	wire [18:0] read_addr;
	wire [18:0] write_addr;
	wire [35:0] write_data;
	
	wire [35:0] data[9:0];
	assign data[0] = 0;
	assign data[1] = 0;
	assign data[2] = 0;
	assign data[3] = 0;
	assign data[4] = 0;
	assign data[5] = {6'b0,10'd512,20'b0};
	assign data[6] = 0;
	assign data[7] = 0;
	assign data[8] = 0;
	assign data[9] = 0;
		
	// Instantiate the Unit Under Test (UUT)
	gaussian_blurrer #(10, 1) uut (
		.reset(reset), 
		.clk(clk), 
		.start(start), 
		.done(done), 
		.read_addr(read_addr), 
		.read_data(read_data), 
		.write_addr(write_addr), 
		.write_data(write_data)
	);
	
	always #5 clk = ~clk;

	initial begin		
		// Initialize Inputs
		reset = 0;
		clk = 0;
		start = 0;

		// Wait 100 ns for global reset to finish
		#100;
		start = 1;
		#10;
		start = 0;
	end
	
	assign read_data = data[read_addr];
      
endmodule

