module PipeDecode (
    input  logic [31:0] instr,
    output logic [ 4:0] rs1,
    output logic [ 4:0] rs2,
    output logic [ 4:0] rd,
    output logic [ 2:0] funct3,
    output logic [31:0] imm,
    output logic        regWrite,
    output logic        memRead,
    output logic        memWrite,
    output logic        aluSrcA,
    output logic        aluSrcB,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic [ 1:0] wbSel,
    output logic [ 3:0] aluCtrl,
    output logic        uses_rs1,
    output logic        uses_rs2
);
    localparam [6:0] OPCODE_R = 7'b0110011;
    localparam [6:0] OPCODE_I = 7'b0010011;
    localparam [6:0] OPCODE_LOAD = 7'b0000011;
    localparam [6:0] OPCODE_STORE = 7'b0100011;
    localparam [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam [6:0] OPCODE_JALR = 7'b1100111;
    localparam [6:0] OPCODE_JAL = 7'b1101111;
    localparam [6:0] OPCODE_LUI = 7'b0110111;
    localparam [6:0] OPCODE_AUIPC = 7'b0010111;
    localparam [6:0] OPCODE_FENCE = 7'b0001111;
    localparam [6:0] OPCODE_SYSTEM = 7'b1110011;

    localparam [3:0] ALU_ADD = 4'd0;
    localparam [3:0] ALU_SUB = 4'd1;
    localparam [3:0] ALU_SLL = 4'd2;
    localparam [3:0] ALU_SLT = 4'd3;
    localparam [3:0] ALU_SLTU = 4'd4;
    localparam [3:0] ALU_XOR = 4'd5;
    localparam [3:0] ALU_SRL = 4'd6;
    localparam [3:0] ALU_SRA = 4'd7;
    localparam [3:0] ALU_OR = 4'd8;
    localparam [3:0] ALU_AND = 4'd9;

    localparam [1:0] WB_ALU = 2'b00;
    localparam [1:0] WB_LOAD = 2'b01;
    localparam [1:0] WB_PC4 = 2'b10;
    localparam [1:0] WB_IMM = 2'b11;

    logic [6:0] opcode;
    logic [6:0] funct7;

    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign funct3 = instr[14:12];
    assign opcode = instr[6:0];
    assign funct7 = instr[31:25];

    assign imm = (opcode == OPCODE_I || opcode == OPCODE_LOAD || opcode == OPCODE_JALR || opcode == OPCODE_SYSTEM || opcode == OPCODE_FENCE)
        ? {{20{instr[31]}}, instr[31:20]}
        : (opcode == OPCODE_STORE)
        ? {{20{instr[31]}}, instr[31:25], instr[11:7]}
        : (opcode == OPCODE_BRANCH)
        ? {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
        : (opcode == OPCODE_LUI || opcode == OPCODE_AUIPC)
        ? {instr[31:12], 12'b0}
        : (opcode == OPCODE_JAL)
        ? {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}
        : 32'b0;

    always @(*) begin
        regWrite = 1'b0;
        memRead = 1'b0;
        memWrite = 1'b0;
        aluSrcA = 1'b0;
        aluSrcB = 1'b0;
        branch = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;
        wbSel = WB_ALU;
        aluCtrl = ALU_ADD;
        uses_rs1 = 1'b0;
        uses_rs2 = 1'b0;

        case (opcode)
            OPCODE_R: begin
                regWrite = 1'b1;
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
                case (funct3)
                    3'b000:  aluCtrl = funct7[5] ? ALU_SUB : ALU_ADD;
                    3'b001:  aluCtrl = ALU_SLL;
                    3'b010:  aluCtrl = ALU_SLT;
                    3'b011:  aluCtrl = ALU_SLTU;
                    3'b100:  aluCtrl = ALU_XOR;
                    3'b101:  aluCtrl = funct7[5] ? ALU_SRA : ALU_SRL;
                    3'b110:  aluCtrl = ALU_OR;
                    3'b111:  aluCtrl = ALU_AND;
                    default: aluCtrl = ALU_ADD;
                endcase
            end

            OPCODE_I: begin
                regWrite = 1'b1;
                aluSrcB  = 1'b1;
                uses_rs1 = 1'b1;
                case (funct3)
                    3'b000:  aluCtrl = ALU_ADD;
                    3'b010:  aluCtrl = ALU_SLT;
                    3'b011:  aluCtrl = ALU_SLTU;
                    3'b100:  aluCtrl = ALU_XOR;
                    3'b110:  aluCtrl = ALU_OR;
                    3'b111:  aluCtrl = ALU_AND;
                    3'b001:  aluCtrl = ALU_SLL;
                    3'b101:  aluCtrl = funct7[5] ? ALU_SRA : ALU_SRL;
                    default: aluCtrl = ALU_ADD;
                endcase
            end

            OPCODE_LOAD: begin
                regWrite = 1'b1;
                memRead = 1'b1;
                aluSrcB = 1'b1;
                wbSel = WB_LOAD;
                aluCtrl = ALU_ADD;
                uses_rs1 = 1'b1;
            end

            OPCODE_STORE: begin
                memWrite = 1'b1;
                aluSrcB  = 1'b1;
                aluCtrl  = ALU_ADD;
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end

            OPCODE_BRANCH: begin
                branch   = 1'b1;
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
                aluCtrl  = ALU_SUB;
            end

            OPCODE_JAL: begin
                regWrite = 1'b1;
                jal = 1'b1;
                wbSel = WB_PC4;
            end

            OPCODE_JALR: begin
                regWrite = 1'b1;
                jalr = 1'b1;
                wbSel = WB_PC4;
                aluSrcB = 1'b1;
                uses_rs1 = 1'b1;
                aluCtrl = ALU_ADD;
            end

            OPCODE_LUI: begin
                regWrite = 1'b1;
                wbSel = WB_IMM;
            end

            OPCODE_AUIPC: begin
                regWrite = 1'b1;
                aluSrcA = 1'b1;
                aluSrcB = 1'b1;
                aluCtrl = ALU_ADD;
                wbSel = WB_ALU;
            end

            OPCODE_FENCE: begin
                // NOP
            end

            OPCODE_SYSTEM: begin
                // ecall/ebreak treated as NOP
            end

            default: begin
                // Unsupported treated as NOP
            end
        endcase
    end
endmodule
