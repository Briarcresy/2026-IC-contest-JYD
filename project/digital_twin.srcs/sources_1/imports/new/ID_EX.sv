`include "defines.sv"
module ID_EX #(
    WIDTH = 32
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             id_stall,
    input  logic             id_flush,
    input  logic [WIDTH-1:0] id_pc,
    input  logic [WIDTH-1:0] id_pc4,
    input  logic [WIDTH-1:0] id_rs1v,
    input  logic [WIDTH-1:0] id_rs2v,
    input  logic [WIDTH-1:0] id_imm,
    input  logic [      4:0] id_rs1,
    input  logic [      4:0] id_rs2,
    input  logic [      4:0] id_rd,
    // input  logic [      6:0] id_opcode,
    // input  logic [      3:0] id_funct4,
    //Control signal EX
    input  logic [     13:0] id_alu_op,
    input  logic [      1:0] id_alusrcA,
    input  logic [      1:0] id_alusrcB,
    input  logic [      1:0] id_npcop,
    input  logic             id_pc_offset_sel,
    //Control signal M
    input  logic             id_mem_write,
    //Control signal WB
    input  logic [      2:0] id_mask,
    input  logic [      1:0] id_regwrmux,
    input  logic             id_reg_write,
    // ...
    output logic [WIDTH-1:0] ex_pc,
    output logic [WIDTH-1:0] ex_pc4,
    output logic [WIDTH-1:0] ex_rs1v,
    output logic [WIDTH-1:0] ex_rs2v,
    output logic [WIDTH-1:0] ex_imm,
    output logic [      4:0] ex_rs1,
    output logic [      4:0] ex_rs2,
    output logic [      4:0] ex_rd,
    // output logic [      6:0] ex_opcode,
    // output logic [      3:0] ex_funct4,
    //Control signal EX
    output logic [     13:0] ex_alu_op,
    output logic [      1:0] ex_alusrcA,
    output logic [      1:0] ex_alusrcB,
    output logic [      1:0] ex_npcop,
    output logic             ex_pc_offset_sel,
    //Control signal M
    output logic             ex_mem_write,
    //Control signal WB
    output logic [      2:0] ex_mask,
    output logic [      1:0] ex_regwrmux,
    output logic             ex_reg_write
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_pc            <= '0;
            ex_pc4           <= '0;
            ex_rs1v          <= '0;
            ex_rs2v          <= '0;
            ex_imm           <= '0;
            ex_rs1           <= '0;
            ex_rs2           <= '0;
            ex_rd            <= '0;
            // ex_opcode        <= '0;
            // ex_funct4        <= '0;
            ex_mask          <= '0;
            ex_reg_write     <= '0;
            ex_mem_write     <= '0;
            ex_regwrmux      <= '0;
            ex_pc_offset_sel <= '0;
            ex_npcop         <= '0;
            ex_alusrcA       <= '0;
            ex_alusrcB       <= '0;
            ex_alu_op        <= '0;
        end else begin
            ex_pc            <= id_pc;
            ex_rs1v          <= id_rs1v;
            ex_rs2v          <= id_rs2v;
            ex_imm           <= id_imm;
            ex_rs1           <= id_rs1;
            ex_rs2           <= id_rs2;
            ex_rd            <= id_rd;
            // ex_opcode        <= id_opcode;
            // ex_funct4        <= id_funct4;
            ex_mask          <= id_mask;
            ex_regwrmux      <= id_regwrmux;
            ex_pc_offset_sel <= id_pc_offset_sel;
            ex_alusrcA       <= id_alusrcA;
            ex_alusrcB       <= id_alusrcB;
            ex_alu_op        <= id_alu_op;
            if (id_flush || id_stall) begin
                ex_reg_write <= '0;
                ex_mem_write <= '0;
                ex_npcop     <= '0;
                ex_pc4       <= '0;
            end else begin
                ex_reg_write <= id_reg_write;
                ex_mem_write <= id_mem_write;
                ex_npcop     <= id_npcop;
                ex_pc4       <= id_pc4;
            end
        end
    end
endmodule
