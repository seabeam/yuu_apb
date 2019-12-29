/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_SEQUENCE_LIB_SV
`define YUU_APB_MASTER_SEQUENCE_LIB_SV

typedef class yuu_apb_master_sequencer;
class yuu_apb_master_sequence_base extends uvm_sequence #(yuu_apb_master_item);
  virtual yuu_apb_master_interface vif;

  yuu_apb_master_config cfg;
  uvm_event_pool events;

  int unsigned n_item = 10;

  yuu_apb_error error_object;

  `uvm_object_utils(yuu_apb_master_sequence_base)
  `uvm_declare_p_sequencer(yuu_apb_master_sequencer)

  function new(string name = "yuu_apb_master_sequence_base");
    super.new(name);
  endfunction

  virtual task pre_start();
    cfg = p_sequencer.cfg;
    vif = cfg.vif;
    events = cfg.events;
  endtask

  virtual task body();
    `uvm_warning("body", "The body task should be OVERRIDED by derived class")
  endtask
endclass

`endif
