module register_ex_mem #(
    WIDTH = 32
) (
    input  logic        clock,
    input  logic        reset,
    input  logic        stall,
    input  logic        flush,
    input  logic [WIDTH-1:0] ex_alu_result,
    input  logic [WIDTH-1:0] ex_rs2_val,
    input  logic [4:0]  ex_rd_addr,
    input  logic [1:0]  ex_npc_op,
    input  logic        ex_reg_write,
    input  logic        ex_mem_write,
    input  logic        ex_mem_to_reg,
    output logic [WIDTH-1:0] mem_alu_result,
    output logic [WIDTH-1:0] mem_rs2_val,
    output logic [4:0]  mem_rd_addr,
    output logic [1:0]  mem_npc_op,
    output logic        mem_reg_write,
    output logic        mem_mem_write,
    output logic        mem_mem_to_reg
);

    logic [WIDTH-1:0] alu_result_reg;
    logic [WIDTH-1:0] rs2_val_reg;
    logic [4:0]  rd_addr_reg;
    logic        reg_write_reg;
    logic        mem_write_reg;
    logic        mem_to_reg_reg;

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            alu_result_reg <= WIDTH'b0;
            rs2_val_reg    <= WIDTH'b0;
            rd_addr_reg    <= 5'b0;
            mem_npc_op     <= 2'b0;
            reg_write_reg  <= 1'b0;
            mem_write_reg  <= 1'b0;
            mem_to_reg_reg <= 1'b0;
        end
        else if (flush) begin
            reg_write_reg  <= 1'b0;
            mem_write_reg  <= 1'b0;
            mem_to_reg_reg <= 1'b0;
            alu_result_reg <= WIDTH'b0;
            rs2_val_reg    <= WIDTH'b0;
            rd_addr_reg    <= 5'b0;
        end
        else if (!stall) begin
            alu_result_reg <= ex_alu_result;
            rs2_val_reg    <= ex_rs2_val;
            rd_addr_reg    <= ex_rd_addr;
            reg_write_reg  <= ex_reg_write;
            mem_write_reg  <= ex_mem_write;
            mem_to_reg_reg <= ex_mem_to_reg;
        end
    end

    assign mem_alu_result = alu_result_reg;
    assign mem_rs2_val    = rs2_val_reg;
    assign mem_rd_addr    = rd_addr_reg;
    assign mem_reg_write  = reg_write_reg;
    assign mem_mem_write  = mem_write_reg;
    assign mem_mem_to_reg = mem_to_reg_reg;

endmodule