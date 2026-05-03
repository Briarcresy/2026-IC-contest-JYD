`timescale 1ns / 1ps
`include "defines.sv"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/01 10:31:41
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU #(
    parameter DATAWIDTH = 32
) (
    input  logic [DATAWIDTH - 1:0] A,
    input  logic [DATAWIDTH - 1:0] B,
    input  logic [           13:0] ALUControl,
    output logic [DATAWIDTH - 1:0] Result,
    output logic                   isTrue
);

    // Operation code decoding
    logic op_add, op_sub, op_and, op_or, op_xor, op_sll, op_srl;
    logic op_sra, op_beq, op_bne, op_blt, op_bge, op_bgeu, op_bltu;

    assign op_add  = ALUControl[0];
    assign op_sub  = ALUControl[1];
    assign op_and  = ALUControl[2];
    assign op_or   = ALUControl[3];
    assign op_xor  = ALUControl[4];
    assign op_sll  = ALUControl[5];
    assign op_srl  = ALUControl[6];
    assign op_sra  = ALUControl[7];
    assign op_beq  = ALUControl[8];
    assign op_bne  = ALUControl[9];
    assign op_blt  = ALUControl[10];
    assign op_bge  = ALUControl[11];
    assign op_bgeu = ALUControl[12];
    assign op_bltu = ALUControl[13];

    // Intermediate results
    logic [DATAWIDTH-1:0] add_sub_result;
    logic [DATAWIDTH-1:0] and_result, or_result, xor_result;
    logic [DATAWIDTH-1:0] sll_result, srl_result, sra_result;
    logic [DATAWIDTH-1:0] beq_result, bne_result;
    logic [DATAWIDTH-1:0] blt_result, bge_result;
    logic [DATAWIDTH-1:0] bgeu_result, bltu_result;

    // ---------- Adder/Subtractor ----------
    logic [DATAWIDTH-1:0] adder_a, adder_b;
    logic adder_cin;
    assign adder_a = A;
    // Only do subtraction when op_sub is active (invert and add 1), otherwise add B directly
    assign adder_b = op_sub ? ~B : B;
    assign adder_cin = op_sub ? 1'b1 : 1'b0;
    assign add_sub_result = adder_a + adder_b + adder_cin;

    // ---------- Logical operations ----------
    assign and_result = A & B;
    assign or_result = A | B;
    assign xor_result = A ^ B;

    // ---------- Shift operations ----------
    assign sll_result = A << B[4:0];
    assign srl_result = A >> B[4:0];
    assign sra_result = $signed(A) >>> B[4:0];

    // ---------- Comparison operations (independent, not relying on adder carry) ----------
    assign beq_result = {{DATAWIDTH - 1{1'b0}}, A == B};
    assign bne_result = {{DATAWIDTH - 1{1'b0}}, A != B};
    assign blt_result = {{DATAWIDTH - 1{1'b0}}, $signed(A) < $signed(B)};
    assign bge_result = {{DATAWIDTH - 1{1'b0}}, $signed(A) >= $signed(B)};
    assign bgeu_result = {{DATAWIDTH - 1{1'b0}}, $unsigned(A) >= $unsigned(B)};
    assign bltu_result = {{DATAWIDTH - 1{1'b0}}, $unsigned(A) < $unsigned(B)};

    // ---------- Multiplexer (case structure for reduced critical path) ----------
    always_comb begin
        Result = '0;  // default value to avoid latch
        case (1'b1)
            op_add, op_sub: Result = add_sub_result;
            op_and:         Result = and_result;
            op_or:          Result = or_result;
            op_xor:         Result = xor_result;
            op_sll:         Result = sll_result;
            op_srl:         Result = srl_result;
            op_sra:         Result = sra_result;
            op_beq:         Result = beq_result;
            op_bne:         Result = bne_result;
            op_blt:         Result = blt_result;
            op_bge:         Result = bge_result;
            op_bgeu:        Result = bgeu_result;
            op_bltu:        Result = bltu_result;
            default:        Result = '0;
        endcase
    end

    // Output flag (consistent with original design: directly take LSB of Result)
    assign isTrue = Result[0];

endmodule
