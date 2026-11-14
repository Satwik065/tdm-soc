//=============================================================================
// tdm_arbiter.sv
//-----------------------------------------------------------------------------
// 4-client deterministic round-robin arbiter plus its register block.
//
// Arbitration model:
//   * Effective enable: arb_en = TDM_CONTROL.enable (bit 0) AND ge (global).
//   * Grant is combinational: every cycle with arb_en=1 and at least one
//     request is an arbitration opportunity. The search starts at the
//     current slot and walks the clients in cyclic order; the first
//     requesting client is granted (exactly one grant, or none).
//   * slot is a register: it advances to the client immediately after the
//     granted client on each granted clock edge; otherwise it holds.
//   * arb_en=0 forces grant=4'b0000 and freezes slot.
//
// Local word offsets:
//   0 TDM_CONTROL (RW) bit0 = enable
//   1 TDM_REQUEST (RO) live tdm_req
//   2 TDM_GRANT   (RO) live tdm_grant
//   3 TDM_STATUS  (RO) [0]=arb_en [1]=any_req [2]=any_grant [3]=multi_req
//                      [5:4]=slot, others 0
//   4 TDM_SLOT    (RO) [1:0]=slot, others 0
//=============================================================================

module tdm_arbiter (
    input  logic        clk,
    input  logic        rst_n,
    // register bus interface
    input  logic [5:0]  local_off,
    input  logic        wr_en,
    input  logic [31:0] wdata,
    // system-level gating
    input  logic        ge,          // global enable (SYSTEM_CONTROL bit 0)
    // arbiter external interface
    input  logic [3:0]  req,
    output logic [3:0]  grant,
    output logic [1:0]  slot,
    // status
    output logic        arb_en,      // effective arbiter enable
    // register read interface
    output logic        reg_hit,
    output logic [31:0] rdata
);

    //-------------------------------------------------------------------------
    // TDM_CONTROL register (only writable TDM register)
    //-------------------------------------------------------------------------
    logic enable_q;

    assign arb_en = enable_q & ge;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            enable_q <= 1'b0;
        end else if (wr_en && (local_off == 6'd0)) begin
            enable_q <= wdata[0];
        end
    end

    //-------------------------------------------------------------------------
    // Round-robin arbitration core
    //-------------------------------------------------------------------------
    logic [3:0] rot_req;      // req rotated so rot_req[k] = req[(slot+k) % 4]
    logic [1:0] sel_off;      // offset of first requester from slot
    logic       any_req;
    logic [1:0] grant_idx;    // absolute index of granted client

    always_comb begin
        case (slot)
            2'd0:    rot_req = req;
            2'd1:    rot_req = {req[0],   req[3:1]};
            2'd2:    rot_req = {req[1:0], req[3:2]};
            default: rot_req = {req[2:0], req[3]};
        endcase
    end

    always_comb begin
        if (rot_req[0])      sel_off = 2'd0;
        else if (rot_req[1]) sel_off = 2'd1;
        else if (rot_req[2]) sel_off = 2'd2;
        else                 sel_off = 2'd3;
    end

    assign any_req   = |req;
    assign grant_idx = slot + sel_off;  // 2-bit wrap = cyclic client index
    assign grant     = (arb_en && any_req) ? (4'b0001 << grant_idx) : 4'b0000;

    // slot pointer: advances past the granted client, holds otherwise
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            slot <= 2'd0;
        end else if (arb_en && any_req) begin
            slot <= grant_idx + 2'd1;
        end
    end

    //-------------------------------------------------------------------------
    // Register block: implemented-register report and read data
    //-------------------------------------------------------------------------
    logic multi_req;

    assign multi_req = ($countones(req) > 1);

    always_comb begin
        case (local_off)
            6'd0, 6'd1, 6'd2, 6'd3, 6'd4: reg_hit = 1'b1;
            default:                      reg_hit = 1'b0;
        endcase
    end

    always_comb begin
        case (local_off)
            6'd0:    rdata = {31'h0, enable_q};                                // TDM_CONTROL
            6'd1:    rdata = {28'h0, req};                                     // TDM_REQUEST
            6'd2:    rdata = {28'h0, grant};                                   // TDM_GRANT
            6'd3:    rdata = {26'h0, slot, multi_req, (|grant), (|req), arb_en}; // TDM_STATUS
            6'd4:    rdata = {30'h0, slot};                                    // TDM_SLOT
            default: rdata = 32'h0000_0000;
        endcase
    end

endmodule