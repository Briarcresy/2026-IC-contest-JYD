module CSR #(
    parameter   DATAWIDTH = 32	
)(
	input  logic 					clk			,
	input  logic 					rst			,
	input  logic [DATAWIDTH-1:0]	pc			,
	input  logic [DATAWIDTH-1:0]	rf1			,
	input  logic [11:0] 			csr_idx		,
	input  logic [3:0]  			CSRControll	,

	output logic [DATAWIDTH-1:0] 	csr_npc		,
	output logic [DATAWIDTH-1:0]	csr_wb
);
	reg [DATAWIDTH-1:0] mstatus, mepc, mtvec, mcause;
	reg [DATAWIDTH-1:0] old_mstatus, old_mepc, old_mtvec, old_mcause;
	reg [DATAWIDTH-1:0] mask;

	// 信号初始化
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mask <= 32'hFFFFFFFF;
		end
	end

	// 寄存器备份，old版本
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			old_mstatus <= 32'h0;
		end else begin
			old_mstatus <= mstatus;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			old_mepc <= 32'h0;
		end else begin
			old_mepc <= mepc;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			old_mtvec <= 32'h0;
		end else begin
			old_mtvec <= mtvec;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			old_mcause <= 32'h0;
		end else begin
			old_mcause <= mcause;
		end
	end

	// mstatus更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mstatus <= 32'h1800;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h300) mstatus <= mask & (old_mstatus | rf1);
				4'b0010: if (csr_idx == 12'h300) mstatus <= mask & rf1;
				4'b0100: mstatus <= { old_mstatus[31:8], old_mstatus[3], old_mstatus[6:4], old_mstatus[2:0] };
				4'b1000: mstatus <= { old_mstatus[31:13], 2'b11, old_mstatus[10:8], 1'b1, old_mstatus[6:4], old_mstatus[3], old_mstatus[2:0] };
				default: mstatus <= mstatus; // 保持原值
			endcase
		end
	end

	// mtvec更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mtvec <= 32'h0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h305) mtvec <= old_mtvec | rf1;
				4'b0010: if (csr_idx == 12'h305) mtvec <= rf1;
				default: mtvec <= mtvec;
			endcase
		end
	end

	// mepc更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mepc <= 32'h0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h341) mepc <= old_mepc | rf1;
				4'b0010: if (csr_idx == 12'h341) mepc <= rf1;
				4'b0100: mepc <= pc;
				default: mepc <= mepc;
			endcase
		end
	end

	// mcause更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mcause <= 32'h0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h342) mcause <= old_mcause | rf1;
				4'b0010: if (csr_idx == 12'h342) mcause <= rf1;
				4'b0100: mcause <= 32'h0b;  // environment call from M-mode
				default: mcause <= mcause;
			endcase
		end
	end

	assign csr_wb = {32{csr_idx == 12'h300}} & old_mstatus |
				{32{csr_idx == 12'h305}} & old_mtvec |
				{32{csr_idx == 12'h341}} & old_mepc |
				{32{csr_idx == 12'h342}} & old_mcause;

	assign csr_npc =  {32{CSRControll == 4'b0100}} & old_mtvec |
				{32{CSRControll == 4'b1000}} & old_mepc;
	
	
endmodule