`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:31:57 11/24/2015
// Design Name:   sin_lookup
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/sin_lookup_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sin_lookup
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sin_lookup_tf;

	// Inputs
	reg clk;
	reg [8:0] angle;

	// Outputs
	wire [12:0] answer;
	wire negative;
	
	// Instantiate the Unit Under Test (UUT)
	sin_lookup uut (
		.clk(clk), 
		.angle(angle), 
		.answer(answer), 
		.negative(negative)
	);
	
	reg go;
	
	always #5 clk = ~clk;
	
	always @(posedge clk) begin
		if(go) begin
			angle <= angle + 5;
		end
	end
	
	initial begin
		// Initialize Inputs
		clk = 0;
		angle = 0;
		go = 0;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		go = 1;
	end
      
endmodule

