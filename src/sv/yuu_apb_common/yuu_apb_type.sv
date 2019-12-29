/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_TYPE_SV
`define YUU_APB_TYPE_SV

  typedef bit[`YUU_APB_ADDR_WIDTH-1:0]   yuu_apb_addr_t;
  typedef bit[`YUU_APB_DATA_WIDTH-1:0]   yuu_apb_data_t;
  typedef bit[`YUU_APB_STRB_WIDTH-1:0] yuu_apb_strb_t;
  typedef class yuu_apb_master_item;
  typedef uvm_reg_predictor #(yuu_apb_master_item) yuu_apb_master_predictor;

  typedef enum bit{
    READ,
    WRITE
  } yuu_apb_direction_e;

  typedef enum bit{
    OKAY,
    ERROR
  } yuu_apb_response_e;

  typedef enum bit{
    NORMAL,
    PRIVILEGED
  } yuu_apb_prot0_e;

  typedef enum bit{
    SECURE,
    NON_SECURE
  } yuu_apb_prot1_e;

  typedef enum bit{
    DATA,
    INSTRUCTION
  } yuu_apb_prot2_e;

  typedef enum bit[3:0]{
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
