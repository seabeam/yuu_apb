/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_MEMORY_SV
`define YUU_APB_SLAVE_MEMORY_SV

class yuu_apb_slave_memory extends uvm_object;
  protected yuu_apb_data_t val[yuu_apb_addr_t];
  
  `uvm_object_utils(yuu_apb_slave_memory)

  function new(string name="yuu_apb_slave_memory");
    super.new(name);
  endfunction

  task write(input yuu_apb_addr_t addr, input yuu_apb_data_t data, input bit[3:0] strob = 4'hF);
    foreach (strob[i]) begin
      if (strob[i])
        val[addr][i*8+:8] = data[i*8+:8];
    end 
  endtask

  task read(input yuu_apb_addr_t addr, output yuu_apb_data_t data);
    data = val[addr];
  endtask
endclass

`endif
