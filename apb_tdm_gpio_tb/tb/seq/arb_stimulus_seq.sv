class arb_stimulus_seq extends uvm_sequence #(sideband_item);
    `uvm_object_utils(arb_stimulus_seq)

    function new(string name = "arb_stimulus_seq");
        super.new(name);
    endfunction

    task body();
        sideband_item req;
        
        `uvm_info(get_type_name(), "Driving tdm_req = 1111", UVM_MEDIUM)
        
        req = sideband_item::type_id::create("req");
        start_item(req);
        req.tdm_req = 4'b1111;
        req.gpio_in = 8'h00;
        req.hc      = 20; // Hold this request for 20 cycles
        finish_item(req);

        `uvm_info(get_type_name(), "Dropping tdm_req to 0000", UVM_MEDIUM)
        
        req = sideband_item::type_id::create("req");
        start_item(req);
        req.tdm_req = 4'b0000;
        req.gpio_in = 8'h00;
        req.hc      = 5;
        finish_item(req);
    endtask
endclass