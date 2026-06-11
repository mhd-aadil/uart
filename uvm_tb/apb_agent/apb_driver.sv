class apb_driver extends uvm_driver#(apb_xtn);
    `uvm_component_utils(apb_driver)
virtual uart_if uart_vif;
  function new(string name="apb_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if)::get(this, "","uart_vif",uart_vif)) begin
        `uvm_fatal("APB_DRIVER", "Virtual interface not found")
    end
  endfunction: build_phase
    
    
    task apb_write(apb_xtn xtn);
        @(posedge uart_vif.PCLK); #1;
        uart_vif.PADDR <= xtn.addr;
        uart_vif.PWRITE <= 1;
        uart_vif.PWDATA <= xtn.data;
        uart_vif.PSEL <= 1;
        uart_vif.PENABLE <= 0;
        @(posedge uart_vif.PCLK); #1;
        uart_vif.PENABLE <= 1;
        wait(uart_vif.PREADY);
        @(posedge uart_vif.PCLK); #1;
        uart_vif.PSEL <= 0;
        uart_vif.PENABLE <= 0;
        `uvm_info("APB_DRIVER", $sformatf("Write: addr=0x%0h, data=0x%0h", xtn.addr, xtn.data), UVM_LOW);
    endtask: apb_write

    task apb_read(apb_xtn xtn);
        @(posedge uart_vif.PCLK); #1;
        uart_vif.PADDR <= xtn.addr;
        uart_vif.PWRITE <= 0;
        uart_vif.PSEL <= 1;
        uart_vif.PENABLE <= 0;
        @(posedge uart_vif.PCLK); #1;
        uart_vif.PENABLE <= 1;
        wait(uart_vif.PREADY);
        @(posedge uart_vif.PCLK); #1;
        @(posedge uart_vif.PCLK); #1;

        xtn.data = uart_vif.PRDATA;
        uart_vif.PSEL <= 0;
        uart_vif.PENABLE <= 0;
        `uvm_info("APB_DRIVER", $sformatf("Read: addr=0x%0h, data=0x%0h", xtn.addr, xtn.data), UVM_LOW);
    endtask: apb_read

    task run_phase(uvm_phase phase);
        apb_xtn xtn;
        forever begin
            seq_item_port.get_next_item(xtn);
            if (xtn.write) begin
                apb_write(xtn);
            end else begin
                apb_read(xtn);
            end
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass: apb_driver

