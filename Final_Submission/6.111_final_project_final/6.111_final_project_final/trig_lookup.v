`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:12:00 11/24/2015 
// Design Name: 
// Module Name:    trig_lookup 
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
module sin_lookup(input [7:0] angle, output reg [12:0] answer, output reg negative);

   wire [7:0] angle_rounded = {angle[7:2], 2'b00};

	always @(*) begin
		case(angle_rounded)
			0: begin answer = 0; negative = 0; end
			4: begin answer = 286; negative = 0; end
			8: begin answer = 570; negative = 0; end
			12: begin answer = 852; negative = 0; end
			16: begin answer = 1129; negative = 0; end
			20: begin answer = 1401; negative = 0; end
			24: begin answer = 1666; negative = 0; end
			28: begin answer = 1923; negative = 0; end
			32: begin answer = 2171; negative = 0; end
			36: begin answer = 2408; negative = 0; end
			40: begin answer = 2633; negative = 0; end
			44: begin answer = 2845; negative = 0; end
			48: begin answer = 3044; negative = 0; end
			52: begin answer = 3228; negative = 0; end
			56: begin answer = 3396; negative = 0; end
			60: begin answer = 3547; negative = 0; end
			64: begin answer = 3681; negative = 0; end
			68: begin answer = 3798; negative = 0; end
			72: begin answer = 3896; negative = 0; end
			76: begin answer = 3974; negative = 0; end
			80: begin answer = 4034; negative = 0; end
			84: begin answer = 4074; negative = 0; end
			88: begin answer = 4094; negative = 0; end
			92: begin answer = 4094; negative = 0; end
			96: begin answer = 4074; negative = 0; end
			100: begin answer = 4034; negative = 0; end
			104: begin answer = 3974; negative = 0; end
			108: begin answer = 3896; negative = 0; end
			112: begin answer = 3798; negative = 0; end
			116: begin answer = 3681; negative = 0; end
			120: begin answer = 3547; negative = 0; end
			124: begin answer = 3396; negative = 0; end
			128: begin answer = 3228; negative = 0; end
			132: begin answer = 3044; negative = 0; end
			136: begin answer = 2845; negative = 0; end
			140: begin answer = 2633; negative = 0; end
			144: begin answer = 2408; negative = 0; end
			148: begin answer = 2171; negative = 0; end
			152: begin answer = 1923; negative = 0; end
			156: begin answer = 1666; negative = 0; end
			160: begin answer = 1401; negative = 0; end
			164: begin answer = 1129; negative = 0; end
			168: begin answer = 852; negative = 0; end
			172: begin answer = 570; negative = 0; end
			176: begin answer = 286; negative = 0; end
			default: begin answer = 0; negative = 0; end
		endcase
	end

endmodule

module cos_lookup(input [7:0] angle, output reg [12:0] answer, output reg negative);	

   wire [7:0] angle_rounded = {angle[7:2], 2'b00};

	always @(*) begin
		case(angle_rounded)
			0: begin answer = 4096; negative = 0; end
			4: begin answer = 4086; negative = 0; end
			8: begin answer = 4056; negative = 0; end
			12: begin answer = 4006; negative = 0; end
			16: begin answer = 3937; negative = 0; end
			20: begin answer = 3849; negative = 0; end
			24: begin answer = 3742; negative = 0; end
			28: begin answer = 3617; negative = 0; end
			32: begin answer = 3474; negative = 0; end
			36: begin answer = 3314; negative = 0; end
			40: begin answer = 3138; negative = 0; end
			44: begin answer = 2946; negative = 0; end
			48: begin answer = 2741; negative = 0; end
			52: begin answer = 2522; negative = 0; end
			56: begin answer = 2290; negative = 0; end
			60: begin answer = 2048; negative = 0; end
			64: begin answer = 1796; negative = 0; end
			68: begin answer = 1534; negative = 0; end
			72: begin answer = 1266; negative = 0; end
			76: begin answer = 991; negative = 0; end
			80: begin answer = 711; negative = 0; end
			84: begin answer = 428; negative = 0; end
			88: begin answer = 143; negative = 0; end
			92: begin answer = 143; negative = 1; end
			96: begin answer = 428; negative = 1; end
			100: begin answer = 711; negative = 1; end
			104: begin answer = 991; negative = 1; end
			108: begin answer = 1266; negative = 1; end
			112: begin answer = 1534; negative = 1; end
			116: begin answer = 1796; negative = 1; end
			120: begin answer = 2048; negative = 1; end
			124: begin answer = 2290; negative = 1; end
			128: begin answer = 2522; negative = 1; end
			132: begin answer = 2741; negative = 1; end
			136: begin answer = 2946; negative = 1; end
			140: begin answer = 3138; negative = 1; end
			144: begin answer = 3314; negative = 1; end
			148: begin answer = 3474; negative = 1; end
			152: begin answer = 3617; negative = 1; end
			156: begin answer = 3742; negative = 1; end
			160: begin answer = 3849; negative = 1; end
			164: begin answer = 3937; negative = 1; end
			168: begin answer = 4006; negative = 1; end
			172: begin answer = 4056; negative = 1; end
			176: begin answer = 4086; negative = 1; end
			default: begin answer = 0; negative = 0; end
		endcase
	end

endmodule
