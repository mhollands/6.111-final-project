`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:22:28 11/15/2015
// Design Name:   main_fsm
// Module Name:   /afs/athena.mit.edu/user/h/o/hollands/6.111-final-project/Rectilinearizer/main_fsm_tf.v
// Project Name:  Rectilinearizer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: main_fsm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module main_fsm_tf;

	// Inputs
	reg clk;
	reg button_enter;
	reg switch;
	reg auto_detection_done;

	// Outputs
	wire [2:0] state;
	wire auto_detectection_start;

	// Instantiate the Unit Under Test (UUT)
	main_fsm uut (
		.clk(clk), 
		.button_enter(button_enter), 
		.switch(switch), 
		.auto_detection_done(auto_detection_done), 
		.state(state), 
		.auto_detection_start(auto_detectection_start)
	);

	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		button_enter = 0;
		switch = 1;
		auto_detection_done = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#100;
		button_enter = 1;
		#10;
		button_enter = 0;
		#50;
		auto_detection_done = 1;
		#10;
		auto_detection_done = 0;
	end
      
endmodule

