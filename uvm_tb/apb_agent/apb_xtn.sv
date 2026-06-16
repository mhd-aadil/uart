//  Module: apb_xtn
//
class apb_xtn extends uvm_sequence_item;
  bit [2:0] addr;
  bit [7:0] data;
     bit        write;  // 1 for write, 0 for read
     bit [7:0]  rdata; // for read data capture

    `uvm_object_utils_begin(apb_xtn)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(write, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_xtn");
        super.new(name);
    endfunction: new

endclass: apb_xtn
