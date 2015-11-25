library verilog;
use verilog.vl_types.all;
entity corner_detector is
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        done            : out    vl_logic;
        corners         : out    vl_logic_vector(79 downto 0)
    );
end corner_detector;
