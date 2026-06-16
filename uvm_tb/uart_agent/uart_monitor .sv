class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_mnitor)
  virtual uart_if uart_vif;
  
  uvm_analysis_port#(uart_xtn)ap;
  
  
  function new(string name="uart_monitor",
                 uvm_component parent=null);

        super.new(name,parent);

        ap = new("ap",this);

    endfunction
  function void build_phase(uvm_phase phase);

     super.build_phase(phase);
     if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
       `uvm_fatal("NO VIF","VIF GETTING FAILLED IN UART MONITOR")
       
  endfunction
  
  task run_phase(uvm_phase phase);
    uart_xtn uxtn;
  	forever 
      begin
        @(negedge uart_vif.tx);
        uxtn=uart_xtn::type_id::create("uxtn");
        
		      //----------------------------------//
          // Sample in middle of start bit    //
          //----------------------------------//
        #(uart_vif.bit_time/2);

        if(uart_vif.tx != 1'b0)
           continue;
        
        #(uart_vif.bit_time);
        
        for(int i=0;i<8;i=i++)
          begin
            uxtn.data[i]=uart_vif.tx;
            
            #(uart_vif.bit_time);
            
          end
        if(uart_vif.tx!=1'b1)
          uxtn.framing_error = 1'b1;
        else
          uxtn.framing_error = 1'b0;
        ap.write(uxtn);
         `uvm_info(
                "UART_MON",
                $sformatf(
                    "RX BYTE = %02h",
                    uxtn.data
                ),
                UVM_MEDIUM
            );

    end

  endtask

endclass


          
            
       
        
        
        
        
        
    
       
       