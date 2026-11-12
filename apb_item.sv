class apb_item extends uvm_sequence_item;
  
   rand bit [31:0] paddr;
   rand bit [31:0] pwdata;
   rand bit        pwrite;
   
   bit [31:0] prdata;
   bit        err;

   `uvm_object_utils_begin(apb_item)
     `uvm_field_int(paddr, UVM_ALL_ON)
     `uvm_field_int(pwdata, UVM_ALL_ON)
     `uvm_field_int(pwrite, UVM_ALL_ON)
     `uvm_field_int(prdata, UVM_ALL_ON)
     `uvm_field_int(err, UVM_ALL_ON)
    `uvm_object_utils_end

    function string convert2string();
    return $sformatf("%s addr=0x%08h %s=0x%08h err=%0b",
                     pwrite ? "WR" : "RD",
                     paddr,
                     pwrite ? "w_data" : "r_data",
                     pwrite ? pwdata : prdata,
                     err);
    endfunction

    function new(string name = "apb_item");
        super.new(name);
    endfunction
endclass