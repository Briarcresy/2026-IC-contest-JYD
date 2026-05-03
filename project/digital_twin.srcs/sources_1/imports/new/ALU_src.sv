`include "defines.sv"
module ALU_src #(
    WIDTH = 32
) (
    input  logic             alu_src,
    input  logic             forward_src,
    input  logic             forward_require,
    input  logic [WIDTH-1:0] alusrc0,
    input  logic [WIDTH-1:0] alusrc1,
    input  logic [WIDTH-1:0] fwdsrc0,
    input  logic [WIDTH-1:0] fwdsrc1,
    output logic [WIDTH-1:0] result
);
    always_comb begin
        if (forward_require) begin
            result = forward_src ? fwdsrc1 : fwdsrc0;
        end else begin
            result = alu_src ? alusrc1 : alusrc0;
        end
    end
endmodule
