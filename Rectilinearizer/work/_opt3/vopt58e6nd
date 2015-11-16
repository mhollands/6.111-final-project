library verilog;
use verilog.vl_types.all;
entity main_fsm is
    generic(
        VIEW_FINDER     : integer := 0;
        \AUTO_DETECTION_START\: integer := 1;
        AUTO_DETECTION_WAIT: integer := 2;
        MANUAL_DETECTION: integer := 4
    );
    port(
        clk             : in     vl_logic;
        button_enter    : in     vl_logic;
        switch          : in     vl_logic;
        auto_detection_done: in     vl_logic;
        state           : out    vl_logic_vector(2 downto 0);
        auto_detection_start: out    vl_logic
    );
end main_fsm;
