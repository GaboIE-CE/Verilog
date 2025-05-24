module UART(
// Outputs
TXD_out, RX_DATA_VALID, RX_DATA, RX_PARITY_ERROR, 


//Inputs
clock, reset, START_STB, TX_DATA, CFG_PARITY, CFG_STOP_BITS, CFG_BAUD_RATE, RXD_in


);
// Entradas
input clock, reset, START_STB, CFG_PARITY, RXD_in;
input [7:0] TX_DATA;
input [1:0] CFG_STOP_BITS;
input [3:0] CFG_BAUD_RATE;
// Salidas
output reg RX_DATA_VALID, RX_PARITY_ERROR, TXD_out;
output reg [7:0] RX_DATA;

//Variables intermedias
reg [1:0] estado, proximo_estado;
reg [4:0]    conteo_bit, conteo_bit_siguiente;
reg siguiente_TXD_out;
reg [9:0]   baud_counter, baud_counter_siguiente;

//Codificacion de estados

localparam IDLE    = 3'b000;
localparam INICIO  = 3'b001;
localparam DATOS   = 3'b010;
localparam PARIDAD = 3'b011;
localparam PARADA  = 3'b100;

//Flip flops
always @(posedge clock) begin
    if (reset) begin
        estado  <= proximo_estado;
        conteo_bit <= conteo_bit_siguiente; 
        TXD_out <= siguiente_TXD_out;
        baud_counter <= baud_counter_siguiente;

    end else begin

    end 
end


//Logica combinacional
always @(*) begin
    // Valores por defecto
    proximo_estado =  estado;
    conteo_bit_siguiente = conteo_bit;
    baud_counter_siguiente = baud_counter;
    siguiente_TXD_out = 1; 


    case (estado)
        // Empezamos
        IDLE: 
        begin
            if (START_STB == 1) begin           // Pasamos a inicio cuando se recibe el pulso start_stb
                baud_counter_siguiente = 0;     // Reinicia el contador de bit
                proximo_estado = INICIO;
                
            end
            
        end        

// Logica transmisor 
        INICIO:                    
        begin
            siguiente_TXD_out = 0;              // Pone la señal en bajo, marca el inicio
            if (baud_counter == CFG_BAUD_RATE - 1) begin           // Mantiene la señal de inicio en base al baud_rate        
                baud_counter_siguiente = 0; 
                proximo_estado = DATOS;                            // Pasa al estado de transmitir datos
                end else begin      
                conteo_bit_siguiente = conteo_bit_siguiente +1;    // Aumenta el contador de birt cada ciclo de reloj             
            end
            
            
        end

        DATOS:
        begin
            if (conteo_bit_siguiente < 8) begin                   // Revisa que el contador del array no se pase
                siguiente_TXD_out = TX_DATA[0 + conteo_bit_siguiente];
                if (baud_counter == CFG_BAUD_RATE -1) begin
                    conteo_bit_siguiente = conteo_bit_siguiente +1;
                    baud_counter_siguiente = 0;
                end else begin
                    
                    baud_counter_siguiente = baud_counter_siguiente +1;
                end              
            end else begin               
                    baud_counter_siguiente = 0;
                    proximo_estado = PARIDAD; 

            end
        end    
        PARIDAD:
        begin
        // Se elige par o impar

        // Falta agregar logica para determinar el bit 
        if (CFG_PARITY ==0) begin               // Paridad par, los unos en el mensaje deben ser par
            if (^TX_DATA == 1) begin            // ^TX_DATA =1 si hay paridad impar
                siguiente_TXD_out = 1;
                if (baud_counter == CFG_BAUD_RATE -1) begin
                    baud_counter_siguiente = 0;
                    proximo_estado = PARADA;
                    baud_counter_siguiente = 0;
                end else begin
                    baud_counter_siguiente = baud_counter_siguiente +1;
                end

            end else begin
                siguiente_TXD_out = 0;          // se ejecuta cuando ^TX_DATA = 0
                if (baud_counter == CFG_BAUD_RATE -1) begin
                    baud_counter_siguiente = 0;
                    proximo_estado = PARADA;
                    baud_counter_siguiente = 0;
                end else begin
                    baud_counter_siguiente = baud_counter_siguiente +1;
                end
            end

                     
        end
        // Falta agregar logica para determinar el bit 
        if (CFG_PARITY ==1) begin              // Paridad impar, los unos en el mensaje deben ser impar
            if (^TX_DATA == 1) begin            // ^TX_DATA =0 si hay paridad impar
                siguiente_TXD_out = 0;
                if (baud_counter == CFG_BAUD_RATE -1) begin
                    baud_counter_siguiente = 0;
                    proximo_estado = PARADA;
                    baud_counter_siguiente = 0;
                end else begin
                    baud_counter_siguiente = baud_counter_siguiente +1;
                end

            end else begin
                siguiente_TXD_out = 1;          // se ejecuta cuando ^TX_DATA = 1
                if (baud_counter == CFG_BAUD_RATE -1) begin
                    baud_counter_siguiente = 0;
                    proximo_estado = PARADA;
                    baud_counter_siguiente = 0;
                end else begin
                    baud_counter_siguiente = baud_counter_siguiente +1;
                end
            end
        end
          
        end    

        PARADA:
        begin
            siguiente_TXD_out = 1;
            if (CFG_STOP_BITS == 0) begin
                if (baud_counter == CFG_BAUD_RATE -1) begin
                    proximo_estado = IDLE;
                    
               end                
           end
            if (CFG_STOP_BITS == 1) begin
                if (baud_counter == 2*(CFG_BAUD_RATE -1)) begin
                    proximo_estado = IDLE;
                    
                end                
            end
            baud_counter_siguiente = baud_counter_siguiente +1;
        end
            
            
    endcase
end 

// Logica Recepctor 



endmodule




