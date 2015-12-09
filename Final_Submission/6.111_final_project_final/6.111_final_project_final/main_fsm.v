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
	 input skip,
    input pixel_transform_done,
    output reg [4:0] state,
    output pixel_transform_start,
	 output set_corners,
	 output blur_start,
	 input blur_done,
	 input edge_detection_done,
	 output edge_detection_start,
	 output L2C_start,
	 input L2C_done,
	 output hough_mem_clear_start,
	 input hough_mem_clear_done,
	 output hough_start,
	 input hough_done,
	 input hough_count_done,
	 output hough_count_start
    );
	
   reg last_enter; // Only proceed/move back on a rising edge of the switch
   
	initial begin
		state = 0;
      last_enter = 1;
	end
	
	  parameter VIEW_FINDER = 5'b00000;
	  parameter BLUR_START = 5'b00011;
	  parameter BLUR_WAIT = 5'b00100;
	  parameter SHOW_BLUR = 5'b00101;
	  parameter EDGE_DETECTOR_START = 5'b00110;
	  parameter EDGE_DETECTOR_WAIT = 5'b00111;
	  parameter SHOW_EDGE_DETECTOR = 5'b01000;
	  parameter HOUGH_MEM_CLEAR_START = 5'b10101;
	  parameter HOUGH_MEM_CLEAR_WAIT = 5'b10110;
	  parameter HOUGH_START = 5'b01001;
	  parameter HOUGH_WAIT = 5'b01010;
	  parameter HOUGH_COUNT_START = 5'b10111;
	  parameter HOUGH_COUNT_WAIT = 5'b11000;
	  parameter SHOW_HOUGH = 5'b01011;
	  parameter L2C_START = 5'b10011;
	  parameter L2C_WAIT = 5'b10100;
	  parameter MANUAL_DETECTION_START = 5'b01100;
	  parameter MANUAL_DETECTION_WAIT = 5'b01101;
     parameter COMPUTE_PARAM_START = 5'b01110;
     parameter COMPUTE_PARAM_WAIT = 5'b01111;
     parameter PIXEL_TRANSFORM_START = 5'b10000;
     parameter PIXEL_TRANSFORM_WAIT = 5'b10001;
     parameter SHOW_TRANSFORMED = 5'b10010;
	  
	//if we are in the MANUAL_DETECTION_START state then
	assign set_corners = (state == MANUAL_DETECTION_START ? 1 : 0);
   //if we are in the PIXEL_TRANSFORM_START state then
   assign pixel_transform_start = (state == PIXEL_TRANSFORM_START ? 1 : 0);
   //if we are in the BLUR_START state then
   assign blur_start = (state == BLUR_START ? 1 : 0);
	//if we are in the EDGE_DETECTION_START state then
   assign edge_detection_start = (state == EDGE_DETECTOR_START ? 1 : 0);
	//if we are in the L2C_START state then
   assign L2C_start = (state == L2C_START ? 1 : 0);
	//if we are in the HOUGH_MEM_CLEAR_START state then
   assign hough_mem_clear_start = (state == HOUGH_MEM_CLEAR_START ? 1 : 0);
	//if we are in the HOUGH_START state then
   assign hough_start = (state == HOUGH_START ? 1 : 0);
	//if we are in the HOUGH_COUNT_START state then
   assign hough_count_start = (state == HOUGH_COUNT_START ? 1 : 0);
	
   reg [6:0] counter; // Counter to wait for the parameter computation, because it's not pipelined
	
	//select if the enter button goes forwards or backwards
	wire forwards, backwards;
	assign forwards = switch & ~last_enter & button_enter;
	assign backwards = ~switch & ~last_enter & button_enter;
		
	reg [4:0] next_state;
	always @(*) begin
		case(state)
			VIEW_FINDER: next_state = forwards ? BLUR_START : VIEW_FINDER;
			BLUR_START: next_state = BLUR_WAIT;
			BLUR_WAIT: next_state = blur_done ? SHOW_BLUR : BLUR_WAIT;
			SHOW_BLUR: next_state = (forwards | skip) ? EDGE_DETECTOR_START : (backwards ? VIEW_FINDER : SHOW_BLUR);
			EDGE_DETECTOR_START: next_state = EDGE_DETECTOR_WAIT;
			EDGE_DETECTOR_WAIT: next_state = edge_detection_done ? SHOW_EDGE_DETECTOR : EDGE_DETECTOR_WAIT;
			SHOW_EDGE_DETECTOR: next_state = (forwards | skip) ? HOUGH_MEM_CLEAR_START : (backwards ? BLUR_START : SHOW_EDGE_DETECTOR);
			HOUGH_MEM_CLEAR_START: next_state = HOUGH_MEM_CLEAR_WAIT;
			HOUGH_MEM_CLEAR_WAIT: next_state = hough_mem_clear_done ? HOUGH_START : HOUGH_MEM_CLEAR_WAIT;
			HOUGH_START: next_state = HOUGH_WAIT;
			HOUGH_WAIT: next_state = hough_done ? HOUGH_COUNT_START : HOUGH_WAIT;
			HOUGH_COUNT_START: next_state = HOUGH_COUNT_WAIT;
			HOUGH_COUNT_WAIT: next_state = hough_count_done ? L2C_START : HOUGH_COUNT_WAIT;
			L2C_START: next_state = L2C_WAIT;
			L2C_WAIT: next_state = L2C_done ? MANUAL_DETECTION_START : L2C_WAIT;
			MANUAL_DETECTION_START: next_state = MANUAL_DETECTION_WAIT;
			MANUAL_DETECTION_WAIT: next_state = backwards ? VIEW_FINDER : (forwards ? COMPUTE_PARAM_WAIT : MANUAL_DETECTION_WAIT);
			COMPUTE_PARAM_START: next_state = COMPUTE_PARAM_WAIT;
         COMPUTE_PARAM_WAIT: next_state = (counter == 0) ? PIXEL_TRANSFORM_START : COMPUTE_PARAM_WAIT;
         PIXEL_TRANSFORM_START: next_state = PIXEL_TRANSFORM_WAIT;
         PIXEL_TRANSFORM_WAIT: next_state = (pixel_transform_done)? SHOW_TRANSFORMED : PIXEL_TRANSFORM_WAIT;
         SHOW_TRANSFORMED: next_state = backwards ? MANUAL_DETECTION_WAIT : SHOW_TRANSFORMED;

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
