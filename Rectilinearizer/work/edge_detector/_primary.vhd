library verilog;
use verilog.vl_types.all;
entity edge_detector is
    generic(
        WIDTH           : integer := 640;
        HEIGHT          : integer := 480;
        THRESHOLD       : integer := 40000
    );
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        start           : in     vl_logic;
        done            : out    vl_logic;
        read_addr       : out    vl_logic_vector(18 downto 0);
        read_data       : in     vl_logic_vector(35 downto 0);
        write_addr      : out    vl_logic_vector(18 downto 0);
        write_data      : out    vl_logic;
        thres           : in     vl_logic_vector(6 downto 0)
    );
end edge_detector;
