class sideband_monitor extends uvm_monitor;
    `uvm_component_utils(sideband_monitor)

    virtual sideband_if vif;

    uvm_analysis_port #(sideband_item) ap;

    function new(string name = "sideband_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual sideband_if)::get(this, "", "sideband_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found");
    endfunction

        task run_phase(uvm_phase phase);
        sideband_item item;
        forever begin
            @(posedge vif.clk);
            item = sideband_item::type_id::create("item");
            item.gpio_in   = vif.gpio_in;
            item.tdm_req   = vif.tdm_req;
            item.gpio_out  = vif.gpio_out;
            item.gpio_oe   = vif.gpio_oe;
            item.tdm_grant = vif.tdm_grant;
            item.tdm_slot  = vif.tdm_slot;
            ap.write(item);
        end
    endtask
endclass