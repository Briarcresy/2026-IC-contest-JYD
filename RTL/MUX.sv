module MUX #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             sel,
    output logic [WIDTH-1:0] out
);
    always_comb begin
        out = sel ? in1 : in0;
    end
endmodule
