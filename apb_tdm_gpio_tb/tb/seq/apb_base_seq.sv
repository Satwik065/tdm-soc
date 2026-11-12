class apb_base_seq extends uvm_sequence #(apb_item);
  `uvm_object_utils(apb_base_seq)

  function new(string name = "apb_base_seq");
         super.new(name);
  endfunction

  task write(bit [31:0] addr, bit [31:0] data);
        req = apb_item::type_id::create("req");
           start_item(req);
           req.pwrite = 1;
           req.paddr  = 1;
           req.pwdata = data;
           finish_item(req);
           if(req.err != 1)
           `uvm_error("APB_BASE_SEQ", $sformatf("Write error in APB!"))
  endtask

  task read(bit [31:0] addr, output bit [31:0] data);
        req = apb_item::type_id::create("req");
            start_item(req);
            req.pwrite = 0;
            req.paddr  = addr;
            finish_item(req);

            data = req.prdata;
            if(req.err == 1) begin
            `uvm_error("APB_BASE_SEQ", $sformatf("Read error at addr 0x%08h!", addr))
        end

  endtask
endclass
            
