class uart_txn extends uvm_sequence_item;
  	bit [7:0] data;

    bit framing_error;
    bit parity_error;

    `uvm_object_utils_begin(uart_txn)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(framing_error, UVM_ALL_ON)
        `uvm_field_int(parity_error, UVM_ALL_ON)
    `uvm_object_utils_end
        

    function new(string name="uart_txn");
        super.new(name);
    endfunction

endclass
