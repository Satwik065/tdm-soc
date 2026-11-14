class apb_driver extends uvm_driver #(apb_item);
     `uvm_component_utils(apb_driver)

        virtual apb_if vif;

        function new(string name = "apb_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
               `uvm_fatal("NOVIF", "Virtual Interface no found");
        endfunction

            task run_phase(uvm_phase phase);
        @(posedge vif.clk);
        vif.psel <= 0; vif.penable <= 0; vif.pwrite <= 0; vif.paddr <= 0; vif.pwdata <= 0;
        wait (vif.rst_n == 1);
        repeat (5) @(posedge vif.clk);
        `uvm_info(get_type_name(), "Starting driver", UVM_MEDIUM)
        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(apb_item item);
        int timeout_count = 0;
        @(posedge vif.clk);
        vif.paddr <= item.paddr;
        vif.pwrite <= item.pwrite;
        vif.psel <= 1;
        vif.penable <= 0;
        if(item.pwrite) vif.pwdata <= item.pwdata;

        @(posedge vif.clk);
        vif.penable <= 1;

        do begin
            @(posedge vif.clk);
            timeout_count++;
            if(timeout_count > 100) begin
                `uvm_error("DRV", "Timeout")
                vif.psel <= 0; vif.penable <= 0;
                return;
            end
        end while (!vif.pready);

        if(!item.pwrite) item.prdata = vif.prdata;
        item.err = vif.pslverr;

        vif.psel <= 0;
        vif.penable <= 0;
        @(posedge vif.clk);
    endtask
endclass
