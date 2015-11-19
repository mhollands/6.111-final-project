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
module gaussian_blurrer #(parameter WIDTH = 640, HEIGHT = 480) 
							  (input reset,
								input clk,
								input start,
								output done,
								output reg [18:0] read_addr,
								input [35:0] read_data,
								output reg [18:0] write_addr,
								output reg [35:0] write_data);
	reg [9:0] x;
	reg [8:0] y;
	reg [9:0] pixel_buffer [8:0];
	reg [9:0] pixel_load_buffer [2:0];
	reg [4:0] multiplication_count;
	reg go = 0;
	reg old_go = 0;
	reg [19:0] pixel;

	assign done = ~go & old_go; //generate the done signal
	
	always @(posedge clk) begin	
		old_go <= go; //used to generate the done signal
		if(go) begin
			multiplication_count <= multiplication_count + 1;
			case(multiplication_count)
				//these are 1024 times too big
				0: pixel <= pixel + (95 * pixel_buffer[0]);
				1: pixel <= pixel + (122 * pixel_buffer[1]);
				2: begin 
						pixel <= pixel + (95 * pixel_buffer[2]);
						//load in pixel data
						pixel_load_buffer[0] <= read_data[29:20];
						//set address of next pixel to read
						read_addr <= {y[8:0], x[9:0]} + 3; 
					end
				3: pixel <= pixel + (122 * pixel_buffer[3]);
				4: pixel <= pixel + (155 * pixel_buffer[4]);
				5: begin
						pixel <= pixel + (122 * pixel_buffer[5]);
						pixel_load_buffer[1] <= read_data[29:20];
						//set address of next pixel to read
						read_addr <= {y[8:0] + 1, x[9:0]} + 3; 
					end
				6: pixel <= pixel + (95 * pixel_buffer[6]);
				7: pixel <= pixel + (122 * pixel_buffer[7]);
				8: pixel <= pixel + (95 * pixel_buffer[8]);
				default begin
					multiplication_count <= 0;
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
					pixel_load_buffer[2] <= read_data[29:20];
					//set address of next pixel to read
					read_addr <= {y[8:0] - 1 , x[9:0]} + 3; 
					//write blurred grayscale pixel in YCrCb
					write_addr <= {y[8:0], x[9:0]};
					write_data <= {6'b0,pixel[19:10],10'd512,10'd512};

					x <= x + 1; //move to next pixel
					if(x == WIDTH - 1) begin
						x <= 0;
						y <= y + 1; //go to next line
					end
					//if we read the end of the image, stop processing
					if(y == HEIGHT - 1 && x == WIDTH - 1) begin
						go <= 0;
					end
					
					pixel <= 0;
				end
			endcase
		end
		
		if(start) begin
				read_addr <= 0;
				write_addr <= 0;
				x <= 0;
				y <= 0;
				multiplication_count <= 0;
				pixel <= 0;
				go <= 1;
				pixel_buffer[0] <= 0;
				pixel_buffer[1] <= 0;
				pixel_buffer[2] <= 0;
				pixel_buffer[3] <= 0;
				pixel_buffer[4] <= 0;
		end
	end

endmodule
