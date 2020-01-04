/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_ADAPTER_SV
`define YUU_APB_MASTER_ADAPTER_SV

class yuu_apb_master_adapter extends uvm_reg_adapter;
  yuu_apb_master_config cfg;

  `uvm_object_utils(yuu_apb_master_adapter)

  extern                  function                   new(string name = "yuu_apb_master_adapter");
  extern          virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  extern          virtual function void              bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
endclass

function yuu_apb_master_adapter::new(string name = "yuu_apb_master_adapter");
  super.new(name);
endfunction

function uvm_sequence_item yuu_apb_master_adapter::reg2bus(const ref uvm_reg_bus_op rw);
  yuu_apb_master_item item = yuu_apb_master_item::type_id::create("item");
  item.direction = (rw.kind == UVM_READ) ? READ : WRITE;
  item.addr = rw.addr;
  item.data = rw.data;
  return item;
endfunction

function void yuu_apb_master_adapter::bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
  yuu_apb_master_item item;
  if (!$cast(item, bus_item)) begin
    `uvm_fatal("bus2reg", "Provided bus_item is not of the correct type(yuu_apb_master_item)")
    return;
  end
  rw.kind = int'(item.direction) ? UVM_WRITE : UVM_READ;
  rw.addr = item.addr;
  rw.data = item.data;
  rw.status = (item.resp == OKAY) ? UVM_IS_OK : UVM_NOT_OK;
endfunction

`endif
