class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)
  uart_monitor uart_mon;
  function new(string name="uart_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_mon = uart_monitor::type_id::create("uart_mon", this);
  endfunction: build_phase
endclass: uart_agent