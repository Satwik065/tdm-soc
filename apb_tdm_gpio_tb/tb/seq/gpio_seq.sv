
class gpio_seq extends apb_base_seq;
    `uvm_object_utils(gpio_seq)

    function new(string name = "gpio_seq");
        super.new(name);
    endfunction

    task body();
        bit [31:0] rdata;

        `uvm_info(get_type_name(), "TEST 1: GPIO Gating", UVM_MEDIUM)

        write(32'h000, 32'hAA);
        read(32'h000, rdata);

        if (rdata !== 32'h00)
            `uvm_error(get_type_name(),
                $sformatf("GPIO Gating FAILED! Expected 0x00, Got 0x%08h", rdata))

        `uvm_info(get_type_name(), "Enabling System", UVM_MEDIUM)

        write(32'h208, 32'h01);

        `uvm_info(get_type_name(), "TEST 2: GPIO Write/Read", UVM_MEDIUM)

        write(32'h000, 32'hAA);
        read(32'h000, rdata);

        if (rdata !== 32'hAA)
            `uvm_error(get_type_name(),
                $sformatf("GPIO Write/Read FAILED! Expected 0xAA, Got 0x%08h", rdata))

        `uvm_info(get_type_name(), "TEST 3: GPIO Direction", UVM_MEDIUM)

        write(32'h004, 32'hFF);
        read(32'h004, rdata);

        if (rdata !== 32'hFF)
            `uvm_error(get_type_name(),
                $sformatf("GPIO_DIR FAILED! Expected 0xFF, Got 0x%08h", rdata))


        `uvm_info(get_type_name(), "TEST 4: GPIO Set", UVM_MEDIUM)

        write(32'h00C, 32'h0F);
        read(32'h000, rdata);

        if (rdata !== 32'hAF)
            `uvm_error(get_type_name(),
                $sformatf("GPIO_SET FAILED! Expected 0xAF, Got 0x%08h", rdata))

        `uvm_info(get_type_name(), "TEST 5: GPIO Clear", UVM_MEDIUM)

        write(32'h010, 32'hF0);
        read(32'h000, rdata);

        if (rdata !== 32'h0F)
            `uvm_error(get_type_name(),
                $sformatf("GPIO_CLEAR FAILED! Expected 0x0F, Got 0x%08h", rdata))

        `uvm_info(get_type_name(), "GPIO SEQUENCE COMPLETED", UVM_LOW)

    endtask

endclass
