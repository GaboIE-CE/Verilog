module probador (
    input [15:0] salida_precio,
    input [3:0] salida_azucar,
    input  salida_concentracion,
    input salida_leche,
    input salida_espuma,

    output reg clock,
    output reg reset,
    output reg PAGO_RECIBIDO,
    output reg [2:0] entrada_cafe,
    output reg [2:0] entrada_tamano,
    output reg [3:0] entrada_azucar
   // output reg ENTER

    

);

    // Reloj
    always begin
        #5 clock = ~clock;  // Periodo de 10 unidades
    end

    initial begin
        // Inicializar todo
        clock = 0;
        
        entrada_cafe = 0;
        entrada_tamano = 0;
        entrada_azucar = 0;
        PAGO_RECIBIDO = 0;
        reset = 1;
        #10 
        reset = 0;
        // Salir de reset
        

        entrada_cafe = 3'b100;
        entrada_tamano = 3'b011;
        entrada_azucar = 4'b0011;

        #10;
        PAGO_RECIBIDO = 1;      
        #10;
        PAGO_RECIBIDO = 0;

        // Esperar para ver la preparación
        #100;


        #100;

        $finish;
    end

endmodule
