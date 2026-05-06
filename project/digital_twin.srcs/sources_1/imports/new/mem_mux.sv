`timescale 1ns / 1ps
`include "defines.sv"
module mem_mux #(
    WIDTH = 32
) (
    input logic [WIDTH-1:0] ex_mux,
    input logic [WIDTH-1:0] mdata,
    input logic [1:0] alu_mux,
    output logic [WIDTH-1:0] result
);
    always_comb begin
        if (alu_mux == 2'b10) begin
            result = mdata;
        end else begin
            result = ex_mux;
        end
    end
endmodule
