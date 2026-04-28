module ID_EX #(
    parameter DATAWIDTH = 32
) (
    input logic clk,
    input logic rst,
    // input  logic                   stall,

    input  logic [DATAWIDTH - 1:0] pc_in,
    output logic [DATAWIDTH - 1:0] pc_out,

    input  logic reg_rdata1_in,
    output logic reg_rdata1_out,

    input  logic reg_rdata2_in,
    output logic reg_rdata2_out,

    input  logic [DATAWIDTH - 1:0] reg_waddr_in,
    output logic [DATAWIDTH - 1:0] reg_waddr_out,

    input  logic [DATAWIDTH - 1:0] reg_raddr1_in,
    output logic [DATAWIDTH - 1:0] reg_raddr1_out,

    input  logic [DATAWIDTH - 1:0] reg_raddr2_in,
    output logic [DATAWIDTH - 1:0] reg_raddr2_out,

    input  logic [DATAWIDTH - 1:0] imm_in,
    output logic [DATAWIDTH - 1:0] imm_out
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            pc_out <= '0;
            reg_rdata1_out <= '0;
            reg_rdata2_out <= '0;
            reg_waddr_out <= '0;
            reg_raddr1_out <= '0;
            reg_raddr2_out <= '0;
            imm_out <= '0;
        end else begin
            pc_out <= pc_in;
            reg_rdata1_out <= reg_rdata1_in;
            reg_rdata2_out <= reg_rdata2_in;
            reg_waddr_out <= reg_waddr_in;
            reg_raddr1_out <= reg_raddr1_in;
            reg_raddr2_out <= reg_raddr2_in;
            imm_out <= imm_in;
        end
    end

endmodule
