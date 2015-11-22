`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:58:28 11/22/2015
// Design Name:   edge_detector
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/edge_detector_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: edge_detector
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module edge_detector_tf;

	// Inputs
	reg reset;
	reg clk;
	reg start;
	reg [35:0] read_data;

	// Outputs
	wire done;
	wire [18:0] read_addr;
	wire [18:0] write_addr;
	wire write_data;

	// Instantiate the Unit Under Test (UUT)
	edge_detector #(6,3,480) uut (
		.reset(reset), 
		.clk(clk), 
		.start(start), 
		.done(done), 
		.read_addr(read_addr), 
		.read_data(read_data), 
		.write_addr(write_addr), 
		.write_data(write_data)
	);

	always #5 clk=~clk;

	initial begin
		// Initialize Inputs
		reset = 0;
		clk = 0;
		start = 0;
		read_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
		start = 1;
		#10;
		start = 0;
		// Add stimulus here
	end
	
	always @(*) begin
		case(read_addr)
			3: read_data = {10'd500, 20'b0};
			4: read_data = 0;
			5: read_data = 0;
			1027: read_data = {10'd500, 20'b0};
			1028: read_data = 0;
			1029: read_data = 0;
			2051: read_data = {10'd500, 20'b0};
			2052: read_data = 0;
			2053: read_data = 0;
			default: read_data = 0;
		endcase
	end
      
endmodule

