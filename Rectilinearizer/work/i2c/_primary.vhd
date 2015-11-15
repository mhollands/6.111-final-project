library verilog;
use verilog.vl_types.all;
entity i2c is
    port(
        reset           : in     vl_logic;
        clock4x         : in     vl_logic;
        data            : in     vl_logic_vector(7 downto 0);
        load            : in     vl_logic;
        idle            : out    vl_logic;
        ack             : out    vl_logic;
        scl             : out    vl_logic;
        sda             : out    vl_logic
    );
end i2c;
