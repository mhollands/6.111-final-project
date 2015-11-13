`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:24:34 11/13/2015 
// Design Name: 
// Module Name:    corner_reg 
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
module corner_reg(
    input [79:0] corners_A,
    input [79:0] corners_B,
    input corners_sel,
    output [79:0] corners_out
    );

	assign corners_out = corners_sel ? corners_A : corners_B;

endmodule
