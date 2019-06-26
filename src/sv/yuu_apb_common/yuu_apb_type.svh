/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_TYPE_SVH
`define YUU_APB_TYPE_SVH

  typedef class yuu_apb_master_item;
  typedef class yuu_apb_slave_item;
  typedef uvm_sequencer #(yuu_apb_master_item) yuu_apb_master_sequencer;
  typedef uvm_sequencer #(yuu_apb_slave_item)  yuu_apb_slave_sequencer;

  typedef bit[`YUU_APB_DATA_WIDTH-1:0]   yuu_apb_data_t;
  typedef bit[`YUU_APB_ADDR_WIDTH-1:0]   yuu_apb_addr_t;
  typedef bit[`YUU_APB_DATA_WIDTH/8-1:0] yuu_apb_strb_t;

  typedef enum {
    READ,
    WRITE
  } yuu_apb_direction_e;

  typedef enum {
    OKAY,
    ERROR
  } yuu_apb_response_e;

  typedef enum {
    NORMAL,
    PRIVILEGED
  } yuu_apb_prot0_e;

  typedef enum {
    SECURE,
    NON_SECURE
  } yuu_apb_prot1_e;

  typedef enum {
    DATA,
    INSTRUCTION
  } yuu_apb_prot2_e;

  typedef enum {
    NO_ERROR,
    EARLIER_ENBALE,
    MISSED_ENABLE,
    MISSED_SELECT,
    INVALID_ADDR,
    READ_ONLY,
    WRITE_ONLY,
    CURRUPT_DATA
  } e_yuu_apb_error_type;

`endif
