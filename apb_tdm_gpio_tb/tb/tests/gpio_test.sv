class gpio_test extends base_test;
    `uvm_component_utils(gpio_test)

    gpio_seq seq; 

    function new(string name = "gpio_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        phase.raise_objection(this);
        
        seq = gpio_seq::type_id::create("seq");
        seq.start(e.apb_agnt.sqr);
        
        phase.drop_objection(this);
    endtask
endclass