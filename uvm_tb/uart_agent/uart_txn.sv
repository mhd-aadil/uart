class uart_txn extends uvm_sequence_item;
  	bit [7:0] data;

    bit framing_error;
    bit parity_error;

    `uvm_object_utils(uart_txn)

    function new(string name="uart_txn");
        super.new(name);
    endfunction

endclass
