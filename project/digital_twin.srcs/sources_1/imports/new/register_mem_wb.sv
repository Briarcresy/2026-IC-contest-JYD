module register_mem_wb (
    input  logic        clock,
    input  logic        reset,
    input  logic        stall,
    input  logic        flush,
    input  logic [31:0] mem_alu_result,
    input  logic [31:0] mem_pc_add_4,
    input  logic [31:0] mem_mdata,
    input  logic [31:0] mem_imm,
    input  logic [ 4:0] mem_rd_addr,
    input  logic [ 2:0] mem_mask,
    input  logic        mem_reg_write,
    output logic [31:0] wb_alu_result,
    output logic [31:0] wb_pc_add_4,
    output logic [31:0] wb_mdata,
    output logic [31:0] wb_imm,
    output logic [ 4:0] wb_rd_addr,
    output logic [ 2:0] wb_mask,
    output logic        wb_reg_write
);

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            wb_alu_result <= 32'b0;
            wb_rd_addr    <= 5'b0;
            wb_reg_write  <= 1'b0;
        end else if (flush) begin
            wb_alu_result <= 32'b0;
            wb_rd_addr    <= 5'b0;
            wb_reg_write  <= 1'b0;
        end else if (!stall) begin
            wb_alu_result <= mem_alu_result;
            wb_pc_add_4   <= mem_pc_add_4;
            wb_mdata      <= mem_mdata;
            wb_imm        <= mem_imm;
            wb_rd_addr    <= mem_rd_addr;
            wb_mask       <= mem_mask;
            wb_reg_write  <= mem_reg_write;
        end
    end

endmodule
