//
// File:   zbt_6111_sample.v
// Date:   26-Nov-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Sample code for the MIT 6.111 labkit demonstrating use of the ZBT
// memories for video display.  Video input from the NTSC digitizer is
// displayed within an XGA 1024x768 window.  One ZBT memory (ram0) is used
// as the video frame buffer, with 8 bits used per pixel (black & white).
//
// Since the ZBT is read once for every four pixels, this frees up time for 
// data to be stored to the ZBT during other pixel times.  The NTSC decoder
// runs at 27 MHz, whereas the XGA runs at 65 MHz, so we synchronize
// signals between the two (see ntsc2zbt.v) and let the NTSC data be
// stored to ZBT memory whenever it is available, during cycles when
// pixel reads are not being performed.
//
// We use a very simple ZBT interface, which does not involve any clock
// generation or hiding of the pipelining.  See zbt_6111.v for more info.
//
// switch[7] selects between display of NTSC video and test bars
// switch[6] is used for testing the NTSC decoder
// switch[1] selects between test bar periods; these are stored to ZBT
//           during blanking periods
// switch[0] selects vertical test bars (hardwired; not stored in ZBT)
//
//
// Bug fix: Jonathan P. Mailoa <jpmailoa@mit.edu>
// Date   : 11-May-09
//
// Use ramclock module to deskew clocks;  GPH
// To change display from 1024*787 to 800*600, use clock_40mhz and change
// accordingly. Verilog ntsc2zbt.v will also need changes to change resolution.
//
// Date   : 10-Nov-11

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2011-Nov-10: Changed resolution to 1024 * 768.
//					 Added back ramclok to deskew RAM clock
//
// 2009-May-11: Fixed memory management bug by 8 clock cycle forecast. 
//              Changed resolution to  800 * 600.
//              Reduced clock speed to 40MHz.
//              Disconnected zbt_6111's ram_clk signal. 
//              Added ramclock to control RAM.
//              Added notes about ram1 default values.
//              Commented out clock_feedback_out assignment.
//              Removed delayN modules because ZBT's latency has no more effect.
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module main(beep, audio_reset_b, 
		       ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
/*
*/
   // ac97_sdata_in is an input

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   //assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b1;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b1;
   //assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = clock_27mhz;//1'b0;
   //assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs

/* change lines below to enable ZBT RAM bank0 */

/*
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_clk = 1'b0;
   assign ram0_we_b = 1'b1;
   assign ram0_cen_b = 1'b0;	// clock enable
*/

/* enable RAM pins */

   assign ram0_ce_b = 1'b0;
   assign ram0_oe_b = 1'b0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_bwe_b = 4'h0; 

/**********/
   
   //These values has to be set to 0 like ram0 if ram1 is used.
   assign ram1_ce_b = 1'b0;
   assign ram1_oe_b = 1'b0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_bwe_b = 4'h0; 

   // clock_feedback_out will be assigned by ramclock
   // assign clock_feedback_out = 1'b0;  //2011-Nov-10
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
/*
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
*/
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   //lab3 assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;
			    
   ////////////////////////////////////////////////////////////////////////////
   // Demonstration of ZBT RAM as video memory

   // use FPGA's digital clock manager to produce a
   // 65MHz clock (actually 64.8MHz)
   wire clock_65mhz_unbuf,clock_65mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));

//   wire clk = clock_65mhz;  // gph 2011-Nov-10

/*   ////////////////////////////////////////////////////////////////////////////
   // Demonstration of ZBT RAM as video memory

   // use FPGA's digital clock manager to produce a
   // 40MHz clock (actually 40.5MHz)
   wire clock_40mhz_unbuf,clock_40mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_40mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 2
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 3
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_40mhz),.I(clock_40mhz_unbuf));

   wire clk = clock_40mhz;
*/
	wire locked;
	//assign clock_feedback_out = 0; // gph 2011-Nov-10
   
   ramclock rc(.ref_clock(clock_65mhz), .fpga_clock(clk),
					.ram0_clock(ram0_clk), 
					.ram1_clock(ram1_clk),
					.clock_feedback_in(clock_feedback_in),
					.clock_feedback_out(clock_feedback_out), .locked(locked));

   
   // power-on reset generation
   wire power_on_reset;    // remain high for first 16 clocks
   SRL16 reset_sr (.D(1'b0), .CLK(clk), .Q(power_on_reset),
		   .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;

   // ENTER button is user reset
   wire reset,user_reset;
   debounce db1(power_on_reset, clk, 1'b0, user_reset);
   assign reset = user_reset | power_on_reset;
   
   wire db_enter;
   debounce debounce_enter(power_on_reset, clk, button_enter, db_enter);

   // display module for debugging
   reg [63:0] dispdata;
   display_16hex hexdisp1(reset, clk, dispdata,
			  disp_blank, disp_clock, disp_rs, disp_ce_b,
			  disp_reset_b, disp_data_out);

   // generate basic XVGA video signals
   wire [10:0] hcount;
   wire [9:0]  vcount;
   wire hsync,vsync,blank;
   xvga xvga1(clk,hcount,vcount,hsync,vsync,blank);

	//set up the main fsm
	wire hough_count_start;
	wire hough_count_done;
	wire hough_start;
	wire hough_done;
	wire hough_memory_clear_start;
	wire hough_memory_clear_done;
	wire lines_to_corners_start;
	wire lines_to_corners_done;
	wire set_corners;
	wire blur_start;
	wire blur_done;
	wire edge_detector_done;
	wire edge_detector_start;
	wire [4:0] fsm_state;
	main_fsm fsm (.clk(clk), 
                 .button_enter(~db_enter), 
                 .switch(switch[7]),
						.skip(switch[6]),
                 .pixel_transform_done(pixel_transform_done), 
                 .state(fsm_state),
                 .pixel_transform_start(pixel_transform_start),
                 .set_corners(set_corners),
					  .blur_start(blur_start),
					  .blur_done(blur_done),
					  .edge_detection_done(edge_detector_done),
					  .edge_detection_start(edge_detector_start),
					  .L2C_start(lines_to_corners_start),
					  .L2C_done(lines_to_corners_done),
					  .hough_mem_clear_start(hough_mem_clear_start),
					  .hough_mem_clear_done(hough_mem_clear_done),
					  .hough_start(hough_start),
					  .hough_done(hough_done),
					  .hough_count_start(hough_count_start),
					  .hough_count_done(hough_count_done));
                 
  // Copy of FSM state list
	  parameter VIEW_FINDER = 5'b00000;
	  parameter BLUR_START = 5'b00011;
	  parameter BLUR_WAIT = 5'b00100;
	  parameter SHOW_BLUR = 5'b00101;
	  parameter EDGE_DETECTOR_START = 5'b00110;
	  parameter EDGE_DETECTOR_WAIT = 5'b00111;
	  parameter SHOW_EDGE_DETECTOR = 5'b01000;
	  parameter HOUGH_MEM_CLEAR_START = 5'b10101;
	  parameter HOUGH_MEM_CLEAR_WAIT = 5'b10110;
	  parameter HOUGH_START = 5'b01001;
	  parameter HOUGH_WAIT = 5'b01010;
	  parameter HOUGH_COUNT_START = 5'b10111;
	  parameter HOUGH_COUNT_WAIT = 5'b11000;
	  parameter SHOW_HOUGH = 5'b01011;
	  parameter L2C_START = 5'b10011;
	  parameter L2C_WAIT = 5'b10100;
	  parameter MANUAL_DETECTION_START = 5'b01100;
	  parameter MANUAL_DETECTION_WAIT = 5'b01101;
     parameter COMPUTE_PARAM_START = 5'b01110;
     parameter COMPUTE_PARAM_WAIT = 5'b01111;
     parameter PIXEL_TRANSFORM_START = 5'b10000;
     parameter PIXEL_TRANSFORM_WAIT = 5'b10001;
     parameter SHOW_TRANSFORMED = 5'b10010;

	//wire up to BRAM
	reg [18:0] bram_addr;
	reg bram_write_enable;
	reg bram_mem_in;
	wire bram_mem_out;
	mybram #(.LOGSIZE(19),.WIDTH(1)) bram(.addr(bram_addr),.clk(clk),.we(bram_write_enable),.din(bram_mem_in),.dout(bram_mem_out));

   // wire up to ZBT ram
   reg [35:0] ram0_write_data_mux, ram1_write_data_mux;
   wire [35:0] ram0_read_data, ram1_read_data;
   reg [18:0] ram0_addr_mux, ram1_addr_mux;
   reg ram0_we_mux, ram1_we_mux;

   wire ram0_clk_not_used, ram1_clk_not_used;
   zbt_6111 zbt0(clk, 1'b1, ram0_we_mux, ram0_addr_mux,
		   ram0_write_data_mux, ram0_read_data,
		   ram0_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
		   ram0_we_b, ram0_address, ram0_data, ram0_cen_b);
   
   zbt_6111 zbt1(clk, 1'b1, ram1_we_mux, ram1_addr_mux,
      ram1_write_data_mux, ram1_read_data,
      ram1_clk_not_used,   //to get good timing, don't connect ram_clk to zbt_6111
      ram1_we_b, ram1_address, ram1_data, ram1_cen_b);

   // generate pixel value from reading ZBT memory
   wire [29:0] vram_pixel;
   wire [18:0] vga_addr;
   reg [35:0] vga_data;
   vram_display #(192,144) vd1(reset,clk,hcount,vcount,vram_pixel,
		    vga_addr, vga_data);

	// generate pixel value from reading bram memory
   wire [29:0] 	bram_pixel;
   wire [18:0] 	bram_display_addr;
	reg bram_display_read_data;
   bram_display #(192,144) bd1(.reset(reset),
											.clk(clk),
											.hcount(hcount),
											.vcount(vcount),
											.br_pixel(bram_pixel),
											.bram_addr(bram_display_addr),
											.bram_read_data(bram_display_read_data));

   // ADV7185 NTSC decoder interface code
   // adv7185 initialization module
   adv7185init adv7185(.reset(reset), .clock_27mhz(clock_27mhz), 
		       .source(1'b0), .tv_in_reset_b(tv_in_reset_b), 
		       .tv_in_i2c_clock(tv_in_i2c_clock), 
		       .tv_in_i2c_data(tv_in_i2c_data));

   wire [29:0] ycrcb;	// video data (luminance, chrominance)
   wire [2:0] fvh;	// sync for field, vertical, horizontal
   wire       dv;	// data valid
   
   ntsc_decode decode (.clk(tv_in_line_clock1), .reset(reset),
		       .tv_in_ycrcb(tv_in_ycrcb[19:10]), 
		       .ycrcb(ycrcb), .f(fvh[2]),
		       .v(fvh[1]), .h(fvh[0]), .data_valid(dv));

   // code to write NTSC data to video memory
   wire [18:0] ntsc_addr;
   wire [35:0] ntsc_data;
   wire ntsc_we;
   ntsc_to_zbt n2z (clk, tv_in_line_clock1, fvh, dv, ycrcb[29:0],
		    ntsc_addr, ntsc_data, ntsc_we);

	//Wire Corners From Lines Module
	wire [7:0] line0_theta,line1_theta,line2_theta,line3_theta;
	wire signed [10:0] line0_r, line1_r, line2_r, line3_r;
	wire [9:0] auto_corner0x, auto_corner1x,auto_corner2x,auto_corner3x;
	wire [9:0] auto_corner0y, auto_corner1y,auto_corner2y,auto_corner3y;
	
	//assign {line0_theta, line1_theta, line2_theta, line3_theta}
	//	= {8'd60, 8'd148, 8'd68, 8'd136};
		
	//assign {line0_r, line1_r, line2_r, line3_r}
	//	= {11'sd528, -11'sd32, 11'sd184, -11'd184};
	
	corners_from_lines l2c(.clk(clk),
                      .start(lines_to_corners_start),
                      .theta0(line0_theta),
							 .theta1(line1_theta),
							 .theta2(line2_theta),
							 .theta3(line3_theta),
                      .r0(line0_r),
							 .r1(line1_r),
							 .r2(line2_r),
							 .r3(line3_r),
                      .done(lines_to_corners_done),
                      .corner1x(auto_corner0x),
							 .corner2x(auto_corner1x),
							 .corner3x(auto_corner2x),
							 .corner4x(auto_corner3x),
                      .corner1y(auto_corner0y),
							 .corner2y(auto_corner1y),
							 .corner3y(auto_corner2y),
							 .corner4y(auto_corner3y));

	//handle corner selection
	wire [9:0] corners1x_manual;
	wire [9:0] corners1y_manual;
	wire [9:0] corners2x_manual;
	wire [9:0] corners2y_manual;
	wire [9:0] corners3x_manual;
	wire [9:0] corners3y_manual;
	wire [9:0] corners4x_manual;
	wire [9:0] corners4y_manual;
	
	//human interface module
	human_interface_corners hic (clk, 
								fvh[2],
								~button_left,
								~button_right,
								~button_up,
								~button_down,
								~db_enter,
								~button0,
								~button1,
								~button2,
								~button3,
								{auto_corner0x,
								auto_corner0y,
								auto_corner1x,
								auto_corner1y,
								auto_corner2x,
								auto_corner2y,
								auto_corner3x,
								auto_corner3y },
								set_corners,
								corners1x_manual,
								corners1y_manual,
								corners2x_manual,
								corners2y_manual,
								corners3x_manual,
								corners3y_manual,
								corners4x_manual,
								corners4y_manual);
	

   wire signed [41:0] p1, p2, p3, p4, p5, p6, p7, p8, p9;
   //Compute parameters
   compute_parameters params(.x1_in(corners1x_manual - 192),
                             .x2_in(corners2x_manual - 192),
                             .x3_in(corners3x_manual - 192),
                             .x4_in(corners4x_manual - 192),
                             .y1_in(corners1y_manual - 144),
                             .y2_in(corners2y_manual - 144),
                             .y3_in(corners3y_manual - 144),
                             .y4_in(corners4y_manual - 144),
                             .p1(p1),
                             .p2(p2),
                             .p3(p3),
                             .p4(p4),
                             .p5(p5),
                             .p6(p6),
                             .p7(p7),
                             .p8(p8),
                             .p9(p9)
                             );
   reg [35:0] transform_source_data;
   wire [35:0] transform_dest_data;
   wire [18:0] transform_source_addr, transform_dest_addr;
   wire transform_dest_we;
   pixel_transform mapper(.clk(clk), 
                         .start(pixel_transform_start),
                         .p1(p1),
                         .p2(p2),
                         .p3(p3),
                         .p4(p4),
                         .p5(p5),
                         .p6(p6),
                         .p7(p7),
                         .p8(p8),
                         .p9(p9),
                         .source_data(transform_source_data),
                         .source_addr(transform_source_addr),
                         .dest_data(transform_dest_data),
                         .dest_addr(transform_dest_addr),
                         .dest_we(transform_dest_we),
                         .done(pixel_transform_done));
   
	//Wire Gaussian Blurrer
	wire [18:0] blur_read_addr;
	reg [35:0] blur_read_data;
	wire [18:0] blur_write_addr;
	wire [35:0] blur_write_data;
	gaussian_blurrer gblur(.reset(1'b0),
								  .clk(clk),
								  .start(blur_start),
								  .done(blur_done),
								  .read_addr(blur_read_addr),
								  .read_data(blur_read_data),
								  .write_addr(blur_write_addr),
								  .write_data(blur_write_data));

	//Wire Canny Edge Detector
	reg [35:0] edge_detector_read_data;
	wire [18:0] edge_detector_write_addr;
	wire edge_detector_write_data;
	wire [18:0] edge_detector_read_addr;

	edge_detector edgedetector(.reset(1'b0),
										.clk(clk),
										.start(edge_detector_start),
										.done(edge_detector_done),
										.read_addr(edge_detector_read_addr),							
										.read_data(edge_detector_read_data),
										.write_addr(edge_detector_write_addr),
										.write_data(edge_detector_write_data),
										.thres(7'b1111111));

	//Wire Hough Transform
	reg hough_bram_read_data;
	wire [18:0] hough_bram_read_addr;
	reg [35:0] hough_vram_read_data;
	wire [18:0] hough_vram_addr;
	wire [35:0] hough_vram_write_data;
	wire hough_vram_we;
	
	hough_transform_coordinate htc(.clk(clk), 
											.reset_memory(hough_mem_clear_start),
											.reset_memory_done(hough_mem_clear_done),
											.start(hough_start),
											.done(hough_done),
											.bram_data_in(hough_bram_read_data),
											.bram_addr(hough_bram_read_addr),
											.vram_read_data(hough_vram_read_data),
											.vram_addr(hough_vram_addr),
											.vram_write_data(hough_vram_write_data),
											.vram_we(hough_vram_we));


	wire [18:0] hough_count_addr;
	reg [35:0] hough_count_read_data;
	hough_transform_find_highest htfh (.clk(clk),
													.start(hough_count_start),
													.done(hough_count_done), 
													.addr(hough_count_addr),
													.read_data(hough_count_read_data), 
													.highest_angle0(line0_theta), 
													.highest_angle1(line1_theta), 
													.highest_angle2(line2_theta), 
													.highest_angle3(line3_theta), 
													.highest_r0(line0_r),
													.highest_r1(line1_r),
													.highest_r2(line2_r),
													.highest_r3(line3_r));

   //////////////////////// MEMORY CONTROL AREA
   // Potential inputs:
   // ntsc_addr, ntsc_data, vga_addr,
   // transform_source_addr, transform_dest_data,
   // transform_dest_addr, and all write enable inputs
   // Potential outputs:
   // vga_data, transform_source_data
   // ram(0,1)_(addr, write_data, we)_mux
   always @(*) begin
      // Default values - so we don't accidentally infer latch behavior
		bram_mem_in = 0;
		bram_addr = 0;
		bram_write_enable = 0;
		bram_display_read_data = 0;
		edge_detector_read_data = 0;
		blur_read_data = 0;
      ram0_addr_mux = 0;
      ram0_write_data_mux = 0;
      ram0_we_mux = 0;
      ram1_addr_mux = 0;
      ram1_write_data_mux = 0;
      ram1_we_mux = 0;
      vga_data = 0;
      transform_source_data = 0;
      hough_vram_read_data = 0;
		hough_bram_read_data = 0;
		hough_count_read_data = 0;
		
      case(fsm_state)
         VIEW_FINDER: begin
            ram0_addr_mux = ntsc_addr;
            ram0_write_data_mux = ntsc_data;
            ram0_we_mux = ntsc_we;
         end
         MANUAL_DETECTION_START, MANUAL_DETECTION_WAIT, COMPUTE_PARAM_START, COMPUTE_PARAM_WAIT: begin
            ram0_addr_mux = vga_addr;
            vga_data = ram0_read_data;
         end
         PIXEL_TRANSFORM_START, PIXEL_TRANSFORM_WAIT: begin
            ram0_addr_mux = transform_source_addr;
            transform_source_data = ram0_read_data;
            ram1_addr_mux = transform_dest_addr;
            ram1_write_data_mux = transform_dest_data;
            ram1_we_mux = transform_dest_we;
         end
			BLUR_START, BLUR_WAIT: begin
				ram0_addr_mux = blur_read_addr;
            blur_read_data = ram0_read_data;
            ram1_addr_mux = blur_write_addr;
            ram1_write_data_mux = blur_write_data;
            ram1_we_mux = 1;
			end
			SHOW_BLUR: begin
				ram1_addr_mux = vga_addr;
            vga_data = ram1_read_data;
			end
			EDGE_DETECTOR_START, EDGE_DETECTOR_WAIT: begin
				bram_addr = edge_detector_write_addr;
				bram_mem_in = edge_detector_write_data;
				bram_write_enable = 1'b1;
				edge_detector_read_data = ram1_read_data;
				ram1_addr_mux = edge_detector_read_addr;
			end
			SHOW_EDGE_DETECTOR: begin
				bram_display_read_data = bram_mem_out;
				bram_addr = bram_display_addr;
			end
			HOUGH_MEM_CLEAR_START, HOUGH_MEM_CLEAR_WAIT, HOUGH_START, HOUGH_WAIT: begin
				bram_addr = hough_bram_read_addr;
				hough_bram_read_data = bram_mem_out;
				ram1_addr_mux = hough_vram_addr;
				ram1_write_data_mux = hough_vram_write_data;
				hough_vram_read_data = ram1_read_data;
				ram1_we_mux = hough_vram_we;
			end
			HOUGH_COUNT_START, HOUGH_COUNT_WAIT: begin
				ram1_addr_mux = hough_count_addr;
				hough_count_read_data = ram1_read_data;
			end
         SHOW_TRANSFORMED: begin
            ram1_addr_mux = vga_addr;
            vga_data = ram1_read_data;
         end
         default: begin
            ram0_addr_mux = vga_addr;
            vga_data = ram0_read_data;
         end
      endcase
   end

	//handle drawing corner markers
	wire [29:0] corner_pixel_A;
	corner_sprite #(32'h3ff00000) corner_sprite_A (corners1x_manual, corners1y_manual, hcount, vcount, corner_pixel_A);
	
	wire [29:0] corner_pixel_B;
	corner_sprite #(32'h3ff003ff) corner_sprite_B (corners2x_manual, corners2y_manual, hcount, vcount, corner_pixel_B);
	
	wire [29:0] corner_pixel_C;
	corner_sprite #(32'h3ffffc00) corner_sprite_C (corners3x_manual, corners3y_manual, hcount, vcount, corner_pixel_C);
	
	wire [29:0] corner_pixel_D;
	corner_sprite #(32'h3fffffff) corner_sprite_D (corners4x_manual, corners4y_manual, hcount, vcount, corner_pixel_D);
	
	//select which pixel to use
	reg [29:0] ycrcb_pixel;
	wire [2:0] which_corner_pixel;
	assign which_corner_pixel = corner_pixel_A ? 1 : corner_pixel_B ? 2 : corner_pixel_C ? 3 : corner_pixel_D ? 4 : 0;
	always @(*) begin
		case(which_corner_pixel)
			1: ycrcb_pixel <= corner_pixel_A;
			2: ycrcb_pixel <= corner_pixel_B;
			3: ycrcb_pixel <= corner_pixel_C;
			4: ycrcb_pixel <= corner_pixel_D;
			default: ycrcb_pixel <= (fsm_state == SHOW_EDGE_DETECTOR ? bram_pixel : vram_pixel);
		endcase
	end
   
	// select output pixel data
   reg [23:0] pixel;
	wire [23:0] rgb_pixel;
   reg 	b,hs,vs;
   
	//convert pixels from ycrcb to rgb just before they go to the screen
	ycrcb2rgb colCvt(ycrcb_pixel[29:20],ycrcb_pixel[19:10],ycrcb_pixel[9:0],
							rgb_pixel[23:16],rgb_pixel[15:8],rgb_pixel[7:0], clk, 1'b0);
	
	//delay hsync, vsync, blank by 3 clock cycles for colour conversion
	reg hsync_delay[2:0];
	reg blank_delay[2:0];
	reg vsync_delay[2:0];
   always @(posedge clk)
     begin
		pixel <= fsm_state == 0 ? 0 : rgb_pixel;
		b <= blank;
		hs <= hsync;
		vs <= vsync;
		{hsync_delay[2],hsync_delay[1],hsync_delay[0]} <= {hsync_delay[1],hsync_delay[0], hs};
		{vsync_delay[2],vsync_delay[1],vsync_delay[0]} <= {vsync_delay[1],vsync_delay[0], vs};
		{blank_delay[2],blank_delay[1],blank_delay[0]} <= {blank_delay[1],blank_delay[0], b};
     end

   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clk.
   assign vga_out_red = pixel[23:16];
   assign vga_out_green = pixel[15:8];
   assign vga_out_blue = pixel[7:0];
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_pixel_clock = ~clk;
   assign vga_out_blank_b = ~blank_delay[2];
   assign vga_out_hsync = hsync_delay[2];
   assign vga_out_vsync = vsync_delay[2];

   // debugging
   assign led = ~{2'b0,fsm_state};

	//displayed on hex display for debugging
   always @(posedge clk)
     // dispdata <= {vram_read_data,9'b0,vram_addr};
	  case({switch[1], switch[0]})
			2'b00: dispdata <= {44'b0, 1'b0,line0_r, line0_theta};
			2'b01: dispdata <= {44'b0, 1'b0,line1_r, line1_theta};
			2'b10: dispdata <= {44'b0, 1'b0,line2_r, line2_theta};
			2'b11: dispdata <= {44'b0, 1'b0,line3_r, line3_theta};
			default: dispdata <= {64'hFFFFFFFFFFFFFFFF};
		endcase
endmodule

///////////////////////////////////////////////////////////////////////////////
// xvga: Generate XVGA display signals (1024 x 768 @ 60Hz)

module xvga(vclock,hcount,vcount,hsync,vsync,blank);
   input vclock;
   output [10:0] hcount;
   output [9:0] vcount;
   output 	vsync;
   output 	hsync;
   output 	blank;

   reg 	  hsync,vsync,hblank,vblank,blank;
   reg [10:0] 	 hcount;    // pixel number on current line
   reg [9:0] vcount;	 // line number

   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   wire      hsyncon,hsyncoff,hreset,hblankon;
   assign    hblankon = (hcount == 1023);    
   assign    hsyncon = (hcount == 1047);
   assign    hsyncoff = (hcount == 1183);
   assign    hreset = (hcount == 1343);

   // vertical: 806 lines total
   // display 768 lines
   wire      vsyncon,vsyncoff,vreset,vblankon;
   assign    vblankon = hreset & (vcount == 767);    
   assign    vsyncon = hreset & (vcount == 776);
   assign    vsyncoff = hreset & (vcount == 782);
   assign    vreset = hreset & (vcount == 805);

   // sync and blanking
   wire      next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always @(posedge vclock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

      blank <= next_vblank | (next_hblank & ~hreset);
   end
endmodule

module vram_display #(parameter XOFFSET = 0, YOFFSET = 0) (reset,clk,hcount,vcount,vram_pixel,
		    vram_addr,vram_read_data);

   input reset, clk;
   input [10:0] hcount;
   input [9:0] 	vcount;
   output reg [29:0] vram_pixel;
   output [18:0] vram_addr;
   input [35:0]  vram_read_data;

	wire[10:0] x;
	wire[9:0] y;
	assign x = hcount - XOFFSET;
	assign y = vcount - YOFFSET;
   //forecast hcount & vcount 2 clock cycles ahead to get data from ZBT
   wire [10:0] hcount_f = (x >= 1048) ? x - 1048 : (x + 2);
   wire [9:0] vcount_f = (x >= 1048) ? ((y == 805) ? 0 : y + 1) : y;
   
	reg [18:0] vram_addr;
	always@(*) begin
		if(hcount_f < 640 && vcount_f < 480) begin
			vram_addr = {vcount_f[8:0], hcount_f[9:0]};
			vram_pixel = vram_read_data[29:0];
		end
		else begin
			vram_pixel = {10'd0,10'd512,10'd512};
		end
	end

endmodule // vram_display

/////////////////////////////////////////////////////////////////////////////
// parameterized delay line 

module delayN(clk,in,out);
   input clk;
   input in;
   output out;

   parameter NDELAY = 3;

   reg [NDELAY-1:0] shiftreg;
   wire 	    out = shiftreg[NDELAY-1];

   always @(posedge clk)
     shiftreg <= {shiftreg[NDELAY-2:0],in};

endmodule // delayN

////////////////////////////////////////////////////////////////////////////
// ramclock module

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- ZBT RAM clock generation
//
//
// Created: April 27, 2004
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// This module generates deskewed clocks for driving the ZBT SRAMs and FPGA 
// registers. A special feedback trace on the labkit PCB (which is length 
// matched to the RAM traces) is used to adjust the RAM clock phase so that 
// rising clock edges reach the RAMs at exactly the same time as rising clock 
// edges reach the registers in the FPGA.
//
// The RAM clock signals are driven by DDR output buffers, which further 
// ensures that the clock-to-pad delay is the same for the RAM clocks as it is 
// for any other registered RAM signal.
//
// When the FPGA is configured, the DCMs are enabled before the chip-level I/O
// drivers are released from tristate. It is therefore necessary to
// artificially hold the DCMs in reset for a few cycles after configuration. 
// This is done using a 16-bit shift register. When the DCMs have locked, the 
// <lock> output of this mnodule will go high. Until the DCMs are locked, the 
// ouput clock timings are not guaranteed, so any logic driven by the 
// <fpga_clock> should probably be held inreset until <locked> is high.
//
///////////////////////////////////////////////////////////////////////////////

module ramclock(ref_clock, fpga_clock, ram0_clock, ram1_clock, 
	        clock_feedback_in, clock_feedback_out, locked);
   
   input ref_clock;                 // Reference clock input
   output fpga_clock;               // Output clock to drive FPGA logic
   output ram0_clock, ram1_clock;   // Output clocks for each RAM chip
   input  clock_feedback_in;        // Output to feedback trace
   output clock_feedback_out;       // Input from feedback trace
   output locked;                   // Indicates that clock outputs are stable
   
   wire  ref_clk, fpga_clk, ram_clk, fb_clk, lock1, lock2, dcm_reset;

   ////////////////////////////////////////////////////////////////////////////
   
   //To force ISE to compile the ramclock, this line has to be removed.
   //IBUFG ref_buf (.O(ref_clk), .I(ref_clock));
	
	assign ref_clk = ref_clock;
   
   BUFG int_buf (.O(fpga_clock), .I(fpga_clk));

   DCM int_dcm (.CLKFB(fpga_clock),
		.CLKIN(ref_clk),
		.RST(dcm_reset),
		.CLK0(fpga_clk),
		.LOCKED(lock1));
   // synthesis attribute DLL_FREQUENCY_MODE of int_dcm is "LOW"
   // synthesis attribute DUTY_CYCLE_CORRECTION of int_dcm is "TRUE"
   // synthesis attribute STARTUP_WAIT of int_dcm is "FALSE"
   // synthesis attribute DFS_FREQUENCY_MODE of int_dcm is "LOW"
   // synthesis attribute CLK_FEEDBACK of int_dcm  is "1X"
   // synthesis attribute CLKOUT_PHASE_SHIFT of int_dcm is "NONE"
   // synthesis attribute PHASE_SHIFT of int_dcm is 0
   
   BUFG ext_buf (.O(ram_clock), .I(ram_clk));
   
   IBUFG fb_buf (.O(fb_clk), .I(clock_feedback_in));
   
   DCM ext_dcm (.CLKFB(fb_clk), 
		    .CLKIN(ref_clk), 
		    .RST(dcm_reset),
		    .CLK0(ram_clk),
		    .LOCKED(lock2));
   // synthesis attribute DLL_FREQUENCY_MODE of ext_dcm is "LOW"
   // synthesis attribute DUTY_CYCLE_CORRECTION of ext_dcm is "TRUE"
   // synthesis attribute STARTUP_WAIT of ext_dcm is "FALSE"
   // synthesis attribute DFS_FREQUENCY_MODE of ext_dcm is "LOW"
   // synthesis attribute CLK_FEEDBACK of ext_dcm  is "1X"
   // synthesis attribute CLKOUT_PHASE_SHIFT of ext_dcm is "NONE"
   // synthesis attribute PHASE_SHIFT of ext_dcm is 0

   SRL16 dcm_rst_sr (.D(1'b0), .CLK(ref_clk), .Q(dcm_reset),
		     .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   // synthesis attribute init of dcm_rst_sr is "000F";
   

   OFDDRRSE ddr_reg0 (.Q(ram0_clock), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));
   OFDDRRSE ddr_reg1 (.Q(ram1_clock), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));
   OFDDRRSE ddr_reg2 (.Q(clock_feedback_out), .C0(ram_clock), .C1(~ram_clock),
		      .CE (1'b1), .D0(1'b1), .D1(1'b0), .R(1'b0), .S(1'b0));

   assign locked = lock1 && lock2;
   
endmodule

