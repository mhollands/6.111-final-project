library verilog;
use verilog.vl_types.all;
entity hough_transform_coordinate is
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        done            : out    vl_logic;
        data_in         : in     vl_logic
    );
end hough_transform_coordinate;