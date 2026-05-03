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
        rR1_data = reg_bank[rR1];
        rR2_data = reg_bank[rR2];

        // 旁路：如果WB写入的寄存器正是当前需要的
        if (wen && waddr != 0) begin
            if (rR1 == waddr) rR1_data = wdata;
            if (rR2 == waddr) rR2_data = wdata;
        end
    end

endmodule
