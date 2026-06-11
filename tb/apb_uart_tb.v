/*module apb_uart_tb;
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
assign w1 = tx; // Loopback for testing*/
/*task apb_write(input [2:0] addr, input [7:0] data);
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
task apb_read;
input [7:0] addr;
begin
    @(posedge PCLK);

    PADDR   <= addr;
    PWRITE  <= 1'b0;
    PSEL    <= 1'b1;
    PENABLE <= 1'b0;

    // Setup phase
    @(posedge PCLK);
    PENABLE <= 1'b1;

    // Access phase
    @(posedge PCLK);

    $display("TIME=%0t ADDR=%0h DATA=%0h",
             $time, addr, PRDATA);

    PSEL    <= 1'b0;
    PENABLE <= 1'b0;
end
endtask*/
// FIXED
/*task apb_write(input [2:0] addr, input [7:0] data);
begin
    @(posedge PCLK); #1;   // #1 avoids race on same edge
    PADDR  <= addr;
    PWDATA <= data;
    PSEL   <= 1;
    PWRITE <= 1;
    PENABLE <= 0;          // SETUP phase: PENABLE=0

    @(posedge PCLK); #1;   // ACCESS phase
    PENABLE <= 1;

    @(posedge PCLK); #1;   // deassert
    PSEL    <= 0;
    PENABLE <= 0;
    PWRITE  <= 0;
end
endtask
task apb_read(input [2:0] addr);
begin
    @(posedge PCLK); #1;
    PADDR   <= addr;
    PWRITE  <= 0;
    PSEL    <= 1;
    PENABLE <= 0;          // SETUP phase

    @(posedge PCLK); #1;  // ACCESS phase
    PENABLE <= 1;

    // Wait for PREADY (good habit even if tied high)
    @(posedge PCLK); #1;  // data is now stable

    PSEL    <= 0;
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

    #10; // Wait for some time
    PRESETn = 1; // Release reset
    #10;
   // FIXED flow
// 1. Write all TX bytes
apb_write(3'h0, 8'hA5);
apb_write(3'h0, 8'h55);
apb_write(3'h0, 8'h3C);
apb_write(3'h0, 8'hF0);

// 2. Wait for each byte to loop back — don't read before waiting
wait(u_apb_uart.u_uart.u_rx_fifo.empty === 1'b0);
@(posedge PCLK); #1;
apb_read(3'h0);
#20;
$display("TIME=%0t ADDR=%0h DATA=%0h", $time, PADDR, PRDATA);

wait(u_apb_uart.u_uart.u_rx_fifo.empty === 1'b0);
@(posedge PCLK); #1;
apb_read(3'h0);
#20;
$display("TIME=%0t ADDR=%0h DATA=%0h", $time,PADDR, PRDATA);

wait(u_apb_uart.u_uart.u_rx_fifo.empty === 1'b0);
@(posedge PCLK); #1;
apb_read(3'h0);
#20;
$display("TIME=%0t ADDR=%0h DATA=%0h", $time, PADDR, PRDATA);

wait(u_apb_uart.u_uart.u_rx_fifo.empty === 1'b0);
@(posedge PCLK); #1;
apb_read(3'h0);
#20;
$display("TIME=%0t ADDR=%0h DATA=%0h", $time, PADDR, PRDATA);

#1000;
$finish;    
end
endmodule
*/
module apb_uart_tb;

reg        PCLK, PRESETn;
reg  [7:0] PADDR;
reg        PSEL, PENABLE, PWRITE;
reg  [7:0] PWDATA;
wire [7:0] PRDATA;
wire       PREADY, tx, irq;
reg        rx;
wire       w1;

assign w1 = tx;  // loopback

apb_uart u_apb_uart (
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PADDR   (PADDR),
    .PSEL    (PSEL),
    .PENABLE (PENABLE),
    .PWRITE  (PWRITE),
    .PWDATA  (PWDATA),
    .PRDATA  (PRDATA),
    .PREADY  (PREADY),
    .rx      (w1),
    .tx      (tx),
    .irq     (irq)
);

// -------------------------------------------------------
// Clock
// -------------------------------------------------------
initial begin PCLK = 0; forever #5 PCLK = ~PCLK; end

// -------------------------------------------------------
// APB idle helper — explicit IDLE state between transfers
// -------------------------------------------------------
task apb_idle;
begin
    @(posedge PCLK); #1;
    PSEL    <= 0;
    PENABLE <= 0;
    PWRITE  <= 0;
end
endtask

// -------------------------------------------------------
// APB write — correct 3-phase: IDLE → SETUP → ACCESS
// -------------------------------------------------------
task apb_write(input [2:0] addr, input [7:0] data);
begin
    // SETUP phase
    @(posedge PCLK); #1;
    PADDR   <= {5'b0, addr};
    PWDATA  <= data;
    PSEL    <= 1;
    PWRITE  <= 1;
    PENABLE <= 0;

    // ACCESS phase
    @(posedge PCLK); #1;
    PENABLE <= 1;

    // Wait for slave ready
    while (!PREADY) @(posedge PCLK);

    // IDLE
    @(posedge PCLK); #1;
    PSEL    <= 0;
    PENABLE <= 0;
    PWRITE  <= 0;
end
endtask

// -------------------------------------------------------
// APB read — extra cycle for synchronous FIFO latency
// -------------------------------------------------------
reg [7:0] read_data;  // captured inside task, not from stale wire

task apb_read(input [2:0] addr);
begin
    // SETUP phase
    @(posedge PCLK); #1;
    PADDR   <= {5'b0, addr};
    PWRITE  <= 0;
    PSEL    <= 1;
    PENABLE <= 0;

    // ACCESS phase — rd_en fires inside uart_top here
    @(posedge PCLK); #1;
    PENABLE <= 1;
    @(posedge PCLK); #1;  // wait for FIFO to capture rd_en and present data on next cycle
    // Cycle 1 after ACCESS: wait for PREADY
    while (!PREADY) @(posedge PCLK);
    #1;

    // Cycle 2: sync FIFO data_out now stable → PRDATA valid
    @(posedge PCLK); #1;
    
    @(posedge PCLK); #1;
    read_data = PRDATA;  // blocking capture while still in ACCESS
    $display("TIME=%0t ADDR=%0h DATA=%0h", $time, addr, read_data);    

    // IDLE
    PSEL    <= 0;
    PENABLE <= 0;
    
end
endtask

// -------------------------------------------------------
// Stimulus
// -------------------------------------------------------
initial begin
    $dumpfile("apb_uart_tb.vcd");
    $dumpvars(0, apb_uart_tb);

    // Initialise
    PRESETn = 0;
    PSEL    = 0;
    PENABLE = 0;
    PWRITE  = 0;
    PADDR   = 0;
    PWDATA  = 0;
    rx      = 1;

    // Reset — hold for 2 full cycles minimum
    repeat(4) @(posedge PCLK);
    PRESETn = 1;
    repeat(2) @(posedge PCLK);

    // Write 4 bytes into TX FIFO
    apb_write(3'h3, 8'hA5);
   // apb_write(3'h0, 8'h55);
   // apb_write(3'h0, 8'h3C);
   // apb_write(3'h0, 8'hF0);

    // Read back 4 bytes from RX FIFO (loopback)
    // Each wait ensures FIFO is non-empty before the read task starts.
    // The @(posedge PCLK) after wait re-aligns to a clean clock edge.
    //repeat(1) begin
      //  wait(u_apb_uart.u_uart.u_rx_fifo.empty === 1'b0);
        @(posedge PCLK); #1;
        apb_read(3'h3);
    //end

    // Enough time for all frames at worst-case baud rate
    #500000;
    $finish;
end

endmodule
