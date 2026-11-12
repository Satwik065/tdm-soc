class ref_model extends uvm_object;
    `uvm_object_utils(ref_model)

    bit [7:0] data_q;
    bit [7:0] dir_q;
    bit tdm_enable;
    bit global_enable;
    bit [1:0] slot;

    function new(string name = "ref_model");
        super.new(name);
        data_q = 8'h0;
        dir_q = 8'h0;
        tdm_enable = 1'b0;
        global_enable = 1'b0;
        slot = 2'h0;
    endfunction

    function void do_write(bit [31:0] addr, bit [31:0] data);
        case (addr)
            32'h000: begin
                if(global_enable) begin
                    data_q = data[7:0];
                end
            32'h004: begin
                if(global_enable) begin
                    dir_q = data[7:0];
                end
            end
            32'h00C: begin
                if(global_enable) begin
                    data_q = data_q | data[7:0];
                end
            end

            32'h010: begin
                if(global_enable) begin
                    data_q = data_q & ~data[7:0];
                end
            end

            32'h100: tdm_enable = data[0];
            32'h104: global_enable = data[0];
            default;
        endcase
        endfunction

    function bit [3:0] predict_arbiter(bit [3:0] req);
        bit arb_en;
        bit [1:0] grant_idx;
        int i;

        arb_en = tdm_enable & global_enable;

        if(!arb_en || req == 4'b0000) begin
            return 4'b0000;
        end

        grant_idx = slot;
        for(i=0; i<4; i++) begin
            if(req[(slot + i) % 4] == 1'b1) begin
                grant_idx = (slot + i) % 4;
                break;
            end
        end

        slot = (grant_idx + 1) % 4;
        return 4'b0001 << grant_idx;
    endfunction
endclass
    