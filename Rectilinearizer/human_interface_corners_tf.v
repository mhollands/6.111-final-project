`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:07:06 11/15/2015
// Design Name:   human_interface
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/human_interface_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: human_interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module human_interface_tf;

	// Inputs
	reg clk;
	reg field;
	reg left_button;
	reg right_button;
	reg up_button;
	reg down_button;
	reg enter_button;
	reg zero_button;
	reg one_button;
	reg two_button;
	reg three_button;
	
	// Outputs
	wire [9:0] corners;
	wire field_edge;

	// Instantiate the Unit Under Test (UUT)
	human_interface uut (
		.clk(clk), 
		.field(field), 
		.left_button(left_button), 
		.right_button(right_button), 
		.up_button(up_button), 
		.down_button(down_button), 
		.enter_button(enter_button), 
		.zero_button(zero_button), 
		.one_button(one_button), 
		.two_button(two_button), 
		.three_button(three_button), 
		.corners(corners), 
		.field_edge(field_edge)
	);

		always #5 clk = !clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		field = 0;
		left_button = 0;
		right_button = 0;
		up_button = 0;
		down_button = 0;
		enter_button = 0;
		zero_button = 0;
		one_button = 0;
		two_button = 0;
		three_button = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
		left_button = 1;
		#100;
		field = 1;
		#100;
		left_button = 0;
		right_button = 1;
		#100;
		field = 1;
        
		// Add stimulus here

	end
      
endmodule

