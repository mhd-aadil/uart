class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)
     virtual apb_if apb_vif;
  	uvm_analysis_port#(apb_xtn)ap;
    
 	function new(string name="apb_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
    endfunction: build_phase

endclass: apb_monitor
  