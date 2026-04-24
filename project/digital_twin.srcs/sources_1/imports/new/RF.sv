`timescale 1ns / 1ps

module RF #(
    parameter ADDR_WIDTH = 5,
    parameter DATAWIDTH  = 32
) (
    input logic clk,
    input logic rst,

    // Write rd
    input logic                    wen,
    input logic [ADDR_WIDTH - 1:0] waddr,
    input logic [ DATAWIDTH - 1:0] wdata,

    // Read rs1 rs2
    input logic [ADDR_WIDTH - 1:0] rR1,
    input logic [ADDR_WIDTH - 1:0] rR2,

    output logic [DATAWIDTH - 1:0] rR1_data,
    output logic [DATAWIDTH - 1:0] rR2_data
);

    logic [DATAWIDTH - 1:0] reg_bank[0:31];

    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_bank[i] <= '0;
            end
        end else if (wen && (waddr != '0)) begin
            reg_bank[waddr] <= wdata;
        end
    end

    always_comb begin
        rR1_data = (rR1 == '0) ? '0 : reg_bank[rR1];
        rR2_data = (rR2 == '0) ? '0 : reg_bank[rR2];
    end

endmodule
