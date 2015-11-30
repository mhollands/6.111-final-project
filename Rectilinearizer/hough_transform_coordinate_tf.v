`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:26:09 11/29/2015
// Design Name:   hough_transform_coordinate
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/hough_transform_coordinate_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: hough_transform_coordinate
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module hough_transform_coordinate_tf;

	// Inputs
	reg clk;
	reg start;

	// Outputs
	wire done;

	// Instantiate the Unit Under Test (UUT)
	hough_transform_coordinate uut (
		.clk(clk), 
		.start(start), 
		.done(done)
	);

	always #5 clk=~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		start = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		start = 1;
		#10;
		start = 0;
	end
      
endmodule

