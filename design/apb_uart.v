module apb_uart(

    input  wire       PCLK,
    input  wire       PRESETn,

    input  wire [7:0] PADDR,
    input  wire       PSEL,
    input  wire       PENABLE,
    input  wire       PWRITE,

    input  wire [7:0] PWDATA,

    output wire [7:0] PRDATA,
    output wire       PREADY,

    input  wire       rx,
    output wire       tx,

    output wire       irq
);

wire apb_write;
wire apb_read;

wire [7:0] uart_rdata;

assign apb_write =
       PSEL &&
       PENABLE &&
       PWRITE;

assign apb_read =
       PSEL &&
       PENABLE &&
      !PWRITE;

assign PRDATA = uart_rdata;
assign PREADY = 1'b1;

uart_top u_uart (

    .clk    (PCLK),
    .rstn   (PRESETn),

    .cs     (PSEL),
    .wr     (apb_write),
    .rd     (apb_read),

    .addr   (PADDR[2:0]),
    .wdata  (PWDATA),

    .rdata  (uart_rdata),

    .irq    (irq),

    .rx     (rx),
    .tx     (tx)
);

endmodule