library verilog;
use verilog.vl_types.all;
entity main_fsm is
    generic(
        VIEW_FINDER     : integer := 0;
        \AUTO_DETECTION_START\: integer := 1;
        AUTO_DETECTION_WAIT: integer := 2;
        MANUAL_DETECTION_START: integer := 3;
        MANUAL_DETECTION_WAIT: integer := 4;
        \BLUR_START\    : integer := 5;
        BLUR_WAIT       : integer := 6;
        \EDGE_DETECTION_START\: integer := 7;
        EDGE_DETECTION_WAIT: integer := 8;
        SHOW_BRAM       : integer := 9;
        SHOW_TRANSFORMED: integer := 31
    );
    port(
        clk             : in     vl_logic;
        button_enter    : in     vl_logic;
        switch          : in     vl_logic;
        auto_detection_done: in     vl_logic;
        blur_done       : in     vl_logic;
        edge_detection_done: in     vl_logic;
        state           : out    vl_logic_vector(4 downto 0);
        auto_detection_start: out    vl_logic;
        set_corners     : out    vl_logic;
        blur_start      : out    vl_logic;
        edge_detection_start: out    vl_logic
    );
end main_fsm;
