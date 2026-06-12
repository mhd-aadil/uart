class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils("uart_scoreboard")
  uvm_tlm_analysis_fifo#(apb_xtn)apb_fifo;
  
  //uvm_tlm_analysis_fifo#(uart_xtn)uart_fifo;
  
  bit [7:0] expected_q[$];

  
  
  function new(string name="uart_scoreboard",uvm_component parent);
    super.new=(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_fifo=new("apb_fifo",this);
    uart_fifo=new("apb_fifo",this);
    
  endfunction
  
  task process_apb();
    apb_xtn xtn;
    
    forever
      begin
        if
    
    