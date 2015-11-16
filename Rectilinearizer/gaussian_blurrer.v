`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:15 11/15/2015 
// Design Name: 
// Module Name:    gaussian_blurrer 
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
module gaussian_blurrer(input reset,
								input clk,
								input start,
								output done,
								output [18:0] addr,
								input [35:0] data);
	wire begun = 0;
	wire [9:0] x;
	wire [8:0] y;
	wire [2:0] look_ahead;
	wire [9:0] pixel_buffer [4:0];
	wire [3:0] multiplication_count;
	wire [19:0] pixel;

	always @(posedge clk) begin
		if(start) begin
				addr <= 0;
				x <= 0;
				y <= 0;
				multiplication_count <= 0;
				pixel <= 0;
		end
		
		multiplication_count <= multiplication_count + 1;
					
		case(multiplication_count)
			0: pixel <= pixel + (32 * pixel_buffer[0]) >> 10;
			1: pixel <= pixel + (77 * pixel_buffer[1]) >> 10;
			2: pixel <= pixel + (97 * pixel_buffer[2]) >> 10;
			3: pixel <= pixel + (77 * pixel_buffer[3]) >> 10;
			4: pixel <= pixel + (32 * pixel_buffer[4]) >> 10;
			default begin
				multiplication_count <= 0;
				addr = {x,y} + 3;
				x <= x + 1;
				y <= y + 1;
				if(x == 639) x <= 0;
				if(y == 479) y <= 0;
				//shift in new data
				pixel_buffer = {pixel_buffer[3:0], data[29:20]};
			end
	end

endmodule
