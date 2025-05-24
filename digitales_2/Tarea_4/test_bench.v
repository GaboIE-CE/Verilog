`include "UART.v"
`include "probador.v"

module testbench;

// Entradas 
wire clock, reset, START_STB, CFG_PARITY, RXD_in;
wire [7:0] TX_DATA;
wire [1:0] CFG_STOP_BITS;
wire [3:0] CFG_BAUD_RATE;

// Salidas
wire RX_DATA_VALID, RX_PARITY_ERROR, TXD_out;
wire [7:0] RX_DATA;

initial begin
  $dumpfile("resultados.vcd");     // Nombre del archivo que se va a generar
  $dumpvars(0, testbench);         // Volcado de señales desde el módulo testbench
end



UART U0(
    //Entradas
    .clock(clock),
    .reset(reset),
    .START_STB(START_STB),
    .CFG_PARITY(RXD_in),
    .TX_DATA(TX_DATA),
    .CFG_STOP_BITS(CFG_STOP_BITS),
    .CFG_BAUD_RATE(CFG_BAUD_RATE),
    //Salidas
    .RX_DATA_VALID(RX_DATA_VALID),
    .RX_PARITY_ERROR(RX_PARITY_ERROR),
    .TXD_out(TXD_out),
    .RX_DATA(RX_DATA)

);

probador P0(
    //Entradas
    .clock(clock),
    .reset(reset),
    .START_STB(START_STB),
    .CFG_PARITY(RXD_in),
    .TX_DATA(TX_DATA),
    .CFG_STOP_BITS(CFG_STOP_BITS),
    .CFG_BAUD_RATE(CFG_BAUD_RATE),
    //Salidas
    .RX_DATA_VALID(RX_DATA_VALID),
    .RX_PARITY_ERROR(RX_PARITY_ERROR),
    .TXD_out(TXD_out),
    .RX_DATA(RX_DATA)

);


endmodule