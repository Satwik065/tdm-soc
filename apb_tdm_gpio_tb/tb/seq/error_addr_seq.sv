class error_addr_seq extends apb_base_seq;
    `uvm_object_utils(error_addr_seq)

    function new(string name = "error_addr_seq");
        super.new(name);
    endfunction

    task body();
        apb_item req;
        
        `uvm_info(get_type_name(), "TEST: Bad Address", UVM_MEDIUM)
        
        req = apb_item::type_id::create("req");
        start_item(req);
        req.pwrite = 1;
        req.paddr  = 32'h1000; 
        req.pwdata = 32'hDEADBEEF;
        finish_item(req);

        if (req.err !== 1) 
            `uvm_error(get_type_name(), "Expected PSLVERR for bad address, but got 0!")
        else
            `uvm_info(get_type_name(), "Got expected PSLVERR!", UVM_MEDIUM)
    endtask
endclass