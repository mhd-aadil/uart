module uart_tx_tb;
reg clk;
reg rstn;
reg baud_clk;
reg [7:0] tx_data;
reg tx_start;
reg parity_en;
reg parity_type;
wire tx;
wire tx_busy;

uart_tx #(
    .DATA_WIDTH(8))
uart_tx_inst(
    .clk(clk),
    .rstn(rstn),
    .baud_clk(baud_clk),
    .tx_data(tx_data),
    .tx_start(tx_start),
    .parity_en(parity_en),
    .parity_type(parity_type),
    .tx(tx),
    .tx_busy(tx_busy)
);

initial 
begin
    clk=0;
    forever #10 clk=~clk;
end

initial 
begin
    $dumpfile("uart_tx.vcd");
    $dumpvars(0,uart_tx_tb);
end
initial
begin
    baud_clk=0;
    tx_data=0;
    tx_start=1'b0;
    parity_en=0;
    parity_type=0;
    #20;
    rstn=0;
    #20;
    rstn=1;
    #20;
    tx_data=8'hA5;
    tx_start=1'b1;
    baud_clk=1;
    #20;
    baud_clk=0;
    tx_start=1'b0;
    #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;
     #80;
    baud_clk=1;
    #20;
    baud_clk=0;


    #200;
  $finish;
end
endmodule


    