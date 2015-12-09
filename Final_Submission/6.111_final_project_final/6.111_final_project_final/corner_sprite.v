`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:28:21 11/13/2015 
// Design Name: 
// Module Name:    corner_sprite 
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
module corner_sprite #(parameter COLOUR=29'hFFFFFFFF)(
    input [10:0] x,
    input [9:0] y,
	 input [10:0] hcount,
	 input [9:0] vcount,
    output [29:0] pixel
    );
	
	wire hline;
	wire vline;
	assign hline = (hcount > x - 20 & hcount < x + 20 & y == vcount);
	assign vline = (vcount > y - 20 & vcount < y + 20 & x == hcount);

	assign pixel = ((hline || vline) ? COLOUR : 0);

endmodule
