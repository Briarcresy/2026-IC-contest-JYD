module EX_MEM #(
    parameter DATAWIDTH = 32
) (
    input logic clk,
    input logic rst,

    input  logic [DATAWIDTH - 1:0] mem_wdata_in,
    output logic [DATAWIDTH - 1:0] mem_wdata_out,

    input  logic [DATAWIDTH - 1:0] mem_addr_in,
    output logic [DATAWIDTH - 1:0] mem_addr_out,

    input  logic [DATAWIDTH - 1:0] imm_in,
    output logic [DATAWIDTH - 1:0] imm_out
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            mem_wdata_out <= '0;
            mem_addr_out <= '0;
            imm_out <= '0;
        end else begin
            mem_wdata_out <= mem_wdata_in;
            mem_addr_out <= mem_addr_in;
            imm_out <= imm_in;
        end
    end

endmodule
