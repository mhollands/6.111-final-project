library verilog;
use verilog.vl_types.all;
entity corner_detector is
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        done            : out    vl_logic
    );
end corner_detector;
