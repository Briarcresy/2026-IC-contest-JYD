
`timescale 1ns / 1ps
`include "defines.sv"
module ex_mux #(
    WIDTH = 32
) (
    input  logic [WIDTH-1:0] pcadd4,
    input  logic [WIDTH-1:0] imm,
    input  logic [WIDTH-1:0] alu,
    input  logic [      1:0] alu_mux,
    output logic [WIDTH-1:0] result
);
    always_comb begin
        unique case (alu_mux)
            2'b00:   result = pcadd4;
            2'b01:   result = alu;
            2'b11:   result = imm;
            default: result = 32'b0;
        endcase
    end
endmodule
