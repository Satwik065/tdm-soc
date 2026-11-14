class arb_test extends base_test;
    `uvm_component_utils(arb_test)

    arb_config_seq    apb_seq;
    arb_stimulus_seq  sb_seq;

    function new(string name = "arb_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        apb_seq = arb_config_seq::type_id::create("apb_seq");
        sb_seq  = arb_stimulus_seq::type_id::create("sb_seq");

        fork
            apb_seq.start(e.apb_agnt.sqr);
            sb_seq.start(e.sb_agnt.sqr);
        join

        phase.drop_objection(this);
    endtask
endclass