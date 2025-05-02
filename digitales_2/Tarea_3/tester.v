//`include "maquina_estados.v"
//`include "testbench.v"

module probador(


    output reg clock,
    output reg reset,
    output reg TARJETA_RECIBIDA,
    output reg DIGITO_STB,
    output reg [3:0]DIGITO,
    output reg  [15:0]PIN_CORRECTO,
    output reg MONTO_STB,
    output reg BALANCE_INICIAL,    
  
    input BALANCE_STB,     
    input BALANCE_ACTUALIZADO,
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


    PIN_CORRECTO = 16'b0010_0000_1001_1000;
    TARJETA_RECIBIDA = 1;
    DIGITO_STB = 0;
    #10;
    DIGITO = 4'b0010;
    #10;
    DIGITO_STB = 1;
    #10;
    DIGITO_STB = 0;    
    #20
    $finish;
    
end

endmodule