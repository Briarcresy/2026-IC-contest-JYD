`timescale 1ns / 1ps
`include "defines.sv"
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
    input logic       stall,
    input logic       predict_taken,
    input logic       redirect_taken,

    input logic [DATAWIDTH - 1:0] pc,
    input logic [DATAWIDTH - 1:0] pc_add_4,
    input logic [DATAWIDTH - 1:0] predict_target,
    input logic [DATAWIDTH - 1:0] redirect_target,

    output logic [DATAWIDTH - 1:0] npc
);
    always_comb begin
        if (redirect_taken) begin
            npc = redirect_target;
        end else if (stall) begin
            npc = pc;
        end else if (predict_taken) begin
            npc = predict_target;
        end else begin
            npc = pc_add_4;
        end
    end

endmodule
