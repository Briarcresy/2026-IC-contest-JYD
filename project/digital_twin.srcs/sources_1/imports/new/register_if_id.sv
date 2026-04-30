module register_if_id #(
    WIDTH = 32
) (
    input  logic             clock,
    input  logic             reset,
    input  logic             stall,
    input  logic             flush,
    input  logic [WIDTH-1:0] if_pc,
    input  logic [WIDTH-1:0] if_pc4,
    input  logic [WIDTH-1:0] if_instr,
    output logic [WIDTH-1:0] id_pc,
    output logic [WIDTH-1:0] id_pc4,
    output logic [WIDTH-1:0] id_instr
);
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            id_pc    <= {WIDTH{1'b0}};
            id_pc4   <= {WIDTH{1'b0}};
            id_instr <= {WIDTH{1'b0}};
        end else if (flush) begin
            id_pc    <= {WIDTH{1'b0}};
            id_pc4   <= {WIDTH{1'b0}};
            id_instr <= {WIDTH{1'b0}};
        end else if (!stall) begin
            id_pc    <= if_pc;
            id_pc4   <= if_pc4;
            id_instr <= if_instr;
        end
    end
endmodule
