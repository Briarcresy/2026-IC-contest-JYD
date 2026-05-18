`timescale 1ns / 1ps
`include "defines.sv"
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
`ifdef ENABLE_DEBUG_TRACE
    parameter RESET_VAL = 32'h0000_0000
`else
    parameter RESET_VAL = 32'h8000_0000
`endif
) (
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   stall,
    input  logic [DATAWIDTH - 1:0] npc,
    output logic [DATAWIDTH - 1:0] pc
);
    logic [DATAWIDTH - 1:0] reg_pc;
    logic rst_delay;

    always_ff @(posedge clk) begin
        rst_delay <= rst;
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst | rst_delay) reg_pc <= RESET_VAL;
        else if (!stall) reg_pc <= npc;
    end

    assign pc = reg_pc;
endmodule
