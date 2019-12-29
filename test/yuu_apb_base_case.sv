/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_BASE_CASE_SV
`define YUU_APB_BASE_CASE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import yuu_common_pkg::*;
import yuu_apb_pkg::*;

`include "slave_ral_model.sv"
`uvm_analysis_imp_decl(_master_driver)
`uvm_analysis_imp_decl(_master_monitor)
`uvm_analysis_imp_decl(_slave_driver)
`uvm_analysis_imp_decl(_slave_monitor)
class yuu_apb_mini_scoreboard extends uvm_scoreboard;
  virtual yuu_apb_master_interface vif;

  uvm_analysis_imp_master_driver  #(yuu_apb_master_item, yuu_apb_mini_scoreboard) mst_drv_export;
  uvm_analysis_imp_master_monitor #(yuu_apb_master_item, yuu_apb_mini_scoreboard) mst_mon_export;
  uvm_analysis_imp_slave_driver   #(yuu_apb_slave_item, yuu_apb_mini_scoreboard)  slv_drv_export;
  uvm_analysis_imp_slave_monitor  #(yuu_apb_slave_item, yuu_apb_mini_scoreboard)  slv_mon_export;

  yuu_apb_master_item mst_drv_item_q[$];
  yuu_apb_master_item mst_mon_item_q[$];
  yuu_apb_slave_item  slv_drv_item_q[$];
  yuu_apb_slave_item  slv_mon_item_q[$];

  process processes[string];
  `uvm_component_utils(yuu_apb_mini_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    mst_drv_export = new("mst_drv_export", this);
    mst_mon_export = new("mst_mon_export", this);
    slv_drv_export = new("slv_drv_export", this);
    slv_mon_export = new("slv_mon_export", this);
  endfunction

  function write_master_driver(yuu_apb_master_item t);
    mst_drv_item_q.push_back(t);
  endfunction

  function write_master_monitor(yuu_apb_master_item t);
    mst_mon_item_q.push_back(t);
  endfunction

  function write_slave_driver(yuu_apb_slave_item t);
    slv_drv_item_q.push_back(t);
  endfunction

  function write_slave_monitor(yuu_apb_slave_item t);
    slv_mon_item_q.push_back(t);
  endfunction

  task run_phase(uvm_phase phase);
    process proc_compare;
    yuu_apb_master_item   m0, m1;
    yuu_apb_slave_item    s0, s1;

    fork
      forever begin 
        wait(vif.mon_mp.preset_n === 1'b1);
        fork
          begin
            proc_compare = process::self();
            processes["proc_compare"] = proc_compare;
            wait(mst_drv_item_q.size() > 0);
            wait(mst_mon_item_q.size() > 0);
            wait(slv_drv_item_q.size() > 0);
            wait(slv_mon_item_q.size() > 0);

            m0 = mst_drv_item_q.pop_front();
            m1 = mst_mon_item_q.pop_front();
            s0 = slv_drv_item_q.pop_front();
            s1 = slv_mon_item_q.pop_front();
            $display("[Scoreboard] %0h, %0h, %0h, %0h", m0.data, m1.data, s0.data, s1.data);
          end
        join
      end
      wait_reset();
    join
  endtask


  task init_component();
    mst_mon_item_q.delete();
    mst_mon_item_q.delete();
    slv_drv_item_q.delete();
    slv_mon_item_q.delete();
  endtask

  task wait_reset();
    forever begin
      @(negedge vif.mon_mp.preset_n);
      foreach (processes[i])
        processes[i].kill();
      init_component();
      @(posedge vif.mon_mp.preset_n);
    end
  endtask
endclass : yuu_apb_mini_scoreboard


class yuu_apb_base_case extends uvm_test;
  virtual yuu_apb_interface vif;

  yuu_apb_env env;
  yuu_apb_env_config cfg;
  yuu_apb_virtual_sequencer vsequencer;
  yuu_apb_mini_scoreboard scb;
  slave_ral_model model;

  `uvm_component_utils(yuu_apb_base_case)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    cfg = new("cfg");
    cfg.events = new("events");
    uvm_config_db#(virtual yuu_apb_interface)::get(null, get_full_name(), "vif", vif);
  
    cfg.apb_if = vif;
    begin
      yuu_apb_master_config m_cfg = new("e0_m0");
      m_cfg.apb3_enable = True;
      m_cfg.idle_enable = True;
      m_cfg.coverage_enable = True;
      m_cfg.index = 0;
      cfg.set_config(m_cfg);
    end
    begin
      yuu_apb_slave_config  s_cfg = new("e0_s0");
      s_cfg.apb3_enable = True;
      s_cfg.wait_enable = True;
      s_cfg.index = 0;
      s_cfg.set_map(0, 32'hF000_0000);
      cfg.set_config(s_cfg);
    end

    uvm_config_db#(yuu_apb_env_config)::set(this, "env", "cfg", cfg);
    env = yuu_apb_env::type_id::create("env", this);

    scb = yuu_apb_mini_scoreboard::type_id::create("scb", this);

    model = new("model");
    model.build();
    model.lock_model();
    model.reset();
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    model.default_map.set_sequencer(env.vsequencer.master_sequencer[0], env.master[0].adapter);
    if (cfg.mst_cfg[0].use_reg_model)
      env.master[0].predictor.map = model.default_map;
    vsequencer = env.vsequencer;

    scb.vif = cfg.mst_cfg[0].vif;
    env.master[0].out_driver_ap.connect(scb.mst_drv_export);
    env.master[0].out_monitor_ap.connect(scb.mst_mon_export);
    env.slave[0].out_driver_ap.connect(scb.slv_drv_export);
    env.slave[0].out_monitor_ap.connect(scb.slv_mon_export);
  endfunction
  
  task wait_scb_done();
    wait(scb.mst_drv_item_q.size() == 0);
    wait(scb.mst_mon_item_q.size() == 0);
    wait(scb.slv_drv_item_q.size() == 0);
    wait(scb.slv_mon_item_q.size() == 0);
  endtask
endclass

`endif
