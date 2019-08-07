/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_PKG_SV
`define YUU_APB_PKG_SV

`include "yuu_apb_defines.svh"
`include "yuu_apb_interface.svi"

package yuu_apb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import yuu_common_pkg::*;
  import yuu_amba_pkg::*;

  `include "yuu_apb_common_pkg.svh"
  `include "yuu_apb_master_pkg.svh"
  `include "yuu_apb_slave_pkg.svh"
  `include "yuu_apb_env_pkg.svh"
endpackage

`endif
