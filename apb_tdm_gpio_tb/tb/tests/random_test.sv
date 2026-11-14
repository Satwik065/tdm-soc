class random_test extends base_test;
    `uvm_component_utils(random_test)

    random_seq seq;

    function new(string name = "random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        
        seq = random_seq::type_id::create("seq");
        seq.start(e.apb_agnt.sqr);
        
        phase.drop_objection(this);
    endtask
endclass