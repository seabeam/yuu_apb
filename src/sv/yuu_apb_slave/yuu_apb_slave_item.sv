/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_ITEM_SV
`define YUU_APB_SLAVE_ITEM_SV

class yuu_apb_slave_item extends yuu_apb_item;
  yuu_apb_slave_config cfg;

  rand int unsigned       wait_cycle;

  constraint c_wait {
    cfg.wait_enable == False -> wait_cycle == 0;
    wait_cycle < `YUU_APB_MAX_WAIT;
  }

  `uvm_object_utils_begin(yuu_apb_slave_item)
    `uvm_field_object (cfg,        UVM_PRINT | UVM_COPY)
    `uvm_field_int    (wait_cycle, UVM_PRINT | UVM_COPY)
  `uvm_object_utils_end

  extern function      new(string name = "yuu_apb_slave_item");
  extern function void pre_randomize();
endclass

function yuu_apb_slave_item::new(string name = "yuu_apb_slave_item");
  super.new(name);
endfunction

function void yuu_apb_slave_item::pre_randomize();
  super.pre_randomize();

  if (!uvm_config_db #(yuu_apb_slave_config)::get(null, get_full_name(), "cfg", cfg) && cfg == null)
    `uvm_fatal("pre_randomize", "Cannot get APB slave configuration in transaction")
endfunction

`endif 
