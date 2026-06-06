module uart_tx#(parameter DATA_WIDTH=8)(
input clk,
input rstn,
input baud_clk,
input [DATA_WIDTH-1:0] tx_data,
input tx_start,
input parity_en,//1 to enable parity bit, 0 to disable
input parity_type,//0 for even, 1 for odd

output reg tx,
output reg tx_busy
);

localparam IDLE   = 3'b000;
localparam START  = 3'b001;
localparam DATA   = 3'b010;
localparam PARITY = 3'b011;
localparam STOP   = 3'b100;

  reg [2:0] state;
reg [DATA_WIDTH-1:0] shift_reg;
reg [2:0] bit_cnt;
reg parity_bit;

reg tx_start_latch;

// ─── Latch tx_start in fast clock domain ─────────────────────────────
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        tx_start_latch <= 1'b0;
    else if (tx_start)
        tx_start_latch <= 1'b1;   // Capture any-width pulse immediately
    else if (state == START)
        tx_start_latch <= 1'b0;   // Clear once transmission has begun
end
//always @(posedge clk or negedge rstn)
always @(*)
begin
    if(!rstn)
    begin
        tx_busy = 1'b0;
    end

    // Start immediately when request is latched
    else if(state == IDLE && tx_start_latch)
    begin
        tx_busy = 1'b1;
    end

    // Transmission completed
    else if(state == STOP && baud_clk)
    begin
        tx_busy = 1'b0;
    end
end
always @(posedge clk or negedge rstn)
begin
if(!rstn)
begin
    state<=IDLE;
    tx<=1'b1;
    shift_reg<=8'b0;
    bit_cnt<=3'b0;
    tx_busy<=1'b0;
    parity_bit <= 1'b0;
end
else if (baud_clk) 
begin
    case (state)
    IDLE: 
        begin
            tx <= 1'b1;
            tx_busy <= 1'b0;
            if(tx_start_latch)
            begin
                tx_busy<=1'b1;
                shift_reg<=tx_data;
                state<=START;
                bit_cnt<=0;
                parity_bit<=^tx_data; // Calculate parity bit (even parity)
            end
        end
    START:
        begin
            tx<=1'b0; // Start bit
            state<=DATA;
        end
    DATA:
        begin
            tx<=shift_reg[0]; // Send LSB first
          //shift_reg<={1'b0,shift_reg[DATA_WIDTH-1:1]}; // Shift right
            shift_reg<=shift_reg>>1; // Shift right
            bit_cnt<=bit_cnt+1;
            if(bit_cnt==DATA_WIDTH-1)
            begin
                if(parity_en)
                begin
                state<=PARITY;
                end
                else
                begin
                    state<=STOP;
                end
            end
        end
    PARITY:
        begin
            if(parity_type)
            begin
                tx<=~parity_bit; // Odd parity
            end
            else
            begin
                tx<=parity_bit; // Even parity
            end
            state <= STOP;

        end
    STOP:
        begin
            tx<=1'b1; // Stop bit
            //tx_busy<=1'b0;
            state<=IDLE;
        end
        default:begin
            state<=IDLE;
        end
    endcase

end
    
end

endmodule