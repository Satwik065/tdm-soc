class sideband_item extends uvm_sequence_item;

    rand bit [7:0] gpio_in;
    rand bit [3:0] tdm_req;
    rand int unsigned hc;

    bit [7:0] gpio_out;
    bit [7:0] gpio_oe;
    bit [3:0] tdm_grant;
    bit [1:0] tdm_slot;

    constraint c_hc {c_hc inside {[0:3]};}

    `uvm_object_utils_begin(sideband_item)
        `uvm_field_int(gpio_in, UVM_ALL_ON)
        `uvm_field_int(tdm_req, UVM_ALL_ON)
        `uvm_field_int(hc, UVM_ALL_ON)
        `uvm_field_int(gpio_out, UVM_ALL_ON)
        `uvm_field_int(gpio_oe, UVM_ALL_ON)
        `uvm_field_int(tdm_grant, UVM_ALL_ON)
        `uvm_field_int(tdm_slot, UVM_ALL_ON)
    `uvm_object_utils_end

    function string convert2string();
        return $sformatf("gpio_in=0x%02h tdm_req=0x%01h hc=%0d gpio_out=0x%02h gpio_oe=0x%02h tdm_grant=0x%01h tdm_slot=0x%01h",
                         gpio_in,
                         tdm_req,
                         hc,
                         gpio_out,
                         gpio_oe,
                         tdm_grant,
                         tdm_slot);
    endfunction

    function new(string name = "sideband_item");
        super.new(name);
    endfunction
endclass