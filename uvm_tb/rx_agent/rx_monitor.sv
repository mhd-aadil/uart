class rx_monitor extends uvm_component;
    `uvm_component_utils(rx_monitor);

    uvm_analysis_port#(rx_xtn)ap;
    virtual uart_if uart_vif;

    function new(string name = "rx_monitor", uvm_component parent);
        super.new(name, parent);
        ap=new("ap",this);
    endfunction: new

    function void rx_monitor::build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
        ``uvm_fatal("NO VIF", "GETTING FAILED IN RX_MONITOR")

    endfunction: build_phase

    task rx_monitor::run_phase(uvm_phase phase);
        `uvm_info(get_name(), "<run_phase> started, objection raised.", UVM_NONE)
        rx_xtn rxtn;
        forever
        begin
            @(negedge uart_vif.rx);
            rxtn=rx_xtn::type_id::create("rxtn");
            #(uart_vif.bit_time/2);
            if(uart_vif.rx!=0)
            continue;

            #(uart_vif.bit_time/2);

            for(int i=0;i<8;i++)
            begin
                rxtn.rx[i]=uart_vif.rx;
                #(uart_vif.bit_time/2);
            end

            rxtn.framing_error=(uart_vif.rx!=1);

            rxtn.print();

            ap.write(rxtn);

        end
    endtask




    
        
    
        `uvm_info(get_name(), "<run_phase> finished, objection dropped.", UVM_NONE)
    endtask: run_phase
    ;
        
    endtask: name
    

    



    
endclass: rx_monitor
