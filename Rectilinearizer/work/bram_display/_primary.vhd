library verilog;
use verilog.vl_types.all;
entity bram_display is
    generic(
        XOFFSET         : integer := 0;
        YOFFSET         : integer := 0
    );
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        hcount          : in     vl_logic_vector(10 downto 0);
        vcount          : in     vl_logic_vector(9 downto 0);
        br_pixel        : out    vl_logic_vector(29 downto 0);
        bram_addr       : out    vl_logic_vector(18 downto 0);
        bram_read_data  : in     vl_logic
    );
end bram_display;
