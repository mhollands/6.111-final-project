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
    output reg [4:0] state,
	 output auto_detection_start,
	 output set_corners
    );
	
	initial begin
		state = 0;
	end
	
	  parameter VIEW_FINDER = 5'b00000;
	  parameter AUTO_DETECTION_START = 5'b00001;
	  parameter AUTO_DETECTION_WAIT = 5'b00010;
	  parameter MANUAL_DETECTION_START = 5'b00011;
	  parameter MANUAL_DETECTION_WAIT = 5'b00100;

	//if we are in the AUTO_DETECTION_START state then 
	assign auto_detection_start = (state == AUTO_DETECTION_START ? 1 : 0);
	//if we are in the MANUAL_DETECTION_START state then
	assign set_corners = (state == MANUAL_DETECTION_START ? 1 : 0);
	
	//select if the enter button goes forwards or backwards
	wire forwards, backwards;
	assign forwards = switch & button_enter;
	assign backwards = ~switch & button_enter;

	reg [2:0] next_state;
	always @(*) begin
		case(state)
			VIEW_FINDER: next_state = forwards ? AUTO_DETECTION_START : VIEW_FINDER;
			AUTO_DETECTION_START: next_state = AUTO_DETECTION_WAIT;
			AUTO_DETECTION_WAIT: next_state = auto_detection_done ? MANUAL_DETECTION_START : AUTO_DETECTION_WAIT;
			MANUAL_DETECTION_START: next_state = MANUAL_DETECTION_WAIT;
			MANUAL_DETECTION_WAIT: next_state = backwards ? VIEW_FINDER : MANUAL_DETECTION_WAIT;
			default: next_state = state;
		endcase
	end
	
	always @(posedge clk) begin
		state <= next_state;
	end

endmodule
