/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_SEQUENCE_LIB_SV
`define YUU_APB_SLAVE_SEQUENCE_LIB_SV

typedef class yuu_apb_slave_sequencer;
class yuu_apb_slave_sequence_base extends uvm_sequence #(yuu_apb_slave_item);
  virtual yuu_apb_slave_interface vif;

  yuu_apb_slave_config  cfg;
  uvm_event_pool events;

  yuu_apb_error error_object;

  `uvm_object_utils(yuu_apb_slave_sequence_base)
  `uvm_declare_p_sequencer(yuu_apb_slave_sequencer)

  function new(string name = "yuu_apb_slave_response_sequence");
    super.new(name);
  endfunction

  task pre_start();
    cfg = p_sequencer.cfg;
    vif = cfg.vif;
    events = cfg.events;
  endtask

  task body();
    return;
  endtask
endclass


class yuu_apb_slave_response_sequence extends yuu_apb_slave_sequence_base;
  `uvm_object_utils(yuu_apb_slave_response_sequence)

  function new(string name="yuu_apb_slave_response_sequence");
    super.new(name);
  endfunction


  task body();
    super.body();
    
    if (req == null)
      req = yuu_apb_slave_item::type_id::create("req");
    start_item(req);
    finish_item(req);
  endtask

  task set_item(input yuu_apb_slave_item item);
    req = yuu_apb_slave_item::type_id::create("req");
    
    req.copy(item);
  endtask
endclass

`endif
