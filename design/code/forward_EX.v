
module forward_EX(
	input wire[6:0] EX_opcode,
	input wire[4:0] EX_rs1,
	input wire[4:0] EX_rs2,
	input wire[31:0] EX_reg_1,
	input wire[31:0] EX_reg_2,

	input wire[6:0] ME_opcode,
	input wire[4:0] ME_rd,
	input wire[31:0] ME_alu_res,

	input wire WB_wb_enable,
	input wire[4:0] WB_rd,
	input wire[31:0] WB_reg_d,

	output reg[31:0] reg_1_selected,
	output reg[31:0] reg_2_selected
);
	wire forward_reg_1_ME;
	wire forward_reg_2_ME;
	wire forward_reg_1_WB;
	wire forward_reg_2_WB;

	assign forward_reg_1_ME = (
		EX_rs1 != 5'd0 && EX_rs1 == ME_rd &&
		(ME_opcode != 7'b1101111 && ME_opcode != 7'b1100111 && ME_opcode != 7'b0000011)
	);
	assign forward_reg_2_ME = (
		EX_rs2 != 5'd0 && EX_rs2 == ME_rd && EX_opcode != 7'b0100011 && // Store
		ME_opcode != 7'b0000011 && ME_opcode != 7'b1101111 && // Load, JAL, JALR
		ME_opcode != 7'b1100111
	);
	assign forward_reg_1_WB = (
		EX_rs1 != 5'd0 && EX_rs1 == WB_rd && WB_wb_enable
	);
	assign forward_reg_2_WB = (
		EX_rs2 != 5'd0 && EX_rs2 == WB_rd && WB_wb_enable
	);

	always @(*) begin
		case ({forward_reg_1_ME, forward_reg_1_WB})
			2'b00: begin reg_1_selected[31:0] = EX_reg_1[31:0]; end
			2'b01: begin reg_1_selected[31:0] = WB_reg_d[31:0]; end
			2'b10: begin reg_1_selected[31:0] = ME_alu_res[31:0]; end
			2'b11: begin reg_1_selected[31:0] = ME_alu_res[31:0]; end
		endcase
		case ({forward_reg_2_ME, forward_reg_2_WB})
			2'b00: begin reg_2_selected[31:0] = EX_reg_2[31:0]; end
			2'b01: begin reg_2_selected[31:0] = WB_reg_d[31:0]; end
			2'b10: begin reg_2_selected[31:0] = ME_alu_res[31:0]; end
			2'b11: begin reg_2_selected[31:0] = ME_alu_res[31:0]; end
		endcase
	end
endmodule



