library verilog;
use verilog.vl_types.all;
entity corner_sprite is
    generic(
        COLOUR          : integer := 536870911
    );
    port(
        x               : in     vl_logic_vector(10 downto 0);
        y               : in     vl_logic_vector(9 downto 0);
        hcount          : in     vl_logic_vector(10 downto 0);
        vcount          : in     vl_logic_vector(9 downto 0);
        pixel           : out    vl_logic_vector(29 downto 0)
    );
end corner_sprite;
