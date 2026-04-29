module register_id_ex #(
    WIDTH = 32
) (
    input  logic        clock,
    input  logic        reset,
    input  logic        id_stall,
    input  logic        id_flush,
    input  logic [WIDTH-1:0] id_pc,
    input  logic [WIDTH-1:0] id_rs1v,
    input  logic [WIDTH-1:0] id_rs2v,
    input  logic [WIDTH-1:0] id_imm,
    input  logic [4:0]  id_rs1,
    input  logic [4:0]  id_rs2,
    input  logic [4:0]  id_rd,
    input  logic [6:0]  id_opcode,
    input  logic [3:0]  id_funct4,
    input  logic [2:0]  id_mask,
    input  logic [1:0]  id_regwrmux,
    input  logic        id_reg_write,
    input  logic        id_mem_write,
    // ...
    output logic [WIDTH-1:0] ex_pc,
    output logic [WIDTH-1:0] ex_rs1v,
    output logic [WIDTH-1:0] ex_rs2v,
    output logic [WIDTH-1:0] ex_imm,
    output logic [4:0]  ex_rs1,
    output logic [4:0]  ex_rs2,
    output logic [4:0]  ex_rd,
    output logic [6:0]  ex_opcode,
    output logic [3:0]  ex_funct4,
    output logic [2:0]  ex_mask,
    output logic [1:0]  ex_regwrmux,
    output logic        ex_reg_write,
    output logic        ex_mem_write
);

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            ex_pc <= {WIDTH{1'b0}};
            ex_rs1v <= {WIDTH{1'b0}};
            ex_rs2v <= {WIDTH{1'b0}};
            ex_imm <= {WIDTH{1'b0}};
            ex_rs1 <= 5'b0;
            ex_rs2 <= 5'b0;
            ex_rd <= 5'b0;
            ex_opcode <= 7'b0;
            ex_funct4 <= 4'b0;
            ex_mask <= 3'b0;
            ex_reg_write <= 1'b0;
            ex_mem_write <= 1'b0;
        end 
        else if (id_flush) begin
            ex_reg_write <= 1'b0;
        end
        else if (!id_stall) begin
            ex_pc        <= id_pc;
            ex_rs1v      <= id_rs1v;
            ex_rs2v      <= id_rs2v;
            ex_imm       <= id_imm;
            ex_rs1       <= id_rs1;
            ex_rs2       <= id_rs2;
            ex_rd        <= id_rd;
            ex_opcode    <= id_opcode;
            ex_funct4    <= id_funct4;
            ex_mask      <= id_mask;
            ex_reg_write <= id_reg_write;
            ex_mem_write <= id_mem_write;
            ex_regwrmux  <= id_regwrmux;
        end
    end
endmodule