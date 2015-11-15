library verilog;
use verilog.vl_types.all;
entity ycrcb2rgb is
    generic(
        M13             : integer := 73;
        M22             : integer := 25;
        M23             : integer := 37;
        M32             : integer := 130
    );
    port(
        y               : in     vl_logic_vector(9 downto 0);
        cr              : in     vl_logic_vector(9 downto 0);
        cb              : in     vl_logic_vector(9 downto 0);
        r               : out    vl_logic_vector(7 downto 0);
        g               : out    vl_logic_vector(7 downto 0);
        b               : out    vl_logic_vector(7 downto 0)
    );
end ycrcb2rgb;
