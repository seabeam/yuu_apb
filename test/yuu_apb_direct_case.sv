/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_DIRECT_CASE_SV
`define YUU_APB_DIRECT_CASE_SV

class yuu_apb_master_direct_sequence extends yuu_apb_master_sequence_base;
  `uvm_object_utils(yuu_apb_master_direct_sequence)

  function new(string name="yuu_apb_master_direct_sequence");
    super.new(name);
  endfunction : new

  task body();
    yuu_apb_master_item m_item;

    for (int i=0; i<4; i++) begin
      m_item = new("m_item");
      m_item.cfg = cfg;
      m_item.randomize() with {direction == WRITE;
                               addr == 32'h1000_0000+i;};
      start_item(m_item);
      finish_item(m_item);
      `uvm_info("body", $sformatf("[WRITE] addr = %8h data = %8h", m_item.addr, m_item.data), UVM_LOW)
    end

    for (int i=0; i<4; i++) begin
      m_item = new("m_item");
      m_item.cfg = cfg;
      m_item.randomize() with {direction == READ;
                               addr == 32'h1000_0000+i;};
      start_item(m_item);
      finish_item(m_item);
      `uvm_info("body", $sformatf("[READ] addr = %8h data = %8h", m_item.addr, m_item.data), UVM_LOW)
    end
  endtask
endclass : yuu_apb_master_direct_sequence

class yuu_apb_response_sequence extends yuu_apb_slave_sequence_base;
  `uvm_object_utils(yuu_apb_response_sequence)

  function new(string name = "yuu_apb_response_sequence");
    super.new(name);
  endfunction

  task body();
    forever begin
      req = yuu_apb_slave_item::type_id::create("req");
      req.cfg = cfg;
      start_item(req);
      req.randomize() with {resp == OKAY;};
      finish_item(req);
    end
  endtask
endclass : yuu_apb_response_sequence


class yuu_apb_direct_case extends yuu_apb_base_case;
  `uvm_component_utils(yuu_apb_direct_case)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task main_phase(uvm_phase phase);
    yuu_apb_master_direct_sequence  mst_seq  = yuu_apb_master_direct_sequence::type_id::create("mst_seq");
    yuu_apb_response_sequence       rsp_seq  = yuu_apb_response_sequence::type_id::create("rsp_seq");

    phase.raise_objection(this);
    fork
      mst_seq.start(env.vsequencer.master_sequencer[0]);
      rsp_seq.start(env.vsequencer.slave_sequencer[0]);
    join_any
    phase.drop_objection(this);
  endtask : main_phase

endclass : yuu_apb_direct_case

`endif
