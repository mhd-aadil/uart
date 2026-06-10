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

endinterface