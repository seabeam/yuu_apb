/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_ANALYZER_SV
`define YUU_APB_MASTER_ANALYZER_SV

class yuu_apb_master_analyzer extends uvm_subscriber #(yuu_apb_master_item);
  virtual yuu_apb_master_interface vif;

  yuu_apb_master_config cfg;
  uvm_event_pool events;

  local time m_start_time;
  local time m_end_time;
  local bit  m_start = 0;
  local int  m_count = 0;

  `uvm_component_utils_begin(yuu_apb_master_analyzer)
  `uvm_component_utils_end

  extern                   function      new            (string name, uvm_component parent);
  extern           virtual function void build_phase    (uvm_phase phase);
  extern           virtual function void connect_phase  (uvm_phase phase);
  extern           virtual task          main_phase     (uvm_phase phase);
  extern           virtual function void report_phase   (uvm_phase phase);
  extern           virtual function void write          (yuu_apb_master_item t);
  extern protected virtual task          measure_start  (); 
  extern protected virtual task          measure_end    (); 
endclass

function yuu_apb_master_analyzer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_master_analyzer::build_phase(uvm_phase phase);
  if (cfg == null)
    `uvm_fatal("build_phase", "yuu_apb_master agent configuration is null")
endfunction

function void yuu_apb_master_analyzer::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  events = cfg.events;
endfunction

task yuu_apb_master_analyzer::main_phase(uvm_phase phase);
  measure_start();
  measure_end();
endtask

function void yuu_apb_master_analyzer::report_phase(uvm_phase phase);
  if (m_count == 0) begin
    `uvm_warning("report_phase", "Analyzer haven't received any transaction")
    return;
  end
  `uvm_info("report_phase", $sformatf("Tput value is %d", (m_end_time-m_start_time)/m_count), UVM_LOW);
endfunction

function void yuu_apb_master_analyzer::write(yuu_apb_master_item t);
  if (m_start)
    m_count ++;
endfunction

task yuu_apb_master_analyzer::measure_start();
  uvm_event e = events.get($sformatf("%s_measure_begin", cfg.get_name()));

  e.wait_on();
  m_start_time = $realtime();
  m_start = 1;
  `uvm_info("measure_start", $sformatf("%s analyzer start measure @ %t", cfg.get_name(), m_start_time), UVM_LOW)
endtask

task yuu_apb_master_analyzer::measure_end();
  uvm_event e = events.get($sformatf("%s_measure_end", cfg.get_name()));

  e.wait_on();
  m_end_time = $realtime();
  m_start = 0;
  `uvm_info("measure_end", $sformatf("%s analyzer end measure @ %t", cfg.get_name(), m_end_time), UVM_LOW)
endtask

`endif
