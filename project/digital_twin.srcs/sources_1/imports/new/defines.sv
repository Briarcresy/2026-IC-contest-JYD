//`define RUN_TRACE

`define R_TYPE   7'b011_0011
`define I_TYPE   7'b001_0011
`define IL_TYPE  7'b000_0011 // I lw
`define IJ_TYPE  7'b110_0111 // I jalr
`define S_TYPE   7'b010_0011
`define B_TYPE   7'b110_0011
`define U_TYPE   7'b011_0111 // U lui
`define UA_TYPE  7'b001_0111 // U auipc
`define J_TYPE   7'b110_1111
`define CSR_TYPE 7'b111_0011 // CSR

`define OPCODE_LEN 7