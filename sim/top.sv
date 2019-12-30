/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////

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

    run_test();
  end

  initial begin
    clk = 'b0;
    rst = 'b0;
    #12;
    rst = 'b1;
  end

  always #5 clk = ~clk;

  assign yuu_apb_if.pclk = clk;
  assign yuu_apb_if.preset_n = rst;
endmodule
