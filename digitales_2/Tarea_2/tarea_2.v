module maquina_cafe(
    //Entradas
    input clock,
    input reset,
    input PAGO_RECIBIDO,
    input [2:0] entrada_cafe,
    input [2:0] entrada_tamano,
    input [3:0] entrada_azucar,

    //Salidas
    output reg  salida_concentracion, // Solo puede ser regular o fuerte
    output reg  salida_leche,         // Si o No
    output reg  salida_espuma,        // Si o Nos
    output reg [3:0] salida_azucar,
    output reg [15:0] salida_precio


);

reg [1:0] estado_actual, next_state;      
reg seleccion_hecha;
reg reset_interno;
reg [3:0] variable_azucar;
reg [2:0]  variable_cafe;
reg [2:0]  variable_tamano;
reg [6:0] count; 
reg [1:0]  exit_counter; // suficiente para contar hasta 3
reg [2:0]  ciclos_preparacion;

// Estados
parameter INICIO = 2'b00;
parameter PRECIO = 2'b01;
parameter PREPARACION_CAFE = 2'b10;
parameter IDLE = 2'b11;

// La logica combinacional calcula el próximo estado, la logica secuencial lo actualiza los registros 
// Logica secuencial
always @(posedge clock) begin
    

    if (reset) begin        // if reset o no está en ningun estado de los correctos
        next_state <= INICIO;
        estado_actual <= INICIO;
        variable_azucar   <= 0;
        variable_cafe     <= 0;
        variable_tamano   <= 0;
        count             <= 0;
        exit_counter      <= 0;
        ciclos_preparacion<= 0;
        reset_interno     <= 0; 
        salida_leche      <= 0;
        salida_concentracion <= 0;
        salida_espuma     <= 0;
        salida_azucar     <= 0;
        salida_precio     <= 0;
    end else if  ( reset_interno) begin // Es necesario oprimir reset para que la maquina vuelva al estado inical
        next_state    <= IDLE;
        estado_actual <= IDLE;
        salida_leche      <= 0;
        salida_concentracion <= 0;
        salida_espuma     <= 0;
        salida_azucar     <= 0;
        salida_precio     <= 0;

    end else begin
        estado_actual <= next_state;

        if (estado_actual == PRECIO) begin      // Contador espera de pago
            count <= count + 1;
        end else if (estado_actual == PREPARACION_CAFE) begin // Contador de pantalla final
            exit_counter <= exit_counter + 1;
        end
    end
end

// Se ejecuata cada vez que alguna de estas señales cambia
// Logica combinacional
always @(*) begin   
    next_state = estado_actual;
    reset_interno = 0; 

    salida_leche = 0;
    salida_concentracion = 0;
    salida_espuma = 0;
    salida_azucar = 0;
    salida_precio = 0;
    /////////
    variable_azucar = entrada_azucar;
    variable_cafe   = entrada_cafe;
    variable_tamano = entrada_tamano;    
if(estado_actual == INICIO) begin


case (entrada_cafe)
    3'b001: variable_cafe = 3'b001;
    3'b010: variable_cafe = 3'b010;
    3'b011: variable_cafe = 3'b011;
    3'b100: variable_cafe = 3'b100;
    default: variable_cafe = 3'b000;
endcase

case (entrada_tamano)
    3'b001: variable_tamano = 3'b001;    //pequeno
    3'b010: variable_tamano = 3'b010;    //mediano
    3'b011: variable_tamano = 3'b011;    //grande
    default: variable_tamano = 3'b000;
    
endcase

case (entrada_azucar)
    3'b000: variable_azucar = 3'b000;
    3'b001: variable_azucar = 3'b001;
    3'b010: variable_azucar = 3'b010;
    3'b011: variable_azucar = 3'b011;
    3'b100: variable_azucar = 3'b100;
    3'b101: variable_azucar = 3'b101;
    default: variable_azucar = 4'b0000; // Opcional para seguridad
endcase

    case({variable_cafe, variable_tamano}) // Suma las dos entrdas

        // El cafe es negro
        6'b001_001: begin                 // El cafe es negro y pequeno
        salida_precio = 16'b0000000111110100;  // Tiene un precio 500 colones
        next_state = PRECIO;      

        end

        6'b001_010: begin                   // El cafe es negro y mediano
        salida_precio = 16'b0000_0011_1110_1000;   // Tiene un precio 1000 colones
        next_state = PRECIO;
       // $display("Precio = %d", salida_precio);  En decimal
        
        end

        6'b001_011: begin                   // El cafe es negro y grande
        salida_precio = 16'b0000010111011100;   // Tiene un precio 1500 colones
        next_state = PRECIO;
       // $display("Precio = %d", salida_precio);  En decimal

        end

        // El cafe es con leche
        6'b010_001: begin                   // El cafe es con leche y pequeno
        salida_precio = 16'b0000001011101110;   // Tiene un precio 750 colones
        next_state = PRECIO;
       // $display("Precio = %d", salida_precio);   En decimal

        end

        6'b010_010: begin                   // El cafe es con leche y mediano
        salida_precio = 16'b0000010011100010;   // Tiene un precio 1250 colones
        next_state = PRECIO;
      //  $display("Precio = %d", salida_precio);  En decimal

        end

        6'b010_011: begin                   // El cafe es con leche y grande
        salida_precio = 16'b0000011011010110;   // Tiene un precio 1750 colones
        next_state = PRECIO;
       // $display("Precio = %d", salida_precio);  En decimal

        end

        // El cafe es espresso
        6'b011_001: begin                 // El cafe es con espresoo y pequeno
        salida_precio = 16'b0000_0011_1110_1000;  // Tiene un precio 1000 colones
        next_state = PRECIO;
     //   $display("Precio = %d", salida_precio);  En decimal

        end

        6'b011_010: begin                 // El cafe es con espresso y mediano
        salida_precio = 16'b0000010111011100;  // Tiene un precio 1500 colones
        next_state = PRECIO;
       // $display("Precio = %d", salida_precio);  En decimal

        end

        6'b011_011: begin                 // El cafe es con espresso y grande
        salida_precio = 16'b0000011111010000;  // Tiene un precio 2000 colones
        next_state = PRECIO;
      //  $display("Precio = %d", salida_precio);  En decimal

        end
        // El cafe es capuccino
        6'b100_001: begin                 // El cafe es con capuccino y pequeno
        salida_precio = 16'b0000010011100010;  // Tiene un precio 1250 colones
        next_state = PRECIO;
       // $display("Precio = %d", salida_precio); // En decimal

        end

        6'b100_010: begin                 // El cafe es con capuccino y mediano
        salida_precio = 16'b0000011011010110;  // Tiene un precio 1750 colones
        next_state = PRECIO;
      //  $display("Precio = %d", salida_precio); // En decimal

        end

        6'b100_011: begin                 // El cafe es con capuccino y grande
        salida_precio = 16'b0000_1000_1100_1010;  // Tiene un precio 2250 colones
        next_state = PRECIO;
       // $display("Precio = %d", salida_precio); // En decimal

        end    

        default: reset_interno = 1;     // Se trata como un binario
    endcase
end

    else if(estado_actual == PRECIO) begin // AQui esperamos el pago

        if(count > 10 ) begin
            reset_interno =1; 
                      
        end else if(PAGO_RECIBIDO) begin
            next_state = PREPARACION_CAFE;
        end
    end

    if(estado_actual == PREPARACION_CAFE) begin // AQui vamos a producir la salida binaria de aucar, leche etc
        case(entrada_cafe)          // con el tipo se pueden determinar las otras variables
        3'b001:begin                // Negro
            salida_leche = 1'b0;
            salida_concentracion = 1'b0;
            salida_espuma = 1'b0;
            salida_azucar = variable_azucar;
            //reset_interno = 1; 
        end

        3'b010:begin             // con leche
            salida_leche = 1'b1;
            salida_concentracion = 1'b0;
            salida_espuma = 1'b0; 
            salida_azucar = variable_azucar;
           // reset_interno = 1;  
        end        

        3'b011:begin
            salida_leche = 1'b0;
            salida_concentracion = 1'b1;
            salida_espuma = 1'b0;
            salida_azucar = variable_azucar; 
            //reset_interno = 1;  
        end

        3'b100:begin
            salida_leche = 1'b1;
            salida_concentracion = 1'b1;
            salida_espuma = 1'b1; 
            salida_azucar = variable_azucar; 
            //reset_interno = 1; 
        end
    endcase
        if (variable_tamano == exit_counter) begin
            salida_leche = 1'b0;
            salida_concentracion = 1'b0;
            salida_espuma = 1'b0; 
            salida_azucar = 1'b0; 
            reset_interno = 1;
            //next_state <= INICIO;                
            end 
        end       
    end
endmodule