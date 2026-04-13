`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/18 11:22:17
// Design Name: 
// Module Name: IMMGEN
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

module IMMGEN#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [DATAWIDTH-1:0]   instr   ,
    output logic [DATAWIDTH - 1:0] imm       
);
    logic op_itype, op_stype, op_btype, op_utype, op_jtype;
    logic [6:0] opcode;

    assign opcode = instr[6:0];

    assign op_itype = (opcode == `I_TYPE) 
        || (opcode == `IL_TYPE) 
        || (opcode == `IJ_TYPE);
    assign op_stype = opcode == `S_TYPE;
    assign op_btype = opcode == `B_TYPE;
    assign op_utype = (opcode == `U_TYPE) || (opcode == `UA_TYPE);
    assign op_jtype = opcode == `J_TYPE;

    assign imm = {32{op_itype}} & {{20{instr[31]}}, instr[31:20]} |
                {32{op_stype}} & {{20{instr[31]}}, instr[31:25], instr[11:7]} |
                {32{op_btype}} & {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} |
                {32{op_utype}} & {instr[31:12], 12'b0} |
                {32{op_jtype}} & {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

endmodule