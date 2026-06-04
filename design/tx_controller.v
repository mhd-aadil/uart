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
localparam LOAD  = 2'b01;
localparam SEND  = 2'b10;

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
                        state      <= LOAD;
                    end
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