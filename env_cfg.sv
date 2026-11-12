class env_cfg extends uvm_object;
    `uvm_object_utils(env_cfg)

    function new(string name = "env_cfg");
        super.new(name);
    endfunction

    uvm_active_passive_enum apb_is_active = UVM_ACTIVE;
    uvm_active_passive_enum sideband_is_active = UVM_ACTIVE;

endclass