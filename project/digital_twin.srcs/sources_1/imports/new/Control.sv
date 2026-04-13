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

module Control(
    input  logic [6:0]  opcode      ,
    input  logic [2:0]  funct       ,
    output logic [1:0]  NpcOp       ,
    output logic        RegWrite    ,
    output logic [2:0]  MemToReg    ,
    output logic        MemWrite    ,
    output logic [1:0]  OffsetOrigin,
    output logic        ALUSrcA     ,
    output logic        ALUSrcB
);
    logic op_jalr, op_branch, op_jal, op_store, op_rtype, op_itype, op_load, op_auipc, op_lui, op_csr, op_call_ret;

    assign op_jalr = opcode == `IJ_TYPE;
    assign op_branch = opcode == `B_TYPE;
    assign op_jal = opcode == `J_TYPE;
    assign op_store = opcode == `S_TYPE;
    assign op_rtype = opcode == `R_TYPE;
    assign op_itype = opcode == `I_TYPE;
    assign op_load = opcode == `IL_TYPE;
    assign op_auipc = opcode == `UA_TYPE;
    assign op_lui = opcode == `U_TYPE;
    assign op_csr = (opcode == `CSR_TYPE) && (funct[2:0] != 3'b0);
    assign op_call_ret = (opcode == `CSR_TYPE) && (funct[2:0] == 3'b0);

    assign NpcOp = {2{op_jalr}} & 2'b10 |
                {2{op_call_ret}} & 2'b10 |
                {2{op_branch}} & 2'b01 |
                {2{op_jal}} & 2'b11;
    assign RegWrite = ~(op_branch | op_store | op_call_ret);
    assign MemToReg = {3{op_rtype}} & 3'b001 |
                    {3{op_itype}} & 3'b001 | 
                    {3{op_auipc}} & 3'b001 | 
                    {3{op_load}} & 3'b010 |
                    {3{op_lui}} & 3'b011 |
                    {3{op_csr}} & 3'b100;
    assign MemWrite = op_store;
    assign OffsetOrigin = {2{op_jalr}} & 2'b01 |
                {2{op_call_ret}} & 2'b10;
    assign ALUSrcA = op_auipc;
    assign ALUSrcB = ~(op_rtype | op_branch);


endmodule
