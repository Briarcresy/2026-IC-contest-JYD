`timescale 1ns / 1ps
`include "defines.sv"
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

`ifdef ENABLE_DEBUG_TRACE
    input  logic [31:0] perip_rdata,
    output wire         debug_wb_have_inst,
    output wire  [31:0] debug_wb_pc,
    output wire         debug_wb_ena,
    output wire  [ 4:0] debug_wb_reg,
    output wire  [31:0] debug_wb_value
`else
    input  logic [31:0] perip_rdata
`endif
);
    parameter DATAWIDTH = 32;
`ifdef ENABLE_DEBUG_TRACE
    parameter RESET_VAL = 32'h0000_0000;
`else
    parameter RESET_VAL = 32'h8000_0000;
`endif
    parameter ADDR_WIDTH = 5;

    logic clk, rst;
    logic [DATAWIDTH-1:0] pc_offset;
    // logic [          1:0] NpcOp;
    // logic [          1:0] MemToReg;
    // logic                 RegWrite;
    // logic                 pc_offset_sel;
    // logic [DATAWIDTH-1:0] imm;
    // logic [DATAWIDTH-1:0] csr_npc;
    logic                 isTrue;
    logic [          6:0] opcode;
    logic [          3:0] funct;
    logic [DATAWIDTH-1:0] A;
    // logic [DATAWIDTH-1:0] din;
    logic [DATAWIDTH-1:0] B;
    // logic [         11:0] csr_idx;
    // logic [          3:0] CSRControll;
    // logic ALUSrcA, ALUSrcB;
    logic [         13:0] ALUControl;
    logic [DATAWIDTH-1:0] mdata;
    // logic [DATAWIDTH-1:0] csr_wb;

    logic [DATAWIDTH-1:0] npc;
    // logic [DATAWIDTH-1:0] instr;
    logic [DATAWIDTH-1:0] pcadd4;
    logic [DATAWIDTH-1:0] wdata;
    // logic [DATAWIDTH-1:0] ALU_result;

    // logic                 MemWrite;
    // logic [          1:0] mask;
    // logic [         31:0] rR2_data;
    logic [         31:0] DRAM_rdata;

    logic [DATAWIDTH-1:0] pc;

    assign irom_addr = pc;
    // assign instr = irom_data;

    // assign perip_addr = Result;
    // assign perip_wen = MemWrite;
    // assign perip_mask = mask;
    // assign perip_wdata = rR2_data;
    assign DRAM_rdata = perip_rdata;

    // assign rR2_data = din;
    // assign Result = daddr;
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
    logic [DATAWIDTH-1:0] if_post_pc4;
    logic [DATAWIDTH-1:0] if_post_instruction;
    assign if_post_instruction = irom_data;
    assign if_post_pc          = irom_addr;
    assign if_post_pc4         = pcadd4;

    logic [DATAWIDTH-1:0] id_thru_pc4;
    logic [DATAWIDTH-1:0] id_thru_pc;
    logic [DATAWIDTH-1:0] id_pre_instruction;

    logic [          2:0] id_post_mask;
    logic [          4:0] id_post_rs1;
    logic [          4:0] id_post_rs2;
    logic [          4:0] id_post_rd;
    logic                 id_post_memwrite;
    logic                 id_post_regwrite;
    logic [DATAWIDTH-1:0] id_post_rs1v;
    logic [DATAWIDTH-1:0] id_post_rs2v;
    logic [DATAWIDTH-1:0] id_post_imm;
    logic [          1:0] id_post_npc_op;
    logic [          1:0] id_post_regwrmux;
    logic [          1:0] id_post_alusrcA;
    logic [          1:0] id_post_alusrcB;
    logic                 id_post_pc_offset_sel;
    assign id_post_mask = funct[2:0];
    assign id_post_rs1  = id_pre_instruction[19:15];  // for forwarding
    assign id_post_rs2  = id_pre_instruction[24:20];  // for forwarding
    assign id_post_rd   = id_pre_instruction[11:7];  // save reg-write-target
    //logic []
    //logic

    logic [DATAWIDTH-1:0] ex_pre_pc;
    logic [          2:0] ex_thru_mask;
    logic [          4:0] ex_pre_rs1;  // for forwarding
    logic [          4:0] ex_pre_rs2;  // for forwarding
    logic [DATAWIDTH-1:0] ex_pre_rs1v;
    logic [          6:0] ex_pre_opcode;
    logic [          3:0] ex_pre_funct4;
    logic [          1:0] ex_pre_alusrcA;
    logic [          1:0] ex_pre_alusrcB;
    logic [DATAWIDTH-1:0] ex_pre_rs2v;
    logic                 ex_pre_pc_offset_sel;
    logic [DATAWIDTH-1:0] ex_thru_imm;
    logic [DATAWIDTH-1:0] ex_thru_pc4;
    logic [          1:0] ex_thru_npc_op;
    logic [          4:0] ex_thru_rd;
    logic                 ex_thru_memwrite;
    logic                 ex_thru_regwrite;
    logic [          1:0] ex_thru_regwrmux;
    logic [DATAWIDTH-1:0] ex_post_result;
    logic [DATAWIDTH-1:0] ex_post_rs2v;
    logic [          1:0] ex_post_mask_memread;
    assign ex_post_mask_memread = ex_pre_funct4[1:0];

    logic [DATAWIDTH-1:0] mem_pre_rs2v;
    logic [          1:0] mem_pre_npc_op;
    logic                 mem_pre_memwrite;
    logic [DATAWIDTH-1:0] mem_pre_result;
    logic [DATAWIDTH-1:0] mem_pre_imm;
    logic [DATAWIDTH-1:0] mem_pre_pc4;
    logic [          1:0] mem_pre_mask_memread;
    logic [          4:0] mem_thru_rd;
    logic [          2:0] mem_thru_mask;
    logic [          1:0] mem_thru_regwrmux;
    logic                 mem_thru_regwrite;
    logic [DATAWIDTH-1:0] mem_post_result_mem_mux;
    assign perip_wdata = mem_pre_rs2v;
    assign perip_addr  = mem_pre_result;
    assign perip_wen   = mem_pre_memwrite;
    assign perip_mask  = mem_pre_mask_memread;

    logic [          4:0] wb_pre_rd;
    logic [          2:0] wb_pre_mask;
    logic                 wb_pre_regwrite;
    logic [DATAWIDTH-1:0] wb_pre_result_mem_mux;
    logic [DATAWIDTH-1:0] wb_pre_dram_rdata;
    logic [          1:0] wb_pre_regwrmux;

    logic                 pipeline_stall;
    logic                 pipeline_flush;

`ifdef ENABLE_DEBUG_TRACE
    logic [DATAWIDTH-1:0] _D_wb_pre_pc4;
`endif

    register_if_id #(DATAWIDTH) if_id (
        .clk(clk),
        .rst(rst),
        .stall(pipeline_stall),
        .flush(pipeline_flush),
        .if_pc(if_post_pc),
        .if_pc4(if_post_pc4),
        .if_instr(if_post_instruction),
        .id_pc(id_thru_pc),
        .id_pc4(id_thru_pc4),
        .id_instr(id_pre_instruction)
    );

    register_id_ex #(DATAWIDTH) id_ex (
        .clk(clk),
        .rst(rst),
        .id_stall(pipeline_stall),
        .id_flush(pipeline_flush),
        .id_pc(id_thru_pc),
        .id_pc4(id_thru_pc4),
        .id_rs1v(id_post_rs1v),
        .id_rs2v(id_post_rs2v),
        .id_imm(id_post_imm),
        .id_rs1(id_post_rs1),
        .id_rs2(id_post_rs2),
        .id_rd(id_post_rd),
        .id_opcode(id_pre_instruction[6:0]),
        .id_funct4(funct),
        .id_mask(id_post_mask),
        .id_regwrmux(id_post_regwrmux),
        .id_npcop(id_post_npc_op),
        .id_alusrcA(id_post_alusrcA),
        .id_alusrcB(id_post_alusrcB),
        .id_reg_write(id_post_regwrite),
        .id_mem_write(id_post_memwrite),
        .id_pc_offset_sel(id_post_pc_offset_sel),
        .ex_pc(ex_pre_pc),
        .ex_pc4(ex_thru_pc4),
        .ex_rs1v(ex_pre_rs1v),
        .ex_rs2v(ex_pre_rs2v),
        .ex_imm(ex_thru_imm),
        .ex_rs1(ex_pre_rs1),
        .ex_rs2(ex_pre_rs2),
        .ex_rd(ex_thru_rd),
        .ex_opcode(ex_pre_opcode),
        .ex_funct4(ex_pre_funct4),
        .ex_mask(ex_thru_mask),
        .ex_regwrmux(ex_thru_regwrmux),
        .ex_npcop(ex_thru_npc_op),
        .ex_alusrcA(ex_pre_alusrcA),
        .ex_alusrcB(ex_pre_alusrcB),
        .ex_reg_write(ex_thru_regwrite),
        .ex_mem_write(ex_thru_memwrite),
        .ex_pc_offset_sel(ex_pre_pc_offset_sel)
    );

    register_ex_mem #(DATAWIDTH) ex_mem (
        .clk(clk),
        .rst(rst),
        .stall(0),
        .flush(0),
        .ex_alu_result(ex_post_result),
        .ex_rs2_val(ex_post_rs2v),
        .ex_imm(ex_thru_imm),
        .ex_pc4(ex_thru_pc4),
        .ex_rd_addr(ex_thru_rd),
        .ex_mask(ex_thru_mask),
        .ex_npc_op(ex_thru_npc_op),
        .ex_regwrmux(ex_thru_regwrmux),
        .ex_reg_write(ex_thru_regwrite),
        .ex_mem_write(ex_thru_memwrite),
        .ex_mask_memread(ex_post_mask_memread),
        .mem_alu_result(mem_pre_result),
        .mem_rs2_val(mem_pre_rs2v),
        .mem_imm(mem_pre_imm),
        .mem_pc4(mem_pre_pc4),
        .mem_rd_addr(mem_thru_rd),
        .mem_mask(mem_thru_mask),
        .mem_npc_op(mem_pre_npc_op),
        .mem_regwrmux(mem_thru_regwrmux),
        .mem_reg_write(mem_thru_regwrite),
        .mem_mem_write(mem_pre_memwrite),
        .mem_mask_memread(mem_pre_mask_memread)
    );

    register_mem_wb #() mem_wb (
`ifdef ENABLE_DEBUG_TRACE
        .mem_pc4(mem_pre_pc4),
        .wb_pc4(_D_wb_pre_pc4),
`endif
        .clk(clk),
        .rst(rst),
        .stall(0),
        .flush(0),
        .mem_alu_result(mem_post_result_mem_mux),
        .mem_mdata(DRAM_rdata),
        .mem_rd_addr(mem_thru_rd),
        .mem_mask(mem_thru_mask),
        .mem_regwrmux(mem_thru_regwrmux),
        .mem_reg_write(mem_thru_regwrite),
        .wb_alu_result(wb_pre_result_mem_mux),
        .wb_mdata(wb_pre_dram_rdata),
        .wb_rd_addr(wb_pre_rd),
        .wb_mask(wb_pre_mask),
        .wb_regwrmux(wb_pre_regwrmux),
        .wb_reg_write(wb_pre_regwrite)
    );

    // MuxKey => ex_mux + mem_mux

    ex_mux #(DATAWIDTH) mem_mux_instance (
        .pcadd4(mem_pre_pc4),
        .imm(mem_pre_imm),
        .alu(mem_pre_result),
        .alu_mux(mem_thru_regwrmux),
        .result(mem_post_result_mem_mux)
    );

    mem_mux #(DATAWIDTH) wb_mux_instance (
        .ex_mux (wb_pre_result_mem_mux),
        .mdata  (mdata),
        .alu_mux(wb_pre_regwrmux),
        .result (wdata)
    );

    logic alu_a_forward_sel;
    logic alu_a_forward_require;
    logic alu_b_forward_sel;
    logic alu_b_forward_require;

    forwarding_unit forwarding_unit_instance (
        .rd1(mem_thru_rd),
        .rd1_we(mem_thru_regwrite),
        .rd2(wb_pre_rd),
        .rd2_we(wb_pre_regwrite),
        .rs1(ex_pre_rs1),
        .rs2(ex_pre_rs2),
        .rs1_needed(!ex_pre_alusrcA),
        .rs2_needed(!ex_pre_alusrcB),
        .rs1_forward_sel(alu_a_forward_sel),
        .rs1_forward_require(alu_a_forward_require),
        .rs2_forward_sel(alu_b_forward_sel),
        .rs2_forward_require(alu_b_forward_require)
    );

    // TODO: Temp Solution
    // alu-a, alu-b requires forwarding
    // rs2v also needs forwarding
    // this is for save instructions
    // sw rs2, imm(rs1)
    // here imm+rs1 goes ALU path
    // rs2 & rs2v goes a special rs2v path.
    always_comb begin
        if (ex_pre_rs2 == 5'b0) begin
            assign ex_post_rs2v = 32'b0;
        end else if (ex_pre_rs2 == mem_thru_rd && mem_thru_regwrite) begin
            assign ex_post_rs2v = mem_post_result_mem_mux;
        end else if (ex_pre_rs2 == wb_pre_rd && wb_pre_regwrite) begin
            assign ex_post_rs2v = wdata;
        end else begin
            assign ex_post_rs2v = ex_pre_rs2v;
        end
    end
    // END: Temp Solution

    hazard_detection_unit hazard_detection_unit_instance (
        .npcop(ex_thru_npc_op),
        .alu_is_true(isTrue),
        .regwrmux(ex_thru_regwrmux),
        .reg_write(ex_thru_regwrite),
        .rd(ex_thru_rd),
        .rs1(id_post_rs1),
        .rs2(id_post_rs2),
        .trigger_stall(pipeline_stall),
        .trigger_flush(pipeline_flush)
    );

    // pipilines END

    PC #(DATAWIDTH, RESET_VAL) pc_inst (
        .clk(clk),
        .rst(rst),
        .npc(npc),
        .pc (pc)
    );

    NPC #(DATAWIDTH) npc_inst (
        .isTrue         (isTrue),
        .npc_op         (ex_thru_npc_op),
        .pc             (pc),
        .offset         (pc_offset),
        .pc_add_offset  (ex_pre_pc + pc_offset),
        .pcadd4_pipeline(ex_thru_pc4),
        .npc            (npc),
        .pcadd4         (pcadd4)
    );

    assign pc_offset = ex_pre_pc_offset_sel ? ex_post_result : ex_thru_imm;

    RF #(ADDR_WIDTH, DATAWIDTH) rf_inst (
        .clk     (clk),
        .rst     (rst),
        .wen     (wb_pre_regwrite),
        .waddr   (wb_pre_rd),
        .wdata   (wdata),
        .rR1     (id_pre_instruction[19:15]),
        .rR2     (id_pre_instruction[24:20]),
        .rR1_data(id_post_rs1v),
        .rR2_data(id_post_rs2v)
    );

    ALU_src alu_a (
        .alu_src        (ex_pre_alusrcA),
        .forward_src    (alu_a_forward_sel),
        .forward_require(alu_a_forward_require),
        .alusrc0        (ex_pre_rs1v),
        .alusrc1        (ex_pre_pc),
        .fwdsrc0        (mem_post_result_mem_mux),
        .fwdsrc1        (wdata),
        .result         (A)
    );

    ALU_src alu_b (
        .alu_src        (ex_pre_alusrcB),
        .forward_src    (alu_b_forward_sel),
        .forward_require(alu_b_forward_require),
        .alusrc0        (ex_pre_rs2v),
        .alusrc1        (ex_thru_imm),
        .fwdsrc0        (mem_post_result_mem_mux),
        .fwdsrc1        (wdata),
        .result         (B)
    );

    // assign B = ALUSrcB ? ex_thru_imm : ex_pre_rs2v;
    // assign A = ALUSrcA ? ex_pre_pc : ex_pre_rs1v;

    Control control_inst (
        .opcode       (opcode),
        // .funct       (funct[2:0]),
        .NpcOp        (id_post_npc_op),
        .RegWrite     (id_post_regwrite),
        .MemToReg_sel (id_post_regwrmux),
        .MemWrite     (id_post_memwrite),
        .pc_offset_sel(id_post_pc_offset_sel),
        .ALUSrcA      (id_post_alusrcA),
        .ALUSrcB      (id_post_alusrcB)
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
        .Result    (ex_post_result),
        .isTrue    (isTrue)
    );

    ACTL actl_inst (
        .opcode    (ex_pre_opcode),
        .funct     (ex_pre_funct4),
        .ALUControl(ALUControl)
    );

    Mask #(DATAWIDTH) mask_inst (
        .mask (wb_pre_mask),
        .dout (wb_pre_dram_rdata),
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

`ifdef ENABLE_DEBUG_TRACE
    always_comb begin
        logic [31:0] breakpoint;
        logic [31:0] wbpc;
        logic cond;
        assign wbpc = _D_wb_pre_pc4 - 32'h4;
        assign breakpoint = 32'h181;

        assign cond = breakpoint == wbpc;
        if (cond == 1'b0) begin
            assign debug_wb_have_inst = _D_wb_pre_pc4 != 32'b0;
            assign debug_wb_pc = wbpc;
            assign debug_wb_ena = wb_pre_regwrite;
            assign debug_wb_reg = wb_pre_rd;
            assign debug_wb_value = wdata;
        end else begin
            assign debug_wb_have_inst = 1;
            assign debug_wb_pc = 32'h114514;
            assign debug_wb_ena = 0;
            assign debug_wb_reg = wb_pre_regwrmux;
            assign debug_wb_value = wdata;
        end
    end
`endif
endmodule

