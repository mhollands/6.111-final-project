`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:11:24 11/15/2015 
// Design Name: 
// Module Name:    human_interface 
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
module human_interface_corners(
	input clk,
	input field,
   input left_button,
   input right_button,
   input up_button,
   input down_button,
   input enter_button,
   input zero_button,
   input one_button,
   input two_button,
   input three_button,
	input [79:0] auto_corners, 
	input set_corners,
   output reg [9:0] corners1x,
	output reg [9:0] corners1y,
	output reg [9:0] corners2x,
	output reg [9:0] corners2y,
	output reg [9:0] corners3x,
	output reg [9:0] corners3y,
	output reg [9:0] corners4x,
	output reg [9:0] corners4y
   );
	
	reg old_field;
	wire field_edge;
	assign field_edge = field & ~old_field;
	
	reg [1:0] selected_corner;
	
	always @(posedge clk) begin
		old_field <= field;
		
					
		if(set_corners) begin
			corners1x <= auto_corners[79:70];
			corners1y <= auto_corners[69:60];
			corners2x <= auto_corners[59:50];
			corners2y <= auto_corners[49:40];
			corners3x <= auto_corners[39:30];
			corners3y <= auto_corners[29:20];
			corners4x <= auto_corners[19:10];
			corners4y <= auto_corners[09:00];
		end
      
		//every frame
		else if(field_edge == 1) begin
			//move selected corner left
			if(left_button == 1) begin
				if(selected_corner == 0) corners1x <= corners1x - 2;
				if(selected_corner == 1) corners2x <= corners2x - 2;
				if(selected_corner == 2) corners3x <= corners3x - 2;
				if(selected_corner == 3) corners4x <= corners4x - 2;
			end
			
			//move selected corner right
			else if(right_button == 1) begin
				if(selected_corner == 0) corners1x <= corners1x + 2;
				if(selected_corner == 1) corners2x <= corners2x + 2;
				if(selected_corner == 2) corners3x <= corners3x + 2;
				if(selected_corner == 3) corners4x <= corners4x + 2;
			end
			
			//move selected corner up
			else if(up_button == 1) begin
				if(selected_corner == 0) corners1y <= corners1y - 2;
				if(selected_corner == 1) corners2y <= corners2y - 2;
				if(selected_corner == 2) corners3y <= corners3y - 2;
				if(selected_corner == 3) corners4y <= corners4y - 2;
			end
			
			//move selected corner down
			else if(down_button == 1) begin
				if(selected_corner == 0) corners1y <= corners1y + 2;
				if(selected_corner == 1) corners2y <= corners2y + 2;
				if(selected_corner == 2) corners3y <= corners3y + 2;
				if(selected_corner == 3) corners4y <= corners4y + 2;
			end
			
			//select which corner you're moving
			if(zero_button == 1) selected_corner <= 0;
			else if(one_button == 1) selected_corner <= 1;
			else if(two_button == 1) selected_corner <= 2;
			else if(three_button == 1) selected_corner <= 3;
		end
	end

endmodule
