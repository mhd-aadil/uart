class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)
    uart_env env;

    function new(string name = "uart_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Build test components here (e.g., sequencer, driver, monitor)
        env = uart_env::type_id::create("env", this);

    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Running UART base test", UVM_LOW)
        // Test sequence will be implemented here
    endtask

endclass: uart_base_test

class  lcr_rw_test extends uart_base_test;
    `uvm_component_utils(lcr_rw_test)

    function new(string name = "lcr_rw_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        lcr_rw_seq seq;

        super.run_phase(phase);
        `uvm_info(get_type_name(), "Running LCR read/write test", UVM_LOW)
        
        phase.raise_objection(this);
        seq = lcr_rw_seq::type_id::create("seq");
        seq.start(env.apb_agt.apb_seqr);
        #100ns;
        phase.drop_objection(this);

    endtask
endclass: lcr_rw_test

class ier_rw_test extends uart_base_test;
    `uvm_component_utils(ier_rw_test)

    function new(string name = "ier_rw_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ier_rw_seq seq_ier;

        super.run_phase(phase);
        `uvm_info(get_type_name(), "Running IER read/write test", UVM_LOW)
        
        phase.raise_objection(this);
      seq_ier = ier_rw_seq::type_id::create("seq_ier");
        seq_ier.start(env.apb_agt.apb_seqr);
        #100ns;
        phase.drop_objection(this);

    endtask

endclass: ier_rw_test

class div_rw_test extends uart_base_test;
    `uvm_component_utils(div_rw_test)

    function new(string name = "div_rw_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        div_rw_seq seq;

        super.run_phase(phase);
        `uvm_info(get_type_name(), "Running Divisor Latch read/write test", UVM_LOW)
        
        phase.raise_objection(this);
        seq = div_rw_seq::type_id::create("seq");
        seq.start(env.apb_agt.apb_seqr);
        #100ns;
        phase.drop_objection(this);

    endtask

endclass: div_rw_test
        
class thr_write_test extends uart_base_test;
    `uvm_component_utils(thr_write_test)

    function new(string name = "thr_write_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        thr_write_seq seq;

        super.run_phase(phase);
      `uvm_info(get_type_name(), "Running thr write test", UVM_LOW)
        
        phase.raise_objection(this);
        seq = thr_write_seq::type_id::create("seq");
        seq.start(env.apb_agt.apb_seqr);
        #60000ns;
        phase.drop_objection(this);

    endtask

endclass: thr_write_test

class thr_wr_test extends uart_base_test;
    `uvm_component_utils(thr_wr_test)

    function new(string name = "thr_wr_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        thr_wr_seq seq;

        super.run_phase(phase);
      `uvm_info(get_type_name(), "Running thr write read test", UVM_LOW)
        
        phase.raise_objection(this);
        seq = thr_wr_seq::type_id::create("seq");
        seq.start(env.apb_agt.apb_seqr);
        #60000ns;
        phase.drop_objection(this);

    endtask

endclass: thr_wr_test

class rx_wr_test extends uart_base_test;

    `uvm_component_utils(uart_base_test);
    rx_sequence rx_seq;
    rx_read_sequence rx_read_seq;
    
    function new(string name = "uart_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_name(), "<run_phase> started, objection raised.", UVM_NONE)
        rx_seq.start(env.rx_agt.rx_seqr);
        rx_read_seq.start(env.apb_agt.apb_seqr);
        #1000;
        phase.drop_objection(this);
        `uvm_info(get_name(), "<run_phase> finished, objection dropped.", UVM_NONE)
    endtask: run_phase
    
    
        
endclass: uart_base_test
    