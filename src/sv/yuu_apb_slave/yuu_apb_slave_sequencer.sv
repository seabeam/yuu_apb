/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_SEQUENCER_SV
`define YUU_APB_SLAVE_SEQUENCER_SV

class yuu_apb_slave_sequencer extends uvm_sequencer #(yuu_apb_slave_item);
  virtual yuu_apb_slave_interface vif;

  yuu_apb_slave_config cfg;
  uvm_event_pool events;

  `uvm_component_utils(yuu_apb_slave_sequencer)

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void connect_phase(uvm_phase phase);
endclass

function yuu_apb_slave_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_slave_sequencer::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  this.vif = cfg.vif;
  this.events = cfg.events;
endfunction

`endif
