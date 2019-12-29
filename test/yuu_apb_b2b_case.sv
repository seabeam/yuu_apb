/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_B2B_CASE_SV
`define YUU_APB_B2B_CASE_SV

class yuu_apb_master_b2b_sequence extends yuu_apb_master_sequence_base;
  `uvm_object_utils(yuu_apb_master_b2b_sequence)

  function new(string name="yuu_apb_master_b2b_sequence");
    super.new(name);
  endfunction : new

  task body();
    yuu_apb_master_item m_item;
    yuu_apb_data_t  write_data[$];

    for (int i=0; i<4; i++) begin
      m_item = new("m_item");
      m_item.cfg = cfg;
      m_item.randomize() with {direction == WRITE;
                               addr == 32'h1000_0000+i*4;};
      start_item(m_item);
      finish_item(m_item);
      write_data.push_back(m_item.data);
    end

    for (int i=0; i<4; i++) begin
      m_item = new("m_item");
      m_item.cfg = cfg;
      m_item.randomize() with {direction == READ;
                               addr == 32'h1000_0000+i*4;};
      start_item(m_item);
      finish_item(m_item);
      if (write_data[i] != m_item.data)
        `uvm_error("body", $sformatf("Compare failed, write data is %0h, read data is %0h", write_data[i], m_item.data))
      else
        `uvm_info("body", $sformatf("Compare pass, read data is %0h", write_data[i]), UVM_LOW)
    end
  endtask
endclass : yuu_apb_master_b2b_sequence

class yuu_apb_b2b_virtual_sequence extends yuu_apb_virtual_sequence;
  `uvm_object_utils(yuu_apb_b2b_virtual_sequence)

  function new(string name = "yuu_apb_b2b_virtual_sequence");
    super.new(name);
  endfunction

  task body();
    yuu_apb_master_b2b_sequence  mst_seq = yuu_apb_master_b2b_sequence::type_id::create("mst_seq");
    yuu_apb_response_sequence    rsp_seq = yuu_apb_response_sequence::type_id::create("rsp_seq");

    fork
      mst_seq.start(p_sequencer.master_sequencer[0]);
      rsp_seq.start(p_sequencer.slave_sequencer[0]);
    join_any
  endtask
endclass : yuu_apb_b2b_virtual_sequence


class yuu_apb_b2b_case extends yuu_apb_base_case;
  `uvm_component_utils(yuu_apb_b2b_case)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    cfg.mst_cfg[0].idle_enable = False;
    cfg.slv_cfg[0].wait_enable = False;
  endfunction : build_phase
  
  task run_phase(uvm_phase phase);
    yuu_apb_b2b_virtual_sequence seq = yuu_apb_b2b_virtual_sequence::type_id::create("seq");

    phase.raise_objection(this);
    seq.start(vsequencer);
    wait_scb_done();
    phase.drop_objection(this);
  endtask : run_phase
endclass : yuu_apb_b2b_case

`endif
