class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)
  uvm_tlm_analysis_fifo#(apb_xtn)apb_fifo;
  
  uvm_tlm_analysis_fifo#(uart_xtn)uart_fifo;

  uvm_tlm_analysis_fifo#(rx_xtn)rx_fifo;
  
  bit [7:0] expected_q[$];
  bit [7:0] expected_rx[$];


  
  
  function new(string name="uart_scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_fifo=new("apb_fifo",this);
    uart_fifo=new("uart_fifo",this);
    rx_fifo=new("rx_fifo",this);
    
  endfunction
  
  task process_apb();
    apb_xtn xtn; 
    bit [7:0]actual_rx;
    bit[7:0]expected_rx_data;
    forever
      begin
        apb_fifo.get(xtn);
        
        if(xtn.write&&xtn.addr==3'b000) // write to data reg
        begin  
        expected_q.push_back(xtn.data);
        `uvm_info(
                    "SB",
                    $sformatf(
                    "EXPECTED PUSH = %02h",
                    xtn.data),
                    UVM_MEDIUM
                );
        end
       /* else if (!xtn.write&&xtn.addr==3'b000)
        begin
          expected_rx.push_back(xtn.rdata);
          $display("SB: EXPECTED RX DATA=%02h",xtn.rdata);
        end*/
        else
        begin
          if(xtn.write==1'b0&&xtn.addr==3'b000)
          begin
            actual_rx=xtn.rdata;
            if(expected_rx.size()==0)
            begin
              `uvm_error(
                    "SB",
                    $sformatf(
                    "Unexpected RX read = %02h",
                    actual_rx)
                );
                continue;
            end
            else
            begin
              expected_rx_data=expected_rx.pop_front();
              if(expected_rx_data==actual_rx)
                begin
                string msg;
                msg = {"\n+----------------------------------+\n",
                      "|         SCOREBOARD MATCH         |\n",
                       "+----------------------------------+\n",
                     $sformatf("|  EXP = 0x%02h                     |\n", expected_rx_data),
                       $sformatf("|  ACT = 0x%02h                     |\n",actual_rx),
                      "+----------------------------------+"};
                  `uvm_info("SB", msg, UVM_MEDIUM);
               end
              else 
              begin
              `uvm_error(get_name(),$sformatf("EXPECTED DATA %02h ACTUAL DATA %02h",expected_rx_data,actual_rx) );
              end
            end
          end
        end
      end
  endtask

  task process_uart();
    uart_xtn uxtn;
    bit [7:0] expected_data;
    forever
      begin
        uart_fifo.get(uxtn);
        if(expected_q.size()==0)
        begin
          `uvm_error(
                    "SB",
                    $sformatf(
                    "EXPECTED PUSH = %02h",
                    uxtn.data)
                );
                continue;
        end

        else
          begin
            expected_data=expected_q.pop_front();
            if(expected_data!=uxtn.data)
              begin
              `uvm_error(
                    "SB",
                    $sformatf(
                    "MISMATCH EXP=%02h ACT=%02h",
                    expected_data,
                    uxtn.data)
                );
              end
            else
              begin
             /* `uvm_info(
                    "SB",
                    $sformatf(
                    "MATCH EXP=%02h ACT=%02h",
                    expected_data,
                    uxtn.data),
                    UVM_MEDIUM
                );*/
                string msg;
msg = {"\n+----------------------------------+\n",
       "|         SCOREBOARD MATCH         |\n",
       "+----------------------------------+\n",
       $sformatf("|  EXP = 0x%02h                     |\n", expected_data),
       $sformatf("|  ACT = 0x%02h                     |\n", uxtn.data),
       "+----------------------------------+"};
`uvm_info("SB", msg, UVM_MEDIUM);
                
              end
          end
      end
  endtask
  task rx_process;
    rx_xtn rxtn;
    forever
    begin
      rx_fifo.get(rxtn);
      expected_rx.push_back(rxtn.rx);
        
      end
  endtask


        
          
          



  task run_phase(uvm_phase phase);
    fork
      process_apb();
      process_uart();
      rx_process();
    join
  endtask
  
endclass


    