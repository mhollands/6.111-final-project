module ycrcb2rgb(
	input unsigned [9:0] y, 
   input signed [9:0] cr, cb,
	output reg [7:0] r, g, b);
	
   // Absolute-value parameters from the RGB -> YCrCb transformation matrix
   // Left-shifted 6 bits so we can perform fixed point arithmetic
	parameter M13 = 8'b01001001;
	parameter M22 = 8'b00011001;
	parameter M23 = 8'b00100101;
	parameter M32 = 8'b10000010;
   
   // Intermediate scratch reg for g computation
   reg [9:0] g1;
   // Intermediate values regs to force computation on the upper bits
   // of the multiplications
   reg [17:0] inter1;
   reg [17:0] inter2;
   reg [17:0] inter3;
   reg [17:0] inter4;
   
   // Compute R
   always @(*) begin
      if (cb < 0) begin
         $display("testr");
         inter1 = $unsigned(M13) * $unsigned(-cb);
         r = y - (inter1 >> 6);
      end
      else begin
         inter1 = $unsigned(M13) * $unsigned(cb);
         r = y + (inter1 >> 6);
      end
   end

   // Compute G
   always @(*) begin
      if (cr < 0) begin 
         $display("testg");
         inter2 = $unsigned(M22) * $unsigned(-cr);
         g1 = y + (inter2 >> 6);
      end
      else begin
         inter2 = $unsigned(M22) * $unsigned(cr);
         g1 = y - (inter2 >> 6);
      end
      
      if (cb < 0) begin
         $display("testg2");
         inter3 = $unsigned(M23) * $unsigned(-cb);
         g = g1 + (inter3 >> 6);
      end
      else begin
         $display("blahg2");
         inter3 = $unsigned(M23) * $unsigned(cb);
         g = g1 - (inter3 >> 6);
      end
   end
   
   // Compute B
   always @(*) begin
      if (cr < 0) begin 
         $display("testb");
         inter4 = $unsigned(M32) * $unsigned(-cr);
         b = y - (inter4 >> 6);
      end
      else begin
         inter4 = $unsigned(M32) * $unsigned(cr);
         b = y + (inter4 >> 6);
      end
   end

endmodule
