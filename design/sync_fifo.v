module sync_fifo #(parameter
        DEPTH=16,
        DATA_WIDTH=8) (
        input clk,
        input rstn,
        input clear,
        input wr_en,
        input rd_en,
        input [DATA_WIDTH-1:0] data_in,
        output reg [DATA_WIDTH-1:0]data_out,
        output full,
        output empty,
        output reg [ADDR_WIDTH:0]count
);
localparam ADDR_WIDTH=$clog2(DEPTH);

reg [DATA_WIDTH-1:0]mem[0:DEPTH-1];
reg [ADDR_WIDTH-1:0]wr_pntr;
reg [ADDR_WIDTH-1:0]rd_pntr;
integer i;
always@(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        data_out<={DATA_WIDTH{1'b0}};
        wr_pntr<={ADDR_WIDTH{1'b0}};
        rd_pntr<={ADDR_WIDTH{1'b0}};
        count<={(ADDR_WIDTH+1){1'b0}};
    end
     else if(clear)
    begin
        data_out<={DATA_WIDTH{1'b0}};
        wr_pntr<={ADDR_WIDTH{1'b0}};
        rd_pntr<={ADDR_WIDTH{1'b0}};
        count<={(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
        if(wr_en&&(!full))
        begin
            mem[wr_pntr]<=data_in;
            if(wr_pntr==(DEPTH-1))
                wr_pntr<={ADDR_WIDTH{1'b0}};
            else
                wr_pntr=wr_pntr+1'b1;
        end
        if(rd_en&&(!empty))
        begin
            data_out<=mem[rd_pntr];
            if(rd_pntr==(DEPTH-1))
                rd_pntr<={ADDR_WIDTH{1'b0}};
            else
                rd_pntr<=rd_pntr+1'b1;
        end


        case({wr_en&&(!full),rd_en&&(!empty)})
        2'b01:count<=count+1'b1;
        2'b10:count<=count-1'b1;
        default:count<=count;

        endcase

    end

end        

assign full=(count==DEPTH);
assign empty=(count==0); 
 
endmodule