//
// File:   ntsc2zbt.v
// Date:   27-Nov-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Example for MIT 6.111 labkit showing how to prepare NTSC data
// (from Javier's decoder) to be loaded into the ZBT RAM for video
// display.
//
// The ZBT memory is 36 bits wide; we only use 32 bits of this, to
// store 4 bytes of black-and-white intensity data from the NTSC
// video input.
//
// Bug fix: Jonathan P. Mailoa <jpmailoa@mit.edu>
// Date   : 11-May-09  // gph mod 11/3/2011
//
// 
// Bug due to memory management will be fixed. It happens because
// the memory addressing protocol is off between ntsc2zbt.v and
// vram_display.v. There are 2 solutions:
// -. Fix the memory addressing in this module (neat addressing protocol)
//    and do memory forecast in vram_display module.
// -. Do nothing in this module and do memory forecast in vram_display
//    module (different forecast count) while cutting off reading from 
//    address(0,0,0).
//
// Bug in this module causes 4 pixel on the rightmost side of the camera
// to be stored in the address that belongs to the leftmost side of the 
// screen.
// 
// In this example, the second method is used. NOTICE will be provided
// on the crucial source of the bug.
//
/////////////////////////////////////////////////////////////////////////////
// Prepare data and address values to fill ZBT memory with NTSC data

module ntsc_to_zbt(clk, vclk, fvh, dv, din, ntsc_addr, ntsc_data, ntsc_we);

   input 	 clk;	// system clock
   input 	 vclk;	// video clock from camera
   input [2:0] 	 fvh;
   input 	 dv;
   input [29:0] 	 din;
   output [18:0] ntsc_addr;
   output [35:0] ntsc_data;
   output 	 ntsc_we;	// write enable for NTSC data

   parameter 	 COL_START = 10'd0;
   parameter 	 ROW_START = 10'd0;

   // here put the luminance data from the ntsc decoder into the ram
   // this is for 1024 * 788 XGA display

   reg [9:0] 	 col = 0;
   reg [9:0] 	 row = 0;
   reg [29:0] 	 vdata = 0;
   reg 		 vwe;
   reg 		 old_dv;
   reg 		 old_frame;	// frames are even / odd interlaced
   reg 		 even_odd;	// decode interlaced frame to this wire
   
   wire 	 frame = fvh[2];
   wire 	 frame_edge = frame & ~old_frame;

   always @ (posedge vclk) //LLC1 is reference
     begin
	old_dv <= dv;
	vwe <= dv && !fvh[2] & ~old_dv; // if data valid, write it
	old_frame <= frame; //used to detect frame edge
	//on frame edge, flip even_odd
	even_odd = frame_edge ? ~even_odd : even_odd;

	if (!fvh[2])
	  begin
	     col <= fvh[0] ? COL_START :
		    (!fvh[2] && !fvh[1] && dv && (col < 640)) ? col + 1 : col;
	     row <= fvh[1] ? ROW_START : 
		    (!fvh[2] && fvh[0] && (row < 480)) ? row + 1 : row;
	     vdata <= (dv && !fvh[2]) ? din : vdata;
	  end
     end

   // synchronize with system clock

   reg [9:0] x[1:0],y[1:0];
   reg [29:0] data[1:0];
   reg       we[1:0];
   reg 	     eo[1:0];

	//delay x,y,data,we,eo by 2 clock cycles
   always @(posedge clk)
     begin
			{x[1],x[0]} <= {x[0],col};
			{y[1],y[0]} <= {y[0],row};
			{data[1],data[0]} <= {data[0],vdata};
			{we[1],we[0]} <= {we[0],vwe};
			{eo[1],eo[0]} <= {eo[0],even_odd};
     end

   // edge detection on write enable signal
   reg old_we;
   wire we_edge = we[1] & ~old_we;
   always @(posedge clk) old_we <= we[1];
   
   reg [39:0] x_delay;
   reg [39:0] y_delay;
   reg [3:0] we_delay;
   reg [3:0] eo_delay;
   
   always @ (posedge clk)
   begin
     x_delay <= {x_delay[29:0], x[1]};
     y_delay <= {y_delay[29:0], y[1]};
     we_delay <= {we_delay[2:0], we[1]};
     eo_delay <= {eo_delay[2:0], eo[1]};
   end
   
   // compute address to store data in
   wire [8:0] y_addr = y_delay[38:30];
	wire [9:0] x_addr = x_delay[39:30];
   wire [18:0] myaddr = {y_addr[7:0], eo_delay[3], x_addr[9:0]};
   
	reg [18:0] ntsc_addr;
	reg [35:0] ntsc_data;
	wire ntsc_we;
	
	assign ntsc_we = we_delay[3];
   always @(posedge clk)
     if ( ntsc_we )
       begin
			ntsc_addr <= myaddr;
			ntsc_data <= {5'b0, data[1]};
       end
   
endmodule // ntsc_to_zbt
