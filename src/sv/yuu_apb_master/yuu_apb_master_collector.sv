/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_COLLECTOR_SV
`define YUU_APB_MASTER_COLLECTOR_SV

class yuu_apb_master_collector extends uvm_subscriber #(yuu_apb_master_item);
  virtual yuu_apb_master_interface vif;

  yuu_apb_master_config cfg;

  yuu_apb_master_item item;

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

  `uvm_component_utils_begin(yuu_apb_master_collector)
  `uvm_component_utils_end

  extern                   function      new              (string name, uvm_component parent);
  extern           virtual function void build_phase      (uvm_phase phase);
  extern           virtual function void connect_phase    (uvm_phase phase);
  extern           virtual task          main_phase       (uvm_phase phase);
  extern           virtual function void write            (yuu_apb_master_item t);
endclass

function yuu_apb_master_collector::new(string name, uvm_component parent);
  super.new(name, parent);

  apb_transaction_cg = new;
endfunction

function void yuu_apb_master_collector::build_phase(uvm_phase phase);
  if (cfg == null)
    `uvm_fatal("build_phase", "yuu_apb_master agent configuration is null")
endfunction

function void yuu_apb_master_collector::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
endfunction

task yuu_apb_master_collector::main_phase(uvm_phase phase);
endtask

function void yuu_apb_master_collector::write(yuu_apb_master_item t);
  item = yuu_apb_master_item::type_id::create("item");
  item.copy(t);
  apb_transaction_cg.sample();
endfunction

`endif
