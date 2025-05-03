//`include "maquina_estados.v"
//`include "testbench.v"

module probador(


    output reg clock,
    output reg reset,
    output reg TARJETA_RECIBIDA,
    output reg DIGITO_STB,
    output reg [3:0]DIGITO,
    output reg  [15:0]PIN_CORRECTO,
    output reg [31:0] MONTO,
    output reg MONTO_STB,
    output reg [63:0]BALANCE_INICIAL, 
    output reg TIPO_TRANS,   
  
    input BALANCE_STB,     
    input [63:0] BALANCE_ACTUALIZADO,
    input ENTREGAR_DINERO,
    input PIN_INCORRECTO,
    input ADVERTENCIA,
    input BLOQUEO,
    input FONDOS_INSUFICIENTES

);


always begin

    #5 clock = ~clock;
end

initial begin
    clock = 0;
    MONTO_STB = 0;


    PIN_CORRECTO = 16'b1000_0011_0100_0100; // = 8 3 4 4
    TIPO_TRANS   = 1;
    TARJETA_RECIBIDA = 1;
    BALANCE_INICIAL  = 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0110_0100;
    


    DIGITO_STB = 0;
    #10;
    DIGITO = 4'b1000;
    DIGITO_STB = 1;
    #10;
    DIGITO_STB = 0;    
    #10
    DIGITO = 4'b0011;
    DIGITO_STB = 1;
    #10;
    DIGITO_STB = 0;
    #10
    DIGITO = 4'b0100;
    DIGITO_STB = 1;
    #10;
    DIGITO_STB = 0;
    #10
    DIGITO = 4'b0100;
    DIGITO_STB = 1;
    #10;
    DIGITO_STB = 0;   
    MONTO = 32'b0000_0000_0000_0000_0000_0000_0011_0010;
    MONTO_STB = 1;
    #10
    MONTO_STB = 0;

    #100


    $finish;
    
end

endmodule