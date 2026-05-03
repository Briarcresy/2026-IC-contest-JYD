
`include "defines.sv"

module MEM_WB #(
    WIDTH = 32
) (
`ifdef ENABLE_DEBUG_TRACE
    input  logic [WIDTH-1:0] mem_pc4,
    output logic [WIDTH-1:0] wb_pc4,
`endif
    input  logic             clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] mem_alu_result,
    input  logic [WIDTH-1:0] mem_mdata,
    input  logic [      4:0] mem_rd_addr,

    //Control signal WB
    input logic [2:0] mem_mask,
    input logic [1:0] mem_regwrmux,
    input logic       mem_reg_write,

    output logic [WIDTH-1:0] wb_alu_result,
    output logic [WIDTH-1:0] wb_mdata,
    output logic [      4:0] wb_rd_addr,

    //Control signal WB
    output logic [2:0] wb_mask,
    output logic [1:0] wb_regwrmux,
    output logic       wb_reg_write
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_alu_result <= '0;
            wb_mdata      <= '0;
            wb_rd_addr    <= '0;
            wb_mask       <= '0;
            wb_reg_write  <= '0;
            wb_regwrmux   <= '0;
        end else begin
            wb_alu_result <= mem_alu_result;
            wb_mdata      <= mem_mdata;
            wb_mask       <= mem_mask;
            wb_regwrmux   <= mem_regwrmux;
            wb_rd_addr    <= mem_rd_addr;
            wb_reg_write  <= mem_reg_write;
        end
    end

`ifdef ENABLE_DEBUG_TRACE
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_pc4 <= '0;
        end else begin
            wb_pc4 <= mem_pc4;
        end
    end
`endif

endmodule
