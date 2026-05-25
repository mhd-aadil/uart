/*module uart_tb;
reg clk;
reg rstn;
reg tx_start;
reg rx;
reg [7:0] tx_data;
wire  tx;
wire [7:0] rx_data;
wire  rx_valid;
wire  tx_busy;

uart_top uart_top_inst(
.clk(clk),
.rstn(rstn),
.tx_start(tx_start),
.rx(rx),
.tx_data(tx_data),
.tx(tx),
.rx_data(rx_data),
.rx_valid(rx_valid),
.tx_busy(tx_busy)
);

initial begin
    clk = 0;
    forever #10 clk = ~clk;// 50MHz clock
end
task initialize;
begin
rstn = 1;
tx_start = 0;
rx = 1;
tx_data = 8'b0;
end
endtask
task rst_dut;
begin
rstn = 0;
#20;
rstn = 1;
#20;
end
endtask
task send_data(input [7:0] data);
begin
tx_data = data;
tx_start = 1;
@(posedge clk);
tx_start = 0;
end
endtask
task receive_data;
begin
rx = 0; // Start bit
@(posedge clk);
rx = 1; // Data bits
@(posedge clk);
rx = 0;
@(posedge clk);
rx = 1;
@(posedge clk);
rx = 0;
@(posedge clk);
rx = 1;
@(posedge clk);
rx = 0;
@(posedge clk);
rx = 1;
@(posedge clk);
rx = 0;
@(posedge clk);
rx = 1; // Stop bit
@(posedge clk);
end
endtask
initial begin
initialize;
rst_dut;
//send_data(8'hA5);
//#50000; // Wait for transmission to complete
//receive_data;
//#50000; // Wait for reception to complete
//send_data(8'h3C);
//receive_data;
//#50000; // Wait for reception to complete

    $dumpfile("uart.vcd");
    $dumpvars(0, uart_tb);

$finish;
end
endmodule

`timescale 1ns/1ps

module uart_top_tb;

    //----------------------------------------
    // Clock and Reset
    //----------------------------------------
    reg clk;
    reg rst_n;

    //----------------------------------------
    // tx interface
    //----------------------------------------
    reg        tx_start;
    reg [7:0]  tx_data;
    wire       tx_busy;

    //----------------------------------------
    // rx interface
    //----------------------------------------
    wire [7:0] rx_data;
    wire       rx_valid;

    //----------------------------------------
    // UART serial line
    //----------------------------------------
    wire tx;

    // loopback connection
    wire rx;

    assign rx = tx;

    //----------------------------------------
    // DUT
    //----------------------------------------
    uart_top dut (
        .clk      (clk),
        .rst_n    (rst_n),

        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx_busy  (tx_busy),

        .rx       (rx),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),

        .tx       (tx)
    );

    //----------------------------------------
    // Clock generation
    //----------------------------------------
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz
    end

    //----------------------------------------
    // Stimulus
    //----------------------------------------
    initial begin

        //------------------------------------
        // Initialize
        //------------------------------------
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'h00;

        //------------------------------------
        // Reset
        //------------------------------------
        #100;
        rst_n = 1;

        //------------------------------------
        // Send first byte
        //------------------------------------
        @(posedge clk);

        tx_data  = 8'hA5;
        tx_start = 1'b1;

        @(posedge clk);
        tx_start = 1'b0;

        //------------------------------------
        // Wait for transmission complete
        //------------------------------------
        wait(tx_busy == 0);

        #50000;

        //------------------------------------
        // Send second byte
        //------------------------------------
        @(posedge clk);

        tx_data  = 8'h3C;
        tx_start = 1'b1;

        @(posedge clk);
        tx_start = 1'b0;

        wait(tx_busy == 0);

        #50000;

        //------------------------------------
        // Finish
        //------------------------------------
        $finish;

    end

    //----------------------------------------
    // Monitor
    //----------------------------------------
    initial begin
        $monitor(
            "TIME=%0t tx=%b TX_BUSY=%b RX_VALID=%b RX_DATA=%h",
            $time,
            tx,
            tx_busy,
            rx_valid,
            rx_data
        );
    end

    //----------------------------------------
    // Dump waves
    //----------------------------------------
    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_top_tb);
    end

endmodule

module tb;
reg  clk;
reg rstn;
reg tx_start;
reg rx;
reg [7:0] tx_data;
wire [7:0] rx_data;
wire  tx;
wire rx_valid;
wire tx_busy;
  
  uart_top DUT(clk,rstn,tx_start,rx,tx_data,tx,rx_data,rx_valid,tx_busy);
 
  always #10 clk=~clk;

task rx_task(input a);
begin
  @(posedge DUT.baud_gen_inst.baud_clk); 
  #1;
  rx = a;
end
endtask  
  initial
    begin
      $dumpfile("uart.vcd");
      $dumpvars(0, tb);
      
    end
  initial
    begin
      clk=0;
      rstn=1;
      tx_start=0;
      tx_data=0;
      @(posedge clk);
      rstn=0;
      @(posedge clk);
      rstn=1;
      rx_task(0); // Start bit
      rx_task(1); // Data bit 0
      rx_task(0); // Data bit 1
      rx_task(1); // Data bit 2
      rx_task(0); // Data bit 3
      rx_task(1); // Data bit 4
      rx_task(0); // Data bit 5
      rx_task(1); // Data bit 6
      rx_task(0); // Data bit 7
      rx_task(1); // Stop bit
      
      
      #100;
      $finish;
      

    end
endmodule
module tb_loopback;

reg        clk;
reg        rstn;
reg        tx_start;
reg [7:0]  tx_data;
wire       tx;
wire       tx_busy;
wire [7:0] rx_data;
wire       rx_valid;

// Loopback
wire rx;
assign rx = tx;

uart_top DUT(
    .clk      (clk),
    .rstn     (rstn),
    .tx_start (tx_start),
    .rx    (rx),
    .tx_data  (tx_data),
    .tx   (tx),
    .rx_data  (rx_data),
    .rx_valid (rx_valid),
    .tx_busy  (tx_busy)
);

initial clk = 0;
always #10 clk = ~clk;

initial begin
    $dumpfile("loopback.vcd");
    $dumpvars(0, tb_loopback);

    // Init
    rstn     = 0;
    tx_start = 0;
    tx_data  = 8'h00;
    repeat(4) @(posedge clk);

    // Reset
    rstn = 1;
    repeat(4) @(posedge clk);

    // Send 0xA5
    tx_data  = 8'hA5;
    tx_start = 1'b1;
    @(posedge DUT.baud_gen_inst.baud_clk); 
    #20;
    tx_start = 1'b0;

    // Wait TX done
    wait(tx_busy == 0);

    // Wait RX valid
    wait(rx_valid == 1);
    @(posedge DUT.baud_gen_inst.baud_clk); #20;

    // Check
    if(rx_data == 8'hA5)
        $display("PASS | sent=0xA5 | received=0x%h", rx_data);
    else
        $display("FAIL | sent=0xA5 | received=0x%h", rx_data);

    #500;
    $finish;
end

// Watchdog
initial begin
    #500;
    $display("TIMEOUT");
    $finish;
end

endmodule*/
module tb;
reg  clk;
reg rstn;
reg tx_start;
reg  rx;
reg [7:0] tx_data;
wire [7:0] rx_data;
wire  tx;
wire rx_valid;
wire tx_busy;

wire w1;
assign w1=tx; // Loopback connection  
  uart_top DUT(clk,rstn,tx_start,w1,tx_data,tx,rx_data,rx_valid,tx_busy);
 
  always #10 clk=~clk;

/*task rx_task(input a);
begin
  @(posedge DUT.baud_gen_inst.baud_clk); 
  #1;
  rx = a;
end
endtask  */
  initial
    begin
      $dumpfile("uart.vcd");
      $dumpvars(0, tb);
      
    end
  initial
    begin
      clk=0;
      rstn=1;
      tx_start=0;
      tx_data=0;
      @(posedge clk);
      rstn=0;
      @(posedge clk);
      rstn=1;
      @(posedge clk);
      tx_data=8'd146;
      @(posedge DUT.baud_gen_inst.baud_clk);
      //#5;
      tx_start=1;
      @(posedge DUT.baud_gen_inst.baud_clk);
      //#5;
      tx_start=0;
      wait(tx_busy==0);

     
      
      
      #100;
      $finish;
      

    end
endmodule