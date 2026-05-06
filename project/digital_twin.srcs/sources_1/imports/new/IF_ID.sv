`timescale 1ns / 1ps
`include "defines.sv"

module IF_ID #(
    WIDTH = 32
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             stall,
    input  logic             flush,
    input  logic [WIDTH-1:0] if_pc,
    input  logic [WIDTH-1:0] if_pc4,
    input  logic [WIDTH-1:0] if_instr,
    output logic [WIDTH-1:0] id_pc,
    output logic [WIDTH-1:0] id_pc4,
    output logic [WIDTH-1:0] id_instr
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            id_pc    <= '0;
            id_pc4   <= '0;
            id_instr <= '0;
        end else if (flush) begin
            id_pc    <= '0;
            id_pc4   <= '0;
            id_instr <= '0;
        end else if (!stall) begin
            id_pc    <= if_pc;
            id_pc4   <= if_pc4;
            id_instr <= if_instr;
        end
    end
endmodule
