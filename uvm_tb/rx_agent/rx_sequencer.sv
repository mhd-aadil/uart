class rx_sequencer extends uvm_sequencer#(rx_xtn);
    `uvm_component_utils(rx_sequencer)

    function new(string name="rx_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction: new
endclass: rx_sequencer
