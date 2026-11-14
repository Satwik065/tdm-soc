class error_addr_test extends base_test;
    `uvm_component_utils(error_addr_test)

    error_addr_seq seq; 

    function new(string name = "error_addr_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        phase.raise_objection(this);
        
        seq = error_addr_seq::type_id::create("seq");
        seq.start(e.apb_agnt.sqr);
        
        phase.drop_objection(this);
    endtask
endclass