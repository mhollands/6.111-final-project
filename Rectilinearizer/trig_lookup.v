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
module sin_lookup(input clk, input [8:0] angle, output [12:0] answer, output negative)
    );
	
	always @(posedge clk) begin
		case(angle):
			0: begin answer <= 0; negative <= 0; end
			5: begin answer <= 357; negative <= 0; end
			10: begin answer <= 711; negative <= 0; end
			15: begin answer <= 1060; negative <= 0; end
			20: begin answer <= 1401; negative <= 0; end
			25: begin answer <= 1731; negative <= 0; end
			30: begin answer <= 2048; negative <= 0; end
			35: begin answer <= 2349; negative <= 0; end
			40: begin answer <= 2633; negative <= 0; end
			45: begin answer <= 2896; negative <= 0; end
			50: begin answer <= 3138; negative <= 0; end
			55: begin answer <= 3355; negative <= 0; end
			60: begin answer <= 3547; negative <= 0; end
			65: begin answer <= 3712; negative <= 0; end
			70: begin answer <= 3849; negative <= 0; end
			75: begin answer <= 3956; negative <= 0; end
			80: begin answer <= 4034; negative <= 0; end
			85: begin answer <= 4080; negative <= 0; end
			90: begin answer <= 4096; negative <= 0; end
			175: begin answer <= 357; negative <= 0; end
			170: begin answer <= 711; negative <= 0; end
			165: begin answer <= 1060; negative <= 0; end
			160: begin answer <= 1401; negative <= 0; end
			155: begin answer <= 1731; negative <= 0; end
			150: begin answer <= 2048; negative <= 0; end
			145: begin answer <= 2349; negative <= 0; end
			140: begin answer <= 2633; negative <= 0; end
			135: begin answer <= 2896; negative <= 0; end
			130: begin answer <= 3138; negative <= 0; end
			125: begin answer <= 3355; negative <= 0; end
			120: begin answer <= 3547; negative <= 0; end
			115: begin answer <= 3712; negative <= 0; end
			110: begin answer <= 3849; negative <= 0; end
			105: begin answer <= 3956; negative <= 0; end
			100: begin answer <= 4034; negative <= 0; end
			95: begin answer <= 4080; negative <= 0; end
	end

endmodule
