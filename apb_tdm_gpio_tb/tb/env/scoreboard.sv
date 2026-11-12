`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_sb)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp_apb #(apb_item, scoreboard) apb_export;
  uvm_analysis_imp_sb  #(sideband_item, scoreboard) sb_export;

  ref_model rm;

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    apb_export = new("apb_export", this);
    sb_export  = new("sb_export", this);

    rm = ref_model::type_id::create("rm");
  endfunction

  function void write_apb(apb_item item);

    bit [31:0] ex_data;

    if(item.pwrite == 1) begin
      rm.do_write(item.paddr, item.pwdata);
      `uvm_info("SCB_APB", $sformatf("WRITE  Addr:0x%03h Data:0x%08h", item.paddr, item.pwdata), UVM_HIGH)
    end
    else begin
      case(item.paddr)
        32'h000: ex_data = {24'h0, rm.data_q};
        32'h004: ex_data = {24'h0, rm.dir_q};
        32'h008: ex_data = 32'h0;
        32'h00C: ex_data = 32'h0;
        32'h010: ex_data = 32'h0;
        32'h100: ex_data = {31'h0, rm.tdm_enable};
        32'h110: ex_data = {30'h0, rm.slot};
        32'h200: ex_data = 32'h54444D31;
        32'h208: ex_data = {31'h0, rm.global_enable};
        default: ex_data = 32'h0;
      endcase

      if(item.prdata !== ex_data) begin
        `uvm_error("SCB_APB", $sformatf("READ MISMATCH at 0x%03h! Exp: 0x%08h, Act: 0x%08h", item.paddr, ex_data, item.prdata))
      end else begin
        `uvm_info("SCB_APB", $sformatf("READ   Addr:0x%03h Data:0x%08h [PASS]", item.paddr, item.prdata), UVM_HIGH)
      end
    end
  endfunction

  function void write_sb(sideband_item item);
    bit [3:0] ex_gr;
    if (item.gpio_out !== rm.data_q) begin
      `uvm_error("SCB_SB", $sformatf("GPIO_OUT MISMATCH! Exp: 0x%02h, Act: 0x%02h", rm.data_q, item.gpio_out))
    end
    if (item.gpio_oe !== rm.dir_q) begin
      `uvm_error("SCB_SB", $sformatf("GPIO_OE MISMATCH! Exp: 0x%02h, Act: 0x%02h", rm.dir_q, item.gpio_oe))
    end

    ex_gr = rm.predict_arbiter(item.tdm_req);

    if(item.tdm_grant !== ex_gr) begin
      `uvm_error("SCB_SB", $sformatf("TDM_GRANT MISMATCH! Req: 0x%01h, Exp: 0x%01h, Act: 0x%01h, Slot: %0d", item.tdm_req, ex_gr, item.tdm_grant, rm.slot))
    end
  endfunction
endclass
    
  



