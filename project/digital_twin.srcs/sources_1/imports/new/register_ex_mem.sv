module register_ex_mem #(
    WIDTH = 32
) (
    input  logic             clock,
    input  logic             reset,
    input  logic             stall,
    input  logic             flush,
    input  logic [WIDTH-1:0] ex_alu_result,
    input  logic [WIDTH-1:0] ex_rs2_val,
    input  logic [      4:0] ex_rd_addr,
    input  logic [      1:0] ex_npc_op,
    input  logic [      1:0] ex_regwrmux,
    input  logic             ex_reg_write,
    input  logic             ex_mem_write,
    input  logic             ex_mem_to_reg,
    output logic [WIDTH-1:0] mem_alu_result,
    output logic [WIDTH-1:0] mem_rs2_val,
    output logic [      4:0] mem_rd_addr,
    output logic [      1:0] mem_npc_op,
    output logic [      1:0] mem_regwrmux,
    output logic             mem_reg_write,
    output logic             mem_mem_write,
    output logic             mem_mem_to_reg
);
    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            mem_alu_result <= {WIDTH{1'b0}};
            mem_rs2_val    <= {WIDTH{1'b0}};
            mem_rd_addr    <= 5'b0;
            mem_npc_op     <= 2'b0;
            mem_reg_write  <= 1'b0;
            mem_mem_write  <= 1'b0;
            mem_mem_to_reg <= 1'b0;
        end else if (flush) begin
            mem_reg_write  <= 1'b0;
            mem_mem_write  <= 1'b0;
            mem_mem_to_reg <= 1'b0;
            mem_alu_result <= {WIDTH{1'b0}};
            mem_rs2_val    <= {WIDTH{1'b0}};
            mem_rd_addr    <= 5'b0;
        end else if (!stall) begin
            mem_alu_result <= ex_alu_result;
            mem_rs2_val    <= ex_rs2_val;
            mem_rd_addr    <= ex_rd_addr;
            mem_npc_op     <= ex_npc_op;
            mem_regwrmux   <= ex_regwrmux;
            mem_reg_write  <= ex_reg_write;
            mem_mem_write  <= ex_mem_write;
            mem_mem_to_reg <= ex_mem_to_reg;
        end
    end
endmodule
