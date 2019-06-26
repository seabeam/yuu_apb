/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_ITEM_SV
`define YUU_APB_ITEM_SV

class yuu_apb_item extends yuu_amba_item;
  rand yuu_apb_addr_t      addr;
  rand yuu_apb_data_t      data;
  rand yuu_apb_direction_e direction;
       yuu_apb_strb_t      strb;
  rand yuu_apb_prot0_e     prot0;
  rand yuu_apb_prot1_e     prot1;
  rand yuu_apb_prot2_e     prot2;

       yuu_apb_error error_object;


  constraint c_len {
    len == 0;
  }

  constraint c_address {
    addr == start_address;
  }

  constraint c_burst_type {
    burst_type == INCR;
  }

  `uvm_object_utils_begin(yuu_apb_item)
    `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_enum(yuu_apb_direction_e, direction, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_int(strb, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_enum(yuu_apb_prot0_e, prot0, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_enum(yuu_apb_prot1_e, prot1, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_enum(yuu_apb_prot2_e, prot2, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_object(error_object, UVM_DEFAULT | UVM_NOCOMPARE)
  `uvm_object_utils_end

  extern function      new(string name = "yuu_apb_item");
  extern function void pre_randomize();
  extern function void post_randomize();
endclass

function yuu_apb_item::new(string name = "yuu_apb_item");
  super.new(name);
endfunction

function void yuu_apb_item::pre_randomize();
  address_aligned_enable = True;
endfunction

function void yuu_apb_item::post_randomize();
  super.post_randomize();

  strb = 0;
  if (direction == READ) begin
    data = 0;
  end
  else begin
    for (int i=lower_byte_lane[0]; i<=upper_byte_lane[0]; i++) begin
      strb[i] = 1'b1;
    end
  end
endfunction

`endif 
