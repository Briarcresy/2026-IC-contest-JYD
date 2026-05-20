`timescale 1ns / 1ps
`include "defines.sv"

module hazard_detection_unit #(
) (
    input  logic [1:0] regwrmux,
    input  logic       reg_write,
    input  logic [4:0] rd,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic       uses_rs1,
    input  logic       uses_rs2,
    output logic       trigger_stall
);
    logic load_use_hazard;

    assign load_use_hazard = (regwrmux == 2'b10) &&
                             (rd != 5'b0) &&
                             reg_write &&
                             ((uses_rs1 && rs1 == rd) || (uses_rs2 && rs2 == rd));

    assign trigger_stall = load_use_hazard;
endmodule
