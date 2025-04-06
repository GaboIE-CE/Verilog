module maquina_cafe(
    input clock,
    input reset,
    input PAGO_RECIBIDO,
    input [1:0] tipo_cafe,
    input [1:0] entrada_tamano,
    input [3:0] azucar,

    output reg [3:0] nivel_azucar,
    output reg  concentracion, // Solo puede ser regular o fuerte
    output reg  leche,         // Si o No
    output reg  espuma,         // Si o Nos
    output reg [3:0] salida_azucar,
    output reg [15:0] precio_real


);

reg [1:0] estado_actual, next_state;
reg [6:0] count;                
reg reset_interno;
reg [15:0] precio;
reg [2:0] cafe;
reg [1:0] tamano;
reg [1:0] exit_counter; // suficiente para contar hasta 3
reg [1:0] ciclos_preparacion;

// tipos de cafe
// parameter NEGRO = 2'b00;
// parameter CON_LECHE = 2'b01;
// parameter ESPRESSO = 2'b10;
// parameter CAPPUCCINO = 2'b11;
parameter INICIO = 2'b00;
parameter PRECIO = 2'b01;
parameter PREPARACION_CAFE = 2'b10;

// La logica combinacional calcula el próximo estado, la logica secuencial lo actualiza los registros 
// Logica secuencial
always @(posedge clock) begin       // Correr siempre que haya un flanco positivo de reloj
      
      if (reset || reset_interno) begin              // Cuando se active el reset  
        next_state <= INICIO;
        precio_real   <= 0;          // Vuelve al estado inicial
        count         <= 0;
        exit_counter <=  0;
        reset_interno <= 0;

        end else begin

            estado_actual <= next_state; // Se pasa al estado sigueinte   

            if(estado_actual == PRECIO) begin           
                precio_real <= precio;      // Despliega el precio del café
                count <= count + 1;  
            end else if(estado_actual == PREPARACION_CAFE) begin
                exit_counter <=  exit_counter +1;
            end
    end
end

// Logica combinacional
// Se ejecuata cada vez que alguna de estas señales cambia
always @(*) begin
if(estado_actual == INICIO) begin
    $display(">>> Estamos en INICIO @ t=%0t", $time);

case (tipo_cafe)
    2'b00: cafe = 2'b00:;
    2'b01: cafe = 2'b01;
    2'b10: cafe = 2'b10;
    2'b11: cafe = 2'b11;
endcase

case (entrada_tamano)
    2'b00: tamano = 2'b00;
    2'b01: tamano = 2'b01;
    2'b10: tamano = 2'b10;
    2'b11: tamano = 2'b11;
endcase

case (azucar)
    3'b000: nivel_azucar = 3'b000;
    3'b001: nivel_azucar = 3'b001;
    3'b010: nivel_azucar = 3'b010;
    3'b011: nivel_azucar = 3'b011;
    3'b100: nivel_azucar = 3'b100;
    3'b101: nivel_azucar = 3'b101;
    default: nivel_azucar = 4'b0000; // Opcional para seguridad
endcase

    case({cafe, tamano}) // Suma las dos entrdas

        // El cafe es negro
        4'b0000: begin                 // El cafe es negro y pequeno
        precio = 16'b0000000111110100;  // Tiene un precio 500 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        4'b0001: begin                   // El cafe es negro y mediano
        precio = 16'b0000011111010000;   // Tiene un precio 1000 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        4'b0010: begin                   // El cafe es negro y grande
        precio = 16'b0000010111011100;   // Tiene un precio 1500 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        // El cafe es con leche
        4'b0100: begin                   // El cafe es con leche y pequeno
        precio = 16'b0000001011101110;   // Tiene un precio 750 colones
        next_state = PRECIO;
        $display("Precio = %d", precio);  // En decimal

        end

        4'b0101: begin                   // El cafe es con leche y mediano
        precio = 16'b0000010011100010;   // Tiene un precio 1250 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        4'b0110: begin                   // El cafe es con leche y grande
        precio = 16'b0000011011010110;   // Tiene un precio 1750 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        // El cafe es espresso
        4'b1000: begin                 // El cafe es con espresoo y pequeno
        precio = 16'b0000001011101110;  // Tiene un precio 1000 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        4'b1001: begin                 // El cafe es con espresso y mediano
        precio = 16'b0000010111011100;  // Tiene un precio 1500 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        4'b1010: begin                 // El cafe es con espresso y grande
        precio = 16'b0000011111010000;  // Tiene un precio 2000 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end
        // El cafe es capuccino
        4'b1100: begin                 // El cafe es con capuccino y pequeno
        precio = 16'b0000010011100010;  // Tiene un precio 1250 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        4'b1101: begin                 // El cafe es con capuccino y mediano
        precio = 16'b0000011011010110;  // Tiene un precio 1750 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end

        4'b1110: begin                 // El cafe es con capuccino y grande
        precio = 16'b0000100111000100;  // Tiene un precio 2500 colones
        next_state = PRECIO;
        $display("Precio = %d", precio); // En decimal

        end    

        default: reset_interno = 1;     // Se trata como un binario
    endcase
end

    else if(estado_actual == PRECIO) begin // AQui esperamos el pago
        if(count == 44) begin
            reset_interno =1;           
        end else if(PAGO_RECIBIDO) begin
            next_state = PREPARACION_CAFE;
        end
    end

    if(estado_actual == PREPARACION_CAFE) begin // AQui vamos a producir la salida binaria de aucar, leche etc
        case(tipo_cafe)          // con el tipo se pueden determinar las otras variables
        2'b00:begin              // Negro
            leche = 1'b0;
            concentracion = 1'b0;
            espuma = 1'b0;
            salida_azucar = nivel_azucar;
            reset_interno = 1; 
        end

        2'b01:begin             // con leche
            leche = 1'b1;
            concentracion = 1'b0;
            espuma = 1'b0; 
            salida_azucar = nivel_azucar;
            reset_interno = 1;  
        end        

        2'b10:begin
            leche = 1'b0;
            concentracion = 1'b1;
            espuma = 1'b0;
            salida_azucar = nivel_azucar; 
            reset_interno = 1;  
        end

        2'b11:begin
            leche = 1'b1;
            concentracion = 1'b1;
            espuma = 1'b1; 
            salida_azucar = nivel_azucar; 
            reset_interno = 1; 
        end
    endcase
        if ((tamano == 2'b00 && ciclos_preparacion == 1) ||  // Pequeño
            (tamano == 2'b01 && ciclos_preparacion == 2) ||  // Mediano
            (tamano == 2'b10 && ciclos_preparacion == 3)) begin
                next_state <= INICIO;
                 
        end 

    end

    
     
    end
endmodule