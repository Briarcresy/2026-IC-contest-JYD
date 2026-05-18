`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2025 11:42:01 AM
// Design Name: 
// Module Name: dram_driver
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


module dram_driver (
    input logic clk,

    input  logic [17:0] perip_addr,
    input  logic [31:0] perip_wdata,
    input  logic [ 1:0] perip_mask,
    input  logic        dram_wen,
    output logic [31:0] perip_rdata
);
    logic [15:0] dram_addr;
    logic [ 1:0] offset;
    logic [ 3:0] dram_we;
    logic [31:0] dram_wdata, dram_rdata_raw, dout;

    assign dram_addr = perip_addr[17:2];
    assign offset = perip_addr[1:0];
    assign perip_rdata = dout;

    blk_mem_DRAM Mem_DRAM (
        .clka (clk),
        .ena  (1'b1),
        .wea  (dram_we),
        .addra(dram_addr),
        .dina (dram_wdata),
        .douta(dram_rdata_raw)
    );

    // dram_rdata_raw process, lh lb
    always_comb begin
        dout = 0;
        case (perip_mask)
            2'b00:  // lb/lbu
            case (offset)
                2'b00: dout = {24'b0, dram_rdata_raw[7:0]};
                2'b01: dout = {24'b0, dram_rdata_raw[15:8]};
                2'b10: dout = {24'b0, dram_rdata_raw[23:16]};
                2'b11: dout = {24'b0, dram_rdata_raw[31:24]};
            endcase
            2'b01:  // lh/lhu
            case (offset[1])
                1'b0: dout = {16'b0, dram_rdata_raw[15:0]};
                1'b1: dout = {16'b0, dram_rdata_raw[31:16]};
            endcase
            2'b10: dout = dram_rdata_raw;
            default: dout = 0;
        endcase
    end

    // Native BRAM byte write enables avoid read-modify-write on stores.
    always_comb begin
        dram_we = 4'b0000;
        dram_wdata = 32'b0;

        case (perip_mask)
            2'b10: begin  // sw
                dram_we = {4{dram_wen}};
                dram_wdata = perip_wdata;
            end
            2'b01: begin  // sh
                dram_wdata = offset[1] ? {perip_wdata[15:0], 16'b0} :
                                        {16'b0, perip_wdata[15:0]};
                case (offset[1])
                    1'b0: dram_we = dram_wen ? 4'b0011 : 4'b0000;
                    1'b1: dram_we = dram_wen ? 4'b1100 : 4'b0000;
                endcase
            end
            2'b00: begin  // sb
                dram_wdata = {4{perip_wdata[7:0]}};
                case (offset)
                    2'b00: dram_we = dram_wen ? 4'b0001 : 4'b0000;
                    2'b01: dram_we = dram_wen ? 4'b0010 : 4'b0000;
                    2'b10: dram_we = dram_wen ? 4'b0100 : 4'b0000;
                    2'b11: dram_we = dram_wen ? 4'b1000 : 4'b0000;
                endcase
            end
            default: begin
                dram_we = 4'b0000;
                dram_wdata = perip_wdata;
            end
        endcase
    end
endmodule
