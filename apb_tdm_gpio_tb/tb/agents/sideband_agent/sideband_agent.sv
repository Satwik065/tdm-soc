class sideband_agent extends uvm_agent;
    `uvm_component_utils(sideband_agent)

    sideband_driver dvr;
    sideband_sequencer sqr;
    sideband_monitor mon;
    uvm_analysis_port #(sideband_item) ap;

    function new(string name = "sideband_agent", uvm_component parent = null);
         super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon = sideband_monitor::type_id::create("mon", this);
        ap = new("ap", this);

        if(get_is_active() == UVM_ACTIVE) begin
            sqr = sideband_sequencer::type_id::create("sqr", this);
            dvr = sideband_driver::type_id::create("dvr", this);
        end
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            mon.ap.connect(ap);
            if(get_is_active() == UVM_ACTIVE) begin
                dvr.seq_item_port.connect(sqr.seq_item_export);
            end
        endfunction
endclass
