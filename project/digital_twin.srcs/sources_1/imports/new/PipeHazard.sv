module PipeHazard (
    input  logic       memReadE,
    input  logic [4:0] rdE,
    input  logic       uses_rs1_D,
    input  logic       uses_rs2_D,
    input  logic [4:0] rs1D,
    input  logic [4:0] rs2D,
    input  logic       redirectE,
    output logic       stallF,
    output logic       stallD,
    output logic       flushD,
    output logic       flushE
);
    logic dep_E;

    assign dep_E = memReadE && (rdE != 5'd0) && ((uses_rs1_D && (rdE == rs1D)) || (uses_rs2_D && (rdE == rs2D)));

    assign stallF = dep_E;
    assign stallD = stallF;
    assign flushD = redirectE;
    assign flushE = redirectE | stallF;
endmodule
