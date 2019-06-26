/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_DRIVER_SVH
`define YUU_APB_SLAVE_DRIVER_SVH

class yuu_apb_slave_driver extends uvm_driver #(yuu_apb_slave_item);
  virtual yuu_apb_slave_interface vif;
  uvm_analysis_port #(yuu_apb_slave_item) out_driver_ap;

  yuu_apb_slave_config cfg;
  uvm_event_pool events;

  protected yuu_apb_slave_memory  mem;

  `uvm_register_cb(yuu_apb_slave_driver, yuu_apb_slave_driver_callback)

  `uvm_component_utils_begin(yuu_apb_slave_driver)
  `uvm_component_utils_end

  extern                   function      new          (string name = "yuu_apb_slave_driver", uvm_component parent);
  extern           virtual function void build_phase  (uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          reset_phase  (uvm_phase phase);
  extern           virtual task          main_phase   (uvm_phase phase);
  extern protected virtual task          reset_signal ();
  extern protected virtual task          get_and_drive();
  extern protected virtual task          drive_bus    ();
  extern protected virtual task          wait_reset   (uvm_phase phase);
endclass

function yuu_apb_slave_driver::new(string name = "yuu_apb_slave_driver", uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_slave_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if (cfg == null)
    `uvm_fatal("build_phase", "yuu_apb_slave agent configuration is null")
  out_driver_ap  = new("out_driver_ap", this);
endfunction

function void yuu_apb_slave_driver::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  events = cfg.events;
endfunction

task yuu_apb_slave_driver::reset_phase(uvm_phase phase);
  mem = yuu_apb_slave_memory::type_id::create("mem");
  reset_signal();
endtask

task yuu_apb_slave_driver::main_phase(uvm_phase phase);
  wait(vif.preset_n === 1'b1);
  @(vif.cb);
  fork
    forever begin
      get_and_drive();
    end
    wait_reset(phase);
  join
endtask

task yuu_apb_slave_driver::reset_signal();
  vif.cb.prdata   <= 'h0;
  vif.cb.pready   <= 1'b1;
  vif.cb.pslverr  <= 1'b0;
endtask

task yuu_apb_slave_driver::get_and_drive();
  seq_item_port.get_next_item(req);
  `uvm_do_callbacks(yuu_apb_slave_driver, yuu_apb_slave_driver_callback, pre_send(this, req));
  drive_bus();
  `uvm_do_callbacks(yuu_apb_slave_driver, yuu_apb_slave_driver_callback, post_send(this, req));
  rsp = yuu_apb_slave_item::type_id::create("rsp");
  rsp.copy(req);
  rsp.set_id_info(req);
  seq_item_port.item_done(rsp);
endtask

task yuu_apb_slave_driver::drive_bus();
  uvm_event drive_trans_begin = events.get($sformatf("%s_drive_trans_begin", cfg.get_name()));
  uvm_event drive_trans_end   = events.get($sformatf("%s_drive_trans_end", cfg.get_name()));

  bit has_error = 1'b0;

  drive_trans_begin.trigger();

  if (cfg.apb3_enable) begin
    vif.cb.pready <= 1'b0;
    repeat(req.wait_cycle) @(vif.cb);
    vif.cb.pready <= 1'b1;
  end
  // Process error flag
  if (req.error_object == null)
    has_error = 1'b0;
  else if (req.error_object.error_type == INVALID_ADDR)
    has_error = 1'b1;
  else if (req.direction == WRITE && req.error_object.error_type == READ_ONLY)
    has_error = 1'b1;
  else if (req.direction == READ && req.error_object.error_type == WRITE_ONLY)
    has_error = 1'b1;

  if (req.direction == WRITE) begin
    if (!has_error) begin 
      if (cfg.apb4_enable)
        mem.write(req.addr, req.data, req.strb);
      else
        mem.write(req.addr, req.data);
    end
    else if (req.error_object != null) begin
      if (req.error_object.error_type == CURRUPT_DATA) begin
        mem.write(req.addr, req.user_data);
      end
    end
  end
  else if (req.direction == READ) begin
    yuu_apb_data_t data;

    mem.read(req.addr, data);
    if (!has_error) begin 
      if (cfg.use_random_data)
        vif.cb.prdata <= $urandom();
      else
        vif.cb.prdata <= data;
    end
    else if (req.error_object != null) begin
      if (req.error_object.error_type == CURRUPT_DATA) begin
        vif.cb.prdata <= req.user_data;
      end
    end
    else begin
      vif.cb.prdata <= 'h0;
    end
  end
  if (cfg.apb3_enable && has_error) begin 
    vif.cb.pslverr <= 1'b1;
  end
  @(vif.cb);
  vif.cb.pslverr <= 1'b0;

  drive_trans_end.trigger();
endtask

task yuu_apb_slave_driver::wait_reset(uvm_phase phase);
  @(negedge vif.preset_n);
  phase.jump(uvm_reset_phase::get());
endtask

`endif

