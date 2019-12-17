import uvm_pkg::*;
`include "uvm_macros.svh"

import yuu_common_pkg::*;
import yuu_apb_pkg::*;
`include "yuu_apb_defines.svh"
`include "yuu_apb_interface.svi"

class uvc_wo_callback extends yuu_apb_slave_driver_callback;
  virtual task pre_send(yuu_apb_slave_driver driver, yuu_apb_slave_item item);
    item.error_object.error_type = WRITE_ONLY;
  endtask
endclass : uvc_wo_callback

class uvc_test_sequence extends uvm_sequence#(uvm_sequence_item);
  yuu_apb_master_config cfg;

  `uvm_object_utils(uvc_test_sequence)

  function new(string name="uvc_test_sequence");
    super.new(name);
  endfunction : new

  task body();
    bit[31:0] addr;
    yuu_apb_master_item m_item;

    m_item = new("m_item");
    m_item.cfg = cfg;
    m_item.randomize() with {direction == WRITE;};
    addr = m_item.addr;
    $display("data = %8h", m_item.data);
    start_item(m_item);
    finish_item(m_item);
    m_item.data = 0;

    m_item.randomize() with {direction == READ;};
    m_item.addr = addr;
    start_item(m_item);
    finish_item(m_item);
    $display("data = %8h", m_item.data);
  endtask
endclass : uvc_test_sequence

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
      s_cfg.use_random_data = True;
      cfg.set_config(s_cfg);
    end

    uvm_config_db#(yuu_apb_env_config)::set(this, "env", "cfg", cfg);
    env = yuu_apb_env::type_id::create("env", this);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvc_wo_callback wo_cb = new();
    //uvm_callbacks #(yuu_apb_slave_driver, yuu_apb_slave_driver_callback)::add(env.slave[0].driver, wo_cb);
    uvm_callbacks #(yuu_apb_slave_driver, yuu_apb_slave_driver_callback)::display();
  endfunction

  task main_phase(uvm_phase phase);
    uvc_test_sequence seq = new("seq");

    seq.cfg = cfg.mst_cfg[0];
    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);
    fork
      seq.start(env.master[0].sequencer);
      wait_event();
    join_any
    disable fork;
    phase.drop_objection(this);
  endtask : main_phase

  task wait_event();
    forever begin
      uvm_event e = cfg.events.get("e0_m0_drive_trans_begin");

      e.wait_trigger();
      $display("Begin @ %t", $realtime());
    end
  endtask
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
