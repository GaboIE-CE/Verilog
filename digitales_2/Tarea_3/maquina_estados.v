//`include "testbench.v"
//`include "tester.v"

module cajero(

    input clock,
    input reset,
    input TARJETA_RECIBIDA,
    input DIGITO_STB,
    input [3:0]DIGITO,
    input  [15:0]PIN_CORRECTO ,
    input [31:0]MONTO,
    input MONTO_STB,
    input [63:0]BALANCE_INICIAL,
    input TIPO_TRANS,    
  
    output reg BALANCE_STB,     
    output reg [63:0] BALANCE_ACTUALIZADO,
    output reg ENTREGAR_DINERO,
    output reg PIN_INCORRECTO,
    output reg ADVERTENCIA,
    output reg BLOQUEO,
    output reg FONDOS_INSUFICIENTES

);

// Variables internas

reg [3:0]contador_DIGITO = 0; 
reg [3:0]contador_DIGITO_next = 0; // Con este contamos por cual parte del PIN vamos
reg [9:0]contador_balance_stb_siguiente = 0;
reg [9:0]contador_balance_stb = 0;
reg [1:0] estado_actual = 0;
reg [1:0]estado_siguiente = 0 ;
reg DIGITO_STB_ANTERIOR = 0;
reg [63:0] BALANCE_ACTUALIZADO_siguiente = 0;
reg bandera_fondos_insuficientes = 0;
reg BALANCE_STB_siguiente=0;
reg ENTREGAR_DINERO_siguiente = 0;

// Estados
parameter IDLE = 2'b00;
parameter INICIO = 2'b01;
parameter TRANSACCION = 2'b10;
parameter DINERO = 2'b11;

always @(posedge clock) begin
    estado_actual <= estado_siguiente;
    contador_DIGITO <= contador_DIGITO_next;
    DIGITO_STB_ANTERIOR <= DIGITO_STB;
    BALANCE_ACTUALIZADO <= BALANCE_ACTUALIZADO_siguiente;
    FONDOS_INSUFICIENTES <= bandera_fondos_insuficientes;
    BALANCE_STB <= BALANCE_STB_siguiente;
    ENTREGAR_DINERO <= ENTREGAR_DINERO_siguiente
    
end

always @(*) begin
    estado_siguiente = estado_actual;
    contador_DIGITO_next = contador_DIGITO;
    BALANCE_STB_siguiente = 0; // por defecto



   if (estado_actual == IDLE) begin
     if(TARJETA_RECIBIDA && contador_DIGITO_next == 0)begin
         estado_siguiente = INICIO;
    end    
   end 


    if(estado_actual == INICIO) begin
        if(DIGITO_STB == 1 && contador_DIGITO <4 && DIGITO_STB_ANTERIOR == 0)begin
            //$display("PIN[%0d] = %d", contador_DIGITO, PIN_CORRECTO[15 - contador_DIGITO*4 -: 4]); // Toma 4 bits empezando en el bit más significativo (bit 15), y avanza hacia abajo en grupos de 4 bits
            //$display(DIGITO);
            if(DIGITO == PIN_CORRECTO[15 - contador_DIGITO*4 -: 4])begin
                //$display("El digito corresponde al pint");
                contador_DIGITO_next = contador_DIGITO + 1;
            end //else if(DIGITO != PIN_CORRECTO[15 - contador_DIGITO*4 -: 4])
        end else if(contador_DIGITO == 4) begin       
                    $display("Pin correcto ingresado");
                    estado_siguiente = TRANSACCION;
                    $display(estado_siguiente);

        end
    end 
    if(estado_actual == TRANSACCION) begin
        if(MONTO<BALANCE_INICIAL)begin
            BALANCE_ACTUALIZADO_siguiente = BALANCE_INICIAL - MONTO;
            BALANCE_STB_siguiente = 1;
            estado_siguiente = DINERO;
            $display("Balance actualizado");
            $display(BALANCE_ACTUALIZADO_siguiente);

        end else begin
            $display("Fondos insuficientes");
            bandera_fondos_insuficientes = 1;
        end

    end
    if(estado_actual == DINERO) begin
        ENTREGAR_DINERO_siguiente = 1;
        
    end
end

endmodule