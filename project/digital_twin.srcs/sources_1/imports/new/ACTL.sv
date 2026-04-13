`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/03 11:25:24
// Design Name: 
// Module Name: ACTL
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

module ACTL(
    input  logic [6:0] opcode       ,
    input  logic [3:0] funct        ,
    output logic [13:0] ALUControl    
);
    localparam ADD      = 14'h0001;
    localparam SUB      = 14'h0002;
    localparam AND      = 14'h0004;
    localparam OR       = 14'h0008;
    localparam XOR      = 14'h0010;
    localparam SLL      = 14'h0020;
    localparam SRL      = 14'h0040;
    localparam SRA      = 14'h0080;
    localparam BEQ      = 14'h0100;
    localparam BNE      = 14'h0200;
    localparam BLT      = 14'h0400;
    localparam BGE      = 14'h0800;
    localparam BGEU     = 14'h1000;
    localparam BLTU     = 14'h2000;

    localparam ERR      = 14'h0;

    logic op_add, op_sub, op_and, op_or, op_xor, op_sll, op_srl;
    logic op_sra, op_beq, op_bne, op_blt, op_bge, op_bgeu, op_bltu;

    assign ALUControl = {14{op_add}} & ADD |
                        {14{op_sub}} & SUB |
                        {14{op_and}} & AND |
                        {14{op_or}} & OR |
                        {14{op_xor}} & XOR |
                        {14{op_sll}} & SLL |
                        {14{op_srl}} & SRL |
                        {14{op_sra}} & SRA |
                        {14{op_beq}} & BEQ |
                        {14{op_bne}} & BNE |
                        {14{op_blt}} & BLT |
                        {14{op_bge}} & BGE |
                        {14{op_bgeu}} & BGEU |
                        {14{op_bltu}} & BLTU;

    logic rtype, itype, load, store, jalr, auipc, branch;

    assign rtype = opcode == `R_TYPE;
    assign itype = opcode == `I_TYPE;
    assign load = opcode == `IL_TYPE;
    assign store = opcode == `S_TYPE;
    assign jalr = opcode == `IJ_TYPE;
    assign auipc = opcode == `UA_TYPE;
    assign branch = opcode == `B_TYPE;

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