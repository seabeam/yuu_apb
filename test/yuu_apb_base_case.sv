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
`include "yuu_apb_defines.svh"
`include "yuu_apb_interface.svi"

class yuu_apb_base_case extends uvm_test;
  virtual yuu_apb_interface vif;

  yuu_apb_env env;
  yuu_apb_env_config cfg;

  `uvm_component_utils(yuu_apb_base_case)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    cfg = new("cfg");
    cfg.events = new("events");
    uvm_config_db#(virtual yuu_apb_interface)::get(null, get_full_name(), "vif", cfg.apb_if);
  
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
  endfunction : build_phase
endclass

`endif
