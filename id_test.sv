class id_test extends base_test;
    `uvm_component_utils(base_test)

    function new(string name = "id_test", uvm_component parent = null);
       super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
       super.run_phase(phase);

       phase.raise_objection(this);

       read_id_seq seq = read_id_seq::type_id::create("seq");

       seq.start(e.apb_agnt.sqr);

       phase.drop_objection(this);
    endtask
endclass
