/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_ITEM_SV
`define YUU_APB_MASTER_ITEM_SV

class yuu_apb_master_item extends yuu_apb_item;
  yuu_apb_master_config cfg;

  rand int unsigned       idle_delay;

  constraint c_idle {
    cfg.idle_enable == False -> idle_delay == 0;
    idle_delay < `YUU_APB_MAX_IDLE;
  }

  constraint c_response {
    resp == OKAY;
  }

  `uvm_object_utils_begin(yuu_apb_master_item)
    `uvm_field_int (idle_delay, UVM_PRINT | UVM_COPY)
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
    `uvm_fatal("pre_randomize", "Cannot get APB master configuration in transaction")

  if (!cfg.apb4_enable) begin
    prot0.rand_mode(0);
    prot1.rand_mode(0);
    prot2.rand_mode(0);
  end
endfunction

`endif 
