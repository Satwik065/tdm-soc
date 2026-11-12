class sideband_sequencer extends uvm_sequencer #(sideband_item);
    `uvm_component_utils(sideband_sequencer)

    function new(string name = "sideband_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass