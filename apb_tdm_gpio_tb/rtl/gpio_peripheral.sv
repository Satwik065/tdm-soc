//=============================================================================
// gpio_peripheral.sv
//-----------------------------------------------------------------------------
// 8-bit GPIO peripheral. Local word offsets:
//   0 GPIO_DATA  (RW) output data        [7:0]
//   1 GPIO_DIR   (RW) output enable      [7:0] (1=output)
//   2 GPIO_INPUT (RO) live gpio_in       [7:0]
//   3 GPIO_SET   (W)  write-1 sets DATA bits, reads as 0
//   4 GPIO_CLEAR (W)  write-1 clears DATA bits, reads as 0
//
// wr_en is a 1-clock strobe qualified with the GPIO block select (and with
// the system global enable by the top level). Writes to read-only or
// unimplemented offsets have no effect. rdata = 0 for non-implemented
// offsets and for SET/CLEAR.
//=============================================================================

module gpio_peripheral (
    input  logic        clk,
    input  logic        rst_n,
    // register bus interface
    input  logic [5:0]  local_off,
    input  logic        wr_en,
    input  logic [31:0] wdata,
    // external pins
    input  logic [7:0]  gpio_in,
    output logic [7:0]  gpio_out,
    output logic [7:0]  gpio_oe,
    // register read interface
    output logic        reg_hit,
    output logic [31:0] rdata
);

    logic [7:0] data_q;
    logic [7:0] dir_q;

    assign gpio_out = data_q;
    assign gpio_oe  = dir_q;

    // implemented-register report (combinational)
    always_comb begin
        case (local_off)
            6'd0, 6'd1, 6'd2, 6'd3, 6'd4: reg_hit = 1'b1;
            default:                      reg_hit = 1'b0;
        endcase
    end

    // sequential state updates
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            data_q <= 8'h00;
            dir_q  <= 8'h00;
        end else if (wr_en) begin
            case (local_off)
                6'd0:    data_q <= wdata[7:0];            // GPIO_DATA  : direct write
                6'd1:    dir_q  <= wdata[7:0];            // GPIO_DIR   : direct write
                6'd3:    data_q <= data_q | wdata[7:0];   // GPIO_SET   : set marked bits
                6'd4:    data_q <= data_q & ~wdata[7:0];  // GPIO_CLEAR : clear marked bits
                default: ;                                // GPIO_INPUT / unmapped: no effect
            endcase
        end
    end

    // combinational read data (0 when not hit; SET/CLEAR read as 0)
    always_comb begin
        case (local_off)
            6'd0:    rdata = {24'h0, data_q};
            6'd1:    rdata = {24'h0, dir_q};
            6'd2:    rdata = {24'h0, gpio_in};
            default: rdata = 32'h0000_0000;
        endcase
    end

endmodule