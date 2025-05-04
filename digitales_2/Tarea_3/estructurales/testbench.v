// File: testbench.v
// Instanciación del DUT y del probador, y VCD para GTKWave

`timescale 1ns/1ps

module testbench;
    // Señales compartidas
    wire        CLK, RESET, tarjeta_received;
    wire [15:0] pin_correcto;
    wire [3:0]  digito;
    wire        digito_stb, tipo_trans, monto_stb;
    wire [31:0] monto;
    wire [63:0] balance_inicial;

    wire [63:0] balance_actualizado;
    wire        balance_stb, entregar_dinero;
    wire        fondos_insuficientes, pin_incorrecto;
    wire        advertencia, bloqueo;

    // Probador
    tester TB (
        .CLK(CLK),
        .RESET(RESET),
        .tarjeta_received(tarjeta_received),
        .pin_correcto(pin_correcto),
        .digito(digito),
        .digito_stb(digito_stb),
        .tipo_trans(tipo_trans),
        .monto(monto),
        .monto_stb(monto_stb),
        .balance_inicial(balance_inicial)
    );

    // DUT
    maquina_estados DUT (
        .CLK(CLK),
        .RESET(RESET),
        .tarjeta_received(tarjeta_received),
        .pin_correcto(pin_correcto),
        .digito(digito),
        .digito_stb(digito_stb),
        .tipo_trans(tipo_trans),
        .monto(monto),
        .monto_stb(monto_stb),
        .balance_inicial(balance_inicial),
        .balance_actualizado(balance_actualizado),
        .balance_stb(balance_stb),
        .entregar_dinero(entregar_dinero),
        .fondos_insuficientes(fondos_insuficientes),
        .pin_incorrecto(pin_incorrecto),
        .advertencia(advertencia),
        .bloqueo(bloqueo)
    );

    initial begin
        $dumpfile("maquina_estados.vcd");
        $dumpvars(0, testbench);
    end
endmodule
