//////////////////////////////////////////////////////////////////////////
//LCR (Line Control Register)                                           //
//bit  | definitions:                                                   //
//Bit    Name                             Purpose                       //
//-----------------------------------------------------------------     //
//[1:0]| word length             |         5/6/7/8 bits                 //
//[2]  | stop bits               |         1 or 2 stop bits             //
//[3]  | parity enable           |         enable parity                //
//[4]  | parity type             |         even/odd                     //
//[5]  | stick parity            |         advanced                     //
//[6]  | break control           |         force TX low                 //
//[7]  | DLAB                    |         divisor latch access         //
//////////////////////////////////////////////////////////////////////////

module uart_reg_file(input  wire       clk,input  wire       rstn,

input  wire       cs,
input  wire       wr,
input  wire       rd,
input  wire [2:0] addr,
input  wire [7:0] wdata,

input  wire [7:0] rx_fifo_data_out,
input  wire       rx_fifo_empty,
input  wire       tx_fifo_empty,
input  wire       rx_fifo_full,
input  wire       tx_fifo_full,
input  wire       tx_busy,
input  wire       framing_error,
input  wire       parity_error,

output reg  [7:0] rdata,
output reg  [7:0] ier,
output reg  [7:0] lcr,
output reg  [7:0] fcr,
output reg  [15:0] divisor,

output reg  [7:0] iir,
output reg  [7:0] lsr,
output wire       irq,

output reg  [7:0] tx_fifo_data_in,
output reg        tx_fifo_wr,
output reg        rx_fifo_rd,
output reg        tx_fifo_clear,
output reg        rx_fifo_clear

);

wire dlab;
assign dlab = lcr[7];

reg parity_error_latched;
reg framing_error_latched;
reg rbr_pending;   // high for one cycle after rx_fifo_rd issued


reg irq_r;
assign irq = irq_r;
//////////////////////////////////////////////////////
// Bit	|Name	  |Meaning                          //
//--------------------------------------------------//
// 0	|DR	      |Data Ready                       //
// 1	|OE	      |Overrun Error                    //          
// 2	|PE	      |Parity Error                     //  
// 3	|FE 	  |Framing Error                    //
// 4	|BI	      |Break Interrupt                  //
// 5	|THRE	  |Transmit Holding Register Empty  //
// 6	|TEMT	  |Transmitter Empty                //
// 7	|RX Error |Error Summary                    //
//////////////////////////////////////////////////////
always @(*) begin
    lsr = 8'h00;
    lsr[0] = ~rx_fifo_empty;
    lsr[1] = 1'b0;
    lsr[2] = parity_error_latched;
    lsr[3] = framing_error_latched;
    lsr[4] = 1'b0;
    lsr[5] = tx_fifo_empty;
    lsr[6] = tx_fifo_empty && !tx_busy;
    lsr[7] = parity_error_latched || framing_error_latched;

    // Determine interrupt ID and pending flag independently,
    // then OR in FIFO-enabled bits [7:6] cleanly.
    //
    // 16550A IIR layout:
    //   [7:6] = 11 when FIFOs enabled, 00 otherwise
    //   [3:1] = interrupt ID
    //   [0]   = 0 → interrupt pending, 1 → no interrupt pending

    if (ier[2] && (parity_error_latched || framing_error_latched))
        iir[3:1] = 3'b011;          // Line Status (priority 1)
    else if (ier[0] && !rx_fifo_empty)
        iir[3:1] = 3'b010;          // RX Data Available (priority 2)
    else if (ier[1] && tx_fifo_empty)
        iir[3:1] = 3'b001;          // THR Empty (priority 3)
    else
        iir[3:1] = 3'b000;          // No interrupt

    iir[0]   = ~(ier[2] && (parity_error_latched || framing_error_latched))
             & ~(ier[0] && !rx_fifo_empty)
             & ~(ier[1] && tx_fifo_empty);   // 1 = no interrupt pending

    iir[5:4] = 2'b00;               // always 0 in standard 16550
    iir[7:6] = fcr[0] ? 2'b11 : 2'b00;  // FIFO enabled flag, orthogonal from ID
end

wire irq_next;
////////////////////////////////////////////////////////////////////////
//Interrupt Enable Register (IER) bits                                //
//--------------------------------------------------------------------//
//Bit	|Name  	 |Purpose                                             //          
//------|--------|----------------------------------------------------//
//0	    |ERBFI	 |Enable RX Data Available Interrupt                  //
//1	    |ETBEI	 |Enable THR Empty Interrupt                          //
//2	    |ELSI	 |Enable Receiver Line Status Interrupt               //
//3	    |EDSSI	 |Enable Modem Status Interrupt (not implemented)     //
//[7:4]	|Reserved|	0                                                 //
////////////////////////////////////////////////////////////////////////
assign irq_next =
       (ier[2] && (parity_error_latched || framing_error_latched))
    || (ier[0] && !rx_fifo_empty)
    || (ier[1] && tx_fifo_empty);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        irq_r                <= 1'b0;
        rdata                <= 8'b0;
        ier                  <= 8'b0;
        lcr                  <= 8'h03;
        fcr                  <= 8'hC0;
        divisor              <= 16'd434;
        tx_fifo_data_in      <= 8'b0;
        tx_fifo_wr           <= 1'b0;
        rx_fifo_rd           <= 1'b0;
        tx_fifo_clear        <= 1'b0;
        rx_fifo_clear        <= 1'b0;
        parity_error_latched <= 1'b0;
        framing_error_latched<= 1'b0;
        rbr_pending          <= 1'b0;
    end
    else begin
        tx_fifo_wr    <= 1'b0;
        rx_fifo_rd    <= 1'b0;
        tx_fifo_clear <= 1'b0;
        rx_fifo_clear <= 1'b0;
        if (rx_fifo_rd) 
        begin
            rbr_pending <= 1'b1;  // data will be valid on next cycle
        end
        if (rbr_pending) begin
            rdata       <= rx_fifo_data_out;  // now valid
            rbr_pending <= 1'b0;
        end

        if (parity_error)
            parity_error_latched <= 1'b1;
        if (framing_error)
            framing_error_latched <= 1'b1;

        irq_r <= irq_next;

        if (cs) begin
            // FIX: wr and rd are mutually exclusive; wr takes priority
            if (wr && !rd) begin
                case (addr)
                    3'b000: begin
                        if (dlab)
                            divisor[7:0] <= wdata;
                        else if (!tx_fifo_full) begin
                            tx_fifo_data_in <= wdata;
                            tx_fifo_wr      <= 1'b1;
                        end
                    end
                    3'b001: begin
                        if (dlab)
                            divisor[15:8] <= wdata;
                        else
                            ier <= wdata;
                    end
                    3'b010: begin
                        fcr <= (wdata & 8'hF9);
                        if (wdata[1]) rx_fifo_clear <= 1'b1;
                        if (wdata[2]) tx_fifo_clear <= 1'b1;
                    end
                    3'b011: begin
                        lcr <= wdata;
                    end
                    default: ;
                endcase
            end

            // FIX: rd only fires when wr is not asserted
            if (rd && !wr) begin
                case (addr)
                    3'b000: begin
                                if (dlab) 
                                begin
                                    rdata <= divisor[7:0];
                                end
                                else 
                                begin
                                    if (rx_fifo_empty)
                                        rdata <= 8'h00;
                                    else 
                                    begin
                                        rx_fifo_rd <= 1'b1;
                                        //rbr_pending <= 1'b1;
                                        
                                    end
                                end
                            end
                    3'b001: begin
                        if (dlab)
                            rdata <= divisor[15:8];
                        else
                            rdata <= ier;
                    end
                    3'b010: begin
                        if (!dlab)
                            rdata <= iir;
                        else
                            rdata <= 8'b0;
                    end
                    3'b011: begin
                        rdata <= lcr;
                    end
                    3'b101: begin
                        rdata <= lsr;
                        if (!parity_error)
                            parity_error_latched <= 1'b0;
                        if (!framing_error)
                            framing_error_latched <= 1'b0;
                    end
                    default: begin
                        rdata <= 8'b0;
                    end
                endcase
            end
        end
    end
end

endmodule