/*Bit	Name	Purpose
[1:0]	word length	5/6/7/8 bits
[2]	stop bits	1 or 2 stop bits
[3]	parity enable	enable parity
[4]	parity type	even/odd
[5]	stick parity	advanced
[6]	break control	force TX low
[7]	DLAB	divisor latch access
*/
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
output reg  [7:0] ier,
output reg  [7:0] lcr,
output reg  [15:0] divisor,

output reg [7:0] tx_fifo_data_in,
output reg tx_fifo_wr
output reg rx_fifo_rd
);

wire dlab;
assign dlab = lcr[7];



