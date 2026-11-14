`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_sb)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp_apb #(apb_item, scoreboard)      apb_export;
  uvm_analysis_imp_sb  #(sideband_item, scoreboard) sb_export;

  ref_model rm;

  // Writes waiting to be applied to the model one clock after their ACCESS edge
  time       wr_ts   [$];
  bit [31:0] wr_addr [$];
  bit [31:0] wr_data [$];

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_export = new("apb_export", this);
    sb_export  = new("sb_export", this);
    rm = ref_model::type_id::create("rm");
  endfunction

  // Apply every pending write strictly older than 'now', then commit slot
  function void flush_pending(time now);
    bit [31:0] a, d;
    while (wr_ts.size() > 0 && wr_ts[0] < now) begin
      void'(wr_ts.pop_front());
      a = wr_addr.pop_front();
      d = wr_data.pop_front();
      rm.do_write(a, d);
    end
    rm.commit_slot(now);
  endfunction

  function bit is_valid_addr(bit [31:0] a);
    case (a)
      32'h000, 32'h004, 32'h008, 32'h00C, 32'h010,
      32'h100, 32'h104, 32'h108, 32'h10C, 32'h110,
      32'h200, 32'h204, 32'h208: return 1;
      default:                   return 0;
    endcase
  endfunction

  //---------------------------------------------------------------------------
  // APB transfers
  //---------------------------------------------------------------------------
  function void write_apb(apb_item item);
    bit [31:0] ex_data;
    bit        valid;
    bit        exp_err;
    bit        skip;
    time       now;

    now = $time;
    flush_pending(now);              // model state as of this transfer's ACCESS cycle
    valid   = is_valid_addr(item.paddr);
    exp_err = !valid;
    skip    = 0;

    if (item.err !== exp_err)
      `uvm_error("SCB_APB", $sformatf("PSLVERR MISMATCH at 0x%03h! Exp: %0b, Act: %0b",
                                      item.paddr, exp_err, item.err))

    if (item.pwrite == 1) begin
      if (valid) begin
        wr_ts.push_back(now);
        wr_addr.push_back(item.paddr);
        wr_data.push_back(item.pwdata);
      end
      `uvm_info("SCB_APB", $sformatf("WRITE  Addr:0x%03h Data:0x%08h", item.paddr, item.pwdata), UVM_HIGH)
    end
    else begin
      case (item.paddr)
        32'h000: ex_data = {24'h0, rm.data_q};
        32'h004: ex_data = {24'h0, rm.dir_q};
        32'h00C: ex_data = 32'h0;
        32'h010: ex_data = 32'h0;
        32'h100: ex_data = {31'h0, rm.tdm_enable};
        32'h110: ex_data = {30'h0, rm.slot};
        32'h200: ex_data = 32'h5444_4D31;
        32'h208: ex_data = {31'h0, rm.global_enable};
        // live registers: depend on pins in this exact cycle, not checked yet
        32'h008, 32'h104, 32'h108, 32'h10C, 32'h204: begin
          skip    = 1;
          ex_data = 32'h0;
        end
        default: ex_data = 32'h0;    // invalid address reads as 0
      endcase

      if (skip) begin
        `uvm_info("SCB_APB", $sformatf("READ   Addr:0x%03h is a live register, not checked yet", item.paddr), UVM_HIGH)
      end
      else if (item.prdata !== ex_data) begin
        `uvm_error("SCB_APB", $sformatf("READ MISMATCH at 0x%03h! Exp: 0x%08h, Act: 0x%08h",
                                        item.paddr, ex_data, item.prdata))
      end
      else begin
        `uvm_info("SCB_APB", $sformatf("READ   Addr:0x%03h Data:0x%08h [PASS]", item.paddr, item.prdata), UVM_HIGH)
      end
    end
  endfunction

  //---------------------------------------------------------------------------
  // Sideband samples (one per clock)
  //---------------------------------------------------------------------------
  function void write_sb(sideband_item item);
    bit [3:0] ex_gr;
    bit [1:0] slot_before;

    flush_pending($time);            // writes from earlier clocks are now visible on the pins

    if (item.gpio_out !== rm.data_q)
      `uvm_error("SCB_SB", $sformatf("GPIO_OUT MISMATCH! Exp: 0x%02h, Act: 0x%02h", rm.data_q, item.gpio_out))
    if (item.gpio_oe !== rm.dir_q)
      `uvm_error("SCB_SB", $sformatf("GPIO_OE MISMATCH! Exp: 0x%02h, Act: 0x%02h", rm.dir_q, item.gpio_oe))

    // check the slot pin BEFORE predicting (prediction schedules the next slot)
    if (item.tdm_slot !== rm.slot)
      `uvm_error("SCB_SB", $sformatf("TDM_SLOT MISMATCH! Exp: %0d, Act: %0d", rm.slot, item.tdm_slot))

    slot_before = rm.slot;
    ex_gr = rm.predict_arbiter(item.tdm_req, $time);

    if (item.tdm_grant !== ex_gr)
      `uvm_error("SCB_SB", $sformatf("TDM_GRANT MISMATCH! Req: 0x%01h, Exp: 0x%01h, Act: 0x%01h, Slot: %0d",
                                     item.tdm_req, ex_gr, item.tdm_grant, slot_before))
  endfunction
endclass
    
  



