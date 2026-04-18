module PipeForward (
    input  logic        regWriteM,
    input  logic        memReadM,
    input  logic [ 4:0] rdM,
    input  logic        regWriteW,
    input  logic [ 4:0] rdW,
    input  logic [ 4:0] rs1E,
    input  logic [ 4:0] rs2E,
    input  logic [31:0] rs1ValE,
    input  logic [31:0] rs2ValE,
    input  logic [31:0] wbDataM,
    input  logic [31:0] wbData,
    output logic [31:0] forwardAData,
    output logic [31:0] forwardBData
);
    always @(*) begin
        if (regWriteM && (rdM != 5'd0) && (rdM == rs1E)) begin
            forwardAData = wbDataM;
        end else if (regWriteW && (rdW != 5'd0) && (rdW == rs1E)) begin
            forwardAData = wbData;
        end else begin
            forwardAData = rs1ValE;
        end
    end

    always @(*) begin
        if (regWriteM && (rdM != 5'd0) && (rdM == rs2E)) begin
            forwardBData = wbDataM;
        end else if (regWriteW && (rdW != 5'd0) && (rdW == rs2E)) begin
            forwardBData = wbData;
        end else begin
            forwardBData = rs2ValE;
        end
    end
endmodule
