`timescale 1ns / 1ps
`include "defines.sv"
module ALU_src #(
    WIDTH = 32
) (
    input  logic             alu_src,
    input  logic [      1:0] forward_src,
    input  logic [WIDTH-1:0] alusrc0,
    input  logic [WIDTH-1:0] alusrc1,
    input  logic [WIDTH-1:0] fwdsrc0,
    input  logic [WIDTH-1:0] fwdsrc1,
    output logic [WIDTH-1:0] result
);
    always_comb begin
        if (alu_src) begin
            result = alusrc1;
        end else begin
            unique case (forward_src)
                2'b00:   result = alusrc0;
                2'b10:   result = fwdsrc0;
                2'b11:   result = fwdsrc1;
                default: result = alusrc0;
            endcase
        end
    end
endmodule
