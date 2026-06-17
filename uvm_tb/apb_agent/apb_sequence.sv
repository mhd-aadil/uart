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
   // wait(10ns); // Wait for write to complete

    //--------------------------------
    // Read from LCR
    //--------------------------------
    start_item(xtn);
    xtn.addr = 8'h03; // LCR address
    xtn.write = 0; // Read operation
    finish_item(xtn);
    endtask: body
endclass: lcr_rw_seq

class ier_rw_seq extends apb_sequence ;
  `uvm_object_utils(ier_rw_seq)

  function new(string name = "ier_rw_seq");
        super.new(name);
    endfunction: new

    task body();
        apb_xtn xtn;
    //--------------------------------       
    // Write to IER
    //--------------------------------
    xtn=apb_xtn::type_id::create("xtn");

    start_item(xtn);
    xtn.addr = 8'h01; // IER address
    xtn.data = 8'h0F; // Enable all interrupts
    xtn.write = 1; // Write operation
    finish_item(xtn);
   // wait(10ns); // Wait for write to complete

    //--------------------------------
    // Read from IER
    //--------------------------------
    start_item(xtn);
    xtn.addr = 8'h01; // IER address
    xtn.write = 0; // Read operation
    finish_item(xtn);
    endtask: body

endclass

class div_rw_seq extends apb_sequence ;
    `uvm_object_utils(div_rw_seq)

    function new(string name = "div_rw_seq");
        super.new(name);
    endfunction: new

    task body();
        apb_xtn xtn;
    //--------------------------------       
    // Write to Divisor Latch
    //--------------------------------
    xtn=apb_xtn::type_id::create("xtn");

    start_item(xtn);
    xtn.addr= 8'h03; // LCR address to set DLAB=1
    xtn.data= 8'b10000000; // Set DLAB=1
    xtn.write= 1; // Write operation
    finish_item(xtn);

    start_item(xtn);
    xtn.addr= 8'h00; // DLL address (when DLAB=1)
    xtn.data= 8'h34; // Set DLL value
    xtn.write= 1; // Write operation
    finish_item(xtn);

    start_item(xtn);
    xtn.addr= 8'h01; // DLM address (when DLAB=1)
    xtn.data= 8'h12; // Set DLM value
    xtn.write= 1; // Write operation
    finish_item(xtn);

    //--------------------------------
    // Read back Divisor Latch
    //--------------------------------
    start_item(xtn);
    xtn.addr= 8'h03; // LCR address to set DLAB=1
    xtn.write= 0; // Read operation
    finish_item(xtn);

    start_item(xtn);
    xtn.addr= 8'h00; // DLL address (when DLAB=1)
    xtn.write= 0; // Read operation
    finish_item(xtn);   

    start_item(xtn);
    xtn.addr= 8'h01; // DLM address (when DLAB=1)
    xtn.write= 0; // Read operation
    finish_item(xtn);
    endtask: body
endclass: div_rw_seq

class thr_write_seq extends apb_sequence;
  `uvm_object_utils(thr_write_seq)

    function new(string name = "thr_write_seq");
        super.new(name);
    endfunction: new
  task body;
    apb_xtn xtn;
    xtn=apb_xtn::type_id::create("xtn");
    start_item(xtn);
    
    xtn.addr=3'b000;
    xtn.data=8'h55;
    xtn.write=1'b1;
    
    finish_item(xtn);
    
   /* start_item(xtn);
    
    xtn.addr=3'b000;
    xtn.write=1'b0;
    
    finish_item(xtn);*/
  endtask
endclass

class thr_wr_seq extends apb_sequence;
  `uvm_object_utils(thr_wr_seq)

    function new(string name = "thr_wr_seq");
        super.new(name);
    endfunction: new
  task body;
    apb_xtn xtn;
    bit [7:0]lsr;
    xtn=apb_xtn::type_id::create("xtn");
    start_item(xtn);
    
    xtn.addr=3'b000;
    xtn.data=8'h55;
    xtn.write=1'b1;
    
    finish_item(xtn);
    
    do begin
      start_item(xtn);
      xtn.addr=3'b101;
      xtn.write=1'b0;
      
      finish_item(xtn);
      lsr=xtn.rdata;
      `uvm_info(get_type_name(),
                $sformatf("LSR = %0h", lsr),
                UVM_LOW)
    end while(lsr[0]==1'b0);
      
      
    start_item(xtn);
    
    xtn.addr=3'b000;
    xtn.write=1'b0;
    
    finish_item(xtn);
  endtask
endclass

//  Class: rx_read_seq
//
class rx_read_sequence extends apb_sequence;
    `uvm_object_utils(rx_read_sequence);

    function new(string name = "rx_read_sequence");
        super.new(name);
    endfunction: new
    task body;
        bit[7:0]lsr;
    apb_xtn xtn;
    xtn=apb_xtn::type_id::create("xtn");
    
    do begin
    start_item(xtn);
    xtn.addr=3'b101;
    xtn.write=1'b0;
    finish_item(xtn);
    lsr=xtn.rdata;
    end while(lsr[0]==1'b0);

    start_item(xtn);
    xtn.addr=3'b00;
    xtn.write=1'b0;
    finish_item(xtn);
endtask

endclass: rx_read_sequence





        