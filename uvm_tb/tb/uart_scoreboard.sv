class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils("uart_scoreboard")
  uvm_tlm_analysis_fifo#(apb_xtn)apb_fifo;
  
  uvm_tlm_analysis_fifo#(uart_xtn)uart_fifo;
  
  bit [7:0] expected_q[$];

  
  
  function new(string name="uart_scoreboard",uvm_component parent);
    super.new=(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_fifo=new("apb_fifo",this);
    uart_fifo=new("uart_fifo",this);
    
  endfunction
  
  task process_apb();
    apb_xtn xtn; 
    
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
                    tx.data),
                    UVM_MEDIUM
                );
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
                    uxtn.data),
                    UVM_MEDIUM
                );
                continue;
        end
        expected_data=expected_q.pop_front();

        else
          begin
            if(expected_data!=uxtn.data)
              `uvm_error(
                    "SB",
                    $sformatf(
                    "MISMATCH EXP=%02h ACT=%02h",
                    expected_data,
                    uxtn.data)
                );
            else
              `uvm_info(
                    "SB",
                    $sformatf(
                    "MATCH EXP=%02h ACT=%02h",
                    expected_data,
                    uxtn.data),
                    UVM_MEDIUM
                );
          end
      end
  endtask

  task run_phase(uvm_phase phase);
    fork
      process_apb();
      process_uart();
    join
  endtask
  
endclass


    