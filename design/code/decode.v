`define R_TYPE 7'b0110011
`define I_TYPE 7'b1100111, 7'b0000011, 7'b1110011
`define R_I_TYPE 7'b0010011
`define S_TYPE 7'b0100011
`define B_TYPE 7'b1100011
`define U_TYPE 7'b0110111, 7'b0010111
`define J_TYPE 7'b1101111


module decode(
	input[31:0] instruction,
	
	output[6:0] opcode_out,
	output[2:0] funct3_out,
	output[6:0] funct7_out,
	output[4:0] rs1_out,
	output[4:0] rs2_out,
	output[4:0] rd_out,
	output reg[31:0] imm
);
	wire[6:0] funct7;
	wire[4:0] shamt;
	wire[4:0] rs2;
	wire[4:0] rs1;
	wire[2:0] funct3;
	wire[4:0] rd;
	wire[6:0] opcode;
	assign funct7[6:0] = instruction[31:25];
	assign shamt[4:0]  = instruction[24:20];
	assign rs2[4:0]    = instruction[24:20];
	assign rs1[4:0]    = instruction[19:15];
	assign funct3[2:0] = instruction[14:12];
	assign rd[4:0]     = instruction[11:7];
	assign opcode[6:0] = instruction[6:0];

	assign opcode_out[6:0] = opcode[6:0];
	assign funct3_out[2:0] = (
		opcode[6:0] != 7'b0110111 && opcode[6:0] != 7'b0010111 && opcode[6:0] != 7'b1101111
	) ? funct3[2:0] : 3'd0;
	assign funct7_out[6:0] = (
		opcode[6:0] == 7'b0010011 || opcode[6:0] == 7'b0110011
	) ? funct7[6:0] : 7'd0;
	assign rs1_out[4:0] = (
		opcode[6:0] != 7'b0110111 && opcode[6:0] != 7'b0010111 && opcode[6:0] != 7'b1101111
	) ? rs1[4:0] : 5'd0;
	assign rs2_out[4:0] = (
		opcode[6:0] == 7'b0110011 || opcode[6:0] == 7'b0100011 || opcode[6:0] == 7'b1100011
	) ? rs2[4:0] : 5'd0;
	assign rd_out[4:0] = (
		opcode[6:0] != 7'b0100011 && opcode[6:0] != 7'b1100011
	) ? rd[4:0] : 5'd0;


	// immediate value
    always @(*) begin
        case (opcode)
			`R_I_TYPE: begin
				case (funct3)
					3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: begin
						imm[31:12] = { 20{instruction[31]} };
						imm[11:0]  = instruction[31:20];
					end
					3'b001, 3'b101: begin
						imm[31:5] = { 27{1'b0} };
						imm[4:0]  = instruction[24:20];
					end
				endcase

			end
			`R_TYPE: begin
                imm[31:0]  = { 32{1'b0} };
            end
            `I_TYPE: begin
				case (opcode)
					7'b1100111: begin // JALR
						imm[31:12] = { 20{instruction[31]} };
						imm[11:0]  = instruction[31:20];
					end
					7'b0000011: begin // LOAD
						case (funct3[1:0])
							2'b00: begin // LB LBU
								imm[31:8] = { 24{instruction[27]} };
								imm[7:0]  = instruction[27:20];
							end
							2'b01: begin // LH LHU
								imm[31:12] = { 20{instruction[31]} };
								imm[11:0]  = instruction[31:20];
							end
							2'b10: begin // LW
								imm[31:12] = { 20{instruction[31]} };
								imm[11:0]  = instruction[31:20];
							end
							default: imm[31:0]  = { 32{1'b0} };
						endcase
					end
					default: begin
						imm[31:12] = { 20{instruction[31]} };
						imm[11:0]  = instruction[31:20];
					end
				endcase
			end
            `S_TYPE: begin
                imm[31:12] = { 20{instruction[31]} };
                imm[11:5]  = instruction[31:25];
                imm[4:0]   = instruction[11:7];
            end
            `B_TYPE: begin
                imm[31:13] = { 19{instruction[31]} };
                imm[12]    = instruction[31];
                imm[11]    = instruction[7];
                imm[10:5]  = instruction[30:25];
                imm[4:1]   = instruction[11:8];
                imm[0]     = 1'b0;
            end
            `U_TYPE: begin
                imm[31:12] = instruction[31:12];
                imm[11:0]  = { 12{1'b0} };
            end
            `J_TYPE: begin
                imm[31:21] = { 11{instruction[31]} };
                imm[20]    = instruction[31];
                imm[19:12] = instruction[19:12];
                imm[11]    = instruction[20];
                imm[10:1]  = instruction[30:21];
                imm[0]     = 0'b0;
            end
            default: begin
				imm[31:0]  = { 32{1'b0} };
				// $fatal("Error: Unexpected opcode: %07b", opcode[6:0]);
            end
        endcase
    end
endmodule




