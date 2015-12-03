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
      if (reset_addr + 1 == 0) begin
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



