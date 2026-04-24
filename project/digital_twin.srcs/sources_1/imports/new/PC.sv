`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/08 12:42:16
// Design Name: 
// Module Name: PC
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

module PC #(
    parameter DATAWIDTH = 32,
    parameter RESET_VAL = 32'h8000_0000
) (
    input  logic                   clk,
    input  logic                   rst,
    input  logic [DATAWIDTH - 1:0] npc,
    output logic [DATAWIDTH - 1:0] pc
);
    logic rst_delay;

    always_ff @(posedge clk) begin
        rst_delay <= rst;
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst | rst_delay) pc <= RESET_VAL;
        else pc <= npc;
    end

endmodule
