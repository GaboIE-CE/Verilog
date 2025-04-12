`include "tarea_2.v"
`include "tester.v"

module tarea_2_tb;

wire clock, reset, PAGO_RECIBIDO;
wire [2:0] entrada_cafe, entrada_tamano;
wire [3:0] entrada_azucar;
//wire ENTER;

wire [15:0] salida_precio;

wire salida_concentracion; 
wire [3:0] salida_azucar;
wire salida_leche, salida_espuma;
initial begin
  $dumpfile("resultados.vcd");     // Nombre del archivo que se va a generar
  $dumpvars(0, tarea_2_tb);        // Volcado de señales desde el módulo testbench
end




maquina_cafe UO(
  .clock(clock),
  .reset(reset),
  .PAGO_RECIBIDO(PAGO_RECIBIDO),
  .entrada_cafe(entrada_cafe),
  .entrada_tamano(entrada_tamano),
  .entrada_azucar(entrada_azucar),
  .salida_precio(salida_precio),
  .salida_azucar(salida_azucar),
  .salida_concentracion(salida_concentracion),
  .salida_leche(salida_leche),
  //.ENTER(ENTER),
  .salida_espuma(salida_espuma)
);


probador PO(
  .clock(clock),
  .reset(reset),
  .PAGO_RECIBIDO(PAGO_RECIBIDO),
  .entrada_cafe(entrada_cafe),
  .entrada_tamano(entrada_tamano),
  .entrada_azucar(entrada_azucar),
  .salida_precio(salida_precio),
  .salida_azucar(salida_azucar),
  .salida_concentracion(salida_concentracion),
  .salida_leche(salida_leche),
  //.ENTER(ENTER),
  .salida_espuma(salida_espuma)
  );

endmodule
