module probador (
    // Entradas
output reg clock, reset, START_STB, CFG_PARITY, RXD_in,
output reg [7:0] TX_DATA,
output reg [1:0] CFG_STOP_BITS,
output reg [3:0] CFG_BAUD_RATE,

// Salidas
input RX_DATA_VALID, RX_PARITY_ERROR, TXD_out,
input [7:0] RX_DATA

);
    always begin
        #5 clock = ~clock;  // Periodo de 10 unidades
    end

    initial begin
        CFG_STOP_BITS = 0;
        clock = 0;
        reset = 0;
        CFG_BAUD_RATE = 4'b0100;
        START_STB = 0;
        CFG_PARITY  = 0;
        
        #10;
        reset = 1;
        TX_DATA = 8'b01111111;
        #10
        START_STB = 1;
        
        
        


        #10
        START_STB = 0;
        #500;



        $finish;
    end
endmodule