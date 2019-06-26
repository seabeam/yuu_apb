/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_RESPONSE_SEQUENCE_SV
`define YUU_APB_SLAVE_RESPONSE_SEQUENCE_SV

class yuu_apb_slave_response_sequence extends yuu_apb_slave_base_sequence;
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
