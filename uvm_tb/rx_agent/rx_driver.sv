class rx_driver extends uvm_driver#(rx_xtn);
    `uvm_component_utils(rx_driver)
virtual uart_if uart_vif;
  function new(string name="rx_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if)::get(this, "","uart_vif",uart_vif)) begin
        `uvm_fatal("APB_DRIVER", "Virtual interface not found")
    end
  endfunction: build_phase