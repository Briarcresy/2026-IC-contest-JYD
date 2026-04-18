`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/24 10:51:04
// Design Name: 
// Module Name: myCPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module myCPU (
    input logic cpu_rst,
    input logic cpu_clk,

    // Interface to IROM
    output logic [31:0] irom_addr,
    input  logic [31:0] irom_data,

    // Interface to DRAM
    output logic [31:0] perip_addr,
    output logic        perip_wen,
    output logic [ 1:0] perip_mask,
    output logic [31:0] perip_wdata,
    input  logic [31:0] perip_rdata

);
    parameter DATAWIDTH = 32;
    parameter RESET_VAL = 32'h8000_0000;
    parameter ADDR_WIDTH = 5;

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

    logic clk, rst;

    logic [31:0] pcF;
    logic [31:0] pc_next;
    logic [31:0] instrF;

    logic [31:0] pcD;
    logic [31:0] instrD;
    logic [31:0] pc4D;

    logic [31:0] pcE;
    logic [31:0] pc4E;
    logic [31:0] immE;
    logic [31:0] rs1ValE;
    logic [31:0] rs2ValE;
    logic [ 4:0] rs1E;
    logic [ 4:0] rs2E;
    logic [ 4:0] rdE;
    logic [ 3:0] aluCtrlE;
    logic [ 6:0] opcodeE;
    logic [ 3:0] funct4E;
    logic [ 2:0] funct3E;
    logic        regWriteE;
    logic        memReadE;
    logic        memWriteE;
    logic        aluSrcAE;
    logic        aluSrcBE;
    logic        branchE;
    logic        jalE;
    logic        jalrE;
    logic [ 1:0] wbSelE;

    logic [31:0] pc4M;
    logic [31:0] immM;
    logic [31:0] aluResultM;
    logic [31:0] storeDataM;
    logic [ 4:0] rdM;
    logic [ 2:0] funct3M;
    logic        regWriteM;
    logic        memReadM;
    logic        memWriteM;
    logic [ 1:0] wbSelM;

    logic [31:0] pc4W;
    logic [31:0] immW;
    logic [31:0] aluResultW;
    logic [31:0] loadDataW;
    logic [ 4:0] rdW;
    logic [ 2:0] funct3W;
    logic        regWriteW;
    logic [ 1:0] wbSelW;

    logic [ 4:0] rs1D;
    logic [ 4:0] rs2D;
    logic [ 4:0] rdD;
    logic [ 2:0] funct3D;
    logic [ 6:0] opcodeD;
    logic [ 3:0] funct4D;
    logic [31:0] immD;
    logic [31:0] rs1DataD;
    logic [31:0] rs2DataD;

    logic        regWriteD;
    logic        memReadD;
    logic        memWriteD;
    logic        aluSrcAD;
    logic        aluSrcBD;
    logic        branchD;
    logic        jalD;
    logic        jalrD;
    logic [ 1:0] wbSelD;
    logic [ 3:0] aluCtrlD;
    logic        uses_rs1_D;
    logic        uses_rs2_D;

    logic [31:0] wbData;
    logic [31:0] wbDataM;
    logic [31:0] loadExtM;
    logic [31:0] forwardAData;
    logic [31:0] forwardBData;
    logic [31:0] aluOpA;
    logic [31:0] aluOpB;
    logic [31:0] aluResultE;
    logic [13:0] aluControl14E;
    logic        aluIsTrueE;
    logic [31:0] branchTargetE;
    logic [31:0] jumpTargetE;
    logic        branchTakenE;
    logic        redirectE;
    logic [31:0] redirectTargetE;

    logic [31:0] loadExtW;

    logic        stallF;
    logic        stallD;
    logic        flushD;
    logic        flushE;

    assign clk = cpu_clk;
    assign rst = cpu_rst;

    assign instrF = irom_data;
    assign irom_addr = pcF;

    assign perip_addr = aluResultM;
    assign perip_wen = memWriteM;
    assign perip_mask = funct3M[1:0];
    assign perip_wdata = storeDataM;

    assign pc4D = pcD + 32'd4;
    assign opcodeD = instrD[6:0];
    assign funct4D = {instrD[30], instrD[14:12]};

    PipeDecode decode_inst (
        .instr(instrD),
        .rs1(rs1D),
        .rs2(rs2D),
        .rd(rdD),
        .funct3(funct3D),
        .imm(immD),
        .regWrite(regWriteD),
        .memRead(memReadD),
        .memWrite(memWriteD),
        .aluSrcA(aluSrcAD),
        .aluSrcB(aluSrcBD),
        .branch(branchD),
        .jal(jalD),
        .jalr(jalrD),
        .wbSel(wbSelD),
        .aluCtrl(aluCtrlD),
        .uses_rs1(uses_rs1_D),
        .uses_rs2(uses_rs2_D)
    );

    PipeHazard hazard_inst (
        .memReadE(memReadE),
        .rdE(rdE),
        .uses_rs1_D(uses_rs1_D),
        .uses_rs2_D(uses_rs2_D),
        .rs1D(rs1D),
        .rs2D(rs2D),
        .redirectE(redirectE),
        .stallF(stallF),
        .stallD(stallD),
        .flushD(flushD),
        .flushE(flushE)
    );

    PipeForward forward_inst (
        .regWriteM(regWriteM),
        .memReadM(memReadM),
        .rdM(rdM),
        .regWriteW(regWriteW),
        .rdW(rdW),
        .rs1E(rs1E),
        .rs2E(rs2E),
        .rs1ValE(rs1ValE),
        .rs2ValE(rs2ValE),
        .wbDataM(wbDataM),
        .wbData(wbData),
        .forwardAData(forwardAData),
        .forwardBData(forwardBData)
    );

    always @(*) begin
        case (wbSelM)
            WB_ALU:  wbDataM = aluResultM;
            WB_LOAD: wbDataM = loadExtM;
            WB_PC4:  wbDataM = pc4M;
            WB_IMM:  wbDataM = immM;
            default: wbDataM = aluResultM;
        endcase
    end

    assign aluOpA = aluSrcAE ? pcE : forwardAData;
    assign aluOpB = aluSrcBE ? immE : forwardBData;

    ACTL ex_actl_inst (
        .opcode(opcodeE),
        .funct(funct4E),
        .ALUControl(aluControl14E)
    );

    ALU #(DATAWIDTH) ex_alu_inst (
        .A(aluOpA),
        .B(aluOpB),
        .ALUControl(aluControl14E),
        .Result(aluResultE),
        .isTrue(aluIsTrueE)
    );

    assign branchTakenE = aluIsTrueE;

    assign branchTargetE = pcE + immE;
    assign jumpTargetE = jalrE ? ((forwardAData + immE) & 32'hFFFF_FFFE) : (pcE + immE);
    assign redirectE = (branchE && branchTakenE) || jalE || jalrE;
    assign redirectTargetE = (jalE || jalrE) ? jumpTargetE : branchTargetE;

    always @(*) begin
        if (redirectE) begin
            pc_next = redirectTargetE;
        end else if (stallF) begin
            pc_next = pcF;
        end else begin
            pc_next = pcF + 32'd4;
        end
    end

    PipeLoadExt load_ext_inst (
        .funct3  (funct3W),
        .loadData(loadDataW),
        .loadExt (loadExtW)
    );

    PipeLoadExt load_ext_m_inst (
        .funct3  (funct3M),
        .loadData(perip_rdata),
        .loadExt (loadExtM)
    );

    always @(*) begin
        unique case (wbSelW)
            WB_ALU:  wbData = aluResultW;
            WB_LOAD: wbData = loadExtW;
            WB_PC4:  wbData = pc4W;
            WB_IMM:  wbData = immW;
            default: wbData = aluResultW;
        endcase
    end

    RF #(ADDR_WIDTH, DATAWIDTH) rf_inst (
        .clk     (clk),
        .rst     (rst),
        .wen     (regWriteW),
        .waddr   (rdW),
        .wdata   (wbData),
        .rR1     (rs1D),
        .rR2     (rs2D),
        .rR1_data(rs1DataD),
        .rR2_data(rs2DataD)
    );

    PC #(DATAWIDTH, RESET_VAL) pc_inst (
        .clk   (clk),
        .rst   (rst),
        .npc   (pc_next),
        .pc_out(pcF)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pcD <= RESET_VAL;
            instrD <= 32'h0000_0013;
        end else if (!stallD) begin
            if (flushD) begin
                pcD <= RESET_VAL;
                instrD <= 32'h0000_0013;
            end else begin
                pcD <= pcF;
                instrD <= instrF;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst || flushE) begin
            pcE <= 32'b0;
            pc4E <= 32'b0;
            immE <= 32'b0;
            rs1ValE <= 32'b0;
            rs2ValE <= 32'b0;
            rs1E <= 5'b0;
            rs2E <= 5'b0;
            rdE <= 5'b0;
            aluCtrlE <= ALU_ADD;
            opcodeE <= 7'b0;
            funct4E <= 4'b0;
            funct3E <= 3'b0;
            regWriteE <= 1'b0;
            memReadE <= 1'b0;
            memWriteE <= 1'b0;
            aluSrcAE <= 1'b0;
            aluSrcBE <= 1'b0;
            branchE <= 1'b0;
            jalE <= 1'b0;
            jalrE <= 1'b0;
            wbSelE <= WB_ALU;
        end else begin
            pcE <= pcD;
            pc4E <= pc4D;
            immE <= immD;
            rs1ValE <= rs1DataD;
            rs2ValE <= rs2DataD;
            rs1E <= rs1D;
            rs2E <= rs2D;
            rdE <= rdD;
            aluCtrlE <= aluCtrlD;
            opcodeE <= opcodeD;
            funct4E <= funct4D;
            funct3E <= funct3D;
            regWriteE <= regWriteD;
            memReadE <= memReadD;
            memWriteE <= memWriteD;
            aluSrcAE <= aluSrcAD;
            aluSrcBE <= aluSrcBD;
            branchE <= branchD;
            jalE <= jalD;
            jalrE <= jalrD;
            wbSelE <= wbSelD;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc4M <= 32'b0;
            immM <= 32'b0;
            aluResultM <= 32'b0;
            storeDataM <= 32'b0;
            rdM <= 5'b0;
            funct3M <= 3'b0;
            regWriteM <= 1'b0;
            memReadM <= 1'b0;
            memWriteM <= 1'b0;
            wbSelM <= WB_ALU;
        end else begin
            pc4M <= pc4E;
            immM <= immE;
            aluResultM <= aluResultE;
            storeDataM <= forwardBData;
            rdM <= rdE;
            funct3M <= funct3E;
            regWriteM <= regWriteE;
            memReadM <= memReadE;
            memWriteM <= memWriteE;
            wbSelM <= wbSelE;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc4W <= 32'b0;
            immW <= 32'b0;
            aluResultW <= 32'b0;
            loadDataW <= 32'b0;
            rdW <= 5'b0;
            funct3W <= 3'b0;
            regWriteW <= 1'b0;
            wbSelW <= WB_ALU;
        end else begin
            pc4W <= pc4M;
            immW <= immM;
            aluResultW <= aluResultM;
            loadDataW <= perip_rdata;
            rdW <= rdM;
            funct3W <= funct3M;
            regWriteW <= regWriteM;
            wbSelW <= wbSelM;
        end
    end
endmodule

