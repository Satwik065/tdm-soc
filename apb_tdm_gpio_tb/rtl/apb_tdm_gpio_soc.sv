//=============================================================================
// apb_tdm_gpio_soc.sv
//-----------------------------------------------------------------------------
// Top level: APB slave register fabric + GPIO peripheral + TDM arbiter +
// system register block.
//
// APB timing model (zero wait states):
//   PREADY  = PSEL & PENABLE        (high during ACCESS only)
//   writes  = 1-cycle strobe in ACCESS phase
//   reads   = combinational in ACCESS phase
//   PRDATA / PSLVERR = 0 outside the ACCESS phase
//   unmapped address : PRDATA=32'h0, PSLVERR=1 (read or write)
//=============================================================================

module apb_tdm_gpio_soc (
    input  logic        PCLK,
    input  logic        PRESETn,
    // APB slave interface
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR,
    // GPIO interface
    input  logic [7:0]  gpio_in,
    output logic [7:0]  gpio_out,
    output logic [7:0]  gpio_oe,
    // TDM arbiter interface
    input  logic [3:0]  tdm_req,
    output logic [3:0]  tdm_grant,
    // round-robin slot pointer (direct observability of arbiter state)
    output logic [1:0]  tdm_slot
);

    //-------------------------------------------------------------------------
    // APB phase tracking
    //-------------------------------------------------------------------------
    logic apb_access;
    logic apb_wr;

    assign apb_access = PSEL & PENABLE;         // ACCESS phase
    assign apb_wr     = apb_access & PWRITE;    // one pulse per write transfer

    assign PREADY = apb_access;                 // zero wait states

    //-------------------------------------------------------------------------
    // Address decode
    //-------------------------------------------------------------------------
    logic        gpio_sel, tdm_sel, sys_sel;
    logic [5:0]  local_off;
    logic        gpio_hit, tdm_hit, sys_hit;
    logic        decode_err;
    logic [31:0] gpio_rdata, tdm_rdata, sys_rdata;

    apb_decoder u_decoder (
        .paddr     (PADDR),
        .gpio_hit  (gpio_hit),
        .tdm_hit   (tdm_hit),
        .sys_hit   (sys_hit),
        .gpio_sel  (gpio_sel),
        .tdm_sel   (tdm_sel),
        .sys_sel   (sys_sel),
        .local_off (local_off),
        .decode_err(decode_err)
    );

    //-------------------------------------------------------------------------
    // System-level control
    //-------------------------------------------------------------------------
    logic global_enable;    // SYSTEM_CONTROL[0]
    logic tdm_arb_en;       // effective TDM arbiter enable

    //-------------------------------------------------------------------------
    // Write strobes (per block). GPIO writes are blocked while the system is
    // globally disabled; TDM_CONTROL and SYSTEM_CONTROL writes are never
    // blocked (SYSTEM_CONTROL is the re-enable path). Unimplemented offsets
    // inside a selected block cause no state change inside the peripherals.
    //-------------------------------------------------------------------------
    logic gpio_wr_en, tdm_wr_en, sys_wr_en;

    assign gpio_wr_en = apb_wr & gpio_sel & global_enable;
    assign tdm_wr_en  = apb_wr & tdm_sel;
    assign sys_wr_en  = apb_wr & sys_sel;

    //-------------------------------------------------------------------------
    // Peripherals
    //-------------------------------------------------------------------------
    gpio_peripheral u_gpio (
        .clk      (PCLK),
        .rst_n    (PRESETn),
        .local_off(local_off),
        .wr_en    (gpio_wr_en),
        .wdata    (PWDATA),
        .gpio_in  (gpio_in),
        .gpio_out (gpio_out),
        .gpio_oe  (gpio_oe),
        .reg_hit  (gpio_hit),
        .rdata    (gpio_rdata)
    );

    tdm_arbiter u_tdm (
        .clk      (PCLK),
        .rst_n    (PRESETn),
        .local_off(local_off),
        .wr_en    (tdm_wr_en),
        .wdata    (PWDATA),
        .ge       (global_enable),
        .req      (tdm_req),
        .grant    (tdm_grant),
        .slot     (tdm_slot),
        .arb_en   (tdm_arb_en),
        .reg_hit  (tdm_hit),
        .rdata    (tdm_rdata)
    );

    system_regs u_sys (
        .clk          (PCLK),
        .rst_n        (PRESETn),
        .local_off    (local_off),
        .wr_en        (sys_wr_en),
        .wdata        (PWDATA),
        .apb_active   (apb_access),
        .gpio_any_oe  (|gpio_oe),
        .tdm_arb_en   (tdm_arb_en),
        .tdm_any_req  (|tdm_req),
        .tdm_any_grant(|tdm_grant),
        .global_enable(global_enable),
        .reg_hit      (sys_hit),
        .rdata        (sys_rdata)
    );

    //-------------------------------------------------------------------------
    // APB read data and error response
    //-------------------------------------------------------------------------
    always_comb begin
        PRDATA = 32'h0000_0000;
        if (apb_access) begin
            if (gpio_sel)      PRDATA = gpio_rdata;
            else if (tdm_sel)  PRDATA = tdm_rdata;
            else if (sys_sel)  PRDATA = sys_rdata;
            else               PRDATA = 32'h0000_0000;
        end
    end

    assign PSLVERR = apb_access & decode_err;

endmodule