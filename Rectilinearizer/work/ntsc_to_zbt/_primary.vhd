library verilog;
use verilog.vl_types.all;
entity ntsc_to_zbt is
    generic(
        COL_START       : integer := 0;
        ROW_START       : integer := 0
    );
    port(
        clk             : in     vl_logic;
        vclk            : in     vl_logic;
        fvh             : in     vl_logic_vector(2 downto 0);
        dv              : in     vl_logic;
        din             : in     vl_logic_vector(29 downto 0);
        ntsc_addr       : out    vl_logic_vector(18 downto 0);
        ntsc_data       : out    vl_logic_vector(35 downto 0);
        ntsc_we         : out    vl_logic
    );
end ntsc_to_zbt;
