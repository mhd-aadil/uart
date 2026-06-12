class apb_xtn extends uvm_sequence_item;
  bit [2:0] addr;
  bit [7:0] data;
     bit        write;  // 1 for write, 0 for read
     bit [7:0]  rdata; // for read data capture

    `uvm_object_utils(apb_xtn)

    function new(string name = "apb_xtn");
        super.new(name);
    endfunction: new

endclass: apb_xtn