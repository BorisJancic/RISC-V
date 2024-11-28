`define R_I_U_J_TYPE 7'b0010011, 7'b0110011, 7'b1100111, 7'b0000011, 7'b1110011, 7'b0110111, 7'b0010111, 7'b1101111
`define S_B_TYPE 7'b0100011, 7'b1100011

module writeback (
	input clock,
	input reset,
	input valid,
	input[31:0] pc,
	input[6:0] opcode,
	input[4:0] rd,
	input[2:0] funct3,

	input[31:0] mem_res,
	input[31:0] alu_res,

	output wb_enable,
	output reg[31:0] reg_d
);
	// Writeback Enable
	assign wb_enable = !reset && valid && rd != 5'd0;
	
	// Writeback Output
	always @(*) begin
		case (opcode)
			7'b0000011: begin // LB LH LW LBU LHU
				case (funct3)
					3'b000: reg_d[31:0] = { {24{mem_res[7]}}, mem_res[7:0] };
					3'b001: reg_d[31:0] = { {16{mem_res[15]}}, mem_res[15:0] };
					3'b010: reg_d[31:0] = mem_res[31:0];
					3'b100: reg_d[31:0] = { 24'd0, mem_res[7:0] };
					3'b101: reg_d[31:0] = { 16'd0, mem_res[15:0] };
					default: reg_d[31:0] = 32'd0;
				endcase
			end
			7'b1101111, 7'b1100111: begin // JAL JALR
				reg_d[31:0] = pc[31:0] + 4;
			end
			default: begin // ALU RES
				reg_d[31:0] = alu_res[31:0];
			end
		endcase
	end

endmodule


