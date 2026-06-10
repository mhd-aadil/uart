module tx_controller(
    input clk,
    input rstn,
    // FIFO interface
    input  wire [7:0] tx_fifo_dout,
    input  wire       tx_fifo_empty,

    output reg        tx_fifo_rd,

    // UART TX interface
    input  wire       tx_busy,

    output reg [7:0]  tx_data,
    output reg        tx_start
);

localparam IDLE  = 2'b00;
localparam WAIT  = 2'b01;
localparam LOAD  = 2'b10;
localparam SEND  = 2'b11;

reg [1:0] state;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        state <= IDLE;
        tx_fifo_rd <= 1'b0;
        tx_data <= 8'b0;
        tx_start <= 1'b0;
    end
    else
    begin
     // default pulses
        tx_fifo_rd <= 1'b0;
        tx_start   <= 1'b0;
        case(state)

                //--------------------------------
                // Wait for data in FIFO
                //--------------------------------
                IDLE:
                begin
                    if(!tx_busy && !tx_fifo_empty)
                    begin
                        tx_fifo_rd <= 1'b1;
                        state      <= WAIT;
                    end
                end
                WAIT:
                begin
                    tx_fifo_rd <= 1'b0; // Clear read after one cycle
                    if(tx_busy) // Wait for transmitter to be ready
                        state <= WAIT;
                    else
                        state <= LOAD;
                end
                //--------------------------------
                // Capture FIFO output
                //--------------------------------
                LOAD:
                begin
                    tx_data <= tx_fifo_dout;
                    state   <= SEND;
                end

                //--------------------------------
                // Start UART transmitter
                //--------------------------------
                SEND:
                begin
                    tx_start <= 1'b1;
                    state    <= IDLE;
                end

                default:
                    state <= IDLE;

        endcase        
    end
end
endmodule