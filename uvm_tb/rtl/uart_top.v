`include "baud_gen.v"
`include "sync_fifo.v"
`include "tx_controller.v"
`include "uart_reg_file.v"
`include "uart_rx.v"
`include "uart_tx.v"
module uart_top (

    input  wire       clk,
    input  wire       rstn,

    // Register interface
    input  wire       cs,
    input  wire       wr,
    input  wire       rd,
    input  wire [2:0] addr,
    input  wire [7:0] wdata,

    output wire [7:0] rdata,
    output wire       irq,

    // UART pins
    input  wire       rx,
    output wire       tx
);
wire w1;
    //----------------------------------------
    // Register file outputs
    //----------------------------------------

    wire [7:0]  ier;
    wire [7:0]  lcr;
    wire [7:0]  fcr;
    wire [15:0] divisor;

    wire [7:0]  iir;
    wire [7:0]  lsr;

    wire [7:0]  tx_fifo_data_in;
    wire        tx_fifo_wr;
    wire        rx_fifo_rd;

    wire        tx_fifo_clear;
    wire        rx_fifo_clear;

    //----------------------------------------
    // TX FIFO
    //----------------------------------------

    wire [7:0] tx_fifo_dout;
    wire       tx_fifo_full;
    wire       tx_fifo_empty;
    wire [4:0] tx_fifo_count;

    //----------------------------------------
    // RX FIFO
    //----------------------------------------

    wire [7:0] rx_fifo_dout;
    wire       rx_fifo_full;
    wire       rx_fifo_empty;
    wire [4:0] rx_fifo_count;

    //----------------------------------------
    // UART RX
    //----------------------------------------

    wire [7:0] rx_uart_data;
    wire       rx_uart_valid;

    wire       framing_error;
    wire       parity_error;

    //----------------------------------------
    // Baud generator
    //----------------------------------------

    wire baud_clk;

    //----------------------------------------
    // UART TX
    //----------------------------------------

    wire tx_busy;

    //----------------------------------------
    // TX Controller
    //----------------------------------------

    wire       tx_fifo_rd;
    wire [7:0] tx_ctrl_data;
    wire       tx_ctrl_start;

    //----------------------------------------
    // Register File
    //----------------------------------------

    uart_reg_file u_reg_file (

        .clk              (clk),
        .rstn             (rstn),

        .cs               (cs),
        .wr               (wr),
        .rd               (rd),
        .addr             (addr),
        .wdata            (wdata),

        .rx_fifo_data_out (rx_fifo_dout),
        .rx_fifo_empty    (rx_fifo_empty),
        .tx_fifo_empty    (tx_fifo_empty),

        .rx_fifo_full     (rx_fifo_full),
        .tx_fifo_full     (tx_fifo_full),

        .tx_busy          (tx_busy),

        .framing_error    (framing_error),
        .parity_error     (parity_error),

        .rdata            (rdata),

        .ier              (ier),
        .lcr              (lcr),
        .fcr              (fcr),
        .divisor          (divisor),

        .iir              (iir),
        .lsr              (lsr),

        .irq              (irq),

        .tx_fifo_data_in  (tx_fifo_data_in),
        .tx_fifo_wr       (tx_fifo_wr),

        .rx_fifo_rd       (rx_fifo_rd),

        .tx_fifo_clear    (tx_fifo_clear),
        .rx_fifo_clear    (rx_fifo_clear)
    );

    //----------------------------------------
    // Baud Generator
    //----------------------------------------

    baud_gen u_baud_gen (

        .clk      (clk),
        .rstn     (rstn),

        .div      (divisor),

        .baud_clk (baud_clk)
    );

    //----------------------------------------
    // TX FIFO
    //----------------------------------------

    sync_fifo #(
        .DEPTH      (16),
        .DATA_WIDTH (8)
    ) u_tx_fifo (

        .clk      (clk),
        .rstn     (rstn),

        .clear    (tx_fifo_clear),

        .wr_en    (tx_fifo_wr),
        .rd_en    (tx_fifo_rd),

        .data_in  (tx_fifo_data_in),
        .data_out (tx_fifo_dout),

        .full     (tx_fifo_full),
        .empty    (tx_fifo_empty),

        .count    (tx_fifo_count)
    );

    //----------------------------------------
    // TX Controller
    //----------------------------------------

    tx_controller u_tx_controller (

        .clk           (clk),
        .rstn          (rstn),

        .tx_fifo_dout  (tx_fifo_dout),
        .tx_fifo_empty (tx_fifo_empty),

        .tx_fifo_rd    (tx_fifo_rd),

        .tx_busy       (tx_busy),

        .tx_data       (tx_ctrl_data),
        .tx_start      (tx_ctrl_start)
    );

    //----------------------------------------
    // UART TX
    //----------------------------------------

    uart_tx u_uart_tx (

        .clk         (clk),
        .rstn        (rstn),

        .baud_clk    (baud_clk),

        .tx_data     (tx_ctrl_data),
        .tx_start    (tx_ctrl_start),

        .parity_en   (lcr[3]),
        .parity_type (lcr[4]),

        .tx          (tx),
       // .tx          (w1),
        .tx_busy     (tx_busy)
    );

    //----------------------------------------
    // UART RX
    //----------------------------------------

    uart_rx u_uart_rx (

        .clk            (clk),
        .rstn           (rstn),

        .divisor        (divisor),

        .rx             (rx),
       // .rx             (w1),

        .parity_en      (lcr[3]),
        .parity_type    (lcr[4]),

        .rx_data        (rx_uart_data),
        .rx_valid       (rx_uart_valid),

        .framing_error  (framing_error),
        .parity_error   (parity_error)
    );

    //----------------------------------------
    // RX FIFO
    //----------------------------------------

    sync_fifo #(
        .DEPTH      (16),
        .DATA_WIDTH (8)
    ) u_rx_fifo (

        .clk      (clk),
        .rstn     (rstn),

        .clear    (rx_fifo_clear),

        .wr_en    (rx_uart_valid),
        .rd_en    (rx_fifo_rd),

        .data_in  (rx_uart_data),
        .data_out (rx_fifo_dout),

        .full     (rx_fifo_full),
        .empty    (rx_fifo_empty),

        .count    (rx_fifo_count)
    );
//assign tx_ctrl_data = tx_fifo_dout;
   // wire w2;
   // assign w1=tx;
    //assign rx=w1;
   // assign rx=w2;
endmodule