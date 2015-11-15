library verilog;
use verilog.vl_types.all;
entity delayN is
    generic(
        NDELAY          : integer := 3
    );
    port(
        clk             : in     vl_logic;
        \in\            : in     vl_logic;
        \out\           : out    vl_logic
    );
end delayN;
