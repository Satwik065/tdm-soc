package tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "agents/apb_agent/apb_item.sv"
    `include "agents/apb_agent/apb_sequencer.sv"
    `include "agents/apb_agent/apb_driver.sv"
    `include "agents/apb_agent/apb_monitor.sv"
    `include "agents/apb_agent/apb_agent.sv"

    `include "agents/sideband_agent/sideband_item.sv"
    `include "agents/sideband_agent/sideband_sequencer.sv"
    `include "agents/sideband_agent/sideband_driver.sv"
    `include "agents/sideband_agent/sideband_monitor.sv"
    `include "agents/sideband_agent/sideband_agent.sv"

    `include "env/env_cfg.sv"
    `include "env/ref_model.sv"
    `include "env/scoreboard.sv"
    `include "env/env.sv"

    `include "seq/apb_base_seq.sv"
    `include "seq/read_id_seq.sv"

    `include "tests/base_test.sv"
    `include "tests/id_test.sv"
endpackage