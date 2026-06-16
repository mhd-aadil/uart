class rx_xtn extends uvm_sequence_item;

    `uvm_object_utils_begin(uart_xtn)
        `uvm_field_int(rx, UVM_ALL_ON)
        `uvm_field_int(framing_error, UVM_ALL_ON)
    `uvm_object_utils_end

    bit[7:0]rx;
    bit framing_error;
    //  Constructor: new
    function new(string name = "rx_xtn");
        super.new(name);
    endfunction: new

    
    
endclass: rx_xtn




