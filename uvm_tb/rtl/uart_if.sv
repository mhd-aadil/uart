interface uart_if(
    input logic PCLK);
    // APB signals
    logic PSEL;
    logic PENABLE;
    logic PWRITE;
    logic [7:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic PREADY;
    logic PRESETn;
    logic tx; // UART TX line
    //logic rx; // UART RX line (not used in this testbench)
    time bit_time=440ns; // Time duration of one UART bit

endinterface