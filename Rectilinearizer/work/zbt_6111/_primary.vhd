library verilog;
use verilog.vl_types.all;
entity zbt_6111 is
    port(
        clk             : in     vl_logic;
        cen             : in     vl_logic;
        we              : in     vl_logic;
        addr            : in     vl_logic_vector(18 downto 0);
        write_data      : in     vl_logic_vector(35 downto 0);
        read_data       : out    vl_logic_vector(35 downto 0);
        ram_clk         : out    vl_logic;
        ram_we_b        : out    vl_logic;
        ram_address     : out    vl_logic_vector(18 downto 0);
        ram_data        : inout  vl_logic_vector(35 downto 0);
        ram_cen_b       : out    vl_logic
    );
end zbt_6111;
