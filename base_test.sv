class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  env e;
  env_cfg cfg;

  function new(string name = "base_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      e = env::type_id::create("e", this);
      cfg = env_cfg::type_id::create("cfg");
      cfg.apb_is_active = UVM_ACTIVE;
      cfg.sideband_is_active = UVM_ACTIVE;
      uvm_config_db#(env_cfg)::set(this,"*","env_cfg", cfg);
  endfunction

  virtual task run_phase(uvm_phase phase);
  endtask

endclass




