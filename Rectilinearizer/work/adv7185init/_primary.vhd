library verilog;
use verilog.vl_types.all;
entity adv7185init is
    port(
        reset           : in     vl_logic;
        clock_27mhz     : in     vl_logic;
        source          : in     vl_logic;
        tv_in_reset_b   : out    vl_logic;
        tv_in_i2c_clock : out    vl_logic;
        tv_in_i2c_data  : out    vl_logic
    );
end adv7185init;
