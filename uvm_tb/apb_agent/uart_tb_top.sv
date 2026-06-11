module uart_tb_top;
    logic PCLK;
    logic PRESETn;

    uart_if uart_vif(PCLK);
    // Instantiate the APB agent
    apb_uart DUT (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(uart_vif.PADDR),
        .PWDATA(uart_vif.PWDATA),
        .PWRITE(uart_vif.PWRITE),
        .PSEL(uart_vif.PSEL),
        .PENABLE(uart_vif.PENABLE),
        .PRDATA(uart_vif.PRDATA),
        .PREADY(uart_vif.PREADY),
        .rx(1'b1) // Tie RX to idle state
        .tx() // Connect TX to testbench for monitoring
        .irq() // Connect IRQ to testbench for monitoring
        );

    // Clock generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK; // 100MHz clock
    end 

    initial begin
        PRESETn = 0;
        #100 PRESETn = 1; // Release reset after 100ns
    end

    initial
    begin
        run_test("lcr_rw_seq");
        
        $dumpfile("uart_tb_top.vcd");
        $dumpvars(0, uart_tb_top);
        #1000; // Run simulation for 1000ns
        $finish;
    end
    