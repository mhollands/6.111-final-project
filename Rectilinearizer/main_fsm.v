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
	 input blur_done,
	 input edge_detection_done,
    output reg [4:0] state,
	 output auto_detection_start,
	 output set_corners,
	 output blur_start,
	 output edge_detection_start
    );
	
	initial begin
		state = 0;
	end
	
	  parameter VIEW_FINDER = 5'b00000;
	  parameter AUTO_DETECTION_START = 5'b00001;
	  parameter AUTO_DETECTION_WAIT = 5'b00010;
	  parameter MANUAL_DETECTION_START = 5'b00011;
	  parameter MANUAL_DETECTION_WAIT = 5'b00100;
	  parameter BLUR_START = 5'b00101;
	  parameter BLUR_WAIT = 5'b00110;
	  parameter EDGE_DETECTION_START = 5'b00111;
	  parameter EDGE_DETECTION_WAIT = 5'b01000;
	  parameter SHOW_BRAM = 5'b01001;
	  parameter SHOW_TRANSFORMED = 5'b11111;

	//if we are in the AUTO_DETECTION_START state then 
	assign auto_detection_start = (state == AUTO_DETECTION_START ? 1 : 0);
	//if we are in the MANUAL_DETECTION_START state then
	assign set_corners = (state == MANUAL_DETECTION_START ? 1 : 0);
	//if we are in the BLUR_START state then
	assign blur_start = (state == BLUR_START ? 1 : 0);
		//if we are in the EDGE_DETECTION_START state then
	assign edge_detection_start = (state == EDGE_DETECTION_START ? 1 : 0);
	
	//select if the enter button goes forwards or backwards
	wire forwards_edge, backwards_edge, forwards, backwards;
	reg old_forwards, old_backwards;
	assign forwards = switch & button_enter;
	assign backwards = ~switch & button_enter;
	assign forwards_edge = forwards & ~old_forwards;
	assign backwards_edge = backwards & ~old_backwards;
	reg [4:0] next_state;
	always @(*) begin
		case(state)
			VIEW_FINDER: next_state = forwards_edge ? AUTO_DETECTION_START : VIEW_FINDER;
			AUTO_DETECTION_START: next_state = AUTO_DETECTION_WAIT;
			AUTO_DETECTION_WAIT: next_state = auto_detection_done ? MANUAL_DETECTION_START : AUTO_DETECTION_WAIT;
			MANUAL_DETECTION_START: next_state = MANUAL_DETECTION_WAIT;
			MANUAL_DETECTION_WAIT: next_state = backwards_edge ? VIEW_FINDER : forwards_edge ? BLUR_START : MANUAL_DETECTION_WAIT;
			BLUR_START: next_state = BLUR_WAIT;
			BLUR_WAIT: next_state = blur_done ? EDGE_DETECTION_START : BLUR_WAIT;
			EDGE_DETECTION_START: next_state = EDGE_DETECTION_WAIT;
			EDGE_DETECTION_WAIT: next_state = edge_detection_done ? SHOW_TRANSFORMED : EDGE_DETECTION_WAIT;
			SHOW_TRANSFORMED: next_state = backwards_edge ? MANUAL_DETECTION_WAIT : forwards_edge ? SHOW_BRAM : SHOW_TRANSFORMED;
			SHOW_BRAM: next_state = backwards_edge ? SHOW_TRANSFORMED : SHOW_BRAM;
			default: next_state = state;
		endcase
	end
	
	always @(posedge clk) begin
		old_forwards <= forwards;
		old_backwards <= backwards;
		state <= next_state;
	end

endmodule
