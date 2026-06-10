module baud_gen#(parameter DIV_WIDTH=16 )(
input clk,
input rstn,
input[DIV_WIDTH-1:0] div,
output reg baud_clk);

reg[DIV_WIDTH-1:0] cnt;

always@(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        cnt<=0;
        baud_clk<=0;
    end
    else
    begin
        if(div<=1)
        begin
            cnt<=0;
            baud_clk<=1;
        end
        else if (cnt==div-1)
        begin
            cnt<=0;
            baud_clk<=1;
        end
        else
        begin
            cnt<=cnt+1;
            baud_clk<=0;
        end
    end
    
end
endmodule