/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_MONITOR_SV
`define YUU_APB_MASTER_MONITOR_SV

class yuu_apb_master_monitor extends uvm_monitor;
  virtual yuu_apb_master_interface vif;
  uvm_analysis_port #(yuu_apb_master_item) out_monitor_ap;
  
  yuu_apb_master_config cfg;
  uvm_event_pool events;

  yuu_apb_master_item item;

  `uvm_register_cb(yuu_apb_master_monitor, yuu_apb_master_monitor_callback)

  `uvm_component_utils_begin(yuu_apb_master_monitor)
  `uvm_component_utils_end

  extern                   function      new          (string name, uvm_component parent);
  extern           virtual function void build_phase  (uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          main_phase   (uvm_phase phase);
  extern protected virtual task          collect      ();
  extern protected virtual task          wait_reset   (uvm_phase phase);
endclass

function yuu_apb_master_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_master_monitor::build_phase(uvm_phase phase);
  if (cfg == null)
    `uvm_fatal("build_phase", "yuu_apb_master agent configuration is null")
  out_monitor_ap = new("out_monitor_ap", this);
endfunction

function void yuu_apb_master_monitor::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  events = cfg.events;
endfunction

task yuu_apb_master_monitor::main_phase(uvm_phase phase);
  wait(vif.preset_n === 1'b1);
  @(vif.mon_cb);
  fork
    forever begin
      item = yuu_apb_master_item::type_id::create("mon_item");
      `uvm_do_callbacks(yuu_apb_master_monitor, yuu_apb_master_monitor_callback, pre_collect(this, item));
      collect();
      `uvm_do_callbacks(yuu_apb_master_monitor, yuu_apb_master_monitor_callback, post_collect(this, item));
    end
    wait_reset(phase);
  join
endtask

task yuu_apb_master_monitor::collect();
  uvm_event observe_trans_begin = events.get($sformatf("%s_observe_trans_begin", cfg.get_name()));
  uvm_event observe_trans_end   = events.get($sformatf("%s_observe_trans_end", cfg.get_name()));

  while (vif.mon_cb.psel !== 1'b1)
    @(vif.mon_cb);

  observe_trans_begin.trigger();

  item.addr       = vif.mon_cb.paddr;
  item.direction  = yuu_apb_direction_e'(vif.mon_cb.pwrite);
  if (item.direction == WRITE)
    item.data = vif.mon_cb.pwdata;
  if (cfg.apb4_enable) begin
    item.strb = vif.mon_cb.pstrb;
    {item.prot2, item.prot1, item.prot0} = vif.mon_cb.pprot;
  end
  while (vif.mon_cb.penable !== 1'b1)
    @(vif.mon_cb);
  if (cfg.apb3_enable) begin
    while (vif.mon_cb.pready !== 1'b1)
      @(vif.mon_cb);
    item.resp = yuu_apb_response_e'(vif.cb.pslverr);
  end
  if (item.direction == READ)
    item.data = vif.mon_cb.prdata;
  out_monitor_ap.write(item);
  `uvm_info("collect", $sformatf("Collected yuu_apb_master transaction (Direction:%s Addr:%8h Data:%8h)", item.direction, item.addr, item.data), UVM_HIGH)
  @(vif.mon_cb);

  observe_trans_end.trigger();
endtask

task yuu_apb_master_monitor::wait_reset(uvm_phase phase);
  @(negedge vif.preset_n);
  phase.jump(uvm_reset_phase::get());
endtask

`endif
