/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_APB_SLAVE_CONFIG_SV
`define YUU_APB_SLAVE_CONFIG_SV

class yuu_apb_slave_config extends yuu_apb_agent_config;
  virtual yuu_apb_slave_interface vif;

            boolean wait_enable = True;
            boolean use_response= False;
  protected boolean multi_range = False;
  yuu_common_mem_pattern_e mem_init_pattern = PATTERN_ALL_0;

  yuu_amba_addr_map maps[];

  `uvm_object_utils_begin(yuu_apb_slave_config)
    `uvm_field_enum        (boolean,                  wait_enable,     UVM_PRINT | UVM_COPY)
    `uvm_field_enum        (boolean,                  use_response,    UVM_PRINT | UVM_COPY)
    `uvm_field_enum        (boolean,                  multi_range,     UVM_PRINT | UVM_COPY)
    `uvm_field_enum        (yuu_common_mem_pattern_e, mem_init_pattern,UVM_PRINT | UVM_COPY)
    `uvm_field_array_object(                          maps,            UVM_PRINT | UVM_COPY)
  `uvm_object_utils_end

  extern         function         new(string name = "yuu_apb_slave_config");
  extern virtual function void    set_map(yuu_amba_addr_t low, yuu_amba_addr_t high);
  extern virtual function void    set_maps(yuu_amba_addr_t lows[], yuu_amba_addr_t highs[]);
  extern virtual function         yuu_amba_addr_map get_map();
  extern virtual function void    get_maps(ref yuu_amba_addr_map maps[]);
  extern virtual function boolean is_multi_range();
endclass

  function yuu_apb_slave_config::new(string name = "yuu_apb_slave_config");
    super.new(name);
  endfunction

  // set_map
  //
  // Set slave address range
  // low: low address boundary
  // high: high address boundary
  function void yuu_apb_slave_config::set_map(yuu_amba_addr_t low, yuu_amba_addr_t high);
    maps = new[1];
    maps[0] = yuu_amba_addr_map::type_id::create($sformatf("%s_maps[0]", this.get_name()));
  
    maps[0].set_map(low, high);
  endfunction

  function void yuu_apb_slave_config::set_maps(yuu_amba_addr_t lows[], yuu_amba_addr_t highs[]);
    if (lows.size() == 0|| highs.size() == 0)
      `uvm_error("set_maps", "The lows or highs array is empty")
    else if (lows.size() != highs.size())
      `uvm_error("set_maps", "The lows and highs array must in the same size")
    else begin
      maps = new[lows.size()];
      foreach (maps[i])
        maps[i] = yuu_amba_addr_map::type_id::create($sformatf("%s_maps[%0d]", this.get_name(), i));
      foreach (lows[i])
        maps[i].set_map(lows[i], highs[i]);
      multi_range = True;
    end
  endfunction

  function yuu_amba_addr_map yuu_apb_slave_config::get_map();
    return this.maps[0];
  endfunction

  function void yuu_apb_slave_config::get_maps(ref yuu_amba_addr_map maps[]);
    maps = new[this.maps.size()];
    foreach (maps[i]) begin
      maps[i] = yuu_amba_addr_map::type_id::create("map");
      maps[i].copy(this.maps[i]);
    end
  endfunction

  function boolean yuu_apb_slave_config::is_multi_range();
    return this.multi_range;
  endfunction

`endif
