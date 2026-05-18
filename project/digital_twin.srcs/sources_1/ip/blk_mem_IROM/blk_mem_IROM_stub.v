// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Tue May 19 00:13:26 2026
// Host        : briarcresy-ThinkPad-P1-Gen-7 running 64-bit Ubuntu 24.04.4 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/briarcresy/2026_IC_contest/2026-IC-contest-JYD/project/digital_twin.srcs/sources_1/ip/blk_mem_IROM/blk_mem_IROM_stub.v
// Design      : blk_mem_IROM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *)
module blk_mem_IROM(clka, ena, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="ena,addra[11:0],douta[31:0]" */
/* synthesis syn_force_seq_prim="clka" */;
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [11:0]addra;
  output [31:0]douta;
endmodule
