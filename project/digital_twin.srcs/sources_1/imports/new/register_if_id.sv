module register_if_id #(
    WIDTH = 32
) (
    input  logic             clock,
    input  logic             reset,
    input  logic             stall,
    input  logic             flush,
    input  logic [WIDTH-1:0] if_pc,
    input  logic [WIDTH-1:0] if_instr,
    output logic [WIDTH-1:0] id_pc,
    output logic [WIDTH-1:0] id_instr
);
    logic [WIDTH-1:0] register_pc;
    logic [WIDTH-1:0] register_instr;

    always_ff @(posedge clock or negedge reset) begin
        if (!reset) begin
            register_pc    <= {WIDTH{1'b0}};
            register_instr <= {WIDTH{1'b0}};
        end else if (flush) begin
            register_pc    <= {WIDTH{1'b0}};
            register_instr <= {WIDTH{1'b0}};
        end else if (!stall) begin
            register_pc <= if_pc;
            register_instr <= if_instr;
        end
    end

    assign id_pc    = register_pc;
    assign id_instr = register_instr;
endmodule
