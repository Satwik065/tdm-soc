class ref_model extends uvm_object;
    `uvm_object_utils(ref_model)

    // GPIO / TDM / SYSTEM state (values as of the current clock)
    bit [7:0] data_q;
    bit [7:0] dir_q;
    bit       tdm_enable;
    bit       global_enable;
    bit [1:0] slot;

    // slot update waiting for the next clock edge
    bit [1:0] slot_next;
    time      slot_ts;
    bit       slot_pend;

    function new(string name = "ref_model");
        super.new(name);
        data_q        = 0;
        dir_q         = 0;
        tdm_enable    = 0;
        global_enable = 0;
        slot          = 0;
        slot_next     = 0;
        slot_ts       = 0;
        slot_pend     = 0;
    endfunction

    // Apply a register write. Call this one clock AFTER the write's ACCESS edge.
    function void do_write(bit [31:0] addr, bit [31:0] data);
        case (addr)
            32'h000: if (global_enable) data_q = data[7:0];
            32'h004: if (global_enable) dir_q  = data[7:0];
            32'h00C: if (global_enable) data_q = data_q |  data[7:0];
            32'h010: if (global_enable) data_q = data_q & ~data[7:0];
            32'h100: tdm_enable    = data[0];
            32'h208: global_enable = data[0];
            default: ;   // read-only or unmapped: no state change
        endcase
    endfunction

    // Commit a pending slot update once a later clock has arrived.
    function void commit_slot(time now);
        if (slot_pend && slot_ts < now) begin
            slot      = slot_next;
            slot_pend = 0;
        end
    endfunction

    // Predict the grant for this clock's req sample.
    // The slot change it causes is held back until the next clock.
    function bit [3:0] predict_arbiter(bit [3:0] req, time now);
        bit       arb_en;
        bit [1:0] grant_idx;
        int       i;

        commit_slot(now);
        arb_en = tdm_enable & global_enable;

        if (!arb_en || req == 4'b0000) begin
            return 4'b0000;
        end

        grant_idx = slot;
        for (i = 0; i < 4; i++) begin
            if (req[(slot + i) % 4]) begin
                grant_idx = (slot + i) % 4;
                break;
            end
        end

        slot_next = grant_idx + 1;   // 2-bit wrap
        slot_ts   = now;
        slot_pend = 1;
        return 4'b0001 << grant_idx;
    endfunction
endclass