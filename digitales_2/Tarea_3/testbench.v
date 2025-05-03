//`include "tester.v"
//`include "maquina_estados.v"

module tarea_3_tb;


// Entradas
    wire clock;
    wire reset;
    wire TARJETA_RECIBIDA;
    wire DIGITO_STB;
    wire [3:0]DIGITO;
    wire  [15:0]PIN_CORRECTO ;
    wire [31:0]MONTO;
    wire MONTO_STB;
    wire [63:0]BALANCE_INICIAL;  

// Salidas 

    wire BALANCE_STB;     
    wire [63:0]BALANCE_ACTUALIZADO;
    wire ENTREGAR_DINERO;
    wire PIN_INCORRECTO;
    wire ADVERTENCIA;
    wire BLOQUEO;
    wire FONDOS_INSUFICIENTES;

initial begin
  $dumpfile("resultados.vcd");     // Nombre del archivo que se va a generar
  $dumpvars(0, tarea_3_tb);        // Volcado de señales desde el módulo testbench
end

cajero UO(
    .clock(clock),
    .reset(reset),
    .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
    .DIGITO_STB(DIGITO_STB),
    .DIGITO(DIGITO),
    .PIN_CORRECTO(PIN_CORRECTO),
    .MONTO(MONTO),
    .MONTO_STB(MONTO_STB),
    .BALANCE_INICIAL(BALANCE_INICIAL),
    .BALANCE_STB(BALANCE_STB),
    .BALANCE_ACTUALIZADO(BALANCE_ACTUALIZADO),
    .ENTREGAR_DINERO(ENTREGAR_DINERO),
    .PIN_INCORRECTO(PIN_INCORRECTO),
    .ADVERTENCIA(ADVERTENCIA),
    .BLOQUEO(BLOQUEO),
    .FONDOS_INSUFICIENTES(FONDOS_INSUFICIENTES),
    .TIPO_TRANS(TIPO_TRANS)

);

probador PO(
    .clock(clock),
    .reset(reset),
    .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
    .DIGITO_STB(DIGITO_STB),
    .DIGITO(DIGITO),
    .PIN_CORRECTO(PIN_CORRECTO),
    .MONTO(MONTO),
    .MONTO_STB(MONTO_STB),
    .BALANCE_INICIAL(BALANCE_INICIAL),
    .BALANCE_STB(BALANCE_STB),
    .BALANCE_ACTUALIZADO(BALANCE_ACTUALIZADO),
    .ENTREGAR_DINERO(ENTREGAR_DINERO),
    .PIN_INCORRECTO(PIN_INCORRECTO),
    .ADVERTENCIA(ADVERTENCIA),
    .BLOQUEO(BLOQUEO),
    .FONDOS_INSUFICIENTES(FONDOS_INSUFICIENTES),
    .TIPO_TRANS(TIPO_TRANS)

);

endmodule