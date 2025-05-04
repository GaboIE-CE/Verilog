// File: tester.v
// Módulo que genera estímulos para un balance inicial de 100 y retiro de 50

module tester (
    output reg        CLK,
    output reg        RESET,
    output reg        tarjeta_received,
    output reg [15:0] pin_correcto,
    output reg [3:0]  digito,
    output reg        digito_stb,
    output reg        tipo_trans,
    output reg [31:0] monto,
    output reg        monto_stb,
    output reg [63:0] balance_inicial
);
    // Reloj de 10 ns
    initial CLK = 1'b0;
    always #5 CLK = ~CLK;

    initial begin
        // Inicialización de señales
        RESET            = 1'b0;
        tarjeta_received = 1'b0;
        pin_correcto     = 16'h1234;   // PIN de ejemplo: 1,2,3,4
        digito           = 4'd0;
        digito_stb       = 1'b0;
        tipo_trans       = 1'b0;
        monto            = 32'd0;
        monto_stb        = 1'b0;
        balance_inicial  = 64'd100;    // Balance inicial = 100

        // Generar reset activo bajo durante 20 ns
        #20 RESET = 1'b1;

        // -- Caso 1: dos intentos de PIN erróneos --
        // Primer intento: 5,5,5,5
        #20 tarjeta_received = 1'b1;
        repeat (4) begin
            @(posedge CLK);
            digito     = 4'd5;
            digito_stb = 1'b1;
            @(posedge CLK);
            digito_stb = 1'b0;
        end
        @(posedge CLK) tarjeta_received = 1'b0;
        #20;

        // Segundo intento: 6,6,6,6
        @(posedge CLK) tarjeta_received = 1'b1;
        repeat (4) begin
            @(posedge CLK);
            digito     = 4'd6;
            digito_stb = 1'b1;
            @(posedge CLK);
            digito_stb = 1'b0;
        end
        @(posedge CLK) tarjeta_received = 1'b0;
        #20;

        // -- Tercer intento CORRECTO: 1,2,3,4 --
        @(posedge CLK) tarjeta_received = 1'b1;
        // Dígito 1
        @(posedge CLK);
          digito     = 4'd1; digito_stb = 1'b1;
        @(posedge CLK); digito_stb = 1'b0;
        // Dígito 2
        @(posedge CLK);
          digito     = 4'd2; digito_stb = 1'b1;
        @(posedge CLK); digito_stb = 1'b0;
        // Dígito 3
        @(posedge CLK);
          digito     = 4'd3; digito_stb = 1'b1;
        @(posedge CLK); digito_stb = 1'b0;
        // Dígito 4
        @(posedge CLK);
          digito     = 4'd4; digito_stb = 1'b1;
        @(posedge CLK); digito_stb = 1'b0;

        @(posedge CLK) tarjeta_received = 1'b0;
        #20;

        // -- Ahora: RETIRO de 50 --
        tipo_trans = 1'b0;    // 1 = retiro
        monto      = 32'd50;  // monto a retirar = 50
        @(posedge CLK); monto_stb = 1'b1;
        @(posedge CLK); monto_stb = 1'b0;

        // Esperar unos ciclos y terminar
        #100 $finish;
    end
endmodule
