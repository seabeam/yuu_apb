/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_MONITOR_SV
`define YUU_APB_SLAVE_MONITOR_SV

class yuu_apb_slave_monitor extends uvm_monitor;
  virtual yuu_apb_slave_interface vif;
  uvm_analysis_port #(yuu_apb_slave_item)  out_monitor_ap;

  yuu_apb_slave_config cfg;
  uvm_event_pool events;

  yuu_apb_slave_item item;
  yuu_apb_slave_sequencer sequencer;
  yuu_apb_slave_response_sequence resp_seq;

  `uvm_register_cb(yuu_apb_slave_monitor, yuu_apb_slave_monitor_callback)

  `uvm_component_utils_begin(yuu_apb_slave_monitor)
  `uvm_component_utils_end

  extern                   function      new          (string name, uvm_component parent);
  extern           virtual function void build_phase  (uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          reset_phase  (uvm_phase phase);
  extern           virtual task          main_phase   (uvm_phase phase);
  extern protected virtual task          collect      ();
  extern protected virtual task          wait_reset   (uvm_phase phase);
endclass

function yuu_apb_slave_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_slave_monitor::build_phase(uvm_phase phase);
  if (cfg == null)
    `uvm_fatal("build_phase", "yuu_apb_slave agent configuration is null")
  out_monitor_ap = new("out_monitor_ap", this);
endfunction

function void yuu_apb_slave_monitor::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  events = cfg.events;
endfunction

task yuu_apb_slave_monitor::reset_phase(uvm_phase phase);
  if (cfg.sequencer_ptr == null)
    `uvm_fatal("reset_phase", "Sequencer handle in YUU_APB slave configuration has not been set yet")
  this.sequencer = cfg.sequencer_ptr;
  this.sequencer.stop_sequences();
endtask

task yuu_apb_slave_monitor::main_phase(uvm_phase phase);
  wait(vif.preset_n === 1'b1);
  @(vif.mon_cb);
  fork
    forever begin
      item = yuu_apb_slave_item::type_id::create("mon_item");
      item.cfg = cfg;
      item.error_object = yuu_apb_error::type_id::create("error_object");
      item.randomize();
      `uvm_do_callbacks(yuu_apb_slave_monitor, yuu_apb_slave_monitor_callback, pre_collect(this, item));
      collect();
      `uvm_do_callbacks(yuu_apb_slave_monitor, yuu_apb_slave_monitor_callback, post_collect(this, item));
    end
    wait_reset(phase);
  join
endtask

task yuu_apb_slave_monitor::collect();
  uvm_event observe_trans_begin = events.get($sformatf("%s_observe_trans_begin", cfg.get_name()));
  uvm_event observe_trans_end   = events.get($sformatf("%s_observe_trans_end", cfg.get_name()));

  while(vif.mon_cb.psel !== 1'b1)
    @(vif.mon_cb);

  observe_trans_begin.trigger();

  item.addr       = vif.mon_cb.paddr;
  item.direction  = yuu_apb_direction_e'(vif.mon_cb.pwrite);
  if (cfg.apb4_enable) begin
    item.strb = vif.mon_cb.pstrb;
    {item.prot2, item.prot1, item.prot0} = vif.mon_cb.pprot;
  end
  if (item.direction == WRITE)
    item.data = vif.mon_cb.pwdata;
  // TODO
  //foreach (cfg.maps[i])
    //if (!cfg.maps[i].is_contain(item.addr)) begin
      //item.error_object.error_type = INVALID_ADDR;
      //`uvm_error("yuu_apb_monitor", "Access to apb slave out of bound")
    //end
  resp_seq = yuu_apb_slave_response_sequence::type_id::create("resp_seq");
  resp_seq.set_item(item);
  resp_seq.start(sequencer); 
  while (vif.mon_cb.penable !== 1'b1)
    @(vif.mon_cb);
  if (cfg.apb3_enable)  
    while (vif.mon_cb.pready !== 1'b1)
      @(vif.mon_cb);
  if (item.direction == READ)
    item.data = vif.mon_cb.prdata;
  out_monitor_ap.write(item);
  `uvm_info("collect", $sformatf("Collected yuu_apb_slave transaction (Direction:%s Addr:%8h Data:%8h)", item.direction, item.addr, item.data), UVM_HIGH)
  @(vif.mon_cb);

  observe_trans_end.trigger();
endtask

task yuu_apb_slave_monitor::wait_reset(uvm_phase phase);
  @(negedge vif.preset_n);
  phase.jump(uvm_reset_phase::get());
endtask

`endif
