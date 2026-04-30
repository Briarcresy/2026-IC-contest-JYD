module ex_mux #(
    WIDTH = 32
) (
    input  logic [WIDTH-1:0] pcadd4,
    input  logic [WIDTH-1:0] imm,
    input  logic [WIDTH-1:0] alu,
    input  logic [      1:0] alu_mux,
    output logic [WIDTH-1:0] result,
    output logic [WIDTH-1:0] trigger_stall
);
    always_comb begin
        if (alu_mux == 2'b00) begin
            result = pcadd4;
            trigger_stall = 0;
        end else if (alu_mux == 2'b01) begin
            result = alu;
            trigger_stall = 0;
        end else if (alu_mux == 2'b11) begin
            result = imm;
            trigger_stall = 0;
        end else begin
            result = 32'b0;
            trigger_stall = 1;
        end
    end
endmodule
