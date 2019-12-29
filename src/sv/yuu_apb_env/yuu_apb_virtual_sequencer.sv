/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_VIRTUAL_SEQUENCER_SV
`define YUU_APB_VIRTUAL_SEQUENCER_SV

class yuu_apb_virtual_sequencer extends uvm_virtual_sequencer;
  virtual yuu_apb_interface vif;

  yuu_apb_env_config cfg;
  uvm_event_pool  events;

  yuu_apb_master_sequencer  master_sequencer[];
  yuu_apb_slave_sequencer   slave_sequencer[];

  `uvm_component_utils(yuu_apb_virtual_sequencer)

  extern                   function      new(string name, uvm_component parent);
  extern                   function void connect_phase(uvm_phase phase);
endclass

function yuu_apb_virtual_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_virtual_sequencer::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if (cfg == null)
    `uvm_fatal("connect_phase", "Virtual sequencer cannot get env configuration object")

  vif = cfg.apb_if;
  events = cfg.events;
endfunction

class yuu_apb_virtual_sequence extends uvm_sequence_base;
  `uvm_object_utils(yuu_apb_virtual_sequence)
  `uvm_declare_p_sequencer(yuu_apb_virtual_sequencer)

  function new(string name = "yuu_apb_virtual_sequence");
    super.new(name);
  endfunction
endclass

`endif
