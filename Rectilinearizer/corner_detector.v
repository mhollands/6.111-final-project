`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:08:07 11/15/2015 
// Design Name: 
// Module Name:    corner_detector 
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
module corner_detector(
	 input clk,
    input start,
    output reg done,
	 output [79:0] corners
    );

	reg [4:0] count;
	reg pulsed = 0;
	
	assign corners[79:70] = 10'd192;
	assign corners[69:60] = 10'd144;
	assign corners[59:50] = 10'd832;
	assign corners[49:40] = 10'd144;
	assign corners[39:30] = 10'd192;
	assign corners[29:20] = 10'd624;
	assign corners[19:10] = 10'd832;
	assign corners[09:00] = 10'd624;
	
	//for now just implement an empty corner detector
	always @(posedge clk) begin
		count <= count + 1;
		if(start) begin
			count <= 0;
			pulsed <= 0;
		end
		
		if(count == 15 && pulsed == 0) begin
			done <= 1;
			pulsed <= 1;
		end
		else begin
			done <= 0;
		end
	end

endmodule
