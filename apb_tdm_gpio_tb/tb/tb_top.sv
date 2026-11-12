`timescale 1ns/1ps

module tp_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import tb_pkg::*;

    logic pclk;
    logic presetn;

    initial pclk = 0;
    always #5 pclk = ~pclk;
    
    initial begin
        presetn = 0;
        repeat (5) @(posedge pclk);
        presetn = 1;
    end

    apb_if apb_vif(.clk(pclk), .rst_n(presetn));
    sideband_if sb_vif(.clk(pclk), ,rst_n(presetn));

    apb_tdm_gpio_soc u_dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(apb_vif.psel),
        .PENABLE(apb_vif.penable),
        .PWRITE(apb_vif.pwrite),
        .PADDR(apb_vif.paddr),
        .PWDATA(apb_vif.pwdata),
        .PRDATA(apb_vif.prdata),
        .PREADY(apb_vif.pready),
        .PSLVERR(apb_vif.pslverr),
        .gpio_in(sb_vif.gpio_in),
        .gpio_out(sb_vif.gpio_out),
        .gpio_oe(sb_vif.gpio_oe),
        .tdm_req(sb_vif.tdm_req),
        .tdm_grant(sb_vif.tdm_grant),
        .tdm_slot(sb_vif.tdm_slot)
    );

    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb_vif);
        uvm_config_db#(virtual sideband_if)::set(null, "*", "sideband_vif", sideband_vif);

        runt_test();
    end
endmodule