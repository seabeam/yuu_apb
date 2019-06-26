/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_ITEM_SV
`define YUU_APB_MASTER_ITEM_SV

class yuu_apb_master_item extends yuu_apb_item;
  yuu_apb_master_config cfg;

  rand int unsigned       idle_cycle;
       yuu_apb_response_e resp;

  constraint c_idle {
    cfg.idle_enable == False -> idle_cycle == 0;
    idle_cycle < `YUU_APB_MAX_IDLE;
  }


  `uvm_object_utils_begin(yuu_apb_master_item)
    `uvm_field_object(cfg, UVM_PRINT | UVM_COPY)
    `uvm_field_int(idle_cycle, UVM_PRINT | UVM_COPY)
    `uvm_field_enum(yuu_apb_response_e, resp, UVM_PRINT | UVM_COPY)
  `uvm_object_utils_end

  extern function      new(string name = "yuu_apb_master_item");
  extern function void pre_randomize();
endclass

function yuu_apb_master_item::new(string name = "yuu_apb_master_item");
  super.new(name);
endfunction

function void yuu_apb_master_item::pre_randomize();
  super.pre_randomize();

  if (!uvm_config_db #(yuu_apb_master_config)::get(m_sequencer, "", "cfg", cfg) && cfg == null)
    `uvm_fatal("pre_randomize", "Cannot get APB master configuration")
endfunction

`endif 
