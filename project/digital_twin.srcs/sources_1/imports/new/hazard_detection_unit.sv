`timescale 1ns / 1ps
`include "defines.sv"

module hazard_detection_unit #(
) (
    input  logic [1:0] npcop,
    input  logic       alu_is_true,
    input  logic [1:0] regwrmux,
    input  logic       reg_write,
    input  logic [4:0] rd,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    output logic       trigger_stall,
    output logic       trigger_flush
);
    logic jump_or_branch_taken;
    logic load_use_hazard;

    assign jump_or_branch_taken = (npcop == 2'b01 && alu_is_true) || npcop[1];
    assign load_use_hazard = (regwrmux == 2'b10) &&
                             (rd != 5'b0) &&
                             reg_write &&
                             (rs1 == rd || rs2 == rd);

    always_comb begin
        trigger_flush = jump_or_branch_taken;
        trigger_stall = load_use_hazard && !jump_or_branch_taken;
    end
endmodule
