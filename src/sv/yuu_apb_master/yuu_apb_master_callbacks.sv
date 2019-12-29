/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_CALLBACKS_SV
`define YUU_APB_MASTER_CALLBACKS_SV

typedef class yuu_apb_master_driver;
typedef class yuu_apb_master_monitor;

class yuu_apb_master_driver_callback extends uvm_callback;
  `uvm_object_utils(yuu_apb_master_driver_callback)

  function new(string name = "yuu_apb_master_driver_callback");
    super.new(name);
  endfunction

  virtual task pre_send(yuu_apb_master_driver driver, yuu_apb_master_item item);
  endtask

  virtual task post_send(yuu_apb_master_driver driver, yuu_apb_master_item item);
  endtask
endclass


class yuu_apb_master_monitor_callback extends uvm_callback;
  `uvm_object_utils(yuu_apb_master_monitor_callback)

  function new(string name = "yuu_apb_master_monitor_callback");
    super.new(name);
  endfunction

  virtual task pre_collect(yuu_apb_master_monitor monitor, yuu_apb_master_item item);
  endtask

  virtual task post_collect(yuu_apb_master_monitor monitor, yuu_apb_master_item item);
  endtask
endclass

`endif
