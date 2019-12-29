/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_AGENT_SV
`define YUU_APB_MASTER_AGENT_SV

class yuu_apb_master_agent extends uvm_agent;
  yuu_apb_master_config cfg;
  
  yuu_apb_master_sequencer  sequencer;
  yuu_apb_master_driver     driver;
  yuu_apb_master_monitor    monitor;
  yuu_apb_master_collector  collector;
  yuu_apb_master_analyzer   analyzer;
  yuu_apb_master_adapter    adapter;
  yuu_apb_master_predictor  predictor;

  uvm_analysis_port #(yuu_apb_master_item) out_driver_ap;
  uvm_analysis_port #(yuu_apb_master_item) out_monitor_ap;

  `uvm_component_utils_begin(yuu_apb_master_agent)
  `uvm_component_utils_end

  extern         function      new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
endclass

function yuu_apb_master_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_master_agent::build_phase(uvm_phase phase);
  if (!uvm_config_db #(yuu_apb_master_config)::get(null, get_full_name(), "cfg", cfg))
    `uvm_fatal("build_phase", "Cannot get master configuration")
  if (cfg == null)
    `uvm_fatal("build_phase", "Get a null master configuration")

  monitor = yuu_apb_master_monitor::type_id::create("monitor", this);
  monitor.cfg = cfg;
  if (cfg.is_active == UVM_ACTIVE) begin
    sequencer = yuu_apb_master_sequencer::type_id::create("sequencer", this);
    driver    = yuu_apb_master_driver::type_id::create("driver", this);
    sequencer.cfg = cfg;
    driver.cfg = cfg;
  end
  if (cfg.coverage_enable) begin
    collector = yuu_apb_master_collector::type_id::create("collector", this);
    collector.cfg = this.cfg;
  end
  if (cfg.analysis_enable) begin
    analyzer  = yuu_apb_master_analyzer::type_id::create("analyzer", this);
    analyzer.cfg = this.cfg;
  end

  if (cfg.use_reg_model) begin
    adapter = yuu_apb_master_adapter::type_id::create("adapter");
    adapter.cfg = cfg;
    adapter.provides_responses = 1;

    predictor = yuu_apb_master_predictor::type_id::create("predictor", this);
    predictor.adapter = adapter;
  end
endfunction

function void yuu_apb_master_agent::connect_phase(uvm_phase phase);
  out_monitor_ap = monitor.out_monitor_ap;
  
  if (cfg.is_active) begin
    driver.seq_item_port.connect(sequencer.seq_item_export);
    out_driver_ap = driver.out_driver_ap;
  end
  if (cfg.coverage_enable) begin
    monitor.out_monitor_ap.connect(collector.analysis_export);
  end
  if (cfg.analysis_enable) begin
    monitor.out_monitor_ap.connect(analyzer.analysis_export);
  end
  if (cfg.use_reg_model) begin
    monitor.out_monitor_ap.connect(predictor.bus_in);
  end
endfunction

function void yuu_apb_master_agent::end_of_elaboration_phase(uvm_phase phase);
  if (cfg.use_reg_model) begin
    if (predictor.map == null)
      `uvm_fatal("end_of_elaboration_phase", "When register model used, the predictor map should be set")
  end
endfunction

`endif
