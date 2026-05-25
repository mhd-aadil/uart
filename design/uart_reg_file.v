module uart_reg_file(
input clk,
input rstn,

input cs,
input wr,
input rd,
input [2:0] addr,
input [7:0] wdata,

input rx_fifo_data_out,
input rx_fifo_empty,
input tx_fifo_empty,
input tx_busy,
input framing_error,
input parity_error,

output reg [7:0] rdata,
