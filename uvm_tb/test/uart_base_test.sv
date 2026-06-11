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
        
