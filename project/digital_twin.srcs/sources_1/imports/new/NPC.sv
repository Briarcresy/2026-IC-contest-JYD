`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/23 12:42:16
// Design Name: 
// Module Name: NPC
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

module NPC #(
    parameter DATAWIDTH = 32
) (
    input  logic                   isTrue,
    input  logic [            1:0] npc_op,
    input  logic [DATAWIDTH - 1:0] pc,
    input  logic [DATAWIDTH - 1:0] offset,
    input  logic [DATAWIDTH - 1:0] pc_add_offset,
    input  logic [DATAWIDTH - 1:0] pcadd4_pipeline,
    output logic [DATAWIDTH - 1:0] npc,
    output logic [DATAWIDTH - 1:0] pcadd4
);
    // logic op_branch, op_add4, op_jalr, op_jal;
    logic [DATAWIDTH-1:0] branch_addr, jalr_addr, jal_addr;

    // assign op_add4 = (npc_op == 2'b00);
    // assign op_branch = (npc_op == 2'b01);
    // assign op_jalr = (npc_op == 2'b10);
    // assign op_jal = (npc_op == 2'b11);

    assign branch_addr = isTrue ? (pc_add_offset) : (pcadd4);
    assign jalr_addr = {offset[DATAWIDTH-1:1], 1'b0};
    assign jal_addr = pc_add_offset;

    always_comb begin
        case (npc_op)
            2'b00:   npc = pcadd4;
            2'b01:   npc = branch_addr;
            2'b10:   npc = jalr_addr;
            2'b11:   npc = jal_addr;
            default: npc = pcadd4;
        endcase
    end

    // assign npc = {32{op_add4}} & pcadd4 |
    //         {32{op_branch}} & branch_addr |
    //         {32{op_jalr}} & jalr_addr |
    //         {32{op_jal}} & jal_addr;

    assign pcadd4 = pc + 4;
endmodule
