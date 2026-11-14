class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;
    uvm_analysis_port #(apb_item) ap;

    function new(string name = "apb_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found");
    endfunction

    task run_phase(uvm_phase phase);
        apb_item item;
        forever begin
            @(posedge vif.clk);
            // one item per transfer, at the edge that ends ACCESS
            if (vif.psel && vif.penable && vif.pready) begin
                item = apb_item::type_id::create("item");
                item.paddr  = vif.paddr;
                item.pwrite = vif.pwrite;
                if (vif.pwrite) item.pwdata = vif.pwdata;
                else            item.prdata = vif.prdata;
                item.err = vif.pslverr;
                ap.write(item);
            end
        end
    endtask
endclass