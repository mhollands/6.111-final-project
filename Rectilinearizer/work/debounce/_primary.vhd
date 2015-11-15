library verilog;
use verilog.vl_types.all;
entity debounce is
    generic(
        NDELAY          : integer := 650000;
        NBITS           : integer := 20
    );
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        noisy           : in     vl_logic;
        clean           : out    vl_logic
    );
end debounce;
