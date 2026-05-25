module uart_rx#(parameter DIV_WIDTH = 16)(
    input wire clk,
    input wire rstn,
    input wire [DIV_WIDTH-1:0] divisor,
    input wire rx,
    input wire parity_en, // 1 to enable parity bit, 0 to disable
    input wire parity_type, // 0 for even, 1 for odd

    output reg [7:0] rx_data,
    output reg rx_valid,
    output reg framing_error,
    output reg parity_error
);
reg rx_sync0, rx_sync1;
reg [DIV_WIDTH-1:0] cnt;
reg [2:0] bit_cnt;
reg [7:0] rx_shift_reg;
reg [2:0] state;
reg calculated_parity_bit;
reg rx_parity_bit;


localparam IDLE = 3'b000,
           START = 3'b001,
           DATA = 3'b010,
           PARITY = 3'b011,
           STOP = 3'b100;

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        rx_sync0<=1'b1;
        rx_sync1<=1'b1;
    end
    else
    begin
        rx_sync0<=rx;
        rx_sync1<=rx_sync0;
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        rx_data<=8'b0;
        rx_shift_reg<=8'b0;
        cnt<=16'b0;
        bit_cnt<=3'b0;
        rx_valid<=1'b0;
        state<=IDLE;
        framing_error<=1'b0;
        parity_error<=1'b0;
        rx_parity_bit<=1'b0;
        calculated_parity_bit<=1'b0;

    end
    else
    begin                
        rx_valid<=1'b0;
        case (state)
        IDLE:
            begin
                framing_error<=1'b0;
                parity_error<=1'b0;
                if(rx_sync1==1'b0) // Start bit detected
                begin
                    state<=START;
                    //cnt<=(divisor>>1)-1'b1; // Wait half bit time
                    cnt<=(divisor>>1);
                end
            end
        START:
            begin
                if(cnt==0)
                begin
                    if (rx_sync1==0)
                    begin
                        calculated_parity_bit<=1'b0; // Reset parity calculation
                        state<=DATA;
                        cnt<=divisor-1'b1; // Wait full bit time
                        bit_cnt<=0;
                    end
                    else
                    begin
                        state<=IDLE; // False start bit, return to IDLE                        
                    end
                    
                end
                else
                begin
                    cnt<=cnt-1;
                end
            end
        DATA:
            begin
                if (cnt==0) 
                begin
                    rx_shift_reg[bit_cnt] <= rx_sync1;
                    calculated_parity_bit <= calculated_parity_bit ^ rx_sync1; // Update parity calculation
                    if (bit_cnt==3'd7) 
                    begin
                        cnt<=divisor-1'b1;
                        if(parity_en)
                        begin
                            state<=PARITY;
                        end
                        else
                        begin
                            state<=STOP;
                        end
                        
                    end
                    else
                    begin
                        cnt<=divisor-1'b1; // Wait full bit time for next data bit
                        bit_cnt<=bit_cnt+1'b1;
                    end
                end
                else
                begin
                    cnt<=cnt-1'b1;
                end
            end
        PARITY:
            begin
                if(cnt==0)
                begin
                    rx_parity_bit<=rx_sync1; // Sample parity bit
                    if(parity_type) // Odd parity
                    begin
                        if(rx_sync1 != (~calculated_parity_bit))
                        begin
                            parity_error<=1'b1; // Parity error detected
                        end
                    end
                
                    else // Even parity
                    begin
                        if(rx_sync1 != calculated_parity_bit)
                        begin
                            parity_error<=1'b1; // Parity error detected
                        end
                    end
                    state<=STOP;
                    cnt<=divisor-1'b1; // Wait full bit time for stop bit
                end
                else
                begin
                    cnt<=cnt-1'b1;
                end
            end 
            

        STOP:
            begin
                if(cnt==0)
                begin
                    if(rx_sync1==1'b1)
                    begin
                        framing_error<=1'b0; // No framing error 
                        rx_data<=rx_shift_reg; // Latch received data
                        rx_valid<=1'b1; // Indicate data is valid
                             
                    end
                    else
                    begin
                        framing_error<=1'b1; // Framing error detected
                    end
                    state<=IDLE; // Return to IDLE after stop bit
                end
                else
                begin
                    cnt<=cnt-1;
                end
            end
        default: state<=IDLE;
        endcase
    end
end
endmodule
/*module uart_rx#(parameter DATA_WIDTH=8)(
input clk,
input rstn,
input baud_clk,
input rx_in,
  output reg [DATA_WIDTH-1:0] data_out,
output reg rx_valid
);
localparam IDLE  =2'b00 ;
localparam START  =2'b01 ;
localparam DATA  =2'b10 ;
localparam STOP  =2'b11 ;

reg [1:0] state;
reg [DATA_WIDTH-1:0] shift_reg;
reg [2:0] bit_cnt;

always @(posedge clk or negedge rstn)
begin
if(!rstn)
begin
    state<=IDLE;
    data_out<=8'b0;
    bit_cnt<=3'b0;
    rx_valid<=1'b0;
    shift_reg<=8'b0;
end
else if(baud_clk)
begin
    case (state)
    IDLE: 
        begin
            rx_valid<=1'b0;
            bit_cnt<=3'b0;
            if(!rx_in) // Start bit detected
            begin
                state<=DATA;
                rx_valid<=1'b0;
            end
            
        end
    START:
        begin
            
                state<=DATA;
            end
           
    DATA:
        begin
        shift_reg<={rx_in,shift_reg[DATA_WIDTH-1:1]};
        if(bit_cnt==(DATA_WIDTH-1))
            state<=STOP;
        else
            bit_cnt<=bit_cnt+1;

        end
    STOP:
        begin
            if(rx_in) // Stop bit should be high
            begin
                data_out<=shift_reg;
                rx_valid<=1'b1;
                bit_cnt<=0;

            end
            state<=IDLE;
        end
    STOP: begin
    if(rx_in) begin
        data_out  <= shift_reg;
        rx_valid  <= 1'b1;
        bit_cnt <= 0;

    end
    
    state   <= IDLE;
end
    default: state<=IDLE;
    endcase
end
end
endmodule*/