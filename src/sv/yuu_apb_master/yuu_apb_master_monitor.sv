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
  protected process processes[string];

  protected yuu_apb_master_item monitor_item;

  `uvm_register_cb(yuu_apb_master_monitor, yuu_apb_master_monitor_callback)

  `uvm_component_utils_begin(yuu_apb_master_monitor)
  `uvm_component_utils_end

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          run_phase(uvm_phase phase);

  extern protected virtual task          init_component();
  extern protected virtual task          collect();
  extern protected virtual task          wait_reset();
endclass

function yuu_apb_master_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_master_monitor::build_phase(uvm_phase phase);
  out_monitor_ap = new("out_monitor_ap", this);
endfunction

function void yuu_apb_master_monitor::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  this.events = cfg.events;
endfunction

task yuu_apb_master_monitor::run_phase(uvm_phase phase);
  process proc_monitor;

  init_component();
  fork
    forever begin 
      wait(vif.mon_mp.preset_n === 1'b1);
      fork
        begin
          proc_monitor = process::self();
          processes["proc_monitor"] = proc_monitor;
          monitor_item = yuu_apb_master_item::type_id::create("monitor_item");
          `uvm_do_callbacks(yuu_apb_master_monitor, yuu_apb_master_monitor_callback, pre_collect(this, monitor_item));
          collect();
          `uvm_do_callbacks(yuu_apb_master_monitor, yuu_apb_master_monitor_callback, post_collect(this, monitor_item));
        end
      join
    end
    wait_reset();
  join
endtask


task yuu_apb_master_monitor::init_component();
  return;
endtask

task yuu_apb_master_monitor::collect();
  uvm_event observe_trans_begin = events.get($sformatf("%s_observe_trans_begin", cfg.get_name()));
  uvm_event observe_trans_end   = events.get($sformatf("%s_observe_trans_end", cfg.get_name()));

  while (vif.mon_cb.psel !== 1'b1)
    vif.wait_cycle();

  observe_trans_begin.trigger();

  monitor_item.addr       = vif.mon_cb.paddr;
  monitor_item.direction  = yuu_apb_direction_e'(vif.mon_cb.pwrite);
  if (monitor_item.direction == WRITE)
    monitor_item.data = vif.mon_cb.pwdata;
  monitor_item.strb = vif.mon_cb.pstrb;
  {monitor_item.prot2, monitor_item.prot1, monitor_item.prot0} = vif.mon_cb.pprot;
  while (vif.mon_cb.penable !== 1'b1)
    vif.wait_cycle();
  if (cfg.apb3_enable) begin
    while (vif.mon_cb.pready !== 1'b1)
      vif.wait_cycle();
    monitor_item.resp = yuu_apb_response_e'(vif.mon_cb.pslverr);
  end
  if (monitor_item.direction == READ)
    monitor_item.data = vif.mon_cb.prdata;
  out_monitor_ap.write(monitor_item);
  `uvm_info("collect", $sformatf("Collected yuu_apb_master transaction (Direction:%s Addr:%8h Data:%8h)", monitor_item.direction, monitor_item.addr, monitor_item.data), UVM_HIGH)
  vif.wait_cycle();

  observe_trans_end.trigger();
endtask

task yuu_apb_master_monitor::wait_reset();
  forever begin
    @(negedge vif.mon_mp.preset_n);
    `uvm_warning("wait_reset", "Reset signal is asserted, transaction may be dropped")
    foreach (processes[i])
      processes[i].kill();
    init_component();
    @(posedge vif.mon_mp.preset_n);
  end
endtask

`endif
