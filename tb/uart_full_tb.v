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
input [2:0] addr_i;
input [7:0] data_i;
begin
    @(posedge clk);
    cs    <= 1'b1;
    wr    <= 1'b1;
    rd    <= 1'b0;
    addr  <= addr_i;
    wdata <= data_i;

    @(posedge clk);
    cs    <= 1'b0;
    wr    <= 1'b0;
    #60000; // Wait for transmission to complete
end
endtask
task uart_read;
input [2:0] addr_i;
//output [7:0] data;
begin
    @(posedge clk);
    cs    <= 1'b1;
    wr    <= 1'b0;
    rd    <= 1'b1;
    addr  <= addr_i;

    @(posedge clk);
    cs    <= 1'b0;
    rd    <= 1'b0;
   // data  <= rdata;
end
endtask
reg [7:0] data;
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
    //uart_write(3'b011, 8'h1b);

    /*repeat(10) begin
        data = $random&8'hFF;
        uart_write(3'b011, data);
        #60000;
    end*/
    //uart_write(3'b011, 8'h80);
    //uart_write(3'b000, 8'h34);
    //uart_write(3'b001, 8'h12);
    uart_write(3'b000, 8'h55);
    uart_write(3'b001, 8'b00000001);
    uart_read(3'b000);
    //uart_read(3'b101);




    //--------------------------------
    // Wait
    //--------------------------------
    //#60000;
   /* repeat(10) begin
        uart_read(3'b011);
       #4000;
    end*/
    //uart_read(3'b011);
    //uart_read(3'b000);
    //#20
    //uart_read(3'b001);

    #2000;

    $finish;
end
endmodule