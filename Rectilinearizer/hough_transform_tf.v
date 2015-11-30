`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:20:52 11/24/2015
// Design Name:   hough_transformer
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/hough_transform_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: hough_transformer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module hough_transform_tf;

	// Inputs
	reg clk;
	reg start;
	reg [9:0] x;
	reg [8:0] y;

	// Outputs
	wire done;
	wire start_transmit;
	wire [7:0] transmit_angle;
	wire [12:0] transmit_r;
	// Instantiate the Unit Under Test (UUT)
	hough_transform_calculate uut (
		.clk(clk), 
		.start(start), 
		.done(done), 
		.x(x), 
		.y(y),
		.start_transmit(start_transmit),
		.transmit_r(transmit_r),
		.transmit_angle(transmit_angle)
	);

	always #5 clk=~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		start = 0;
		x = 100;
		y = 100;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		start = 1;
		#10;
		start = 0;
	end
      
endmodule

