/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_DRIVER_SV
`define YUU_APB_SLAVE_DRIVER_SV

class yuu_apb_slave_driver extends uvm_driver #(yuu_apb_slave_item);
  virtual yuu_apb_slave_interface vif;
  uvm_analysis_port #(yuu_apb_slave_item) out_driver_ap;

  yuu_apb_slave_config cfg;
  uvm_event_pool events;
  protected process processes[string];
  protected yuu_amba_addr_map maps[];

  protected yuu_apb_slave_memory  m_mem;

  `uvm_register_cb(yuu_apb_slave_driver, yuu_apb_slave_driver_callback)

  `uvm_component_utils_begin(yuu_apb_slave_driver)
  `uvm_component_utils_end

  extern                   function         new(string name = "yuu_apb_slave_driver", uvm_component parent);
  extern           virtual function void    build_phase(uvm_phase phase);
  extern           virtual function void    connect_phase(uvm_phase phase);
  extern           virtual task             reset_phase(uvm_phase phase);
  extern           virtual task             main_phase(uvm_phase phase);

  extern protected virtual function void    init_mem();
  extern protected virtual function boolean is_out(yuu_apb_addr_t addr);
  extern protected virtual task             reset_signal();
  extern protected virtual task             get_and_drive();
  extern protected virtual task             drive_bus();
  extern protected virtual task             wait_reset(uvm_phase phase);
endclass

function yuu_apb_slave_driver::new(string name = "yuu_apb_slave_driver", uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_apb_slave_driver::build_phase(uvm_phase phase);
  out_driver_ap  = new("out_driver_ap", this);
  cfg.get_maps(maps);
endfunction

function void yuu_apb_slave_driver::connect_phase(uvm_phase phase);
  this.vif = cfg.vif;
  this.events = cfg.events;
endfunction

task yuu_apb_slave_driver::reset_phase(uvm_phase phase);
  init_mem();
  reset_signal();
endtask

task yuu_apb_slave_driver::main_phase(uvm_phase phase);
  wait(vif.preset_n === 1'b1);
  vif.wait_cycle();
  fork
    forever begin
      get_and_drive();
    end
    wait_reset(phase);
  join
endtask


function void yuu_apb_slave_driver::init_mem();
  if (!uvm_config_db #(yuu_apb_slave_memory)::get(null, get_full_name(), "mem", m_mem)) begin
    m_mem = new;
  end
  m_mem.init_pattern  = cfg.mem_init_pattern;
  m_mem.data_width    = cfg.data_width;
endfunction

function boolean yuu_apb_slave_driver::is_out(yuu_apb_addr_t addr);
  foreach (maps[i]) begin
    if (maps[i].is_contain(addr))
      return False;
  end

  `uvm_warning("is_out", $sformatf("Address 0x%0h out of bound", addr))
  return True;
endfunction

task yuu_apb_slave_driver::reset_signal();
  vif.drv_cb.prdata   <= 'h0;
  vif.drv_cb.pready   <= 1'b1;
  vif.drv_cb.pslverr  <= 1'b0;
endtask

task yuu_apb_slave_driver::get_and_drive();
  drive_bus();
endtask

task yuu_apb_slave_driver::drive_bus();
  uvm_event drive_trans_begin = events.get($sformatf("%s_drive_trans_begin", cfg.get_name()));
  uvm_event drive_trans_end   = events.get($sformatf("%s_drive_trans_end", cfg.get_name()));

  while(vif.drv_cb.psel !== 1'b1)
    vif.wait_cycle();

  seq_item_port.get_next_item(req);
  @(vif.drv_cb);
  `uvm_do_callbacks(yuu_apb_slave_driver, yuu_apb_slave_driver_callback, pre_send(this, req));
  drive_trans_begin.trigger();

  req.addr = vif.drv_cb.paddr;
  req.direction = yuu_apb_direction_e'(vif.drv_cb.pwrite);
  req.strb = vif.drv_cb.pstrb; 
  {req.prot2, req.prot1, req.prot0} = vif.mon_cb.pprot;
  if (is_out(req.addr))
    req.resp = ERROR;

  if (cfg.apb3_enable) begin
    vif.drv_cb.pready <= 1'b0;
    repeat(req.wait_cycle) vif.wait_cycle();
    vif.drv_cb.pready <= 1'b1;
  end

  if (req.direction == WRITE) begin
    if (req.resp != ERROR) begin 
      req.data = vif.drv_cb.pwdata;
      if (cfg.apb4_enable)
        m_mem.write(req.addr, req.data, req.strb);
      else
        m_mem.write(req.addr, req.data);
    end
  end
  else if (req.direction == READ) begin
    yuu_apb_data_t data;

    if (req.resp != ERROR) begin 
      m_mem.read(req.addr, data);
      vif.drv_cb.prdata <= data;
      req.data = data;
    end
    else begin
      vif.drv_cb.prdata <= 'h0;
      req.data = 'h0;
    end
  end
  if (cfg.apb3_enable && req.resp == ERROR) begin 
    vif.drv_cb.pslverr <= 1'b1;
  end
  vif.wait_cycle();
  vif.drv_cb.pslverr <= 1'b0;

  `uvm_do_callbacks(yuu_apb_slave_driver, yuu_apb_slave_driver_callback, post_send(this, req));
  out_driver_ap.write(req);
  if (cfg.use_response) begin
    rsp = yuu_apb_slave_item::type_id::create("rsp");
    rsp.copy(req);
    rsp.set_id_info(req);
  end
  seq_item_port.item_done(rsp);
  drive_trans_end.trigger();
  vif.wait_cycle();
endtask

task yuu_apb_slave_driver::wait_reset(uvm_phase phase);
  @(negedge vif.drv_mp.preset_n);
  phase.jump(uvm_reset_phase::get());
endtask

`endif

