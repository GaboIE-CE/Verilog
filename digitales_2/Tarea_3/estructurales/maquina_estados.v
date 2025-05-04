// File: maquina_estados.v
// Descripción conductual 100% Verilog-2001 para síntesis

module maquina_estados (
    input         CLK,
    input         RESET,              // reset activo bajo
    input         tarjeta_received,
    input  [15:0] pin_correcto,
    input  [3:0]  digito,
    input         digito_stb,
    input         tipo_trans,         // 0=depósito, 1=retiro
    input  [31:0] monto,
    input         monto_stb,
    input  [63:0] balance_inicial,

    output reg [63:0] balance_actualizado,
    output reg        balance_stb,
    output reg        entregar_dinero,
    output reg        fondos_insuficientes,
    output reg        pin_incorrecto,
    output reg        advertencia,
    output reg        bloqueo
);

    // Codificación de estados
    parameter S_IDLE           = 4'd0;
    parameter S_PIN_ENTRY      = 4'd1;
    parameter S_CHECK_PIN      = 4'd2;
    parameter S_INCORRECT      = 4'd3;
    parameter S_LOCKED         = 4'd4;
    parameter S_TRANS_TYPE     = 4'd5;
    parameter S_DEPOSIT        = 4'd6;
    parameter S_WITHDRAW_CHECK = 4'd7;
    parameter S_WITHDRAW       = 4'd8;
    parameter S_INSUFFICIENT   = 4'd9;

    reg [3:0]  state, next_state;
    reg [1:0]  attempts;
    reg [1:0]  pin_idx;
    reg [15:0] pin_buffer;
    reg [63:0] balance_reg;

    // Registro de estado y operaciones secuenciales
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            state        <= S_IDLE;
            attempts     <= 2'b00;
            pin_idx      <= 2'b00;
            pin_buffer   <= 16'b0;
            balance_reg  <= 64'b0;
        end else begin
            state <= next_state;

            // Captura dígitos de PIN
            if (state == S_PIN_ENTRY && digito_stb) begin
                pin_buffer <= { pin_buffer[11:0], digito };
                pin_idx    <= pin_idx + 1;
            end

            // Contar intentos y latch de balance
            if (state == S_CHECK_PIN) begin
                if (pin_buffer != pin_correcto)
                    attempts <= attempts + 1;
                else
                    balance_reg <= balance_inicial;
            end

            // Actualizar balance según transacción
            if (state == S_DEPOSIT)
                balance_reg <= balance_reg + monto;
            if (state == S_WITHDRAW)
                balance_reg <= balance_reg - monto;
        end
    end

    // Lógica combinacional de siguiente estado y salidas
    always @(*) begin
        // Defaults
        next_state           = state;
        pin_incorrecto       = 1'b0;
        advertencia          = 1'b0;
        bloqueo              = 1'b0;
        balance_stb          = 1'b0;
        entregar_dinero      = 1'b0;
        fondos_insuficientes = 1'b0;
        balance_actualizado  = balance_reg;

        case (state)
            S_IDLE: begin
                if (tarjeta_received)
                    next_state = S_PIN_ENTRY;
            end

            S_PIN_ENTRY: begin
                if (digito_stb && pin_idx == 2'd3)
                    next_state = S_CHECK_PIN;
            end

            S_CHECK_PIN: begin
                if (pin_buffer == pin_correcto)
                    next_state = S_TRANS_TYPE;
                else if (attempts == 2'd2)
                    next_state = S_LOCKED;
                else
                    next_state = S_INCORRECT;
            end

            S_INCORRECT: begin
                pin_incorrecto = 1'b1;
                if (attempts == 2'd2)
                    advertencia = 1'b1;
                next_state = S_PIN_ENTRY;
            end

            S_LOCKED: begin
                bloqueo   = 1'b1;
                next_state = S_LOCKED;
            end

            S_TRANS_TYPE: begin
                if (monto_stb)
                    next_state = (tipo_trans == 1'b0) ? S_DEPOSIT : S_WITHDRAW_CHECK;
            end

            S_DEPOSIT: begin
                balance_stb = 1'b1;
                next_state  = S_IDLE;
            end

            S_WITHDRAW_CHECK: begin
                if (monto <= balance_reg)
                    next_state = S_WITHDRAW;
                else
                    next_state = S_INSUFFICIENT;
            end

            S_WITHDRAW: begin
                balance_stb     = 1'b1;
                entregar_dinero = 1'b1;
                next_state      = S_IDLE;
            end

            S_INSUFFICIENT: begin
                fondos_insuficientes = 1'b1;
                next_state           = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

endmodule
