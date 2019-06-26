/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_PKG_SVH
`define YUU_APB_SLAVE_PKG_SVH

  `include "yuu_apb_slave_memory.sv"
  `include "yuu_apb_slave_config.sv"
  `include "yuu_apb_slave_item.sv"
  `include "yuu_apb_slave_callbacks.sv"

  `include "yuu_apb_slave_base_sequence.sv"
  `include "yuu_apb_slave_response_sequence.sv"
  `include "yuu_apb_slave_driver.sv"
  `include "yuu_apb_slave_monitor.sv"
  `include "yuu_apb_slave_collector.sv"
  `include "yuu_apb_slave_analyzer.sv"
  `include "yuu_apb_slave_agent.sv"

`endif