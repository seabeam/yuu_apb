/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_ENV_SV
`define YUU_APB_ENV_SV

class yuu_apb_env extends uvm_env;
  yuu_apb_master_agent  master[];
  yuu_apb_slave_agent   slave[];

  yuu_apb_env_config  cfg;

  `uvm_component_utils(yuu_apb_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(yuu_apb_env_config)::get(null, get_full_name(), "cfg", cfg))
      `uvm_fatal("build_phase", "Cannot get YUU_APB env configuration object")
    
    master = new[cfg.mst_cfg.size()];
    foreach(master[i]) begin
      if (cfg.mst_cfg[i].index != -1) begin
        uvm_config_db#(yuu_apb_master_config)::set(this, $sformatf("master_%s", cfg.mst_cfg[i].get_name()), "cfg", cfg.mst_cfg[i]);
        master[i] = yuu_apb_master_agent::type_id::create($sformatf("master_%s", cfg.mst_cfg[i].get_name()), this);
      end
    end

    slave = new[cfg.slv_cfg.size()];
    foreach(slave[i]) begin
      if (cfg.slv_cfg[i].index != -1) begin
        uvm_config_db#(yuu_apb_slave_config)::set(this, $sformatf("slave_%s", cfg.slv_cfg[i].get_name()), "cfg", cfg.slv_cfg[i]);
        slave[i] = yuu_apb_slave_agent::type_id::create($sformatf("slave_%s", cfg.slv_cfg[i].get_name()), this);
      end
    end
  endfunction
endclass

`endif
