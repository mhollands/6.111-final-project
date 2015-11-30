library verilog;
use verilog.vl_types.all;
entity hough_transform_calculate is
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        done            : out    vl_logic;
        x               : in     vl_logic_vector(9 downto 0);
        y               : in     vl_logic_vector(8 downto 0)
    );
end hough_transform_calculate;
