module MEM_WB #(
    parameter DATAWIDTH = 32
) (
    input logic clk,
    input logic rst,

    input  logic [DATAWIDTH - 1:0] pcadd4_in,
    output logic [DATAWIDTH - 1:0] pcadd4_out,

    input  logic [DATAWIDTH - 1:0] ALU_result_in,
    output logic [DATAWIDTH - 1:0] ALU_result_out,

    input  logic [DATAWIDTH - 1:0] mem_rdata_in,
    output logic [DATAWIDTH - 1:0] mem_rdata_out,

    input  logic [DATAWIDTH - 1:0] imm_in,
    output logic [DATAWIDTH - 1:0] imm_out
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            pcadd4_out <= '0;
            ALU_result_out <= '0;
            mem_rdata_out <= '0;
            imm_out <= '0;
        end else begin
            pcadd4_out <= pcadd4_in;
            ALU_result_out <= ALU_result_in;
            mem_rdata_out <= mem_rdata_in;
            imm_out <= imm_in;
        end
    end

endmodule
