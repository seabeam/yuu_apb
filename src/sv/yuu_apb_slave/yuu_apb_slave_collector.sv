/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_COLLECTOR_SV
`define YUU_APB_SLAVE_COLLECTOR_SV

class yuu_apb_slave_collector extends uvm_subscriber #(yuu_apb_slave_item);
  virtual yuu_apb_slave_interface vif;

  yuu_apb_slave_config cfg;
  uvm_event_pool events;

  yuu_apb_slave_item item;

  covergroup apb_transaction_cg();
    direction: coverpoint item.direction {
      bins apb_write = {WRITE};
      bins apb_read  = {READ};
    }
    
    response: coverpoint item.resp {
      bins apb_okay   = {OKAY};
      bins apb_error  = {ERROR};
    }
  endgroup

  `uvm_component_utils_begin(yuu_apb_slave_collector)
  `uvm_component_utils_end

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          main_phase(uvm_phase phase);

  extern           virtual function void write(yuu_apb_slave_item t);
endclass

function yuu_apb_slave_collector::new(string name, uvm_component parent);
  super.new(name, parent);

  apb_transaction_cg = new;
endfunction

function void yuu_apb_slave_collector::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  this.events = cfg.events;
endfunction

task yuu_apb_slave_collector::main_phase(uvm_phase phase);
endtask

function void yuu_apb_slave_collector::write(yuu_apb_slave_item t);
  item = yuu_apb_slave_item::type_id::create("item");
  item.copy(t);
  apb_transaction_cg.sample();
endfunction

`endif
