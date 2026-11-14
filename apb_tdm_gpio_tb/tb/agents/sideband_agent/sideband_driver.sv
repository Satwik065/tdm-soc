class sideband_driver extends uvm_driver #(sideband_item);
    `uvm_component_utils(sideband_driver)

    virtual sideband_if vif;

    function new(string name = "sideband_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual sideband_if)::get(this, "", "sideband_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found");
    endfunction

        task run_phase(uvm_phase phase);
        @(posedge vif.clk);
        vif.gpio_in <= 0; vif.tdm_req <= 0;
        wait (vif.rst_n == 1);
        repeat (5) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(sideband_item item);
        @(posedge vif.clk);
        vif.gpio_in <= item.gpio_in;
        vif.tdm_req <= item.tdm_req;
        repeat(item.hc) @(posedge vif.clk);
        vif.gpio_in <= 0;
        vif.tdm_req <= 0;
        @(posedge vif.clk);
    endtask
endclass
