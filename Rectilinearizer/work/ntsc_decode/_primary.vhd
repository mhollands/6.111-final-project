library verilog;
use verilog.vl_types.all;
entity ntsc_decode is
    generic(
        SYNC_1          : integer := 0;
        SYNC_2          : integer := 1;
        SYNC_3          : integer := 2;
        SAV_f1_cb0      : integer := 3;
        SAV_f1_y0       : integer := 4;
        SAV_f1_cr1      : integer := 5;
        SAV_f1_y1       : integer := 6;
        EAV_f1          : integer := 7;
        SAV_VBI_f1      : integer := 8;
        EAV_VBI_f1      : integer := 9;
        SAV_f2_cb0      : integer := 10;
        SAV_f2_y0       : integer := 11;
        SAV_f2_cr1      : integer := 12;
        SAV_f2_y1       : integer := 13;
        EAV_f2          : integer := 14;
        SAV_VBI_f2      : integer := 15;
        EAV_VBI_f2      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        tv_in_ycrcb     : in     vl_logic_vector(9 downto 0);
        ycrcb           : out    vl_logic_vector(29 downto 0);
        f               : out    vl_logic;
        v               : out    vl_logic;
        h               : out    vl_logic;
        data_valid      : out    vl_logic
    );
end ntsc_decode;
