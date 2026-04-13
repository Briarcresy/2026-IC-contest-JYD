module CCTL (
	input  logic [31:0] instr		,
	output logic [11:0] csr_idx		,
	output logic [3:0]  CSRControll
);
	assign csr_idx = instr[31:20];
	assign CSRControll[0] = (instr[6:0] == 7'b1110011) && (instr[14:12] == 3'b010); // csrrs
	assign CSRControll[1] = (instr[6:0] == 7'b1110011) && (instr[14:12] == 3'b001); // csrrw
	assign CSRControll[2] = instr == 32'h00000073; // ecall
	assign CSRControll[3] = instr == 32'h30200073; // mret
endmodule