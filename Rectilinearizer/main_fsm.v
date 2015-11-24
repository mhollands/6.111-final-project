`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:57:19 11/15/2015 
// Design Name: 
// Module Name:    main_fsm 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module main_fsm(
	 input clk,
    input button_enter,
	 input switch,
	 input auto_detection_done,
    input pixel_transform_done,
    output reg [4:0] state,
	 output auto_detection_start,
    output pixel_transform_start,
	 output set_corners
    );
	
   reg last_enter; // Only proceed/move back on a rising edge of the switch
   
	initial begin
		state = 0;
      last_enter = 1;
	end
	
	  parameter VIEW_FINDER = 5'b000;
	  parameter AUTO_DETECTION_START = 5'b001;
	  parameter AUTO_DETECTION_WAIT = 5'b010;
	  parameter MANUAL_DETECTION_START = 5'b011;
	  parameter MANUAL_DETECTION_WAIT = 5'b100;
     parameter COMPUTE_PARAM_START = 5'b1000;
     parameter COMPUTE_PARAM_WAIT = 5'b1001;
     parameter PIXEL_TRANSFORM_START = 5'b1010;
     parameter PIXEL_TRANSFORM_WAIT = 5'b1011;
     parameter SHOW_TRANSFORMED = 5'b1100;

	//if we are in the AUTO_DETECTION_START state then 
	assign auto_detection_start = (state == AUTO_DETECTION_START ? 1 : 0);
	//if we are in the MANUAL_DETECTION_START state then
	assign set_corners = (state == MANUAL_DETECTION_START ? 1 : 0);
   //if we are in the PIXEL_TRANSFORM_START state then
   assign pixel_transform_start = (state == PIXEL_TRANSFORM_START ? 1 : 0);
   
   reg [6:0] counter; // Counter to wait for the parameter computation, because it's not pipelined
	
	//select if the enter button goes forwards or backwards
	wire forwards, backwards;
	assign forwards = switch & ~last_enter & button_enter;
	assign backwards = ~switch & ~last_enter & button_enter;

	reg [4:0] next_state;
	always @(*) begin
		case(state)
			VIEW_FINDER: next_state = forwards ? AUTO_DETECTION_START : VIEW_FINDER;
			AUTO_DETECTION_START: next_state = AUTO_DETECTION_WAIT;
			AUTO_DETECTION_WAIT: next_state = auto_detection_done ? MANUAL_DETECTION_START : AUTO_DETECTION_WAIT;
			MANUAL_DETECTION_START: next_state = MANUAL_DETECTION_WAIT;
			MANUAL_DETECTION_WAIT: next_state = backwards ? VIEW_FINDER : (forwards ? COMPUTE_PARAM_WAIT : MANUAL_DETECTION_WAIT);
			COMPUTE_PARAM_START: next_state = COMPUTE_PARAM_WAIT;
         COMPUTE_PARAM_WAIT: next_state = (counter == 0) ? PIXEL_TRANSFORM_START : COMPUTE_PARAM_WAIT;
         PIXEL_TRANSFORM_START: next_state = PIXEL_TRANSFORM_WAIT;
         PIXEL_TRANSFORM_WAIT: next_state = forwards ? SHOW_TRANSFORMED : PIXEL_TRANSFORM_WAIT;
         SHOW_TRANSFORMED: next_state = SHOW_TRANSFORMED;
         
         default: next_state = state;
		endcase
	end
	
	always @(posedge clk) begin
		state <= next_state;
      last_enter <= button_enter;
      
      if (state == COMPUTE_PARAM_START) counter <= 100;
      if (counter > 0) counter <= counter - 1;
	end

endmodule
