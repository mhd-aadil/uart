class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_mnitor)
  virtual uart_if uart_vif;
  
  uvm_analysis_port#(uart_xtn)ap;
  
  
  function new(string name="uart_monitor",
                 uvm_component parent=null);

        super.new(name,parent);

        ap = new("ap",this);

    endfunction
  function void build_phase(uvm_phase phase);

     super.build_phase(phase);
     uvm_config_db#(virtual uart_if)::