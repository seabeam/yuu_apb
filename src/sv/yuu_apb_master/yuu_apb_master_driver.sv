/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_MASTER_DRIVER_SV
`define YUU_APB_MASTER_DRIVER_SV

class yuu_apb_master_driver extends uvm_driver #(yuu_apb_master_item);
  virtual yuu_apb_master_interface vif;
  uvm_analysis_port #(yuu_apb_master_item) out_driver_ap;
  
  yuu_apb_master_config cfg;
  uvm_event_pool events;
  protected process processes[string];

  `uvm_register_cb(yuu_apb_master_driver, yuu_apb_master_driver_callback)

  `uvm_component_utils_begin(yuu_apb_master_driver)
  `uvm_component_utils_end

  extern                   function      new(string name = "yuu_apb_master_driver", uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          run_phase(uvm_phase phase);

  extern protected virtual task          init_component();
  extern protected virtual task          reset_signal();
  extern protected virtual task          get_and_drive();
  extern protected virtual task          drive_bus();
  extern protected virtual task          wait_reset();
endclass

function yuu_apb_master_driver::new(string name = "yuu_apb_master_driver", uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_master_driver::build_phase(uvm_phase phase);
  out_driver_ap = new("out_driver_ap", this);
endfunction

function void yuu_apb_master_driver::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  this.events = cfg.events;
endfunction

task yuu_apb_master_driver::run_phase(uvm_phase phase);
  process proc_drive;

  init_component();
  fork
    forever begin
      wait(vif.drv_mp.preset_n === 1'b1);
      fork
        begin
          proc_drive = process::self();
          processes["proc_drive"] = proc_drive;
          get_and_drive();
        end
      join
    end
    wait_reset();
  join
endtask


task yuu_apb_master_driver::init_component();
  reset_signal();
endtask

task yuu_apb_master_driver::reset_signal();
  uvm_event reset_begin = events.get($sformatf("%s_reset_begin", cfg.get_name()));

  vif.drv_cb.paddr   <= 'h0;
  vif.drv_cb.penable <= 1'b0;
  vif.drv_cb.pwrite  <= 1'b0;
  vif.drv_cb.pwdata  <= 'h0;
  vif.drv_cb.pstrb   <= -'h1;
  vif.drv_cb.pprot   <= 1'b0;
  vif.drv_cb.psel    <= 1'b0;

  reset_begin.trigger();
endtask

task yuu_apb_master_driver::get_and_drive();
  uvm_event handshake = events.get("handshake");

  seq_item_port.get_next_item(req);
  handshake.trigger();
  @(vif.drv_cb);
  `uvm_do_callbacks(yuu_apb_master_driver, yuu_apb_master_driver_callback, pre_send(this, req));
  drive_bus();
  `uvm_do_callbacks(yuu_apb_master_driver, yuu_apb_master_driver_callback, post_send(this, req));
  out_driver_ap.write(req);
  rsp = yuu_apb_master_item::type_id::create("rsp");
  rsp.copy(req);
  rsp.set_id_info(req);
  seq_item_port.item_done(rsp);
  handshake.reset();
endtask

task yuu_apb_master_driver::drive_bus();
  uvm_event drive_trans_begin = events.get($sformatf("%s_drive_trans_begin", cfg.get_name()));
  uvm_event drive_trans_end   = events.get($sformatf("%s_drive_trans_end", cfg.get_name()));

  repeat(req.idle_delay) vif.wait_cycle();

  drive_trans_begin.trigger();

  vif.drv_cb.paddr    <= req.addr;
  vif.drv_cb.pwrite   <= bit'(req.direction);
  vif.drv_cb.psel     <= 1'b1;
  vif.drv_cb.pstrb    <= req.strb;
  vif.drv_cb.pprot    <= {bit'(req.prot2), bit'(req.prot1), bit'(req.prot0)};
  if (req.direction == WRITE)
    vif.drv_cb.pwdata   <= req.data;
  vif.wait_cycle();
  vif.drv_cb.penable  <= 1'b1;
  vif.wait_cycle();
  if (cfg.apb3_enable) begin
    int count = 0;
    while(vif.drv_cb.pready !== 1'b1) begin
      vif.wait_cycle();
      count ++;
      if (cfg.timeout > 0 && count >= cfg.timeout) begin
        `uvm_warning("drive_bus", "APB device timeout")
        return;
      end
    end
  end
  if (req.direction == READ) begin
    req.data = vif.drv_cb.prdata;
  end
  vif.drv_cb.psel     <= 1'b0;
  vif.drv_cb.penable  <= 1'b0;

  drive_trans_end.trigger();
endtask

task yuu_apb_master_driver::wait_reset();
  uvm_event handshake = events.get("handshake");

  forever begin
    @(negedge vif.drv_mp.preset_n);
    `uvm_warning("wait_reset", "Reset signal is asserted, transaction may be dropped")
    if (handshake.is_on())
      seq_item_port.item_done();
    foreach (processes[i])
      processes[i].kill();
    init_component();
    @(posedge vif.drv_mp.preset_n);
  end
endtask

`endif
