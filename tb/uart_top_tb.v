`timescale 1ns/1ps

module uart_top_tb;

    reg         clk;
    reg         rstn;
    reg         tx_start;
    reg         rx_read;
    reg         rx;
    reg  [7:0]  tx_data;

    wire        tx;
    wire [7:0]  rx_data;
    wire        rx_valid;
    wire        tx_busy;
    wire w1;
    // loopback: TX -> RX
    assign w1 = tx;

    // DUT
    uart_top dut (
        .clk      (clk),
        .rstn     (rstn),
        .tx_start (tx_start),
        .rx       (w1),
        .rx_read  (rx_read),
        .tx_data  (tx_data),
        .tx       (tx),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .tx_busy  (tx_busy)
    );

    // 50 MHz clock
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    task send_byte(input [7:0] data);
    begin
        @(posedge clk);
        tx_data  <= data;
        tx_start <= 1'b1;
        @(posedge clk);
        wait (tx_busy == 1'b1); // wait until transmission starts
        tx_start <= 1'b0;
    end
    endtask

    task read_byte(output [7:0] data_out);
    begin
        // wait until RX FIFO has data
        wait (rx_valid == 1'b1);

        // pop one byte
        @(posedge clk);
        rx_read <= 1'b1;
        @(posedge clk);
        rx_read <= 1'b0;

        // give FIFO one cycle to update dout
        @(posedge clk);
        data_out = rx_data;
    end
    endtask

    reg [7:0] received;

    initial begin
        $dumpfile("uart_top_tb.vcd");
        $dumpvars(0, uart_top_tb);

        // init
        rstn     = 1'b0;
        tx_start = 1'b0;
        rx_read  = 1'b0;
        tx_data  = 8'h00;

        // reset
        repeat (5) @(posedge clk);
        rstn = 1'b1;

        // send bytes
        send_byte(8'hA5);
        
        wait(tx_busy == 1'b0); // wait until transmission is done
        #300;
        rx_read <= 1'b1;
        #20;
        rx_read <= 1'b0;
        #100;

        $finish;
    end

endmodule