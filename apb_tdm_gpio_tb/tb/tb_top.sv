`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "seq/reset_check_seq.sv"
    `include "tests/reset_test.sv"
    `include "seq/gpio_seq.sv"
    `include "tests/gpio_test.sv"
    `include "seq/error_addr_seq.sv"
    `include "tests/error_addr_test.sv"
    `include "seq/arb_config_seq.sv"
    `include "seq/arb_stimulus_seq.sv"
    `include "tests/arb_test.sv"
    `include "seq/random_seq.sv"
    `include "tests/random_test.sv"
    import tb_pkg::*;

    logic PCLK;
    logic PRESETn;

    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    initial begin
        PRESETn = 0;
        repeat(5) @(posedge PCLK);
        PRESETn = 1;
        $display(">>> RESET DEASSERTED AT TIME %0t <<<", $time);
    end
    
    initial begin
        #100000;
        `uvm_fatal("TIMEOUT", "Simulation hung! The test never finished.")
    end

    apb_if apb_vif(.clk(PCLK), .rst_n(PRESETn));
    sideband_if sb_vif(.clk(PCLK), .rst_n(PRESETn));

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
        uvm_config_db#(virtual sideband_if)::set(null, "*", "sideband_vif", sb_vif);
        
        run_test();
    end
endmodule