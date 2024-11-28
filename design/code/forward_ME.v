
module forward_ME(
	input[6:0] ME_opcode,
	input[4:0] ME_rs2,
	input[31:0] ME_reg_2,
	
	input WB_wb_enable,
	input[4:0] WB_rd,
	input[31:0] WB_reg_d,

	output wire[31:0] reg_2_selected
);
	assign reg_2_selected = (
		ME_rs2 != 5'd0 && ME_rs2 == WB_rd && WB_wb_enable &&
		ME_opcode == 7'b0100011
	) ? WB_reg_d : ME_reg_2;
endmodule


