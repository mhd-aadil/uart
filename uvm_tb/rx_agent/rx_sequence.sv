class rx_sequence extends uvm_sequence#(rx_xtn);

    `uvm_object_utils(rx_sequence);
    
    function new(string name = "rx_sequence");
        super.new(name);
    endfunction: new
    
endclass: rx_sequence

class rx_sequence extends uvm_object;
        `uvm_object_utils(rx_sequence);
    
    function new(string name = "rx_sequence");
        super.new(name);
    endfunction: new

    task body;
        rx_xtn rxtn;
        rxtn=rx_xtn::type_id::create("rxtn");
        start_item(rxtn);
        rxtn.rx=8'h55;
        finish_item(rxtn);

    endtask
        
endclass: rx_sequence
    
 
