module register_ex_mem #(
    WIDTH = 32
) (
    input  logic             clock,
    input  logic             reset,
    input  logic             stall,
    input  logic             flush,
    input  logic [WIDTH-1:0] ex_alu_result,
    input  logic [WIDTH-1:0] ex_rs2_val,
    input  logic [WIDTH-1:0] ex_imm,
    input  logic [WIDTH-1:0] ex_pc4,
    input  logic [      4:0] ex_rd_addr,
    input  logic [      2:0] ex_mask,
    input  logic [      1:0] ex_npc_op,
    input  logic [      1:0] ex_regwrmux,
    input  logic             ex_reg_write,
    input  logic             ex_mem_write,
    input  logic [      1:0] ex_mask_memread,
    output logic [WIDTH-1:0] mem_alu_result,
    output logic [WIDTH-1:0] mem_rs2_val,
    output logic [WIDTH-1:0] mem_imm,
    output logic [WIDTH-1:0] mem_pc4,
    output logic [      4:0] mem_rd_addr,
    output logic [      2:0] mem_mask,
    output logic [      1:0] mem_npc_op,
    output logic [      1:0] mem_regwrmux,
    output logic             mem_reg_write,
    output logic             mem_mem_write,
    output logic [      1:0] mem_mask_memread
);
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            mem_alu_result   <= '0;
            mem_rs2_val      <= '0;
            mem_imm          <= '0;
            mem_pc4          <= '0;
            mem_rd_addr      <= '0;
            mem_mask         <= '0;
            mem_npc_op       <= '0;
            mem_regwrmux     <= '0;
            mem_reg_write    <= '0;
            mem_mem_write    <= '0;
            mem_mask_memread <= '0;
        end else begin
            mem_alu_result   <= ex_alu_result;
            mem_rs2_val      <= ex_rs2_val;
            mem_imm          <= ex_imm;
            mem_pc4          <= ex_pc4;
            mem_rd_addr      <= ex_rd_addr;
            mem_mask         <= ex_mask;
            mem_npc_op       <= ex_npc_op;
            mem_regwrmux     <= ex_regwrmux;
            mem_mask_memread <= ex_mask_memread;
            if (flush) begin
                mem_reg_write <= 1'b0;
                mem_mem_write <= 1'b0;
            end else if (!stall) begin
                mem_reg_write <= ex_reg_write;
                mem_mem_write <= ex_mem_write;
            end
        end
    end
endmodule
