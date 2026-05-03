
`include "defines.sv"

module register_mem_wb (
`ifdef ENABLE_DEBUG_TRACE
    input  logic [31:0] mem_pc4,
    output logic [31:0] wb_pc4,
`endif
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,
    input  logic        flush,
    input  logic [31:0] mem_alu_result,
    input  logic [31:0] mem_mdata,
    input  logic [ 4:0] mem_rd_addr,
    input  logic [ 2:0] mem_mask,
    input  logic [ 1:0] mem_regwrmux,
    input  logic        mem_reg_write,
    output logic [31:0] wb_alu_result,
    output logic [31:0] wb_mdata,
    output logic [ 4:0] wb_rd_addr,
    output logic [ 2:0] wb_mask,
    output logic [ 1:0] wb_regwrmux,
    output logic        wb_reg_write
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
`ifdef ENABLE_DEBUG_TRACE
            wb_pc4 <= mem_pc4;
`endif
            if (flush) begin
                wb_rd_addr   <= 5'b0;
                wb_reg_write <= 1'b0;
            end else if (!stall) begin
                wb_rd_addr   <= mem_rd_addr;
                wb_reg_write <= mem_reg_write;
            end
        end
    end
endmodule
