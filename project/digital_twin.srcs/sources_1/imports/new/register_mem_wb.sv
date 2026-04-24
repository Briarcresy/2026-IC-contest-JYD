module register_mem_wb (
    input  logic        clock,
    input  logic        reset,
    input  logic        stall,
    input  logic        flush,
    input  logic [31:0] mem_alu_result,
    input  logic [4:0]  mem_rd_addr,
    input  logic        mem_reg_write,
    output logic [31:0] wb_alu_result,
    output logic [4:0]  wb_rd_addr,
    output logic        wb_reg_write
);

    logic [31:0] alu_result_reg;
    logic [4:0]  rd_addr_reg;
    logic        reg_write_reg;

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            alu_result_reg <= 32'b0;
            rd_addr_reg    <= 5'b0;
            reg_write_reg  <= 1'b0;
        end
        else if (flush) begin
            reg_write_reg  <= 1'b0;
            alu_result_reg <= 32'b0;
            rd_addr_reg    <= 5'b0;
        end
        else if (!stall) begin
            alu_result_reg <= mem_alu_result;
            rd_addr_reg    <= mem_rd_addr;
            reg_write_reg  <= mem_reg_write;
        end
    end

    assign wb_alu_result = alu_result_reg;
    assign wb_rd_addr    = rd_addr_reg;
    assign wb_reg_write  = reg_write_reg;

endmodule