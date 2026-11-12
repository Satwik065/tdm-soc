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
          if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
              `uvm_fatal("NOVIF", "Virtual Interface no found");
     endfunction

    task run_phase(uvm_phase phase);
        forever begin
            
            @(vif.mon_cb);
            if(vif.mon_cb.psel && vif.mon_cb.penable) begin
                apb_item item = apb_item::type_id::create("item");
                item.paddr  = vif.mon_cb.paddr;
                item.pwrite = vif.mon_cb.pwrite;
                if(vif.mon_cb.pwrite) begin
                    item.pwdata = vif.mon_cb.pwdata;
                end else begin
                    item.prdata = vif.mon_cb.prdata;
                end
                item.err = vif.mon_cb.pslverr;
                ap.write(item);
            end
        end
    endtask
endclass