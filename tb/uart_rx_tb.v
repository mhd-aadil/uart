module uart_rx_tb;
reg clk;
reg rstn;
reg [15:0] divisor;
reg rx;
reg parity_en;
reg parity_type;
wire [7:0] rx_data;
wire rx_valid;
wire framing_error;
wire parity_error;

uart_rx #(
    .DIV_WIDTH(16))
uart_rx_inst(
    .clk(clk),
    .rstn(rstn),
    .divisor(16'd8),
    .rx(rx),
    .parity_en(parity_en),
    .parity_type(parity_type),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .framing_error(framing_error),
    .parity_error(parity_error)
);

initial
begin
    clk=0;
    forever #10 clk=~clk;
end
initial
begin
    $dumpfile("uart_rx.vcd");
    $dumpvars(0,uart_rx_tb);
end
initial
begin
    rstn=0;
    rx=1;
    parity_en=0;
    parity_type=0;
    #20;
    rstn=1;
    #20;
    // Simulate receiving 0xA5 (10100101) with even parity
    rx=0; // Start bit
    #120;
    rx=1; // Bit 0
    #160;

    rx=0; // Bit 1
    #160;
    rx=1; // Bit 2
    #160;
    rx=0; // Bit 3
    #160;
    rx=0; // Bit 4
    #160;
    rx=1; // Bit 5
    #160;
    rx=0; // Bit 6
    #160;
    rx=1; // Bit 7
    #160;
   // rx=0; // Parity bit (even parity)
   //#160;
    rx=1; // Stop bit
    #160;
    #200;
    $finish;
end

endmodule

