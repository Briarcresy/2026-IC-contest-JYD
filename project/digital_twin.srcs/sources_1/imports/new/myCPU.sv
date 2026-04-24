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

    logic clk, rst;
    logic [DATAWIDTH-1:0] pc_offset;
    logic [          1:0] NpcOp;
    logic [          1:0] MemToReg_sel;
    logic                 RegWrite;
    logic                 pc_offset_sel;
    logic [DATAWIDTH-1:0] imm;
    // logic [DATAWIDTH-1:0] csr_npc;
    logic                 isTrue;
    logic [          6:0] opcode;
    logic [          3:0] funct;
    logic [DATAWIDTH-1:0] A;
    logic [DATAWIDTH-1:0] din;
    logic [DATAWIDTH-1:0] B;
    // logic [         11:0] csr_idx;
    // logic [          3:0] CSRControll;
    logic ALUSrcA, ALUSrcB;
    logic [DATAWIDTH-1:0] ALU_A, ALU_B;
    logic [         13:0] ALUControl;
    logic [DATAWIDTH-1:0] mdata;
    // logic [DATAWIDTH-1:0] csr_wb;

    logic [DATAWIDTH-1:0] npc;
    logic [DATAWIDTH-1:0] instr;
    logic [DATAWIDTH-1:0] pcadd4;
    logic [DATAWIDTH-1:0] wdata;
    logic [DATAWIDTH-1:0] ALU_result;

    logic                 MemWrite;
    logic [          1:0] mask;
    logic [         31:0] rR2_data;
    logic [         31:0] DRAM_rdata;

    logic [DATAWIDTH-1:0] pc;

    assign irom_addr = pc;
    assign instr = irom_data;

    assign perip_addr = ALU_result;
    assign perip_wen = MemWrite;
    assign perip_mask = mask;
    assign perip_wdata = rR2_data;
    assign DRAM_rdata = perip_rdata;

    assign rR2_data = din;
    assign clk = cpu_clk;
    assign rst = cpu_rst;
    assign mask = funct[1:0];

    PC #(DATAWIDTH, RESET_VAL) pc_inst (
        .clk(clk),
        .rst(rst),
        .npc(npc),
        .pc (pc)
    );

    NPC #(DATAWIDTH) npc_inst (
        .isTrue(isTrue),
        .npc_op(NpcOp),
        .pc    (pc),
        .offset(pc_offset),
        .npc   (npc),
        .pcadd4(pcadd4)
    );

    assign pc_offset = pc_offset_sel ? ALU_result : imm;

    RF #(ADDR_WIDTH, DATAWIDTH) rf_inst (
        .clk     (clk),
        .rst     (rst),
        .wen     (RegWrite),
        .waddr   (instr[11:7]),
        .wdata   (wdata),
        .rR1     (instr[19:15]),
        .rR2     (instr[24:20]),
        .rR1_data(ALU_A),
        .rR2_data(ALU_B)
    );

    assign B = ALUSrcB ? imm : ALU_B;
    assign A = ALUSrcA ? pc : ALU_A;

    Control control_inst (
        .opcode       (opcode),
        // .funct        (funct[2:0]),
        .NpcOp        (NpcOp),
        .RegWrite     (RegWrite),
        .MemToReg_sel (MemToReg_sel),
        .MemWrite     (MemWrite),
        .pc_offset_sel(pc_offset_sel),
        .ALUSrcA      (ALUSrcA),
        .ALUSrcB      (ALUSrcB)
    );

    IMMGEN #(DATAWIDTH) immgen_inst (
        .instr(instr),
        .imm  (imm)
    );

    // CCTL cctl_inst (
    //     .instr      (instr),
    //     .csr_idx    (csr_idx),
    //     .CSRControll(CSRControll)
    // );

    assign opcode = instr[6:0];
    assign funct = {instr[30], instr[14:12]};
    assign din = ALU_B;

    ALU #(DATAWIDTH) alu_inst (
        .A         (A),
        .B         (B),
        .ALUControl(ALUControl),
        .Result    (ALU_result),
        .isTrue    (isTrue)
    );

    ACTL actl_inst (
        .opcode    (opcode),
        .funct     (funct),
        .ALUControl(ALUControl)
    );

    Mask #(DATAWIDTH) mask_inst (
        .mask (instr[14:12]),
        .dout (DRAM_rdata),
        .mdata(mdata)
    );

    // CSR #(DATAWIDTH) csr_inst (
    //     .clk        (clk),
    //     .rst        (rst),
    //     .pc         (pc),
    //     .rf1        (A),
    //     .csr_idx    (csr_idx),
    //     .CSRControll(CSRControll),
    //     .csr_npc    (csr_npc),
    //     .csr_wb     (csr_wb)
    // );

    always_comb begin : RegWriteMux
        case (MemToReg_sel)
            2'b00:   wdata = pcadd4;
            2'b01:   wdata = ALU_result;
            2'b10:   wdata = mdata;
            2'b11:   wdata = imm;
            default: wdata = ALU_result;
        endcase

    end

    // MuxKey #(4, 2, DATAWIDTH) mux_alu (
    //     wdata,
    //     MemToReg_sel,
    //     {2'b00, pcadd4, 2'b01, ALU_result, 2'b10, mdata, 2'b11, imm}
    // );
endmodule

