/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_AGENT_CONFIG_SV
`define YUU_APB_AGENT_CONFIG_SV

class yuu_apb_agent_config extends uvm_object;
  uvm_event_pool events;

  int index = -1;
  int timeout = 0;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  boolean coverage_enable = False;
  boolean analysis_enable = False;
  // APB3 support, include Wait states and Error reporting
  boolean apb3_enable     = False;
  // APB4 support, include Transaction protection and Sparse data transfer
  boolean apb4_enable     = False;
  boolean protocol_check_enable = True;

  `uvm_object_utils_begin(yuu_apb_agent_config)
    `uvm_field_int(index, UVM_PRINT | UVM_COPY)
    `uvm_field_int(timeout, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(boolean, coverage_enable, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(boolean, analysis_enable, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(boolean, apb3_enable, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(boolean, apb4_enable, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(boolean, protocol_check_enable, UVM_PRINT | UVM_COPY)
  `uvm_object_utils_end 

  function new (string name = "yuu_apb_agent_config");
    super.new(name);
  endfunction
endclass

`endif
