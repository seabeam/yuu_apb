/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_ENV_SV
`define YUU_APB_ENV_SV

class yuu_apb_env extends uvm_env;
  yuu_apb_master_agent      master[];
  yuu_apb_slave_agent       slave[];
  yuu_apb_virtual_sequencer vsequencer;

  yuu_apb_env_config  cfg;

  `uvm_component_utils(yuu_apb_env)

  extern                   function      new(string name, uvm_component parent);
  extern                   function void build_phase(uvm_phase phase);
  extern                   function void connect_phase(uvm_phase phase);
endclass

function yuu_apb_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_env::build_phase(uvm_phase phase);
  if(!uvm_config_db#(yuu_apb_env_config)::get(null, get_full_name(), "cfg", cfg))
    `uvm_fatal("build_phase", "Cannot get yuu_apb_env_config.")
  if (cfg == null)
    `uvm_fatal("build_phase", "Get a null env configuration")

  vsequencer = yuu_apb_virtual_sequencer::type_id::create("vsequencer", this);
  
  master = new[cfg.mst_cfg.size()];
  vsequencer.master_sequencer = new[cfg.mst_cfg.size()];
  foreach(master[i]) begin
    if (cfg.mst_cfg[i].index != -1) begin
      uvm_config_db#(yuu_apb_master_config)::set(this, $sformatf("master_%s", cfg.mst_cfg[i].get_name()), "cfg", cfg.mst_cfg[i]);
      master[i] = yuu_apb_master_agent::type_id::create($sformatf("master_%s", cfg.mst_cfg[i].get_name()), this);
    end
  end

  slave = new[cfg.slv_cfg.size()];
  vsequencer.slave_sequencer = new[cfg.slv_cfg.size()];
  foreach(slave[i]) begin
    if (cfg.slv_cfg[i].index != -1) begin
      uvm_config_db#(yuu_apb_slave_config)::set(this, $sformatf("slave_%s", cfg.slv_cfg[i].get_name()), "cfg", cfg.slv_cfg[i]);
      slave[i] = yuu_apb_slave_agent::type_id::create($sformatf("slave_%s", cfg.slv_cfg[i].get_name()), this);
    end
  end

  vsequencer.cfg = cfg;
endfunction

function void yuu_apb_env::connect_phase(uvm_phase phase);
  foreach (cfg.mst_cfg[i]) begin
    cfg.mst_cfg[i].events = cfg.events;
    vsequencer.master_sequencer[i] = master[i].sequencer;
  end
  foreach (cfg.slv_cfg[i]) begin
    cfg.slv_cfg[i].events = cfg.events;
    vsequencer.slave_sequencer[i] = slave[i].sequencer;
  end
endfunction

`endif
