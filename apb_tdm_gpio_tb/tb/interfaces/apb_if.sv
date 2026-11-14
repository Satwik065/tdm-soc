interface apb_if (input logic clk, input logic rst_n);
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic        pready;
    logic        pslverr;
endinterface