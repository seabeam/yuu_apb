/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_ERROR_SV
`define YUU_APB_ERROR_SV

class yuu_apb_error extends uvm_object;
  int unsigned no_error_wt      = 100;
  int unsigned invalid_addr_wt  = 0;
  int unsigned read_only_wt     = 0;
  int unsigned write_only_wt    = 0;
  int unsigned currupt_data_wt  = 0;

  rand e_yuu_apb_error_type error_type;

  constraint c_error_type {
    error_type dist {
      NO_ERROR      := no_error_wt,
      INVALID_ADDR  := invalid_addr_wt,
      READ_ONLY     := read_only_wt,
      WRITE_ONLY    := write_only_wt,
      CURRUPT_DATA  := currupt_data_wt
    };
  }
 

  `uvm_object_utils_begin(yuu_apb_error)
    `uvm_field_enum(e_yuu_apb_error_type, error_type, UVM_DEFAULT | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "yuu_apb_error");
    super.new(name);
  endfunction
endclass

`endif
