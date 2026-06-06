module apb_uart_tb;
reg PCLK;
reg PRESETn;
reg [7:0] PADDR;
reg PSEL;
reg PENABLE;
reg PWRITE;
reg [7:0] PWDATA;
wire [7:0] PRDATA;
wire PREADY;
reg rx;
wire tx;
wire irq;

apb_uart u_apb_uart (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PADDR(PADDR),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .rx(w1),
    .tx(tx),
    .irq(irq)
);
wire w1;
assign w1 = tx; // Loopback for testing
task apb_write(input [2:0] addr, input [7:0] data);
begin
    @(posedge PCLK);
    PADDR <= addr;
    PWDATA <= data;
    PSEL <= 1;
    PENABLE <= 1;
    PWRITE <= 1;
    @(posedge PCLK);
    PSEL <= 0;
    PENABLE <= 0;
end
endtask

initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK; // 100MHz clock
end

initial begin
    $dumpfile("apb_uart_tb.vcd");
    $dumpvars(0, apb_uart_tb);
    // Reset sequence
    PRESETn = 0;
    PADDR = 0;
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
    PWDATA = 0;
    rx = 1; // Idle state for UART RX

    #20; // Wait for some time
    PRESETn = 1; // Release reset
    #20;
    apb_write(8'h00, 8'hA5);
    apb_write(8'h00, 8'h55);
    apb_write(8'h00, 8'h3C);
    apb_write(8'h00, 8'hF0);
    // Add more test cases as needed
    #10;
    wait(u_apb_uart.u_uart.u_tx_fifo.empty &&
     !u_apb_uart.u_uart.tx_busy);

#1000;
$finish;    
end
endmodule

