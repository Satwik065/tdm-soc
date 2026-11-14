interface sideband_if (input logic clk, input logic rst_n);
    logic [7:0] gpio_in;
    logic [3:0] tdm_req;
    logic [7:0] gpio_out;
    logic [7:0] gpio_oe;
    logic [3:0] tdm_grant;
    logic [1:0] tdm_slot;
endinterface