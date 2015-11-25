library verilog;
use verilog.vl_types.all;
entity ycrcb2rgb is
    port(
        Y               : in     vl_logic_vector(9 downto 0);
        Cr              : in     vl_logic_vector(9 downto 0);
        Cb              : in     vl_logic_vector(9 downto 0);
        R               : out    vl_logic_vector(7 downto 0);
        G               : out    vl_logic_vector(7 downto 0);
        B               : out    vl_logic_vector(7 downto 0);
        clk             : in     vl_logic;
        rst             : in     vl_logic
    );
end ycrcb2rgb;
