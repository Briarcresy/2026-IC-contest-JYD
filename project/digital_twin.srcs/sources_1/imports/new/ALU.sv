`timescale 1ns / 1ps
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

module ALU#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [DATAWIDTH - 1:0]  A           ,
    input  logic [DATAWIDTH - 1:0]  B           ,
    input  logic [13:0]             ALUControl  ,
    output logic [DATAWIDTH - 1:0]  Result      ,
    output logic                    isTrue        
);

    logic op_add, op_sub, op_and, op_or, op_xor, op_sll, op_srl;
    logic op_sra, op_beq, op_bne, op_blt, op_bge, op_bgeu, op_bltu;

    assign op_add = ALUControl[0];
    assign op_sub = ALUControl[1];
    assign op_and = ALUControl[2];
    assign op_or = ALUControl[3];
    assign op_xor = ALUControl[4];
    assign op_sll = ALUControl[5];
    assign op_srl = ALUControl[6];
    assign op_sra = ALUControl[7];
    assign op_beq = ALUControl[8];
    assign op_bne = ALUControl[9];
    assign op_blt = ALUControl[10];
    assign op_bge = ALUControl[11];
    assign op_bgeu = ALUControl[12];
    assign op_bltu = ALUControl[13];

    logic [DATAWIDTH-1:0] add_sub_result, and_result, or_result, xor_result;
    logic [DATAWIDTH-1:0] sll_result, srl_result, sra_result, beq_result, bne_result;
    logic [DATAWIDTH-1:0] blt_result, bge_result, bgeu_result, bltu_result;

    logic [DATAWIDTH-1:0] adder_a, adder_b;
    logic cin, carry;

    assign adder_a = A;
    assign adder_b = (op_sub | op_blt | op_bge | op_bgeu | op_bltu) ? ~B : B;
    assign cin = (op_sub | op_blt | op_bge | op_bgeu | op_bltu) ? 1'b1 : 0;

    /* verilator lint_off WIDTHEXPAND */
    assign {carry, add_sub_result} = adder_a + adder_b + cin;

    assign and_result = A & B;
    assign or_result = A | B;
    assign xor_result = A ^ B;
    assign sll_result = A << B[4:0];
    assign srl_result = A >> B[4:0];
    assign sra_result = ($signed(A)) >>> B[4:0];
    assign beq_result = {31'b0, A == B};
    assign bne_result = {31'b0, A != B};
    assign blt_result = {31'b0, (A[31] &  ~B[31]) | ((~A[31] ^ B[31]) & add_sub_result[31])};
    assign bge_result = ~blt_result;
    assign bgeu_result = {31'b0, carry};
    assign bltu_result = {31'b0, ~carry};

    assign isTrue = Result[0];

    assign Result = {32{op_add | op_sub}} & add_sub_result |
                    {32{op_and}} & and_result |
                    {32{op_or}} & or_result |
                    {32{op_xor}} & xor_result |
                    {32{op_sll}} & sll_result |
                    {32{op_srl}} & srl_result |
                    {32{op_sra}} & sra_result |
                    {32{op_beq}} & beq_result |
                    {32{op_bne}} & bne_result |
                    {32{op_blt}} & blt_result |
                    {32{op_bge}} & bge_result |
                    {32{op_bgeu}} & bgeu_result |
                    {32{op_bltu}} & bltu_result;

endmodule