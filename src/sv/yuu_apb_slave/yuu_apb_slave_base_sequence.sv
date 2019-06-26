/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_BASE_SEQUENCE_SV
`define YUU_APB_SLAVE_BASE_SEQUENCE_SV

class yuu_apb_slave_base_sequence extends uvm_sequence #(yuu_apb_slave_item);
  yuu_apb_slave_config cfg;
  uvm_event_pool events;

  `uvm_object_utils_begin(yuu_apb_slave_base_sequence)
  `uvm_object_utils_end

  function new(string name = "yuu_apb_slave_base_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
  endtask
endclass

`endif
