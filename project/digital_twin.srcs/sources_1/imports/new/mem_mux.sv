module mem_mux #(
    WIDTH = 32
) (
    input logic [WIDTH-1:0] ex_mux,
    input logic [WIDTH-1:0] pc_add_4,
    input logic [WIDTH-1:0] mdata,
    input logic [1:0] alu_mux,
    output logic [WIDTH-1:0] result
);
    always_comb begin
        if (alu_mux == 2'b00) begin
            result = pc_add_4;
        end
        else if (alu_mux == 2'b10) begin
            result = mdata;
        end
        else begin
            result = alu_mux;
        end
    end
endmodule