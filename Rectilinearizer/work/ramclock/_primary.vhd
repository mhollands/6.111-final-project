library verilog;
use verilog.vl_types.all;
entity ramclock is
    port(
        ref_clock       : in     vl_logic;
        fpga_clock      : out    vl_logic;
        ram0_clock      : out    vl_logic;
        ram1_clock      : out    vl_logic;
        clock_feedback_in: in     vl_logic;
        clock_feedback_out: out    vl_logic;
        locked          : out    vl_logic
    );
end ramclock;
