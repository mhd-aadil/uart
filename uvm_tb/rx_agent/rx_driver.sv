class rx_driver extends uvm_driver#(rx_xtn);
    `uvm_component_utils(rx_driver)
virtual uart_if uart_vif;

  function new(string name="rx_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if)::get(this, "","uart_vif",uart_vif))
     begin
        `uvm_fatal("RX_DRIVER", "Virtual interface not found")
    end
  endfunction: build_phase

   task rx_driver::run_phase(uvm_phase phase);
    `uvm_info(get_name(), "<run_phase> started.", UVM_NONE)
    rx_xtn rxtn;
    forever
    begin
    seq_item_port.get_next_item(rxtn);
    rxtn_to_dut(rxtn);
    seq_item_port.item_done();
    end
    `uvm_info(get_name(), "<run_phase> finished", UVM_NONE)
  endtask: run_phase
  task rx_to_dut(rx_xtn rxtn);
    begin
      uart_vif.rx<=1'b1;

      #(uart_vif.bit_time);

      uart_vif.rx<=1'b0;

      #(uart_vif.bit_time);

      for(int i=0;i<8;i++)
      begin
        uart_vif.rx<=rxtn.rx[i];
        #(uart_vif.bit_time);

      end

      if(rxtn.framing_error)
      uart_vif.rx<=1'b0;
      else
      uart_vif.rx<=1'b1;

      #(uart_vif.bit_time);

      uart_vif.rx<=1'b1;
    end
  endtask

endclass


      
  