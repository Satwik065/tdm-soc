class read_id_seq extends apb_base_seq;
    `uvm_object_utils(read_id_seq)

    function new(string name = "read_id_seq");
        super.new(name);
    endfunction

    task body();
       bit [31:0] rdata;
      
       read(32'h200, rdata);

       if (rdata != 32'h54444D31) begin
         `uvm_error(get_type_name(), 
                 $sformatf("ID Mismatch! Expected: 32'h54444D31, Received: 32'h%08h", read_data))
       end else begin
                `uvm_info(get_type_name(), "ID Read PASSED!", UVM_MEDIUM)
       end
  endtask
endclass