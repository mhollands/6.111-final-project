`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:59:54 11/22/2015 
// Design Name: 
// Module Name:    bram_display 
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
module bram_display #(parameter XOFFSET = 0, YOFFSET = 0) (reset,clk,hcount,vcount,br_pixel,
		    bram_addr,bram_read_data);

   input reset, clk;
   input [10:0] hcount;
   input [9:0] 	vcount;
   output reg [29:0] br_pixel;
   output [18:0] bram_addr;
   input  bram_read_data;

	wire[10:0] x;
	wire[9:0] y;
	assign x = hcount - XOFFSET;
	assign y = vcount - YOFFSET;
      
	reg [18:0] bram_addr;
	always@(*) begin
		if(x < 640 && y < 480) begin
			bram_addr = {y[8:0], x[9:0]};
			br_pixel = bram_read_data ? 29'hFFFFFFFF : {10'd0,10'd512,10'd512};
		end
		else begin
			bram_addr = 0;
			br_pixel = {10'd0,10'd512,10'd512};
		end
	end

endmodule
