library verilog;
use verilog.vl_types.all;
entity xvga is
    port(
        vclock          : in     vl_logic;
        hcount          : out    vl_logic_vector(10 downto 0);
        vcount          : out    vl_logic_vector(9 downto 0);
        hsync           : out    vl_logic;
        vsync           : out    vl_logic;
        blank           : out    vl_logic
    );
end xvga;
