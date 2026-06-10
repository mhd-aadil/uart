class apb_driver exends uvm_driver#(apb_xtn);
    `uvm_component_utils(apb_driver)
    virtual apb_if apb_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new
    task apb_write(apb_xtn xtn);
        @(posedge apb_vif.PCLK); #1;
        apb_vif.PADDR <= xtn.addr;
        apb_vif.PWRITE <= 1;
        apb_vif.PWDATA <= xtn.data;
        apb_vif.PSEL <= 1;
        apb_vif.PENABLE <= 0;
        @(posedge apb_vif.PCLK); #1;
        apb_vif.PENABLE <= 1;
        wait(apb_vif.PREADY);
        @(posedge apb_vif.PCLK); #1;
        apb_vif.PSEL <= 0;
        apb_vif.PENABLE <= 0;
        `uvm_info("APB_DRIVER", $sformatf("Write: addr=0x%0h, data=0x%0h", xtn.addr, xtn.data), UVM_LOW);
    endtask: apb_write

    task apb_read(apb_xtn xtn);
        @(posedge apb_vif.PCLK); #1;
        apb_vif.PADDR <= xtn.addr;
        apb_vif.PWRITE <= 0;
        apb_vif.PSEL <= 1;
        apb_vif.PENABLE <= 0;
        @(posedge apb_vif.PCLK); #1;
        apb_vif.PENABLE <= 1;
        wait(apb_vif.PREADY);
        @(posedge apb_vif.PCLK); #1;
        @(posedge apb_vif.PCLK); #1;

        xtn.data = apb_vif.PRDATA;
        apb_vif.PSEL <= 0;
        apb_vif.PENABLE <= 0;
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

