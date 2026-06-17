class rx_sequence_uart extends uvm_sequence#(rx_xtn);

    `uvm_object_utils(rx_sequence_uart);
    
    function new(string name = "rx_sequence_uart");
        super.new(name);
    endfunction: new
    
endclass: rx_sequence_uart

class rx_sequence extends rx_sequence_uart;
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
    
 
