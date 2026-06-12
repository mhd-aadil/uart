class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)
     virtual apb_if apb_vif;
  	uvm_analysis_port#(apb_xtn)ap;
    
 	function new(string name="apb_monitor", uvm_component parent);
        super.new(name, parent);
      ap=new("ap",this);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
        `uvm_fatal("NO VIF","GETTING FAILED IN APB_MONITOR")
        
    endfunction: build_phase
    task run_phase(uvm_phase phase);
      forever
        begin
          if(uart_vif.PSEL &&
               uart_vif.PENABLE &&
               uart_vif.PREADY)
            begin
              xtn=apb_xtn::type_id::create("xtn");
              xtn.addr=uart_vif.PADDR;
              xtn.write=uart_vif.PWRITE;
              if(uart_vif.PWRITE)
                begin
                  xtn.data=uart_vif.PWDATA;
                  `uvm_info(
                        "APB_MON",
                        $sformatf(
                        "WRITE ADDR=%0h DATA=%0h",
                        xtn.addr,
                        xtn.data),
                        UVM_MEDIUM
                    );
                end
              else
                begin
                  xtn.rdata=uart_vif.PRDATA;
                   `uvm_info(
                        "APB_MON",
                        $sformatf(
                        "READ ADDR=%0h DATA=%0h",
                        xtn.addr,
                        xtn.rdata),
                        UVM_MEDIUM
                    );
                end
              ap.write(xtn);
            end
        end
      endtask

endclass: apb_monitor
  