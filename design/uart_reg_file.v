/*
LCR (Line Control Register) bit definitions:
Bit	Name	Purpose
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
output reg tx_fifo_wr,
output reg rx_fifo_rd
);

// DLAB bit in LCR register
// When DLAB is set, the divisor latch registers are accessed instead 
// of the normal data and interrupt registers.
wire dlab;
assign dlab = lcr[7];  

always @(posedge clk or negedge rstn)
begin
    if(!rst)
    begin
        rdata <= 8'b0;
        ier <= 8'b0;
        lcr <= 8'h03;// Default to 8 data bits, no parity, 1 stop bit
        divisor <= 16'd434; // Default baud rate divisor for 115200 baud with a 50 MHz clock
        tx_fifo_data_in <= 8'b0;
        tx_fifo_wr <= 1'b0;
        rx_fifo_rd <= 1'b0;
    end
    else
    begin
        tx_fifo_wr <= 1'b0; // Default to no write
        rx_fifo_rd <= 1'b0; // Default to no read
        if(cs)
        begin
            if(wr)
            begin
                case(addr)
                    3'b000: // RBR/THR/DLL
                    begin
                        if(dlab)
                            divisor[7:0] <= wdata; // DLL
                        else
                        begin
                            tx_fifo_data_in <= wdata; // THR
                            tx_fifo_wr <= 1'b1; // Write to TX FIFO
                        end
                    end
                    3'b001: // IER/DLH
                    begin
                        if(dlab)
                            divisor[15:8] <= wdata; // DLH
                        else
                            ier <= wdata; // IER
                    end
                    3'b011: // LCR
                    begin
                        lcr <= wdata; // LCR
                    end
                    default: ; // Ignore writes to other addresses
                endcase
            end
            if(rd)
            begin
                case(addr)
                    3'b000: // RBR/THR/DLL
                    begin
                        if(dlab)
                        begin
                            rdata <= divisor[7:0]; // DLL
                        end
                        else
                        begin
                            rdata <= rx_fifo_data_out; // RBR
                            if(!rx_fifo_empty)
                            rx_fifo_rd <= 1'b1; // Read from RX FIFO
                        end
                    end
                    3'b001: // IER/DLH
                    begin
                        if(dlab)
                        begin
                            rdata <= divisor[15:8]; // DLH
                        end
                        else                        
                        begin
                            rdata <= ier; // IER
                        end
                    end
                    3'b010: // IIR
                    begin
                        // Interrupt Identification Register (IIR) - read-only
                        // Bit 0: Interrupt Pending (0 = pending, 1 = none)
                        // Bits [3:1]: Interrupt ID (priority)
                        // No interrupt if both FIFOs are empty

                    end
                    3'b011: // LCR
                    begin
                        rdata <= lcr; // LCR
                    end

                    3'd5: 
                    begin
                            // LSR:
                            // bit0 DR   = data ready
                            // bit1 OE   = overrun (not used yet)
                            // bit2 PE   = parity error
                            // bit3 FE   = framing error
                            // bit4 BI   = break interrupt (not used yet)
                            // bit5 THRE  = TX FIFO empty
                            // bit6 TEMT  = TX FIFO empty and TX not busy
                            // bit7      = 0 for now
                            rdata <= {
                                1'b0,
                                (tx_fifo_empty && !tx_busy),
                                tx_fifo_empty,
                                1'b0,
                                framing_error,
                                parity_error,
                                1'b0,
                                !rx_fifo_empty
                            };
                    end
                    default: rdata <= 8'b0; // Return 0 for other addresses
                endcase
            end
        end
    end
end
endmodule



