module PipeLoadExt (
    input  logic [ 2:0] funct3,
    input  logic [31:0] loadData,
    output logic [31:0] loadExt
);
    logic op_other, op_lb, op_lh;

    assign op_lb = funct3 == 3'b000;
    assign op_lh = funct3 == 3'b001;
    assign op_other = ~(op_lh | op_lb);

    always @(*) begin
        loadExt = {32{op_lb}} & {{25{loadData[7]}}, loadData[6:0]} |
                  {32{op_lh}} & {{17{loadData[15]}}, loadData[14:0]} |
                  {32{op_other}} & loadData;
    end
endmodule
