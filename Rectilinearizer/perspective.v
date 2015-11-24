// Compute the parameters of a perspective transform given input coordinates
// The map takes corners (0, 0), (0, 480), (640, 480), (640, 0) in that order to the input corners 1, 2, 3, 4
// The code here is based on mathematical solutions derived by G. Ajjanagadde, S. Jain, and J. Thomas in Fall 2014,
// but with heavy optimization and refinement over their algorithms.
module compute_parameters(input [9:0] x1_in, x2_in, x3_in, x4_in,
                      input [8:0] y1_in, y2_in, y3_in, y4_in,
                      output signed [41:0] p1, p2, p3, p4, p5, p6, p7, p8, p9);

    // Sign-extend all inputs so that subtractions and multiplications are interpreted correctly
    wire signed [10:0] x1, x2, x3, x4;
    assign x1 = {1'b0, x1_in};
    assign x2 = {1'b0, x2_in};
    assign x3 = {1'b0, x3_in};
    assign x4 = {1'b0, x4_in};
    
    wire signed [9:0] y1, y2, y3, y4;
    assign y1 = {1'b0, y1_in};
    assign y2 = {1'b0, y2_in};
    assign y3 = {1'b0, y3_in};
    assign y4 = {1'b0, y4_in};
    
    // Common subtractions
    // The order of the operands is not always index order - it's based on the frequency with which we will need these computations in a given order
    wire signed [10:0] x1minusx2, x1minusx4, x3minusx2, x4minusx3;
    assign x1minusx2 = x1 - x2;
    assign x1minusx4 = x1 - x4;
    assign x3minusx2 = x3 - x2;
    assign x4minusx3 = x4 - x3;
    
    wire signed [9:0] y1minusy2, y1minusy4, y2minusy3, y3minusy4, y4minusy2;
    assign y1minusy2 = y1 - y2;
    assign y1minusy4 = y1 - y4;
    assign y2minusy3 = y2 - y3;
    assign y3minusy4 = y3 - y4;
    assign y4minusy2 = y4 - y2;  
    
    // This is an expression which is used in the computation of 7 of the 9 parameters
    // Constant 1920 is used in 3 of them, and is due to the known choices of the preimage four corners
    // We actually don't lose fidelity with common here, because its maximum magnitude and all intermediate computations
    //   are also bounded by 2^20
    // This requires a mathematical proof, not shown here
    wire signed [20:0] common_scratch1, common_scratch2, common_scratch3, common, negcommon;
    wire signed [31:0] commontimes1920;
    assign common_scratch1 = x4 * y2minusy3;
    assign common_scratch2 = x2 * y3minusy4;
    assign common_scratch3 = x3 * y4minusy2;
    
    assign common = common_scratch1 + common_scratch2 + common_scratch3;
    assign negcommon = -common; // Doing this here may save some negating circuitry in p1, p2, p4, p5 calculations
    assign commontimes1920 = (common << 11) - (common << 7);
    
    // Compute p3, p6, p9 first - they are quick computations given commontimes1920
    assign p3 = commontimes1920 * x1; // p3 max length 42
    assign p6 = commontimes1920 * y1; // p6 max length 41
    assign p9 = commontimes1920; // p9 max length 32
    
    // Compute p7, p8 next - they are needed for the remaining four
    wire signed [19:0] p7_scratch1, p7_scratch2, p8_scratch1, p8_scratch2;
    assign p7_scratch1 = x1minusx4 * y2minusy3;
    assign p7_scratch2 = x3minusx2 * y1minusy4;
    assign p7 = p7_scratch1 + (p7_scratch1 << 1) + p7_scratch2 + (p7_scratch2 << 1); // p7 max length 23
    
    assign p8_scratch1 = x1minusx2 * y3minusy4;
    assign p8_scratch2 = x4minusx3 * y1minusy2;
    assign p8 = (p8_scratch1 << 2) + (p8_scratch2 << 2); // p8 max length 23
    
    // Compute p1, p2, p4, p5 using p7, p8
    wire signed [34:0] p1_scratch1, p2_scratch1;
    wire signed [33:0] p4_scratch1, p5_scratch1;
    wire signed [31:0] p1_scratch2, p2_scratch2, p4_scratch2, p5_scratch2;
    assign p1_scratch1 = x4 * p7;
    assign p1_scratch2 = x1minusx4 * negcommon;
    assign p1 = p1_scratch1 + p1_scratch2 + (p1_scratch2 << 1); // p1 max length 36
    
    assign p2_scratch1 = x2 * p8;
    assign p2_scratch2 = x1minusx2 * negcommon;
    assign p2 = p2_scratch1 + (p2_scratch2 << 2); // p2 max length 36
    
    assign p4_scratch1 = y4 * p7;
    assign p4_scratch2 = y1minusy4 * negcommon;
    assign p4 = p4_scratch1 + p4_scratch2 + (p4_scratch2 << 1); // p4 max length 35
    
    assign p5_scratch1 = y2 * p8;
    assign p5_scratch2 = y1minusy2 * negcommon;
    assign p5 = p5_scratch1 + (p5_scratch2 << 2); // p5 max length 35
    
endmodule

//////////////////// STAFF PROVIDED MODULE
// The divider module divides one number by another. It
// produces a signal named "ready" when the quotient output
// is ready, and takes a signal named "start" to indicate
// the the input dividend and divider is ready.
// sign -- 0 for unsigned, 1 for twos complement

// It uses a simple restoring divide algorithm.
// http://en.wikipedia.org/wiki/Division_(digital)#Restoring_division

module divider #(parameter WIDTH = 8) 
  (input clk, sign, start,
   input [WIDTH-1:0] dividend, 
   input [WIDTH-1:0] divider,
   output reg [WIDTH-1:0] quotient,
   output [WIDTH-1:0] remainder,
   output ready);

   reg [WIDTH-1:0]  quotient_temp;
   reg [WIDTH*2-1:0] dividend_copy, divider_copy, diff;
   reg negative_output;
   
   assign remainder = (!negative_output) ?
             dividend_copy[WIDTH-1:0] : ~dividend_copy[WIDTH-1:0] + 1'b1;

   reg [5:0] bit;
   reg del_ready = 1;
   assign ready = (!bit) & ~del_ready;

   wire [WIDTH-2:0] zeros = 0;
   initial bit = 0;
   initial negative_output = 0;
   always @( posedge clk ) begin
      del_ready <= !bit;
      if( start ) begin

         bit = WIDTH;
         quotient = 0;
         quotient_temp = 0;
         dividend_copy = (!sign || !dividend[WIDTH-1]) ?
                         {1'b0,zeros,dividend} :  
                         {1'b0,zeros,~dividend + 1'b1};
         divider_copy = (!sign || !divider[WIDTH-1]) ?
			 {1'b0,divider,zeros} :
			 {1'b0,~divider + 1'b1,zeros};

         negative_output = sign &&
                           ((divider[WIDTH-1] && !dividend[WIDTH-1])
                            ||(!divider[WIDTH-1] && dividend[WIDTH-1]));
       end
      else if ( bit > 0 ) begin
         diff = dividend_copy - divider_copy;
         quotient_temp = quotient_temp << 1;
         if( !diff[WIDTH*2-1] ) begin
            dividend_copy = diff;
            quotient_temp[0] = 1'd1;
         end
         quotient = (!negative_output) ?
                    quotient_temp :
                    ~quotient_temp + 1'b1;
         divider_copy = divider_copy >> 1;
         bit = bit - 1'b1;
      end
   end
endmodule
////////////////// END STAFF PROVIDED MODULE


module pixel_transform (input clk, 
                         input start,
                         input signed [41:0] p1, p2, p3, p4, p5, p6, p7, p8, p9,
                         input [35:0] source_data,
                         output reg [18:0] source_addr, 
                         output [18:0] dest_addr,
                         output [35:0] dest_data,
                         output dest_we,
                         output reg done);
   
   // Coordinates of the pixel we're currently mapping
   reg [9:0] x;
   reg [8:0] y;
   
   // State registers - wait counters and overall state
   reg [9:0] div_delay;
   reg state;
   
   parameter STATE_READY = 1'b0;
   parameter STATE_WAIT_DIV = 1'b1;
   
   // Avoid multiplying to generate the components based on p1, p4, p7
   reg signed [46:0] p1_component, p4_component, p7_component;
   
   // Avoid multiplying to generate the components based on p2, p3, p5, p6, p8, p9
   reg signed [45:0] p2p3_component, p5p6_component, p8p9_component;
   
   wire signed [47:0] numer1, numer2, denom;
   assign numer1 = p1_component + p2p3_component;
   assign numer2 = p4_component + p5p6_component;
   assign denom = p7_component + p8p9_component;
   
   // initialize signed dividers
   // We give these the fast clock, so we have to wait fewer slow-clock cycles
   reg divstart;
   wire div1ready, div2ready;
   wire [47:0] dummy1, dummy2; // remainder not used
   wire [47:0] quotient1, quotient2;
   divider #(.WIDTH(48)) divider1  // x-coordinate
                    (.dividend(numer1), 
                    .divider(denom), 
                    .quotient(quotient1),
                    .start(divstart),
                    .ready(div1ready),
                    .remainder(dummy1),
                    .sign(1'b1),
                    .clk(clk));
                    
   divider #(.WIDTH(48)) divider2  // y-coordinate
                    (.dividend(numer2), 
                    .divider(denom), 
                    .quotient(quotient2),
                    .start(divstart),
                    .ready(div2ready),
                    .remainder(dummy2),
                    .sign(1'b1),
                    .clk(clk));
                    
   // Wire the source memory data to the destination memory data
   // Need to delay the write enable and dest address signals by 2 cycles
   // Cycle 0: Supply source address, dest write enable, dest write address
   // Cycle 1: Source memory is fetching, dest signals are in delay pipeline
   // Cycle 2: Source memory fetched, dest signals + source data supplied to dest memory
   reg [18:0] dest_addr_delay;
   reg dest_we_delay;
   reg [37:0] dest_addr_pipe;
   reg [1:0] dest_we_pipe;
   assign dest_addr = dest_addr_pipe[37:19];
   assign dest_we = dest_we_pipe[1];
   always @(posedge clk) begin
       dest_addr_pipe <= {dest_addr_pipe[18:0], dest_addr_delay};
       dest_we_pipe <= {dest_we_pipe[0], dest_we_delay};
   end
   assign dest_data = source_data; // Due to how we're handling these signals
   
   // Source address is based on quotients
   // addr = x + 1024y
   wire [18:0] source_addr_next;
   assign source_addr_next = {quotient2[8:0], quotient1[9:0]};

   // This module needs to operate on a slow clock due to large-width arithmetic
   // Reduce the clock speed to 1/4 of the original
   reg [1:0] counter;
   initial begin
      counter <= 0;
   end
   always @(posedge clk) begin
      if (counter == 3) begin
         counter <= 0;
      end
      else counter <= counter + 1;
   end
   
   reg start_slow; // Used to synchronize start with the slow clock, to ensure a full slow-clock cycle to compute initial values
                    
   initial begin
      done = 0;
   end
   
   always @(posedge clk) begin
      if (counter == 0) begin // Simulate a slow clock
         if (start_slow == 1 || start == 1) begin
            start_slow <= 0;
            x <= 0;
            y <= 0;
            p1_component <= 0;
            p4_component <= 0;
            p7_component <= 0;
            p2p3_component <= p3;
            p5p6_component <= p6;
            p8p9_component <= p9;
            dest_addr_delay <= 0;
            dest_we_delay <= 0;
            done <= 0;
            
            state <= STATE_READY;
         end
         else if (y < 480) begin
            if (state == STATE_READY) begin
               divstart <= 1;
               state <= STATE_WAIT_DIV;
               div_delay <= 100; // This should be enough for restoring divide algorithms
            end
            else if (state == STATE_WAIT_DIV) begin
               if (div_delay > 0) begin
                  div_delay <= div_delay - 1;
               end
               else begin // Division is done
                  dest_we_delay <= 1;
                  source_addr <= source_addr_next;
                  state <= STATE_READY;
                  dest_addr_delay <= {y, x};
                  if (x == 639) begin
                     p1_component <= 0;
                     p4_component <= 0;
                     p7_component <= 0;
                     x <= 0;
                     y <= y+1;
                     p2p3_component <= p2p3_component + p2;
                     p5p6_component <= p5p6_component + p5;
                     p8p9_component <= p8p9_component + p8;
                  end
                  else begin
                     p1_component <= p1_component + p1;
                     p4_component <= p4_component + p4;
                     p7_component <= p7_component + p7;
                     x <= x+1;
                  end
               end
            end
         end
         else begin
            done <= 1;
         end
      end
      // Memories will use the fast clock, so we ensure that the write-enable
      // is only high for one fast clock cycle
      // Same for division enable
      // Lastly, synchronize the start signal so we can pulse it for one fast clock cycle
      // but it will only actually start on the next slow clock rising edge
      else begin
         if (dest_we_delay == 1) dest_we_delay <= 0;
         if (divstart == 1) divstart <= 0;
         if (start == 1) start_slow <= 1;
      end
      
   end
   

endmodule
                         
