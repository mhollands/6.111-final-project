library verilog;
use verilog.vl_types.all;
entity corner_reg is
    port(
        corners_A       : in     vl_logic_vector(79 downto 0);
        corners_B       : in     vl_logic_vector(79 downto 0);
        corners_sel     : in     vl_logic;
        corners_out     : out    vl_logic_vector(79 downto 0)
    );
end corner_reg;
