module ID_EX(
	input clock,
	input reset,
	input valid_in,
	input[31:0] pc_in,
	input[31:0] instruction_in,

	input EX_valid,
	input[31:0] EX_instruction,
	input[31:0] EX_alu_res,
	
	input ME_valid,
	input ME_wb_enable,
	input[4:0] ME_rs_d,
	input[31:0] ME_reg_d,	
	
	input WB_wb_enable,
	input[4:0] WB_rs_d,

	input[31:0] reg_1_in,
	input[31:0] reg_2_in,
	input[31:0] imm_in,
	input branch,

	output reg valid_out,
	output reg[31:0] pc_out,
	output reg[31:0] instruction_out,
	
	output reg[31:0] reg_1_out,
	output reg[31:0] reg_2_out,
	output reg[31:0] imm_out,
	output wire stall_out
/*	output wire stall_1_out,
	output wire stall_2_out,
	output wire forward_reg_1_EX_out,
	output wire forward_reg_2_EX_out,
	output wire forward_reg_1_ME_out,
	output wire forward_reg_2_ME_out,
	output wire[31:0] forward_reg_2_val_ME*/
);
	wire[6:0] opcode_in;	
	wire[4:0] rs1_in;
	wire[4:0] rs2_in;
	wire[4:0] EX_rs_d;
	wire[6:0] EX_opcode;

	assign opcode_in[6:0] = instruction_in[6:0];
	assign EX_opcode[6:0] = EX_instruction[6:0];
	assign EX_rs_d		  = EX_instruction[11:7];
	assign rs1_in[4:0] = instruction_in[19:15];
	assign rs2_in[4:0] = instruction_in[24:20];

	wire stall;
	wire stall_1;
	wire stall_2;

	wire forward_reg_1_EX;
	wire forward_reg_1_ME;
	wire forward_reg_2_EX;
	wire forward_reg_2_ME;
	
	wire forward_reg_2_WB_ME;

	/*assign forward_reg_1_EX_out = forward_reg_1_EX;
	assign forward_reg_2_EX_out = forward_reg_2_EX;
	assign forward_reg_1_ME_out = forward_reg_1_ME;
	assign forward_reg_2_ME_out = forward_reg_2_ME;
	assign forward_reg_2_val_ME = ME_reg_d[31:0];
	assign stall_1_out = stall_1;
	assign stall_2_out = stall_2;*/

	assign stall_out = stall;
	assign stall = stall_1 || stall_2;
	assign stall_1 = (
		valid_in && EX_valid && EX_opcode == 7'b0000011 && ( // rd, load
			((rs1_in == EX_rs_d) && (rs1_in != 5'd0) && ( // rs1
				opcode_in == 7'b1100111 || opcode_in == 7'b1100011 ||
				opcode_in == 7'b0000011 || opcode_in == 7'b0100011 ||
				opcode_in == 7'b0010011 || opcode_in == 7'b0110011
			))
			||
			((rs2_in == EX_rs_d) && (rs2_in != 5'd0) && // rs2
			(opcode_in == 7'b1100011 || opcode_in == 7'b0110011))
		)
	);
	assign stall_2 = (
		valid_in &&
		WB_wb_enable &&
		(
			(!forward_reg_1_EX && !forward_reg_1_ME && (
				(rs1_in == WB_rs_d && rs1_in != 5'd0) && ( // rs1
					opcode_in == 7'b1100111 || opcode_in == 7'b1100011 ||
					opcode_in == 7'b0000011 || opcode_in == 7'b0100011 ||
                    opcode_in == 7'b0010011 || opcode_in == 7'b0110011
                )
			))
			||
			(!forward_reg_2_EX && !forward_reg_2_ME && !forward_reg_2_WB_ME && (
				(rs2_in == WB_rs_d) && (rs2_in != 5'd0) && // rs2
				(opcode_in == 7'b1100011 || opcode_in == 7'b0100011 || opcode_in == 7'b0110011)
			))
		)
	);


	assign forward_reg_1_EX = (
		EX_valid && (rs1_in == EX_rs_d) && (rs1_in != 5'd0) && ( // rs1
		    opcode_in == 7'b1100111 || opcode_in == 7'b1100011 ||
			opcode_in == 7'b0000011 || opcode_in == 7'b0100011 ||
			opcode_in == 7'b0010011 || opcode_in == 7'b0110011
        ) && ( // rd
            EX_opcode == 7'b0110111 || EX_opcode == 7'b0010111 ||
            EX_opcode == 7'b1101111 || EX_opcode == 7'b1100111 ||
            EX_opcode == 7'b0000011 || EX_opcode == 7'b0010011 ||
			EX_opcode == 7'b0110011
		)
	);
	assign forward_reg_1_ME = (
		ME_valid && ME_wb_enable && (rs1_in == ME_rs_d) && (rs1_in != 5'd0) && ( // rs1
            opcode_in == 7'b1100111 || opcode_in == 7'b1100011 ||
            opcode_in == 7'b0000011 || opcode_in == 7'b0100011 ||
			opcode_in == 7'b0010011 || opcode_in == 7'b0110011
		)
	);
	assign forward_reg_2_EX = (		
        EX_valid && (rs2_in == EX_rs_d) && (rs2_in != 5'd0) && (  // rs2
			opcode_in == 7'b1100011 || opcode_in == 7'b0100011 || opcode_in == 7'b0110011
		) && ( // rd
            EX_opcode == 7'b0110111 || EX_opcode == 7'b0010111 ||
            EX_opcode == 7'b1101111 || EX_opcode == 7'b1100111 ||
            EX_opcode == 7'b0000011 || EX_opcode == 7'b0010011 ||
            EX_opcode == 7'b0110011
        )
	);
    assign forward_reg_2_ME = (
        ME_valid && ME_wb_enable && (rs2_in == ME_rs_d) && (rs2_in != 5'd0) && ( // rs2
			opcode_in == 7'b1100011 || opcode_in == 7'b0100011 || opcode_in == 7'b0110011
		)
    );
	assign forward_reg_2_WB_ME = (
		EX_valid && (rs2_in == EX_rs_d) && (opcode_in == 7'b0100011) && (
			EX_opcode == 7'b0110111 || EX_opcode == 7'b0010111 ||
			EX_opcode == 7'b1101111 || EX_opcode == 7'b1100111 ||
			EX_opcode == 7'b0000011 || EX_opcode == 7'b0010011 ||
			EX_opcode == 7'b0110011
		)
	);


	always @(posedge clock) begin
		if (reset || branch || stall) begin
			valid_out <= 0;
		end else begin
			valid_out <= valid_in;
		end

		if (reset) begin
			pc_out[31:0] <= pc_in[31:0];
			instruction_out[31:0] <= 32'd0;

			reg_1_out[31:0] <= 32'd0;
			reg_2_out[31:0] <= 32'd0;
			imm_out[31:0] <= 32'd0;
		end else if (stall) begin // NOP
			pc_out[31:0]			<= 32'd0;
	        instruction_out[31:0]	<= 32'd0;

		    reg_1_out[31:0]			<= 32'd0;
			reg_2_out[31:0]			<= 32'd0;
	        imm_out[31:0]			<= 32'd0;
		end else begin
			case ({forward_reg_1_EX, forward_reg_1_ME})
				2'b00: begin reg_1_out[31:0] <= reg_1_in[31:0]; end
				2'b01: begin reg_1_out[31:0] <= ME_reg_d[31:0]; end
				2'b10: begin reg_1_out[31:0] <= EX_alu_res[31:0]; end
				2'b11: begin reg_1_out[31:0] <= EX_alu_res[31:0]; end
			endcase
			case ({forward_reg_2_EX, forward_reg_2_ME})
				2'b00: begin reg_2_out[31:0] <= reg_2_in[31:0]; end
				2'b01: begin reg_2_out[31:0] <= ME_reg_d[31:0]; end
				2'b10: begin reg_2_out[31:0] <= EX_alu_res[31:0]; end
				2'b11: begin reg_2_out[31:0] <= EX_alu_res[31:0]; end
			endcase

			imm_out[31:0] <= imm_in[31:0];

			pc_out[31:0] <= pc_in[31:0];
			instruction_out[31:0] <= instruction_in[31:0];
		end
	end
endmodule



