interface sideband_if (
    input logic clk,
    input logic rst_n
);

    
    logic [7:0] gpio_in;
    logic [3:0] tdm_req;

    logic [7:0] gpio_out;
    logic [7:0] gpio_oe;
    logic [3:0] tdm_grant;
    logic [1:0] tdm_slot;

    
    clocking drv_cb @(posedge clk);
        default input #1step output #1step;

        output gpio_in;
        output tdm_req;

        input  gpio_out;
        input  gpio_oe;
        input  tdm_grant;
        input  tdm_slot;
    endclocking

    
    clocking mon_cb @(posedge clk);
        default input #1step output #1step;

        input gpio_in;
        input tdm_req;
        input gpio_out;
        input gpio_oe;
        input tdm_grant;
        input tdm_slot;
    endclocking

    
    modport DRIVER  (clocking drv_cb);
    modport MONITOR (clocking mon_cb);

endinterface