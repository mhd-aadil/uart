class uart_env extends uvm_env;
  `uvm_component_utils(uart_env);
  apb_agent apb_agt;
  uart_agent uart_agt;
  uart_scoreboard sb;
  
  function new(string name="uart_env",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agt=apb_agent::type_id::create("apb_agt",this);
    uart_agt=uart_agent::type_id::create("uart_agt",this);
    sb=uart_scoreboard::type_id::create("sb",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    apb_agt.apb_mon.ap.connect(sb.apb_fifo.analysis_export);
    uart_agt.uart_mon.ap.connect(sb.uart_fifo.analysis_export);
  endfunction
  
  
endclass