class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)

    function new(string name = "uart_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Build test components here (e.g., sequencer, driver, monitor)
        
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Running UART base test", UVM_LOW)
        // Test sequence will be implemented here
    endtask

endclass: uart_base_test
class class lcr_rw_test extends uart_base_test;
    `uvm_component_utils(lcr_rw_test)

    function new(string name = "lcr_rw_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        
