`include "tarea_1.v"
`include "module_probador.v"

module tarea_1_tb;

wire clock, reset, PAGO_RECIBIDO;
wire [1:0] tipo_cafe, entrada_tamano;
wire [3:0] azucar;

wire [15:0] precio_real;
wire [3:0] nivel_azucar;
wire concentracion; // ✅

wire leche, espuma;
initial begin
  $dumpfile("resultados.vcd");     // Nombre del archivo que se va a generar
  $dumpvars(0, tarea_1_tb);        // Volcado de señales desde el módulo testbench
end




maquina_cafe UO(
  .clock(clock),
  .reset(reset),
  .PAGO_RECIBIDO(PAGO_RECIBIDO),
  .tipo_cafe(tipo_cafe),
  .entrada_tamano(entrada_tamano),
  .azucar(azucar),
  .precio_real(precio_real),
  .nivel_azucar(nivel_azucar),
  .concentracion(concentracion),
  .leche(leche),
  .espuma(espuma)
);


probador PO(
  .clock(clock),
  .reset(reset),
  .PAGO_RECIBIDO(PAGO_RECIBIDO),
  .tipo_cafe(tipo_cafe),
  .entrada_tamano(entrada_tamano),
  .azucar(azucar),
  .precio_real(precio_real),
  .nivel_azucar(nivel_azucar),
  .concentracion(concentracion),
  .leche(leche),
  .espuma(espuma)
  );

endmodule