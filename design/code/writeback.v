`define R_I_U_J_TYPE 7'b0010011, 7'b0110011, 7'b1100111, 7'b0000011, 7'b1110011, 7'b0110111, 7'b0010111, 7'b1101111
`define S_B_TYPE 7'b0100011, 7'b1100011

module writeback (
	input clock,
	input reset,
	input valid,
	input[31:0] pc,
	input[31:0] instruction,
	input[31:0] mem_res,
	input[31:0] alu_res,

	output reg wb_enable,
	output reg[4:0] rs_d,
	output reg[31:0] reg_d
);
	wire[6:0] opcode;
	wire[2:0] func3;
	assign opcode[6:0] = instruction[6:0];
	assign func3[2:0] = instruction[14:12];

	// Writeback Output
	always @(*) begin
		rs_d[4:0] = instruction[11:7];
		
		case (opcode)
			7'b0000011: begin // LB LH LW LBU LHU
				case (func3)
					3'b000: reg_d[31:0] = { {24{mem_res[7]}}, mem_res[7:0] };
					3'b001: reg_d[31:0] = { {16{mem_res[15]}}, mem_res[15:0] };
					3'b010: reg_d[31:0] = mem_res[31:0];
					3'b100: reg_d[31:0] = { 24'd0, mem_res[7:0] };
					3'b101: reg_d[31:0] = { 16'd0, mem_res[15:0] };
					default: reg_d[31:0] = 32'd72;
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

	// Writeback Enable
	always @(*) begin
		if (reset || !valid) begin
			wb_enable = 0;
		end else begin
			if (
					opcode == 7'b0110111 ||
					opcode == 7'b0010111 ||
					opcode == 7'b1101111 ||
					opcode == 7'b1100111 ||
					opcode == 7'b0000011 ||
					opcode == 7'b0010011 ||
					opcode == 7'b0110011
			) begin
				wb_enable = 1;
			end else begin
				wb_enable = 0;
			end
/*			case (opcode)
				`S_B_TYPE:	wb_enable = 0;
				7'b0001111: begin
					if (func3 == 3'b001) begin
						wb_enable = 0;
					end else begin
						wb_enable = 0;
					end
				end
				7'b1110011: begin
					if (func3 == 3'b000) begin
						wb_enable = 0;
					end else begin
						wb_enable = 0;
					end
				end
				default: wb_enable = 1;
			endcase*/
		end
	end
endmodule



