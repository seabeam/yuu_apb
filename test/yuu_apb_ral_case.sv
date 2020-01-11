/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_RAL_CASE_SV
`define YUU_APB_RAL_CASE_SV

class yuu_master_ral_virtual_sequence extends yuu_apb_virtual_sequence;
  slave_ral_model model;

  `uvm_object_utils(yuu_master_ral_virtual_sequence)

  function new(string name="yuu_master_ral_virtual_sequence");
    super.new(name);
  endfunction : new

  task body();
    yuu_apb_response_sequence       rsp_seq = yuu_apb_response_sequence::type_id::create("rsp_seq");
    fork
      begin
        uvm_status_e    status;
        uvm_reg_data_t  value;

        #100ns;
        model.control.Clock.write(status, 32'h12);
        model.common.TIMER.write(status, 32'h5A);
        #100ns;
        model.control.Clock.read(status, value);
        `uvm_info("body", $sformatf("Register Clock value is %8h", value), UVM_LOW);
        model.common.TIMER.read(status, value);
        `uvm_info("body", $sformatf("Register Timer value is %8h", value), UVM_LOW);
      end
      rsp_seq.start(p_sequencer.slave_sequencer[0]);
    join_any
  endtask
endclass : yuu_master_ral_virtual_sequence


class yuu_apb_ral_case extends yuu_apb_base_case;
  `uvm_component_utils(yuu_apb_ral_case)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    cfg.mst_cfg[0].idle_enable = False;
    cfg.mst_cfg[0].use_reg_model = True;
    cfg.slv_cfg[0].wait_enable = False;
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    yuu_master_ral_virtual_sequence seq;

    seq = yuu_master_ral_virtual_sequence::type_id::create("seq");
    seq.model = model;
    phase.raise_objection(this);
    seq.start(vsequencer);
    phase.drop_objection(this);
  endtask : run_phase
endclass : yuu_apb_ral_case

`endif
