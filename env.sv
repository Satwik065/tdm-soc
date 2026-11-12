class env extends uvm_env;
    `uvm_component_utils(env)

    apb_agent apb_agnt;
    sideband_agent sb_agnt;
    scoreboard scb;

    env_cfg   cfg;

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    if (!uvm_config_db#(env_cfg)::get(this, "", "env_cfg", cfg)) begin
            `uvm_fatal("NO_CFG", "env_cfg not found in config_db!")
        end
    
    uvm_config_db#(uvm_active_passive_enum)::set(this, "apb_agnt", "is_active", cfg.apb_is_active);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "sb_agnt", "is_active", cfg.sideband_is_active);

    
    apb_agnt = apb_agent::type_id::create("apb_agnt", this);
    sb_agnt  = sideband_agent::type_id::create("sb_agnt", this);
    scb      = scoreboard::type_id::create("scb", this);

    `uvm_info(get_type_name(), "Building Environment", UVM_MEDIUM)

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        apb_agnt.ap.connect(scb.apb_export);
        sb_agnt.ap.connect(scb.sideband_export);
        endfunction
endclass
