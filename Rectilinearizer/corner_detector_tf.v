`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:12:20 11/15/2015
// Design Name:   corner_detector
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/corner_detector_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: corner_detector
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module corner_detector_tf;

	// Inputs
	reg clk;
	reg start;

	// Outputs
	wire done;

	// Instantiate the Unit Under Test (UUT)
	corner_detector uut (
		.clk(clk), 
		.start(start), 
		.done(done)
	);

	always #5 clk = ~clk;

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

