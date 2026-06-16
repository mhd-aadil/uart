class rx_agent extends uvm_agent;
  `uvm_component_utils(rx_agent)
  
  rx_driver rx_drv;
  rx_sequencer rx_seqr;
  rx_monitor rx_mon;
  
  
  function new(string name="rx_agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rx_mon=rx_monitor::type_id::create("rx_mon",this);
    //if(is_active)
    //begin
    rx_drv=rx_driver::type_id::create("rx_drv",this);
    rx_seqr=rx_sequencer::type_id::create("rx_seqr",this);
    //end
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rx_drv.seq_item_port.connect(rx_seqr.seq_item_export);
  endfunction
    
  
endclass
