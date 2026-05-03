`include "defines.sv"

module forwarding_unit (
    input  logic [4:0] rd1,
    input  logic       rd1_we,
    input  logic [4:0] rd2,
    input  logic       rd2_we,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic       rs1_needed,
    input  logic       rs2_needed,
    output logic       rs1_forward_sel,
    output logic       rs1_forward_require,
    output logic       rs2_forward_sel,
    output logic       rs2_forward_require
);
    always_comb begin
        if (!rs1_needed) begin
            rs1_forward_sel = 0;
            rs1_forward_require = 0;
        end else if (rd1_we && (rd1 != 0) && (rd1 == rs1)) begin
            rs1_forward_sel = 0;
            rs1_forward_require = 1;
        end else if (rd2_we && (rd2 != 0) && (rd2 == rs1)) begin
            rs1_forward_sel = 1;
            rs1_forward_require = 1;
        end else begin
            rs1_forward_sel = 0;
            rs1_forward_require = 0;
        end

        if (!rs2_needed) begin
            rs2_forward_sel = 0;
            rs2_forward_require = 0;
        end else if (rd1_we && (rd1 != 5'b0) && (rd1 == rs2)) begin
            rs2_forward_sel = 0;
            rs2_forward_require = 1;
        end else if (rd2_we && (rd2 != 5'b0) && (rd2 == rs2)) begin
            rs2_forward_sel = 1;
            rs2_forward_require = 1;
        end else begin
            rs2_forward_sel = 0;
            rs2_forward_require = 0;
        end
    end
endmodule
