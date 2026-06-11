class uart_env extends uvm_env;
  `uvm_component_utils(uart_env);
  apb_agent apb_agt;
  
  function new(string name="uart_env",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agt=apb_agent::type_id::create("apb_agt",this);
  endfunction
  
endclass