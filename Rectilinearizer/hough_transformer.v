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
module hough_transform_coordinate(input clk, input start, output done, input data_in);
	reg [9:0] x;
	reg [8:0] y;
	
	reg calculate_start;
	wire calculate_done;
	hough_transform_calculate hough_calculator(.clk(clk),
										.start(calculate_start),
										.done(calculate_done),
										.x(x),
										.y(y));
	
	reg go = 0;
	reg old_go = 0;
	assign done = ~go & old_go;
	reg waiting_calculate = 0;
	always @(posedge clk) begin
			old_go <= go;
			calculate_start <= 0;
			if(go) begin //if we're going
				if(waiting_calculate == 0) begin
					if(data_in == 1) begin
						calculate_start <= 1;
						waiting_calculate <= 1;
					end
					else begin
						x <= x + 1; //increment x
						if(x == 639) begin
							x <= 0;
							y <= y + 1;
							if(y == 479) begin
								go <= 0;
								calculate_start <= 0;
							end
						end
					end
				end
				
				if(calculate_done == 1) begin
					waiting_calculate <= 0; //mark that we are no longer waiting for the calculations
					x <= x + 1; //increment x
					if(x == 639) begin
						x <= 0;
						y <= y + 1;
						if(y == 479) begin
							go <= 0;
							calculate_start <= 0;
						end
					end
				end
			end
			
			if(start) begin //on start
				x <= 0;
				y <= 0;
				go <= 1;
				waiting_calculate <= 0;
			end
	end
	
endmodule

module hough_transform_calculate(input clk, input start, output done, input[9:0] x, input [8:0] y, output start_transmit, output reg [12:0] transmit_r, output reg [7:0] transmit_angle);

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
	wire signed [24:0] r_scaled = (y_sin_theta + (cos_negative ? -x_cos_theta : x_cos_theta));
	
	reg calculate_go; //to mark if we're calculating
	reg transmit_go, transmit_go_old;	//to mark if we're transmitting
	assign start_transmit = transmit_go & ~transmit_go_old; //say that we're beginning sending data
	reg transmit_tick = 0; //so that we only transmit every second cycle
	always @(posedge clk) begin
		old_go <= go;		
		transmit_go_old <= transmit_go;
		if(calculate_go) begin //if we're in the calculating phase
			modify_pointer <= modify_pointer + 1; //move to next calculation
			angle <= angle + 4; //next angle
			modify_r[modify_pointer] <= (r_scaled >>> 12); // store r
			modify_angle[modify_pointer] <= angle; //store angle
			if(modify_pointer == 44) begin //if we reach the last of the 45
				transmit_go <= 1; //start transmittion
				calculate_go <= 0; //stop calculating
				modify_pointer <= 0;
			end
		end
		
		if(transmit_go) begin
			transmit_tick <= transmit_tick + 1;
			if(transmit_tick == 0) begin //every second cycle
				modify_pointer <= modify_pointer + 1;
				transmit_r <= modify_r[modify_pointer];
				transmit_angle <= modify_angle[modify_pointer];
				
				if(modify_pointer == 44) begin //when you;ve finished transmitting
					transmit_go <= 0;
					go <= 0;
				end
			end
		end
		
		if(start) begin
			modify_pointer = 0;
			angle <= 0;
			go <= 1;
			transmit_go <= 0; //don't transmittion
			calculate_go <= 1; //start calculating
		end
	end

endmodule

module hough_transform_find_highest(input clk, input start, output done, output [18:0] addr, input [29:0] read_data, output reg [7:0] highest_angle [3:0], output reg signed [12:0] highest_r [3:0]);
	
	reg signed [10:0] r; // Lower 2 bits actually ignored due to bucketing
	reg [7:0] angle; // Same

   assign read_data = {angle[7:2], radius[10:2]};
	
	reg go, old_go;
	assign done = ~go & old_go;
	
	reg [7:0] highest_angle [3:0];
	reg [12:0] highest_r [3:0];
   reg [29:0] highest_data [3:0];
	
	always @(posedge clk) begin
		old_go <= go;
		
		if(go) begin
			//highest data comparisons
			if(read_data > highest_data[0]) begin
				{highest_angle[0],highest_angle[1],highest_angle[2],highest_angle[3]}
					= {angle,highest_angle[0],highest_angle[1],highest_angle[2]};
            
				{highest_r[0],highest_r[1],highest_r[2],highest_r[3]}
					= {r,highest_r[0],highest_r[1],highest_r[2]};

				{highest_data[0],highest_data[1],highest_data[2],highest_data[3]}
					= {read_data,highest_data[0],highest_data[1],highest_data[2]};
			end
			else begin
				if(read_data > highest_data[1]) begin
					{highest_angle[1],highest_angle[2],highest_angle[3]}
						= {angle,highest_angle[1],highest_angle[2]};

					{highest_r[1],highest_r[2],highest_r[3]}
						= {r,highest_r[1],highest_r[2]};

					{highest_data[1],highest_data[2],highest_data[3]}
						= {read_data,highest_data[1],highest_data[2]};
				end
			end
			else begin
				if(read_data > highest_data[2]) begin
					{highest_angle[2],highest_angle[3]}
						= {angle,highest_angle[2]};

					{highest_r[2],highest_r[3]}
						= {r,highest_r[2]};

					{highest_data[2],highest_data[3]}
						= {read_data,highest_data[2]};
				end		
			end
			else begin
				if(read_angle > highest_angle[3]) begin
					highest_angle[3] = angle;

					highest_r[3] = r;

               highest_data[3] = read_data;
				end		
			end
			
			//move to next angle and r
			angle <= angle + 4;
			if(angle == 176) begin
				angle <= 0;
				r <= r + 4;
				if(r == 800) begin
					r <= -800;
					go <= 0;
				end
			end
		end
		
		if(start) begin
			angle <= 0;
			r <= -800;
			go <= 1;
		end
	end

endmodule
