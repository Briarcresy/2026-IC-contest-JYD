`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/30 8:26:09
// Design Name: 
// Module Name: Control
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
`include "defines.sv"

module Control (
    input  logic [ 6:0] opcode,
    // input  logic [2:0] funct,
    output logic [ 1:0] NpcOp,
    output logic        RegWrite,
    output logic [ 1:0] MemToReg_sel,
    output logic        MemWrite,
    output logic        pc_offset_sel,
    output logic        ALUSrcA,
    output logic        ALUSrcB,
    output logic [13:0] ALUControl
);
    logic jalr, branch, jal, store, rtype, otype, load, auipc, lui;

    // op_csr,
    // op_call_ret;

    assign jalr = (opcode == `IJ_TYPE);
    assign branch = (opcode == `B_TYPE);
    assign jal = (opcode == `J_TYPE);
    assign store = (opcode == `S_TYPE);
    assign rtype = (opcode == `R_TYPE);
    assign itype = (opcode == `I_TYPE);
    assign load = (opcode == `IL_TYPE);
    assign auipc = (opcode == `UA_TYPE);
    assign lui = (opcode == `U_TYPE);
    // assign op_csr = 0;
    // assign op_call_ret = 0;

    assign NpcOp = {2{jalr}} & 2'b10 | {2{branch}} & 2'b01 | {2{jal}} & 2'b11;
    assign RegWrite = !(branch || store);
    assign MemToReg_sel = {2{rtype}} & 2'b01 |
                    {2{itype}} & 2'b01 | 
                    {2{auipc}} & 2'b01 | 
                    {2{load}} & 2'b10 |
                    {2{lui}} & 2'b11;
    assign MemWrite = store;
    assign pc_offset_sel = jalr;
    assign ALUSrcA = auipc;
    assign ALUSrcB = !(rtype || branch);

    localparam ERR = 14'h0;

    logic op_add, op_sub, op_and, op_or, op_xor, op_sll, op_srl;
    logic op_sra, op_beq, op_bne, op_blt, op_bge, op_bgeu, op_bltu;

    assign ALUControl = {
        op_bltu,
        op_bgeu,
        op_bge,
        op_blt,
        op_bne,
        op_beq,
        op_sra,
        op_srl,
        op_sll,
        op_xor,
        op_or,
        op_and,
        op_sub,
        op_add
    };

    assign op_add = (rtype && funct == 4'b0000) ||
                    (itype && funct[2:0] == 3'b000) ||
                    (load && funct[2:0] == 3'b000) ||
                    (load && funct[2:0] == 3'b001) ||
                    (load && funct[2:0] == 3'b010) ||
                    (load && funct[2:0] == 3'b100) ||
                    (load && funct[2:0] == 3'b101) ||
                    (store && funct[2:0] == 3'b000) ||
                    (store && funct[2:0] == 3'b001) ||
                    (store && funct[2:0] == 3'b010) ||
                    auipc || (jalr && funct[2:0] == 3'b000);
    assign op_sub = (rtype && funct == 4'b1000);
    assign op_and = (rtype && funct == 4'b0111) || (itype && funct[2:0] == 3'b111);
    assign op_or = (rtype && funct == 4'b0110) || (itype && funct[2:0] == 3'b110);
    assign op_xor = (rtype && funct == 4'b0100) || (itype && funct[2:0] == 3'b100);
    assign op_sll = (rtype || itype) && funct == 4'b0001;
    assign op_srl = (rtype || itype) && funct == 4'b0101;
    assign op_sra = (rtype || itype) && funct == 4'b1101;
    assign op_bltu = (rtype && funct == 4'b0011) || (branch && funct[2:0] == 3'b110) || (itype && funct[2:0] == 3'b011);
    assign op_blt = (rtype && funct == 4'b0010) || (branch && funct[2:0] == 3'b100) || (itype && funct[2:0] == 3'b010);
    assign op_beq = branch && funct[2:0] == 3'b000;
    assign op_bne = branch && funct[2:0] == 3'b001;
    assign op_bge = branch && funct[2:0] == 3'b101;
    assign op_bgeu = branch && funct[2:0] == 3'b111;

endmodule
