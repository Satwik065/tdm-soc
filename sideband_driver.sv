class sideband_driver extends uvm_driver #(sideband_item);
    `uvm_component_utils(sideband_driver)

    virtual sideband_if vif;

    function new(string name = "sideband_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual sideband_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found");
    endfunction

    task run_phase(uvm_phase phase);
        @(vif.drv_cb);
        vif.drv_cb.gpio_in   <= 8'h0;
        vif.drv_cb.tdm_req   <= 4'h0;

        wait (vif.rst_n == 1);
        repeat (5) @(vif.drv_cb);
        `uvm_info(get_type_name(), "Starting driver", UVM_MEDIUM)

        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(sideband_item item);
      @(vif.drv_cb);
        vif.drv_cb.gpio_in     <= item.gpio_in;
        vif.drv_cb.tdm_req     <= item.tdm_req;

        repeat(item.hc) @(vif.drv_cb);

        vif.drv_cb.gpio_in     <= 8'h0;
        vif.drv_cb.tdm_req     <= 4'h0;

        @(vif.drv_cb);

        endtask
endclass
