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
reg [3:0] estado_actual = 0;
reg [3:0] estado_siguiente = 0 ;
reg DIGITO_STB_ANTERIOR = 0;
reg [63:0] BALANCE_ACTUALIZADO_siguiente = 0;
reg bandera_fondos_insuficientes = 0;
reg BALANCE_STB_siguiente=0;
reg ENTREGAR_DINERO_siguiente = 0;
reg bandera_pin_incorrecto = 0;
reg bandera_pin_incorrecto_siguiente = 0;
reg [3:0]intentos_fallidos = 0;
reg [3:0]intentos_fallidos_siguiente = 0;
reg BLOQUEO_siguiente = 0;
reg PIN_INCORRECTO_siguiente = 0;
reg ADVERTENCIA_siguiente = 0;

// Estados
parameter IDLE = 3'b000;
parameter INICIO = 3'b001;
parameter TRANSACCION = 3'b010;
parameter DINERO = 3'b11;
parameter RETIRO = 3'b100;
parameter estado_BLOQUEO = 3'b101;
parameter reset_apagado = 3'b110;

always @(posedge clock) begin

    if (reset) begin        // reset activo, la maquina de estados trabaja
    estado_actual <= estado_siguiente;
    contador_DIGITO <= contador_DIGITO_next;
    DIGITO_STB_ANTERIOR <= DIGITO_STB;
    BALANCE_ACTUALIZADO <= BALANCE_ACTUALIZADO_siguiente;
    FONDOS_INSUFICIENTES <= bandera_fondos_insuficientes;
    BALANCE_STB <= BALANCE_STB_siguiente;
    ENTREGAR_DINERO <= ENTREGAR_DINERO_siguiente;
    intentos_fallidos <= intentos_fallidos_siguiente;
    PIN_INCORRECTO <= PIN_INCORRECTO_siguiente;
    ADVERTENCIA <= ADVERTENCIA_siguiente;
    BLOQUEO <= BLOQUEO_siguiente;
    bandera_pin_incorrecto <= bandera_pin_incorrecto_siguiente;
    end else if(!reset) begin   // reset inactivo, la maquina no trabaja
    estado_actual <= reset_apagado;
    contador_DIGITO <= 0;
    DIGITO_STB_ANTERIOR <= 0;
    BALANCE_ACTUALIZADO <= 0;
    FONDOS_INSUFICIENTES <= 0;
    BALANCE_STB <= 0;
    ENTREGAR_DINERO <= 0;
    intentos_fallidos <= 0;
    PIN_INCORRECTO <= 0;
    ADVERTENCIA <= 0;
    BLOQUEO <= 0;
    bandera_pin_incorrecto <= 0;
        
    end

    
end

always @(*) begin
    // Valores por defecto
    estado_siguiente = estado_actual;
    contador_DIGITO_next = contador_DIGITO;
    BALANCE_STB_siguiente = 0; 
    bandera_fondos_insuficientes = 0;
    bandera_pin_incorrecto_siguiente = bandera_pin_incorrecto;



   if (estado_actual == IDLE) begin     // Estado inactivo, espera tarjeta
     if(TARJETA_RECIBIDA)begin          // Recibe tarjeta, procede al estado inicial (pedir el PIN)
        $display("Se ingresó una tarjeta valida");
         estado_siguiente = INICIO;
    end    
end 



// Se recibe el PIN
    if(estado_actual == INICIO) begin
        if(DIGITO_STB == 1 && DIGITO_STB_ANTERIOR == 0 && contador_DIGITO <4)begin
            if(DIGITO == PIN_CORRECTO[15 - contador_DIGITO*4 -: 4])begin        // El digito corresponde
                contador_DIGITO_next = contador_DIGITO + 1;                     // Aumenta el contador, llega hasta 4 (los bits del PIN)
            end 
            else if(DIGITO != PIN_CORRECTO[15 - contador_DIGITO*4 -: 4])begin   // El digito no corresponde 
                    contador_DIGITO_next = contador_DIGITO + 1;                 
                    bandera_pin_incorrecto_siguiente = 1;                       // Agregamos una bandera para decir que un digito no fue correcto
            end
        end else if(contador_DIGITO == 4) begin                                 // Ya se recibieron 4 bits, se determina si el PIN es correcto
                    if(!bandera_pin_incorrecto) begin                           // El PIN fue correcto, se procede con la transaccion
                        estado_siguiente = TRANSACCION;                     
                    end else if(bandera_pin_incorrecto) begin                   // El pin fue incorrecto, se vuelve al inicio y se solicita de nuevo
                                bandera_pin_incorrecto_siguiente = 0;           // La bandera se apaga en cada prueba del PIN
                                contador_DIGITO_next = 0;                       
                                intentos_fallidos_siguiente = intentos_fallidos +1; // Se lleva un registro del numero de intentos
                        if(intentos_fallidos_siguiente == 1) begin              // 1 intento fallido, se prode salida PIN_INCORRECTO
                            $display("1 itento fallido");
                            $display(intentos_fallidos);
                            PIN_INCORRECTO_siguiente = 1;                       // Advertencia 1

 
                        end else if( intentos_fallidos_siguiente ==2) begin     // 2 intentos fallidos, se produce salida ADVERTENCIA
                                    $display("2 intentos fallidos");
                                    $display(intentos_fallidos);
                                     ADVERTENCIA_siguiente =1;                 // Adveryencia 2

                        end else if(intentos_fallidos_siguiente ==3) begin     // 3 intentos fallidos, se produce salida BLOQUEO, se procede al estado de bloqueo   
                                    $display("3 intentos fallidos");
                                    $display("Sistema bloqueado");
                                    BLOQUEO_siguiente = 1;                     // Advertencia 3
                                    estado_siguiente = estado_BLOQUEO;         // Se entra en estado de BLOQEO    

                      end                                         
                   end                                  
                end
            end

 // Se recibió el PIN correcto, se procede con la transacción    
    if(estado_actual == TRANSACCION) begin
        if(TIPO_TRANS ==1 ) begin  // Transacción de retiro
        if(MONTO<BALANCE_INICIAL)begin
            BALANCE_ACTUALIZADO_siguiente = BALANCE_INICIAL - MONTO;
            BALANCE_STB_siguiente = 1;
            estado_siguiente = DINERO;
            $display("Balance actualizado");
            $display(BALANCE_ACTUALIZADO_siguiente);

        end else if(MONTO>BALANCE_INICIAL) begin
            $display("Fondos insuficientes");
            bandera_fondos_insuficientes = 1;
            estado_siguiente = IDLE;
        end
        end
        if(TIPO_TRANS == 0)begin   // Transaccion deposito
            BALANCE_ACTUALIZADO_siguiente = BALANCE_INICIAL + MONTO;
            $display("Balance actualizado");
            $display(BALANCE_ACTUALIZADO_siguiente);
            BALANCE_STB_siguiente = 1;
            estado_siguiente = IDLE;

        end

    end
    if(estado_actual == DINERO) begin
        ENTREGAR_DINERO_siguiente = 1;
        estado_siguiente = IDLE;
        
    end
end

endmodule