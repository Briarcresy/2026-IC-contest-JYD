module register_mem_wb (
    input  logic        clock,
    input  logic        reset,
    input  logic        stall,
    input  logic        flush,
    input  logic [31:0] mem_alu_result,
    input  logic [ 4:0] mem_rd_addr,
    input  logic [ 2:0] mem_mask,
    input  logic        mem_reg_write,
    output logic [31:0] wb_alu_result,
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
            wb_rd_addr    <= mem_rd_addr;
            wb_mask       <= mem_mask;
            wb_reg_write  <= mem_reg_write;
        end
    end

endmodule
