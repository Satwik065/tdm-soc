interface apb_if (
    input logic clk,
    input logic rst_n
);

    
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic        pready;
    logic        pslverr;

    
    clocking drv_cb @(posedge clk);
        default input #1step output #1step;

        output paddr, pwdata, psel, penable, pwrite;
        input  prdata, pready, pslverr;
    endclocking

    
    clocking mon_cb @(posedge clk);
        default input #1step output #1step;

        input paddr, pwdata, psel, penable, pwrite;
        input prdata, pready, pslverr;
    endclocking

    
    modport DRIVER  (clocking drv_cb);
    modport MONITOR (clocking mon_cb);

endinterface