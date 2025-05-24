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
// Se implementan duplicadas, para el transmisor y el receptor

// Transmisor
reg [2:0]   estado_emisor = 0; 
reg [2:0]   proximo_estado_emisor;
reg [8:0]   conteo_bit_emisor, conteo_bit_emisor_siguiente;
reg         siguiente_TXD_out;
reg [9:0]   baud_counter, baud_counter_siguiente;

// Receptor
reg [1:0]   estado_receptor, proximo_estado_receptor;
reg [4:0]   conteo_bit_receptor, conteo_bit_receptor_siguiente;
reg [7:0]   RX_DATA_siguiente;

// reg         siguiente_TXD_out;
// reg [9:0]   baud_counter, baud_counter_siguiente;


//Codificacion de estados

localparam IDLE    = 3'b000;
localparam INICIO  = 3'b001;
localparam DATOS   = 3'b010;
localparam PARIDAD = 3'b011;
localparam PARADA  = 3'b100;
localparam RECEPCION  = 3'b101;

//Flip flops
always @(posedge clock) begin
    if (reset) begin

        // Transmisor
        estado_emisor <= proximo_estado_emisor;
        conteo_bit_emisor <= conteo_bit_emisor_siguiente; 
        TXD_out <= siguiente_TXD_out;
        baud_counter <= baud_counter_siguiente;

        // Receptor
        estado_receptor <= proximo_estado_receptor;
        conteo_bit_receptor <= conteo_bit_receptor_siguiente; 
        RX_DATA[conteo_bit_receptor] <= RX_DATA_siguiente[conteo_bit_receptor];



    end else begin
                // Transmisor
        estado_emisor <= 0;
        conteo_bit_emisor <= 0; 
        TXD_out <= 0;
        baud_counter <= 0;

        // Receptor
        estado_emisor <= 0;
        conteo_bit_receptor <= 0; 
        RX_DATA <= 0;

    end 
end


//Logica combinacional
always @(*) begin
    // Valores por defecto
    proximo_estado_emisor=  estado_emisor;
    conteo_bit_emisor_siguiente = conteo_bit_emisor;
    baud_counter_siguiente = baud_counter;
    siguiente_TXD_out = 1; 

// Logica transmisor 
    case (estado_emisor)
        // Empezamos
        IDLE: 
        begin
            if (START_STB == 1) begin           // Pasamos a inicio cuando se recibe el pulso start_stb
                baud_counter_siguiente = 0;     // Reinicia el contador de bit
                proximo_estado_emisor= INICIO;
                
            end
            
        end        


        INICIO:                    
        begin

            siguiente_TXD_out = 0;                                  // Pone la señal en bajo, marca el inicio
            if (baud_counter == CFG_BAUD_RATE - 1) begin           // Mantiene la señal de inicio en base al baud_rate        
                baud_counter_siguiente = 0; 
                proximo_estado_emisor= DATOS;                            // Pasa al estado_emisorde transmitir datos
                end else begin      
                baud_counter_siguiente = baud_counter_siguiente + 1;    
                 
            end
            
            
        end

        DATOS:
        begin
            if (conteo_bit_emisor_siguiente < 8) begin                   // Revisa que el contador del array no se pase
                siguiente_TXD_out = TX_DATA[0 + conteo_bit_emisor_siguiente];
                if (baud_counter == CFG_BAUD_RATE-1) begin
                    baud_counter_siguiente = 0;
                    conteo_bit_emisor_siguiente = conteo_bit_emisor_siguiente +1;
                    
                end else begin
                    
                    baud_counter_siguiente = baud_counter_siguiente +1;     // Aumenta el contador de birt cada ciclo de reloj
                end              
            end else begin               
                    baud_counter_siguiente = 0;
                    proximo_estado_emisor= PARIDAD; 
                    $display("Out Value= %b", TXD_out);

            end
        end    
        PARIDAD:
        begin
        // Se elige par o impar

        // Falta agregar logica para determinar el bit 
        if (CFG_PARITY ==0) begin               // Paridad par, los unos en el mensaje deben ser par
            //$display("Parity of TX_DATA = %b", ^TX_DATA);
            $display("Out Value= %b", TXD_out);

            if (^TX_DATA == 1) begin            // ^TX_DATA =1 si hay paridad impar
                siguiente_TXD_out = 1;
                if (baud_counter == CFG_BAUD_RATE-1) begin
                    proximo_estado_emisor= PARADA;
                    baud_counter_siguiente = 0;
                end else begin
                    baud_counter_siguiente = baud_counter_siguiente +1;
                end

            end else begin
                siguiente_TXD_out = 0;          // se ejecuta cuando ^TX_DATA = 0
                if (baud_counter == CFG_BAUD_RATE-1) begin
                    proximo_estado_emisor= PARADA;
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
                    proximo_estado_emisor= PARADA;
                    baud_counter_siguiente = 0;
                end else begin
                    baud_counter_siguiente = baud_counter_siguiente +1;
                end

            end else begin
                siguiente_TXD_out = 1;          // se ejecuta cuando ^TX_DATA = 1
                if (baud_counter == CFG_BAUD_RATE -1) begin
                    baud_counter_siguiente = 0;
                    proximo_estado_emisor = PARADA;
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
                    proximo_estado_emisor= IDLE;
                    
               end                
           end
            if (CFG_STOP_BITS == 1) begin
                if (baud_counter == 2*(CFG_BAUD_RATE -1)) begin
                    proximo_estado_emisor= IDLE;
                    
                end                
            end
            baud_counter_siguiente = baud_counter_siguiente +1;
        end
            
            
    endcase


// Logica Recepctor 
case (estado_receptor)
    IDLE:                                // Aqui solo se verifica que se inicie la transmison
    begin           
        if (RXD_in == 0) begin          // Si RXD se pone en cero, es porque se va iniciar la recepción de un mensaje
            proximo_estado_receptor = RECEPCION;
            
        end
    end
    RECEPCION:
    begin
        if (conteo_bit_receptor <8)                     // Para asegurarnos que el contador no pase de 8
          RX_DATA_siguiente[conteo_bit_receptor] = RXD_in;
        if (baud_counter == CFG_BAUD_RATE -1) begin
            conteo_bit_receptor_siguiente = conteo_bit_receptor_siguiente + 1;
            if (conteo_bit_receptor == 7) begin
                proximo_estado_receptor = PARIDAD;
    end
        end  else begin
            baud_counter_siguiente = baud_counter_siguiente + 1;
        end
            
        
        
        
    end
    
endcase
end
endmodule




