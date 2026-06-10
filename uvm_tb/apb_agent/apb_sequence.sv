class apb_sequence extends uvm_sequence#(apb_xtn);
    `uvm_object_utils(apb_sequence)

    function new(string name = "apb_sequence");
        super.new(name);
    endfunction: new

endclass: apb_sequence

class lcr_rw_seq extends apb_sequence ;
    `uvm_object_utils(lcr_rw_seq)

    function new(string name = "lcr_rw_seq");
        super.new(name);
    endfunction: new

    task body();
        apb_xtn xtn;
    //--------------------------------       
    // Write to LCR
    //--------------------------------
    xtn=apb_xtn::type_id::create("xtn");

    start_item(xtn);
    xtn.addr = 8'h03; // LCR address
    xtn.data = 8'h1B; // Set DLAB=1 to access DLL and DLM
    xtn.write = 1; // Write operation
    finish_item(xtn);

    //--------------------------------
    // Read from LCR
    //--------------------------------
    start_item(xtn);
    xtn.addr = 8'h03; // LCR address
    xtn.write = 0; // Read operation
    finish_item(xtn);
    endtask: body
endclass: lcr_rw_seq





        