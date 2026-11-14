class coverage extends uvm_subscriber #(apb_item);
    `uvm_component_utils(coverage)

    apb_item req;

    covergroup apb_cg;
        cp_addr: coverpoint req.paddr {
            bins gpio_data = {32'h000};
            bins gpio_dir  = {32'h004};
            bins gpio_set  = {32'h00C};
            bins tdm_ctrl  = {32'h100};
            bins sys_id    = {32'h200};
            bins sys_ctrl  = {32'h208};
            bins err_addr  = default; // Catch bad addresses
        }
        cp_write: coverpoint req.pwrite;
        cx_wr_addr: cross cp_write, cp_addr;
    endgroup

    function new(string name = "coverage", uvm_component parent = null);
        super.new(name, parent);
        apb_cg = new();
    endfunction

    function void write(apb_item t);
        req = t;
        apb_cg.sample();
    endfunction
endclass