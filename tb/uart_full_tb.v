module uart_full_tb;
reg clk;
reg rstn;
reg cs;
reg wr;
reg rd;
reg [2:0] addr;
reg [7:0] wdata;
wire [7:0] rdata;
wire irq;
reg rx;
wire tx;

uart_top u_uart_top (
    .clk(clk),
    .rstn(rstn),
    .cs(cs),
    .wr(wr),
    .rd(rd),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .irq(irq),
    .rx(rx),
    .tx(tx)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
    
end

task uart_write;
input [2:0] addr;
input [7:0] data;
begin
    @(posedge clk);
    cs    <= 1'b1;
    wr    <= 1'b1;
    rd    <= 1'b0;
    addr  <= addr;
    wdata <= data;

    @(posedge clk);
    cs    <= 1'b0;
    wr    <= 1'b0;
end
endtask

initial begin
    $dumpfile("uart_full_tb.vcd");
    $dumpvars(0, uart_full_tb); 

    rstn  = 0;
    cs    = 0;
    wr    = 0;
    rd    = 0;
    addr  = 0;
    wdata = 0;
    rx    = 1'b1;

    #100;
    rstn = 1;

    //--------------------------------
    // Write THR (addr=0)
    //--------------------------------
    uart_write(3'b000, 8'hA5);

    //--------------------------------
    // Wait
    //--------------------------------
    #100000;

    $finish;
end
endmodule