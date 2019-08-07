/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_DEFINES_SVH
`define YUU_APB_DEFINES_SVH
  `ifndef YUU_APB_MASTER_NUM
  `define YUU_APB_MASTER_NUM 1
  `endif
  
  `ifndef YUU_APB_SLAVE_NUM
  `define YUU_APB_SLAVE_NUM 1
  `endif
  
  `ifndef YUU_APB_ADDR_WIDTH
  `define YUU_APB_ADDR_WIDTH 32
  `endif
  
  `ifndef YUU_APB_DATA_WIDTH
  `define YUU_APB_DATA_WIDTH 32
  `endif
  
  `ifndef YUU_APB_MASTER_INPUT_TIME
  `define YUU_APB_MASTER_INPUT_TIME  1ns
  `endif
  
  `ifndef YUU_APB_MASTER_OUTPUT_TIME
  `define YUU_APB_MASTER_OUTPUT_TIME 1ns
  `endif

  `ifndef YUU_APB_SLAVE_INPUT_TIME
  `define YUU_APB_SLAVE_INPUT_TIME  1ns
  `endif
  
  `ifndef YUU_APB_SLAVE_OUTPUT_TIME
  `define YUU_APB_SLAVE_OUTPUT_TIME 1ns
  `endif

  `ifndef YUU_APB_MAX_IDLE
  `define YUU_APB_MAX_IDLE 16
  `endif

  `ifndef YUU_APB_MAX_WAIT
  `define YUU_APB_MAX_WAIT 16
  `endif

`endif
