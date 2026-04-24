module forwarding_unit (
    input logic[4:0] rd1,
    input logic[31:0] rd1v,
    input logic rd1_valid,
    
    input logic[4:0] rd2,
    input logic[31:0] rd2v,
    input logic rd2_valid,
    
    input logic[4:0] rs1,
    input logic[4:0] rs2,
    
    output logic[31:0] rs1v,
    output logic rs1_forward_sel,
    output logic[31:0] rs2v,
    output logic rs2_forward_sel
);
    always_comb begin
        rs1_forward_sel = 2'b00;
        rs1v = 32'b0;
        
        if (rd1_valid && (rd1 != 5'b0) && (rd1 == rs1)) begin
            rs1_forward_sel = 2'b01;
            rs1v = rd1v;
        end
        else if (rd2_valid && (rd2 != 5'b0) && (rd2 == rs1)) begin
            rs1_forward_sel = 2'b10;
            rs1v = rd2v;
        end
        
        rs2_forward_sel = 2'b00;
        rs2v = 32'b0;
        
        if (rd1_valid && (rd1 != 5'b0) && (rd1 == rs2)) begin
            rs2_forward_sel = 2'b01;
            rs2v = rd1v;
        end
        else if (rd2_valid && (rd2 != 5'b0) && (rd2 == rs2)) begin
            rs2_forward_sel = 2'b10;
            rs2v = rd2v;
        end
    end
endmodule