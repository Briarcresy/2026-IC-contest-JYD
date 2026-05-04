`timescale 1ns / 1ps
`include "defines.sv"

module hazard_detection_unit #(
) (
    input  logic [1:0] npcop,
    input  logic       alu_is_true,
    input  logic [1:0] regwrmux,
    // input  logic       reg_write,
    input  logic [4:0] rd,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    output logic       trigger_stall,
    output logic       trigger_flush
);
    always_comb begin
        if (  // npcop = 00 => no jal-jalr-b. ref Control NpcOp
            (npcop == 2'b01 && alu_is_true)
            || (npcop[1])) begin  // jump haappens. discard load-use hazard
            trigger_stall = 0;
            trigger_flush = 1;
        end else if (regwrmux == 2'b10  // regwrmux = 10 => memdata selected.
            && rd != 0 && (rs1 == rd || rs2 == rd)) begin
            // load-use hazard occurred.
            trigger_stall = 1;
            trigger_flush = 0;
        end else begin
            trigger_stall = 0;
            trigger_flush = 0;
        end
    end
endmodule
