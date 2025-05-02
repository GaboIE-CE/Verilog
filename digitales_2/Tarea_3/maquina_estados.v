//`include "testbench.v"
//`include "tester.v"

module cajero(

    input clock,
    input reset,
    input TARJETA_RECIBIDA,
    input DIGITO_STB,
    input [3:0]DIGITO,
    input  [15:0]PIN_CORRECTO ,
    input MONTO_STB,
    input BALANCE_INICIAL,    
  
    output reg BALANCE_STB,     
    output reg BALANCE_ACTUALIZADO,
    output reg ENTREGAR_DINERO,
    output reg PIN_INCORRECTO,
    output reg ADVERTENCIA,
    output reg BLOQUEO,
    output reg FONDOS_INSUFICIENTES

);

// Variables internas

reg [3:0]contador_DIGITO = 0; 
reg [3:0]contador_DIGITO_next = 0; // Con este contamos por cual parte del PIN vamos
reg [1:0] estado_actual, estado_siguiente;
// Estados
parameter IDLE = 2'b00;
parameter INICIO = 2'b01;

always @(posedge clock) begin
    estado_actual <= estado_siguiente;
    contador_DIGITO <= contador_DIGITO_next;
    
end

always @(*) begin
    if(TARJETA_RECIBIDA)begin
        estado_siguiente = INICIO;
    end

    if(estado_actual == INICIO) begin
        if(DIGITO_STB == 1)begin
            $display(PIN_CORRECTO[(contador_DIGITO*4) +:4]);
            $display(PIN_CORRECTO);
            if(DIGITO == PIN_CORRECTO[(contador_DIGITO*4) +:4])begin
                $display("El digito corresponde al pint");
                contador_DIGITO_next = contador_DIGITO + 1;
            end
        end
    end 
end

endmodule