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
    // logic [          1:0] MemToReg;
    logic                 RegWrite;
    logic                 pc_offset_sel;
    logic [DATAWIDTH-1:0] imm;
    // logic [DATAWIDTH-1:0] csr_npc;
    logic                 isTrue;
    logic [          6:0] opcode;
    logic [          3:0] funct;
    logic [DATAWIDTH-1:0] A;
    // logic [DATAWIDTH-1:0] din;
    logic [DATAWIDTH-1:0] B;
    // logic [         11:0] csr_idx;
    // logic [          3:0] CSRControll;
    logic ALUSrcA, ALUSrcB;
    logic [         13:0] ALUControl;
    logic [DATAWIDTH-1:0] mdata;
    // logic [DATAWIDTH-1:0] csr_wb;

    logic [DATAWIDTH-1:0] npc;
    logic [DATAWIDTH-1:0] instr;
    logic [DATAWIDTH-1:0] pcadd4;
    logic [DATAWIDTH-1:0] wdata;
    logic [DATAWIDTH-1:0] ALU_result;

    logic                 MemWrite;
    // logic [          1:0] mask;
    // logic [         31:0] rR2_data;
    logic [         31:0] DRAM_rdata;

    logic [DATAWIDTH-1:0] pc;

    assign irom_addr = pc;
    assign instr = irom_data;

    // assign perip_addr = Result;
    // assign perip_wen = MemWrite;
    // assign perip_mask = mask;
    // assign perip_wdata = rR2_data;
    assign DRAM_rdata = perip_rdata;

    // assign rR2_data = din;
    assign Result = daddr;
    assign clk = cpu_clk;
    assign rst = cpu_rst;
    // assign mask = funct[1:0];

    // pipelines BEGIN
    // <stage>_<pre/post/thru>_<function>
    // pre: at the beginning of the stage (read from pipeline-register)
    // post: at the end of the stage (to write to pipeline-register)
    // thru: passed directly from pre to post

    // TODO: not finished yet
    logic [DATAWIDTH-1:0] if_post_pc;
    logic [DATAWIDTH-1:0] if_post_instruction;
    assign if_post_instruction = irom_data;
    assign if_post_pc          = irom_addr;

    logic [DATAWIDTH-1:0] id_thru_pc;
    logic [DATAWIDTH-1:0] id_pre_instruction;

    logic [          2:0] id_post_mask;
    assign id_post_mask = funct[2:0];
    logic [4:0] id_post_rs1;
    assign id_post_rs1 = id_pre_instruction[19:15];  // for forwarding
    logic [4:0] id_post_rs2;
    assign id_post_rs2 = id_pre_instruction[24:20];  // for forwarding
    logic [4:0] id_post_rd;
    assign id_post_rd = id_pre_instruction[11:7];  // save reg-write-target
    logic                 id_post_memwrite;
    logic                 id_post_regwrite;
    logic [DATAWIDTH-1:0] id_post_rs1v;
    logic [DATAWIDTH-1:0] id_post_rs2v;
    logic [DATAWIDTH-1:0] id_post_imm;
    logic [          1:0] id_post_npc_op;
    logic [          1:0] id_post_regwrmux;
    //logic []
    //logic

    logic [DATAWIDTH-1:0] ex_pre_pc;
    logic [          2:0] ex_thru_mask;
    logic [          4:0] ex_pre_rs1;  // for forwarding
    logic [          4:0] ex_pre_rs2;  // for forwarding
    logic [DATAWIDTH-1:0] ex_pre_rs1v;
    logic [DATAWIDTH-1:0] ex_pre_imm;
    logic [          7:0] ex_pre_opcode;
    logic [          3:0] ex_pre_funct4;
    logic [DATAWIDTH-1:0] ex_thru_rs2v;
    logic [          1:0] ex_thru_npc_op;
    logic [          4:0] ex_thru_rd;
    logic                 ex_thru_memwrite;
    logic                 ex_thru_regwrite;
    logic [          1:0] ex_thru_regwrmux;
    logic [DATAWIDTH-1:0] ex_post_result_ex_mux;

    logic [DATAWIDTH-1:0] mem_pre_rs2v;
    logic [          1:0] mem_pre_npc_op;
    logic                 mem_pre_memwrite;
    logic [DATAWIDTH-1:0] mem_pre_result_ex_mux;
    logic [          1:0] mem_pre_regwrmux;
    logic [          4:0] mem_thru_rd;
    logic [          2:0] mem_thru_mask;
    logic                 mem_thru_regwrite;
    logic [DATAWIDTH-1:0] mem_post_result_mem_mux;

    logic [          4:0] wb_pre_rd;
    logic [          2:0] wb_pre_mask;
    logic                 wb_pre_regwrite;
    logic [DATAWIDTH-1:0] wb_pre_wdata;

    assign perip_wdata = mem_pre_rs2v;
    assign perip_addr  = mem_pre_result_ex_mux;
    assign perip_wen   = mem_pre_memwrite;

    logic pipeline_stall;
    logic pipeline_flush;

    register_if_id #(DATAWIDTH) if_id (
        .clock(clk),
        .reset(rst),
        .stall(pipeline_stall),
        .flush(pipeline_flush),
        .if_pc(if_post_pc),
        .if_instr(if_post_instruction),
        .id_pc(id_thru_pc),
        .id_instr(id_pre_instruction)
    );
    register_id_ex #(DATAWIDTH) id_ex (
        .clock(clk),
        .reset(rst),
        .id_stall(pipeline_stall),
        .id_flush(pipeline_flush),
        .id_pc(id_thru_pc),
        .id_rs1v(id_post_rs1v),
        .id_rs2v(id_post_rs2v),
        .id_imm(id_post_imm),
        .id_rs1(id_post_rs1),
        .id_rs2(id_post_rs2),
        .id_rd(id_post_rd),
        .id_opcode(id_pre_instruction[6:0]),
        .id_funct4({id_pre_instruction[30], id_pre_instruction[14:12]}),
        .id_mask(id_post_mask),
        .id_regwrmux(id_post_regwrmux),
        .id_reg_write(id_post_regwrite),
        .id_mem_write(id_post_memwrite),
        .ex_pc(ex_pre_pc),
        .ex_rs1v(ex_pre_rs1v),
        .ex_rs2v(ex_thru_rs2v),
        .ex_imm(ex_pre_imm),
        .ex_rs1(ex_pre_rs1),
        .ex_rs2(ex_pre_rs2),
        .ex_rd(ex_thru_rd),
        .ex_opcode(ex_pre_opcode),
        .ex_funct4(ex_pre_funct4),
        .ex_mask(ex_thru_mask),
        .ex_regwrmux(ex_thru_regwrmux),
        .ex_reg_write(ex_thru_regwrite),
        .ex_mem_write(ex_thru_memwrite)
    );
    register_ex_mem #(DATAWIDTH) ex_mem (
        .clock(clk),
        .reset(rst),
        .stall(pipeline_stall),
        .flush(pipeline_flush),
        .ex_alu_result(ex_post_result_ex_mux),
        .ex_rs2_val(ex_thru_rs2v),
        .ex_rd_addr(ex_thru_rd),
        .ex_mask(ex_thru_mask),
        .ex_npc_op(ex_thru_npc_op),
        .ex_reg_write(ex_thru_regwrite),
        .ex_mem_write(ex_thru_memwrite),
        .ex_mem_to_reg(ex_thru_regwrmux),
        .mem_alu_result(mem_pre_result_ex_mux),
        .mem_rs2_val(mem_pre_rs2v),
        .mem_rd_addr(mem_thru_rd),
        .mem_mask(mem_thru_mask),
        .mem_npc_op(mem_pre_npc_op),
        .mem_reg_write(mem_thru_regwrite),
        .mem_mem_write(mem_pre_memwrite),
        .mem_mem_to_reg(mem_pre_regwrmux)
    );

    register_mem_wb #() mem_wb (
        .clock(clk),
        .reset(rst),
        .stall(pipeline_stall),
        .flush(pipeline_flush),
        .mem_alu_result(mem_post_result_mem_mux),
        .mem_rd_addr(mem_thru_rd),
        .mem_mask(mem_thru_mask),
        .mem_reg_write(mem_thru_regwrite),
        .wb_alu_result(wb_pre_wdata),
        .wb_rd_addr(wb_pre_rd),
        .wb_mask(wb_pre_mask),
        .wb_reg_write(wb_pre_regwrite)
    );

    // MuxKey => ex_mux + mem_mux

    ex_mux #(DATAWIDTH) ex_mux_instance (
        .imm(ex_pre_imm),
        .alu(daddr),
        .alu_mux(ex_thru_memwrite),
        .result(ex_post_result_ex_mux),
        .trigger_stall(pipeline_stall)  // TODO: pipeline_stall has other conditions
    );

    mem_mux #(DATAWIDTH) mem_mux_instance (
        .ex_mux(alu_mux_result),
        .pc_add_4(pcadd4),
        .mdata(mdata),
        .alu_mux(mem_pre_regwrmux),
        .result(wdata)
    );

    // pipilines END

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

    assign offset = OffsetOrigin ? Result : ex_pre_imm;

    RF #(ADDR_WIDTH, DATAWIDTH) rf_inst (
        .clk     (clk),
        .rst     (rst),
        .wen     (wb_pre_regwrite),
        .waddr   (wb_pre_rd),
        .wdata   (wb_pre_wdata),
        .rR1     (id_pre_instruction[19:15]),
        .rR2     (id_pre_instruction[24:20]),
        .rR1_data(id_post_rs1v),
        .rR2_data(id_post_rs2v)
    );

    assign B = ALUSrcB ? ex_pre_imm : ex_thru_rs2v;
    assign A = ALUSrcA ? ex_pre_pc : ex_pre_rs1v;

    Control control_inst (
        .opcode       (opcode),
        // .funct       (funct[2:0]),
        .NpcOp        (id_post_npc_op),
        .RegWrite     (id_post_memwrite),
        .MemToReg_sel (id_post_regwrmux),
        .MemWrite     (id_post_memwrite),
        .pc_offset_sel(OffsetOrigin),
        .ALUSrcA      (ALUSrcA),
        .ALUSrcB      (ALUSrcB)
    );

    IMMGEN #(DATAWIDTH) immgen_inst (
        .instr(id_pre_instruction),
        .imm  (id_post_imm)
    );

    // CCTL cctl_inst (
    //     .instr      (instr),
    //     .csr_idx    (csr_idx),
    //     .CSRControll(CSRControll)
    // );

    assign opcode = id_pre_instruction[6:0];
    assign funct  = {id_pre_instruction[30], id_pre_instruction[14:12]};
    // assign din = ALU_B;

    ALU #(DATAWIDTH) alu_inst (
        .A         (A),
        .B         (B),
        .ALUControl(ALUControl),
        .Result    (ALU_result),
        .isTrue    (isTrue)
    );

    ACTL actl_inst (
        .opcode    (ex_pre_opcode),
        .funct     (ex_pre_funct4),
        .ALUControl(ALUControl)
    );

    Mask #(DATAWIDTH) mask_inst (
        .mask (wb_pre_mask),
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

    // MuxKey #(4, 2, DATAWIDTH) mux_alu (
    //     wdata,
    //     MemToReg,
    //     {2'b00, pcadd4, 2'b01, daddr, 2'b10, mdata, 2'b11, imm}
    // );

endmodule

