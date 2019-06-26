/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_ENV_CONFIG_SV
`define YUU_APB_ENV_CONFIG_SV

class yuu_apb_env_config extends uvm_object;
  yuu_apb_master_config mst_cfg[$];
  yuu_apb_slave_config  slv_cfg[$];

  virtual yuu_apb_interface apb_if;
  uvm_event_pool events;

  boolean compare_enable    = False;
  boolean bus_checker_enable= False;

  `uvm_object_utils_begin(yuu_apb_env_config)
    `uvm_field_queue_object(mst_cfg, UVM_PRINT | UVM_COPY)
    `uvm_field_queue_object(slv_cfg, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(boolean, compare_enable, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(boolean, bus_checker_enable, UVM_PRINT | UVM_COPY)
  `uvm_object_utils_end

  function new(string name="yuu_apb_env_config");
    super.new(name);
  endfunction

  function void set_config(yuu_apb_agent_config cfg);
    yuu_apb_master_config m_cfg;
    yuu_apb_slave_config  s_cfg;

    if (cfg == null)
      `uvm_fatal("set_config", "Which yuu_apb agent config set is null")

    cfg.events = events;
    if ($cast(m_cfg, cfg)) begin
      if(m_cfg.index >= 0)
        m_cfg.vif = apb_if.get_master_if(m_cfg.index);
      mst_cfg.push_back(m_cfg);
    end
    else if ($cast(s_cfg, cfg))begin
      if (s_cfg.index >= 0)
        s_cfg.vif = apb_if.get_slave_if(s_cfg.index);
      slv_cfg.push_back(s_cfg);
    end
    else
      `uvm_fatal("set_config", "Invalid yuu_apb agent configure object type")
  endfunction

  function void set_configs(yuu_apb_agent_config cfg[]);
    foreach (cfg[i])
      set_config(cfg[i]);
  endfunction
endclass

`endif
