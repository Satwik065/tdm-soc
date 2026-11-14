//=============================================================================
// apb_decoder.sv
//-----------------------------------------------------------------------------
// Purely combinational APB address decoder.
//
//   PADDR[31:12] == 0   required (prevents aliasing of upper address bits)
//   PADDR[1:0]   == 0   required (word aligned; unaligned = decode error)
//   PADDR[11:8]         block select: 0x0=GPIO, 0x1=TDM, 0x2=SYSTEM
//   PADDR[7:2]          local word offset inside the selected block
//
// Each peripheral reports (via <block>_hit) whether the local offset maps to
// an implemented register. decode_err = no block hit OR no register hit.
//=============================================================================

module apb_decoder (
    input  logic [31:0] paddr,
    // implemented-register reports from the peripheral blocks
    input  logic        gpio_hit,
    input  logic        tdm_hit,
    input  logic        sys_hit,
    // block selects (mutually exclusive)
    output logic        gpio_sel,
    output logic        tdm_sel,
    output logic        sys_sel,
    // local word offset inside the selected block
    output logic [5:0]  local_off,
    // 1 = address does not map to any implemented register
    output logic        decode_err
);

    logic upper_zero;
    logic aligned;
    logic block_hit;

    assign upper_zero = (paddr[31:12] == 20'd0);
    assign aligned    = (paddr[1:0]   == 2'b00);
    assign local_off  = paddr[7:2];

    assign gpio_sel = upper_zero && aligned && (paddr[11:8] == 4'h0);
    assign tdm_sel  = upper_zero && aligned && (paddr[11:8] == 4'h1);
    assign sys_sel  = upper_zero && aligned && (paddr[11:8] == 4'h2);

    assign block_hit  = gpio_sel | tdm_sel | sys_sel;

    assign decode_err = ~block_hit
                      | (gpio_sel & ~gpio_hit)
                      | (tdm_sel  & ~tdm_hit)
                      | (sys_sel  & ~sys_hit);

endmodule