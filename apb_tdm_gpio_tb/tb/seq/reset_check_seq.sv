
class reset_check_seq extends apb_base_seq;
    `uvm_object_utils(reset_check_seq)

    function new(string name = "reset_check_seq");
        super.new(name);
    endfunction

    task body();
        bit [31:0] rdata;
        bit [31:0] expected;

        `uvm_info(get_type_name(), "Checking GPIO_DATA", UVM_MEDIUM)
        read(32'h000, rdata);
        if (rdata !== 32'h00000000)
            `uvm_error(get_type_name(), $sformatf("GPIO_DATA reset failed! Expected 0x00000000, Got 0x%08h", rdata))

        `uvm_info(get_type_name(), "Checking GPIO_DIR", UVM_MEDIUM)
        read(32'h004, rdata);
        if (rdata !== 32'h00000000)
            `uvm_error(get_type_name(), $sformatf("GPIO_DIR reset failed! Expected 0x00000000, Got 0x%08h", rdata))

        `uvm_info(get_type_name(), "Checking TDM_CONTROL", UVM_MEDIUM)
        read(32'h100, rdata);
        if (rdata !== 32'h00000000)
            `uvm_error(get_type_name(), $sformatf("TDM_CONTROL reset failed! Expected 0x00000000, Got 0x%08h", rdata))
        
        `uvm_info(get_type_name(), "Checking SYSTEM_CONTROL", UVM_MEDIUM)
        read(32'h208, rdata);
        if (rdata !== 32'h00000000)
            `uvm_error(get_type_name(), $sformatf("SYSTEM_CONTROL reset failed! Expected 0x00000000, Got 0x%08h", rdata))

        `uvm_info(get_type_name(), "Checking SYSTEM_ID", UVM_MEDIUM)
        read(32'h200, rdata);
        if (rdata !== 32'h54444D31)
            `uvm_error(get_type_name(), $sformatf("SYSTEM_ID reset failed! Expected 0x54444D31, Got 0x%08h", rdata))

    endtask

endclass
