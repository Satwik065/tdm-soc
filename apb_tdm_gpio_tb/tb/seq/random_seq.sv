class random_seq extends apb_base_seq;
    `uvm_object_utils(random_seq)

    function new(string name = "random_seq");
        super.new(name);
    endfunction

    task body();
        bit [31:0] rdata;
        
        `uvm_info(get_type_name(), "STARTING RANDOM CHAOS", UVM_LOW)

        // 1. Enable system so GPIO works
        write(32'h208, 32'h1);
        write(32'h100, 32'h1);

        // 2. Throw 50 random APB transactions
        repeat (50) begin
            req = apb_item::type_id::create("req");
            start_item(req);
            
            if (!req.randomize() with { paddr inside {32'h000, 32'h004, 32'h008, 32'h00C, 32'h010, 32'h100, 32'h104, 32'h108, 32'h10C, 32'h110, 32'h200, 32'h204, 32'h208}; }) 
                `uvm_error("RAND", "Randomization failed")
            
            finish_item(req);
        end
    endtask
endclass