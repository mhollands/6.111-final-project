`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:26 11/24/2015 
// Design Name: 
// Module Name:    hough_transformer 
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
module hough_transformer(input clk, input start, output done, input[9:0] x, input [8:0] y);

	wire [7:0] sin_angle;
	wire [12:0] sin_answer;
	wire sin_negative;
	sin_lookup sin(.angle(sin_angle),
						.answer(sin_answer),
						.negative(sin_negative));
						
	wire [7:0] cos_angle;
	wire [12:0] cos_answer;
	wire cos_negative;
	cos_lookup cos(.angle(cos_angle),
						.answer(cos_answer),
						.negative(cos_negative));
	
	reg go, old_go;
	assign done = ~go & old_go; //generate the done signal
	reg [7:0] angle = 0;
	reg [5:0] modify_pointer;
	reg signed [12:0] modify_r [44:0];
	reg [7:0] modify_angle [44:0];
	assign sin_angle = angle;
	assign cos_angle = angle;
	
	wire [21:0] x_cos_theta = x * cos_answer;
	wire [21:0] y_sin_theta = y * sin_answer;
	wire signed [24:0] r_scaled = (x_cos_theta + (cos_negative ? -y_sin_theta : y_sin_theta));
	always @(posedge clk) begin
		old_go <= go;		
		if(go) begin
			modify_pointer <= modify_pointer + 1;
			angle <= angle + 4;
			modify_r[modify_pointer] <= (r_scaled >> 12);
			modify_angle[modify_pointer] <= angle;
			if(modify_pointer == 44) begin
				go <= 0;
			end
		end
		
		if(start) begin
			modify_pointer = 0;
			angle <= 0;
			go <= 1;
		end
	end

endmodule
