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
module hough_transform_coordinate(input clk, input reset_memory, output reset_memory_done, input start, output done, input bram_data_in, output reg [18:0] bram_addr, input [35:0] vram_read_data, output [18:0] vram_addr, output [35:0] vram_write_data, output vram_we);
	reg [9:0] x;
	reg [8:0] y;
	
	reg calculate_start;
	wire calculate_done;
	wire transmit_start;
	wire [7:0] transmit_angle;
	wire [12:0] transmit_r;
	hough_transform_calculate hough_calculator(.clk(clk),
										.start(calculate_start),
										.done(calculate_done),
										.x(x),
										.y(y),
										.start_transmit(transmit_start),
										.transmit_angle(transmit_angle),
										.transmit_r(transmit_r));

	wire mem_done;
	assign reset_memory_done = mem_done;

	hough_mem hm(.clk(clk), 
				 .start(transmit_start), // Pulse when data ready on inputs for next 90 clock cycles
				 .reset(reset_memory), // Initialize ZBT to 0
				 .angle(transmit_angle), // Angle 0 to 180, lower 2 bits ignored
				 .radius(transmit_r), // Radius -800 to 800, lower 2 bits ignored
				 .mem_read_data(vram_read_data),
				 .mem_addr(vram_addr), // 14 bit address {angle[7:2], radius[9:2]}
				 .mem_write_data(vram_write_data),
				 .mem_we(vram_we),
				 .done(mem_done));
	
	
	reg go = 0;
	reg old_go = 0;
	assign done = ~go & old_go;
	reg waiting_calculate = 0;
	always @(posedge clk) begin
			old_go <= go;
			calculate_start <= 0;
			if(go) begin //if we're going
				if(waiting_calculate == 0) begin
					if(bram_data_in == 1) begin
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
				bram_addr <= {y[8:0], x[9:0]};
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
			modify_pointer <= 0;
			angle <= 0;
			go <= 1;
			transmit_go <= 0; //don't transmittion
			calculate_go <= 1; //start calculating
		end
	end

endmodule

module hough_transform_find_highest(input clk, input start, output done, output [18:0] addr, input [35:0] read_data, output reg [7:0] highest_angle0, highest_angle1, highest_angle2, highest_angle3, output reg signed [12:0] highest_r0,highest_r1,highest_r2,highest_r3);
	
	reg signed [10:0] r; // Lower 2 bits actually ignored due to bucketing
	reg [7:0] angle; // Same

   assign addr = {angle[7:2], r[10:2]};
	
	reg go, old_go;
	assign done = ~go & old_go;
	
   reg [35:0] highest_data [3:0];
	
	initial begin
		highest_angle0 = 0;
		highest_angle1 = 0;
		highest_angle2 = 0;
		highest_angle3 = 0;
		highest_r0 = 0;
		highest_r1 = 0;
		highest_r2 = 0;
		highest_r3 = 0;
	end
	
	always @(posedge clk) begin
		old_go <= go;
		
		if(go) begin
			//highest data comparisons
			if(read_data > highest_data[0]) begin
				{highest_angle0,highest_angle1,highest_angle2,highest_angle3}
					<= {angle,highest_angle0,highest_angle1,highest_angle2};
            
				{highest_r0,highest_r1,highest_r2,highest_r3}
					<= {r,highest_r0,highest_r1,highest_r2};

				{highest_data[0],highest_data[1],highest_data[2],highest_data[3]}
					<= {read_data,highest_data[0],highest_data[1],highest_data[2]};
			end
			else begin
				if(read_data > highest_data[1]) begin
					{highest_angle1,highest_angle2,highest_angle3}
						<= {angle,highest_angle1,highest_angle2};

					{highest_r1,highest_r2,highest_r3}
						<= {r,highest_r1,highest_r2};

					{highest_data[1],highest_data[2],highest_data[3]}
						<= {read_data,highest_data[1],highest_data[2]};
				end
				else begin
					if(read_data > highest_data[2]) begin
						{highest_angle2,highest_angle3}
							<= {angle,highest_angle2};

						{highest_r2,highest_r3}
							<= {r,highest_r2};

						{highest_data[2],highest_data[3]}
							<= {read_data,highest_data[2]};
					end	
					else begin
						if(read_data > highest_data[3]) begin
							highest_angle3 <= angle;

							highest_r3 <= r;

							highest_data[3] <= read_data;
						end					
					end
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
			highest_data[3] <= 0;
			highest_data[2] <= 0;
			highest_data[1] <= 0;
			highest_data[0] <= 0;
			highest_angle0 <= 0;
			highest_angle1 <= 0;
			highest_angle2 <= 0;
			highest_angle3 <= 0;
			highest_r0 <= 0;
			highest_r1 <= 0;
			highest_r2 <= 0;
			highest_r3 <= 0;
		end
	end

endmodule

module hough_mem(input clk, 
                 input start, // Pulse when data ready on inputs for next 90 clock cycles
                 input reset, // Initialize ZBT to 0
                 input [7:0] angle, // Angle 0 to 180, lower 2 bits ignored
                 input [10:0] radius, // Radius -800 to 800, lower 2 bits ignored
                 input [35:0] mem_read_data,
                 output reg [18:0] mem_addr, // 14 bit address {angle[7:2], radius[9:2]}
                 output reg [35:0] mem_write_data,
                 output reg mem_we,
                 output reg done);

reg [2:0] state;

parameter STATE_READY = 3'b000;
parameter STATE_RESET = 3'b001;
parameter STATE_UPDATE = 3'b010;
parameter STATE_DONE = 3'b011;

parameter ANGLE_BITS = 6;
parameter RADIUS_BITS = 9;
parameter ADDR_BITS = ANGLE_BITS + RADIUS_BITS;

reg [ADDR_BITS-1:0] reset_addr; // Counter for the memory address that's being reset to 0

reg [6:0] update_counter; // Counter for update cycle

wire [ADDR_BITS-1:0] input_addr;
assign input_addr = {angle[7:2], radius[10:2]};
reg [3*ADDR_BITS-1:0] input_addr_pipe; // Store the data for 3 clock cycles so it can be reused
always @(posedge clk) begin
   input_addr_pipe <= {input_addr_pipe[2*ADDR_BITS-1:0], input_addr};
end

initial begin
   done <= 0;
end


always @(posedge clk) begin
   if (reset == 1) begin
      reset_addr <= 0;
      state <= STATE_RESET;
      done <= 0;
   end
   else if (start == 1) begin
      state <= STATE_UPDATE;
      update_counter <= 0;
      mem_we <= 0;
      done <= 0;
   end
   else if (state == STATE_DONE) begin
      state <= STATE_READY;
      done <= 0;
   end
   else if (state == STATE_RESET) begin
      mem_addr <= reset_addr;
      mem_we <= 1;
      mem_write_data <= 0;
      reset_addr <= reset_addr + 1;
      if (reset_addr == 15'b111111111111111) begin
         state <= STATE_DONE;
         done <= 1;
      end
   end
   else if (state == STATE_UPDATE) begin
      if (update_counter[0] == 0) begin // Even cycle: new data arrived
         mem_addr <= input_addr;
         mem_we <= 0;
      end

      if (update_counter[0] == 1 & update_counter > 2) begin // Odd cycle: Read completed
         mem_addr <= input_addr_pipe[3*ADDR_BITS-1:2*ADDR_BITS]; // Old address
         mem_we <= 1;
         mem_write_data <= mem_read_data+1;
      end

      if (update_counter == 94) begin
         state <= STATE_DONE;
         done <= 1;
      end

      update_counter <= update_counter + 1;
   end
end
   
endmodule


// Edge 0: Data 1 arrives, Read 1 setup
// Edge 1: Read 1 begins
// Edge 2: Data 2 arrives, Read 2 setup
// Edge 3: Read 2 begins, Read 1 completed, Write 1 setup
// Edge 4: Data 3 arrives, Read 3 setup, Write 1 begins
// Edge 5: Read 3 begins, Read 2 completed, Write 2 setup
// Edge 6: Data 4 arrives, Read 4 setup, Write 2 begins
// ...
// Edge 88: Data 45 arrives, Read 45 setup, Write 43 begins
// Edge 89: Read 45 begins, Read 44 completes, Write 44 setup
// Edge 90: Write 44 begins
// Edge 91: Read 45 completes, Write 45 setup
// Edge 92: Write 45 begins
// Edge 93: n/a
// Edge 94: Set up done signal.
