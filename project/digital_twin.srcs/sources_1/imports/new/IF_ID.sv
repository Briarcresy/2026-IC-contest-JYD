module IF_ID #(
    parameter DATAWIDTH = 32
) (
    input logic clk,
    input logic rst,
    // input  logic                   stall,

    input  logic [DATAWIDTH - 1:0] instr_in,
    output logic [DATAWIDTH - 1:0] instr_out,

    input  logic [DATAWIDTH - 1:0] pc_in,
    output logic [DATAWIDTH - 1:0] pc_out
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            instr_out <= '0;
            pc_out <= '0;
        end else begin
            instr_out <= instr_in;
            pc_out <= pc_in;
        end
    end

endmodule
