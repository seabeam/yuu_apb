import uvm_pkg::*;
`include "uvm_macros.svh"

import yuu_common_pkg::*;
import yuu_apb_pkg::*;
`include "yuu_apb_defines.svh"
`include "yuu_apb_interface.svi"

class uvc_test_sequence extends yuu_apb_master_sequence_base;
  `uvm_object_utils(uvc_test_sequence)

  function new(string name="uvc_test_sequence");
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
      $display("addr = %8h data = %8h", m_item.addr, m_item.data);
    end

    for (int i=0; i<4; i++) begin
      m_item = new("m_item");
      m_item.cfg = cfg;
      m_item.randomize() with {direction == READ;
                               addr == 32'h1000_0000+i;};
      start_item(m_item);
      finish_item(m_item);
      $display("addr = %8h data = %8h", m_item.addr, m_item.data);
    end
  endtask
endclass : uvc_test_sequence

class yuu_apb_response_sequence extends yuu_apb_slave_sequence_base;
  `uvm_object_utils(yuu_apb_slave_sequence_base)

  function new(string name = "yuu_apb_slave_response_sequence");
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
endclass


class uvc_test extends uvm_test;
  virtual yuu_apb_interface vif;

  yuu_apb_env env;
  yuu_apb_env_config cfg;

  `uvm_component_utils(uvc_test)

  function new(string name="uvc_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    cfg = new("cfg");
    cfg.events = new("events");
    uvm_config_db#(virtual yuu_apb_interface)::get(null, get_full_name(), "vif", cfg.apb_if);
  
    begin
      yuu_apb_master_config m_cfg = new("e0_m0");
      m_cfg.apb3_enable = True;
      m_cfg.idle_enable = True;
      m_cfg.coverage_enable = True;
      m_cfg.index = 0;
      cfg.set_config(m_cfg);
    end
    begin
      yuu_apb_slave_config  s_cfg = new("e0_s0");
      s_cfg.apb3_enable = True;
      s_cfg.wait_enable = True;
      s_cfg.index = 0;
      s_cfg.set_map(0, 32'hF000_0000);
      cfg.set_config(s_cfg);
    end

    uvm_config_db#(yuu_apb_env_config)::set(this, "env", "cfg", cfg);
    env = yuu_apb_env::type_id::create("env", this);
  endfunction : build_phase

  task main_phase(uvm_phase phase);
    uvc_test_sequence seq = new("seq");
    yuu_apb_response_sequence rsp_seq = new("rsp_seq");

    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);
    fork
      seq.start(env.vsequencer.master_sequencer[0]);
      rsp_seq.start(env.vsequencer.slave_sequencer[0]);
    join_any
    phase.drop_objection(this);
  endtask : main_phase

endclass : uvc_test

module dummy(
  yuu_apb_master_interface m_if,
  yuu_apb_slave_interface  s_if
);
  assign s_if.paddr   = m_if.paddr;
  assign s_if.penable = m_if.penable;
  assign s_if.pwrite  = m_if.pwrite;
  assign s_if.pwdata  = m_if.pwdata;
  assign s_if.psel    = m_if.psel;
  assign s_if.pstrb   = m_if.pstrb;
  assign s_if.pprot   = m_if.pprot;

  assign m_if.prdata  = s_if.prdata;
  assign m_if.pready  = s_if.pready;
  assign m_if.pslverr = s_if.pslverr;
endmodule

module top;
  logic clk;
  logic rst;

  yuu_apb_interface yuu_apb_if();

  dummy DUT(yuu_apb_if.master_if[0], yuu_apb_if.slave_if[0]);

  initial begin
    uvm_config_db#(virtual yuu_apb_interface)::set(null, "*", "vif", yuu_apb_if);

    run_test("uvc_test");
  end

  initial begin
    clk = 'b0;
    rst = 'b0;
    #12;
    rst = 'b1;
  end

  always #5 clk = ~clk;

  assign yuu_apb_if.master_if[0].pclk = clk;
  assign yuu_apb_if.master_if[0].preset_n = rst;
  assign yuu_apb_if.slave_if[0].pclk = clk;
  assign yuu_apb_if.slave_if[0].preset_n = rst;
endmodule
