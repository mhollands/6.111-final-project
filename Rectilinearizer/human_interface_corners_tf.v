`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:00:25 11/15/2015
// Design Name:   human_interface_corners
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/human_interface_corners_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: human_interface_corners
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module human_interface_corners_tf;

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
	reg [79:0] auto_corners;
	reg set_corners;

	// Outputs
	wire [9:0] corners1x;
	wire [9:0] corners1y;
	wire [9:0] corners2x;
	wire [9:0] corners2y;
	wire [9:0] corners3x;
	wire [9:0] corners3y;
	wire [9:0] corners4x;
	wire [9:0] corners4y;

	// Instantiate the Unit Under Test (UUT)
	human_interface_corners uut (
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
		.auto_corners(auto_corners), 
		.set_corners(set_corners), 
		.corners1x(corners1x), 
		.corners1y(corners1y), 
		.corners2x(corners2x), 
		.corners2y(corners2y), 
		.corners3x(corners3x), 
		.corners3y(corners3y), 
		.corners4x(corners4x), 
		.corners4y(corners4y)
	);

	always #5 clk = ~clk;

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
		auto_corners = 0;
		set_corners = 0;

		auto_corners[79:70] = 10'd192;
		auto_corners[69:60] = 10'd144;
		auto_corners[59:50] = 10'd832;
		auto_corners[49:40] = 10'd144;
		auto_corners[39:30] = 10'd192;
		auto_corners[29:20] = 10'd880;
		auto_corners[19:10] = 10'd832;
		auto_corners[09:00] = 10'd880;

		// Wait 100 ns for global reset to finish
		#100;
		set_corners = 1;
		#10;
		set_corners = 0;
		#50;
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

