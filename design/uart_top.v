//`include "baud_gen.v"
//`include "uart_tx.v"
//`include "uart_rx.v"
//`include "sync_fifo.v"
module uart_top(
input clk,
input rstn,
input tx_start,
input rx,
input rx_read,
input [7:0] tx_data,
output  tx,
output  [7:0] rx_data,
output  rx_valid,
output  tx_busy
);

wire baud_clk;

baud_gen baud_gen_inst(
.clk(clk),
.rstn(rstn),
.div(16'd4), // example for 115200 baud @ 50MHz
.baud_clk(baud_clk)
);
//fifo signals
wire [7:0] rx_fifo_data_out;
wire rx_fifo_full;
wire rx_fifo_empty;
wire [4:0] rx_fifo_count;

wire [7:0] tx_fifo_data_out;
wire tx_fifo_full;
wire tx_fifo_empty;
wire [4:0] tx_fifo_count;

//rx_signals
wire framing_error;
wire parity_error;
wire [7:0] rx_uart_data;
wire       rx_uart_valid;




uart_tx uart_tx_inst(
.clk(clk),
.rstn(rstn),
.baud_clk(baud_clk),
.tx_data(tx_fifo_data_out),
.tx_start(!tx_busy && !tx_fifo_empty),
.parity_en(1'b0), // No parity
.parity_type(1'b0), // Even parity (not used since parity is disabled)
.tx(tx),
.tx_busy(tx_busy)
);

uart_rx uart_rx_inst(
.clk(clk),
.rstn(rstn),
.divisor(16'd4), // example for 115200 baud @ 50MHz
.rx(rx),
.parity_en(1'b0), // No parity
.parity_type(1'b0), // Even parity (not used since parity is disabled)
.rx_data(rx_uart_data),
.rx_valid(rx_uart_valid),
.framing_error(framing_error),
.parity_error(parity_error)
);


sync_fifo #(
        .DEPTH(16),
        .DATA_WIDTH(8)
)
rx_fifo (
        .clk(clk),
        .rstn(rstn),
        .wr_en(rx_uart_valid),
        .rd_en(rx_read),
        .data_in(rx_uart_data),
        .data_out(rx_fifo_data_out),
        .full(rx_fifo_full),
        .empty(rx_fifo_empty),
        .count(rx_fifo_count)
        );

sync_fifo #(
        .DEPTH(16),
        .DATA_WIDTH(8)
)
tx_fifo (
        .clk(clk),
        .rstn(rstn),
        .wr_en(tx_start),
        .rd_en(!tx_busy&&!tx_fifo_empty),
        .data_in(tx_data),
        .data_out(tx_fifo_data_out),
        .full(tx_fifo_full),
        .empty(tx_fifo_empty),
        .count(tx_fifo_count)
        );

assign rx_data  = rx_fifo_data_out;
assign rx_valid = !rx_fifo_empty;
endmodule 
