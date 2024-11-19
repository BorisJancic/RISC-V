
module EX_ME(
	input clock,
	input reset,
	input valid_in,
	input[31:0] pc_in,
	input[31:0] instruction_in,	
	input[31:0] alu_res_in,
	input[31:0] reg_2_in,

	input ME_valid,
	input[31:0] ME_instruction,
	input[31:0] ME_alu_res,
	input[31:0] ME_mem_res,

	output reg valid_out,
	output reg[31:0] pc_out,
	output reg[31:0] instruction_out,
	output reg[31:0] alu_res_out,
	output reg[31:0] reg_2_out
);
	wire[4:0] rs2_in;
	wire[4:0] ME_rd;
	wire[6:0] opcode_in;
	wire[6:0] ME_opcode;

	assign rs2_in[4:0] = instruction_in[24:20];
	assign ME_rd[4:0] = ME_instruction[11:7];
	assign opcode_in[6:0] = instruction_in[6:0];
	assign ME_opcode[6:0] = ME_instruction[6:0];


	always @(posedge clock) begin
		if (reset) begin
			valid_out <= 0;
			pc_out[31:0] <= 32'd0;
		    instruction_out[31:0] <= 32'd0;
		end else begin
			valid_out <= valid_in;
			pc_out[31:0] <= pc_in[31:0];
			instruction_out[31:0] <= instruction_in[31:0];
		end
		
		if (reset) begin
			alu_res_out[31:0]   <= 32'd0;
            reg_2_out[31:0]     <= 32'd0;
		end else if (
			ME_valid &&
			(rs2_in == ME_rd) &&
			(opcode_in == 7'b0100011) &&	// store
			(
				ME_opcode == 7'b0110111 ||	// LUI
				ME_opcode == 7'b0010111 ||	// AUIPC
				ME_opcode == 7'b1101111 ||	// JAL
				ME_opcode == 7'b1100111 ||	// JALR
				ME_opcode == 7'b0000011 ||	// load
				ME_opcode == 7'b0010011 ||	// ADDI - SRAI
				ME_opcode == 7'b0110011		// ADD - AND (R_TYPE)
			)
		) begin
			if (ME_opcode == 7'b0000011) begin
				alu_res_out[31:0]	<= alu_res_in[31:0];
				reg_2_out[31:0]		<= ME_mem_res[31:0];	
			end else begin
				alu_res_out[31:0]	<= alu_res_in[31:0];
				reg_2_out[31:0]		<= reg_2_in[31:0];	
			end
			// alu_res_out[31:0]	<= ME_alu_res[31:0];
			// reg_2_out[31:0]		<= ME_mem_res[31:0];		
		end else begin
			alu_res_out[31:0]	<= alu_res_in[31:0];
			reg_2_out[31:0]		<= reg_2_in[31:0];
		end
	end
endmodule


