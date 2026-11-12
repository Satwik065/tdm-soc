class apb_driver extends uvm_driver #(apb_item);
     `uvm_component_utils(apb_driver)

        virtual apb_if vif;

        function new(string name = "apb_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
               `uvm_fatal("NOVIF", "Virtual Interface no found");
        endfunction

        task run_phase(uvm_phase phase);
            @(vif.drv_cb);
            vif.drv_cb.psel  <= 0;
            vif.drv_cb.penable <= 0;
            vif.drv_cb.pwrite <= 0;
            vif.drv_cb.paddr <= 32'h0;
            vif.drv_cb.pwdata <= 32'h0;

            wait (vif.rst_n == 1);
            repeat (5) @(vif.drv_cb);
            `uvm_info(get_type_name(), "Starting driver", UVM_MEDIUM)

            forever begin

                seq_item_port.get_next_item(req);
                drive_item(req);
                seq_item_port.item_done();
            end
            endtask

            task drive_item(apb_item item);
                int timeout_count = 0;
                const int max_wait_cycles = 100;

                @(vif.drv_cb);
                vif.drv_cb.paddr   <= item.paddr;
                vif.drv_cb.pwrite  <= item.pwrite;
                vif.drv_cb.psel    <= 1;
                vif.drv_cb.penable <= 1'b0;

                if(item.pwrite) begin
                    vif.drv_cb.pwdata <= item.pwdata;
                end

                @(vif.drv_cb);
                vif.drv_cb.penable <= 1'b1;

                do begin
                    @(vif.drv_cb);
                    timeout_count++;
                    if(timeout_count > max_wait_cycles) begin
                        `uvm_error(get_type_name(), $sformatf("Timeout waiting for pready signal for address 0x%08h", item.paddr));
                        item.err = 1;
                        vif.drv_cb.psel    <= 1'b0;
                        vif.drv_cb.penable <= 1'b0;
                        return;
                    end
                end while (!vif.drv_cb.pready);

                if(!item.pwrite) begin
                    item.prdata = vif.drv_cb.prdata;
                end
                
                @(vif.drv_cb);
                item.err = vif.drv_cb.pslverr;

                vif.drv_cb.psel    <= 1'b0;
                vif.drv_cb.penable <= 1'b0;

                @(vif.drv_cb);
            endtask
endclass
