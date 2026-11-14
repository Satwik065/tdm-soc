class arb_config_seq extends apb_base_seq;
    `uvm_object_utils(arb_config_seq)

    function new(string name = "arb_config_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Enabling System and TDM Arbiter", UVM_MEDIUM)
        write(32'h208, 32'h1); // Turn on global_enable
        write(32'h100, 32'h1); // Turn on tdm_enable
    endtask
endclass