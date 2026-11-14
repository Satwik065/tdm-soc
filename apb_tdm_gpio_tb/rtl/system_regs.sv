//=============================================================================
// system_regs.sv
//-----------------------------------------------------------------------------
// System register block. Local word offsets:
//   0 SYSTEM_ID      (RO) fixed 32'h5444_4D31 ("TDM1")
//   1 SYSTEM_STATUS  (RO) [0]=APB access active      (PSEL & PENABLE)
//                         [1]=GPIO has >=1 output enabled
//                         [2]=TDM arbiter effectively enabled
//                         [3]=TDM any request active
//                         [4]=TDM any grant active, others 0
//   2 SYSTEM_CONTROL (RW) bit0 = global_enable
//
// global_enable semantics (defined by the top level):
//   0 : TDM arbiter forced off (no grants, slot frozen); APB writes to the
//       GPIO block are ignored; reads everywhere unaffected.
//   1 : normal operation.
// SYSTEM_CONTROL writes are never blocked (re-enable path).
//=============================================================================

module system_regs (
    input  logic        clk,
    input  logic        rst_n,
    // register bus interface
    input  logic [5:0]  local_off,
    input  logic        wr_en,
    input  logic [31:0] wdata,
    // live status inputs
    input  logic        apb_active,     // PSEL & PENABLE
    input  logic        gpio_any_oe,    // |gpio_oe
    input  logic        tdm_arb_en,     // effective TDM arbiter enable
    input  logic        tdm_any_req,    // |tdm_req
    input  logic        tdm_any_grant,  // |tdm_grant
    // outputs
    output logic        global_enable,
    output logic        reg_hit,
    output logic [31:0] rdata
);

    localparam logic [31:0] SYSTEM_ID_VALUE = 32'h5444_4D31;   // "TDM1"

    // SYSTEM_CONTROL register (word offset 2)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            global_enable <= 1'b0;
        end else if (wr_en && (local_off == 6'd2)) begin
            global_enable <= wdata[0];
        end
    end

    // implemented-register report (combinational)
    always_comb begin
        case (local_off)
            6'd0, 6'd1, 6'd2: reg_hit = 1'b1;
            default:          reg_hit = 1'b0;
        endcase
    end

    // combinational read data (0 when not hit)
    always_comb begin
        case (local_off)
            6'd0:    rdata = SYSTEM_ID_VALUE;
            6'd1:    rdata = {27'h0, tdm_any_grant, tdm_any_req, tdm_arb_en,
                              gpio_any_oe, apb_active};
            6'd2:    rdata = {31'h0, global_enable};
            default: rdata = 32'h0000_0000;
        endcase
    end

endmodule