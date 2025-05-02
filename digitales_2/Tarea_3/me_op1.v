// Declaración del módulo y parámetros
module det_sec #(parameter SECUENCIA = 5'b10100,
                 parameter SEC_REINICIO = 5'b00000) (clk,rst,s_in,valido);

// Declaración de entradas y salidas
input clk,rst,s_in;
output reg valido;

//Declaración de variables internas
reg   [4:0] sec_recibida; 

//Se usan dos bits para que sea un flip flop por estado (one-hot encoding) que elimina las carreras
//de estado (race conditions)
//INICIO = 01
//SINCRONIZADO = 10
//
reg   [1:0] estado_actual;
reg   [1:0] prox_estado;

//Definir todos los flip flops
always @(posedge clk) begin
	if (rst) begin 
	   estado_actual <= 2'b01;
	   sec_recibida  <= '0;
	end
	else begin
	   estado_actual   <= prox_estado;
	   sec_recibida[0] <= s_in;
	   sec_recibida[1] <= sec_recibida[0];
	   sec_recibida[2] <= sec_recibida[1];
           sec_recibida[3] <= sec_recibida[2];
	   sec_recibida[4] <= sec_recibida[3];
	end

end

//Definir lógica combinacional
//Case de los estados
always @(*) begin
  //Case de estados para definir:
  //1. Lógica de próximo estado
  //2. Lógica de salida
  case (estado_actual)
    //Estado de inicio
    2'b01: begin
	     valido = 0;
             if (sec_recibida == SECUENCIA) prox_estado = 2'b10;
	     else prox_estado = 2'b01;
           end
    //Estado sincronizado
    2'b10: begin 
             valido = 1;
             if (sec_recibida == SEC_REINICIO) prox_estado = 2'b01;
	     else prox_estado = 2'b10;
           end
    //Cualquier otro caso
    default: begin 
               valido = 0;
               prox_estado = 2'b01;
             end
  endcase

end

endmodule
