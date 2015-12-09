`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:12:42 11/19/2015 
// Design Name: 
// Module Name:    edge_detector 
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
module thinner #(parameter WIDTH = 640, HEIGHT = 480) 
							  (input reset,
								input clk,
								input start,
								output done,
								output reg read_addr,
								input  [35:0] read_data,
								output reg [18:0] write_addr,
								output reg write_data);
	reg [9:0] x;
	reg [8:0] y;
	reg pixel_buffer [8:0];
	reg pixel_load_buffer [2:0];
	reg [4:0] operation_count;
	reg go = 0;
	reg old_go = 0;

	assign done = ~go & old_go; //generate the done signal
	
	reg delete = 0;
	wire [3:0] p = pixel_buffer[0] +  pixel_buffer[1] + 
						pixel_buffer[2] + pixel_buffer[3] + 
						pixel_buffer[5] + pixel_buffer[6] + 
						pixel_buffer[7] + pixel_buffer[8];
	
	always @(posedge clk) begin	
		old_go <= go; //used to generate the done signal
		if(go) begin
			operation_count <= operation_count + 1;
			case(operation_count)
				0: begin
						delete <= 0; //reset delete marker
					end
				1: begin 
						if(p == 1) begin
							delete <= 1;
						end
					end
				2: begin 
						if(p == 7) begin
							delete <= 1;
						end
						//load in pixel data
						pixel_load_buffer[0] <= read_data;
						//set address of next pixel to read
						read_addr <= {y[8:0], x[9:0]} + 3; 
					end
				3: begin 
						if(p == 8) begin
							delete <= 1;
						end
					end
				4: begin 

					end
				5: begin

						//load in pixel data
						pixel_load_buffer[1] <= read_data;
						//set address of next pixel to read
						read_addr <= {y[8:0] + 1, x[9:0]} + 3;
					end
				6: delete <= delete;
				7: delete <= delete;
				default begin
					operation_count <= 0;
					//shift in new data
					pixel_buffer[0] <= pixel_buffer[1];
					pixel_buffer[1] <= pixel_buffer[2];
					pixel_buffer[2] <= pixel_load_buffer[0];
					pixel_buffer[3] <= pixel_buffer[4];
					pixel_buffer[4] <= pixel_buffer[5];
					pixel_buffer[5] <= pixel_load_buffer[1];
					pixel_buffer[6] <= pixel_buffer[7];
					pixel_buffer[7] <= pixel_buffer[8];
					pixel_buffer[8] <= pixel_load_buffer[2];
					
					//load in pixel data
					pixel_load_buffer[2] <= read_data;
					//set address of next pixel to read
					read_addr <= {y[8:0] - 1 , x[9:0]} + 3; 
					//write edge or not
					write_addr <= {y[8:0], x[9:0]};
					
					if(x < 10 | y < 30 | y > 470 | x > 630) begin
						write_data <= 0;
					end
					else begin
						write_data <= pixel_buffer[4] & ~delete;
					end

					x <= x + 1; //move to next pixel
					if(x == WIDTH - 1) begin
						x <= 0;
						y <= y + 1; //go to next line
					end
					//if we read the end of the image, stop processing
					if(y == HEIGHT - 1 && x == WIDTH - 1) begin
						go <= 0;
					end
					
				end
			endcase
		end
		
		if(start) begin
				read_addr <= 0;
				write_addr <= 0;
				write_data <= 0;
				x <= 0;
				y <= 0;
				operation_count <= 0;
				go <= 1;
				pixel_buffer[0] <= 0;
				pixel_buffer[1] <= 0;
				pixel_buffer[2] <= 0;
				pixel_buffer[3] <= 0;
				pixel_buffer[4] <= 0;
				pixel_buffer[5] <= 0;
				pixel_buffer[6] <= 0;
				pixel_buffer[7] <= 0;
				pixel_buffer[8] <= 0;
				pixel_load_buffer[0] <= 0;
				pixel_load_buffer[1] <= 0;
				pixel_load_buffer[2] <= 0;
		end
	end

endmodule

