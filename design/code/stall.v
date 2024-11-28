
module stall(
	input ID_valid,
	input[6:0] ID_opcode,
	input[4:0] ID_rs1,
	input[4:0] ID_rs2,
	
	input EX_valid,
	input[6:0] EX_opcode,
	input[4:0] EX_rd,

	input[4:0] ME_rd,

	input WB_wb_enable,
	input[4:0] WB_rd,

	output wire stall
);
	wire stall_1;
	wire stall_2;
	assign stall = stall_1 || stall_2;
	
	assign stall_1 = (
		//	if ID is an alu_op that needs the rd of a load_op from EX, stall
		ID_valid && EX_valid && EX_opcode == 7'b0000011 && (
			// rs1
			(ID_rs1 != 5'd0 && ID_rs1 == EX_rd)
			||
			// rs2
			(ID_rs2 != 5'd0 && ID_rs2 == EX_rd && ID_opcode != 7'b0100011)
		)
	);
	assign stall_2 = (
		// if ID is an op that needs the rd of a write_back from WB, stall
		// unless, such rd regester will get forwarded to EX or ME
		ID_valid && WB_wb_enable && ME_rd != WB_rd && EX_rd != WB_rd && (
			// rs1
			(ID_rs1 != 5'd0 && ID_rs1 == WB_rd)
			||
			// rs2
			(ID_rs2 != 5'd0 && ID_rs2 == WB_rd)
		)
	);

endmodule


