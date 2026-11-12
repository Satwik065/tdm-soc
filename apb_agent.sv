class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    apb_driver dvr;
    apb_sequencer sqr;
    apb_monitor mon;
    uvm_analysis_port #(apb_item) ap;

    function new(string name = "apb_agent", uvm_component parent = null);
       super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);
    
       mon = apb_monitor::type_id::create("mon", this);
       ap = new("ap", this);

       if(get_is_active() == UVM_ACTIVE) begin
         sqr = apb_sequencer::type_id::create("sqr", this);
         dvr = apb_driver::type_id::create("dvr", this);
         
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