// Code your testbench here
// or browse Examples



module sync_fifo_tb;
        reg   clk;
        reg rstn;
        reg wr_en;
        reg rd_en;
  reg [7:0] data_in;
  wire [7:0]data_out;
        wire full;
        wire empty;
  wire [4:0]count;

sync_fifo #(
  .DEPTH(16),
  .DATA_WIDTH(8))
sync_fifo_inst(
        .clk(clk),
        .rstn(rstn),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .count(count)
        );
  task write_fifo(input [7:0]data);
    begin
      @(posedge clk);
      data_in=data;
      wr_en=1;
      @(posedge clk);
      wr_en=0;
    end
  endtask
  task read;
    begin
    @(posedge clk);
    rd_en=1;
    @(posedge clk);
    rd_en=0;
    end
  endtask

initial
begin
    clk=0;
    forever #5 clk=~clk;
end
initial
  begin
    $dumpfile("sync_fifo.vcd");
    $dumpvars(0,sync_fifo_tb);
  end
initial
begin
    rstn=0;
    wr_en=0;
    rd_en=0;
    data_in=8'h00;
    #20 rstn=1;
    write_fifo(8'd1);
  write_fifo(8'd2);
  write_fifo(8'd3);
  write_fifo(8'd4);
  write_fifo(8'd5);
  write_fifo(8'd6);
  write_fifo(8'd7);
  write_fifo(8'd8);
  write_fifo(8'd9);
  write_fifo(8'd10);
  write_fifo(8'd11);
  write_fifo(8'd12);
  write_fifo(8'd13);
  write_fifo(8'd14);
  write_fifo(8'd15);
  write_fifo(8'd16);
#20;
  read;
    read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;
  read;

  #50;


    #10 $finish;    

end
endmodule