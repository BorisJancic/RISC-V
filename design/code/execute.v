`define R_I_TYPE 7'b0010011
`define R_TYPE 7'b0110011
`define I_TYPE 7'b1100111, 7'b0000011, 7'b1110011
`define S_TYPE 7'b0100011
`define B_TYPE 7'b1100011
`define U_TYPE 7'b0110111, 7'b0010111
`define J_TYPE 7'b1101111

module execute(
	input reset,
	input valid,
	input[31:0] pc,
	input[6:0] opcode,
	input[2:0] funct3,
	input[6:0] funct7,
	input[31:0] imm,
	input[31:0] reg_1,
	input[31:0] reg_2,

    output reg[31:0] alu_res,
    output reg br_taken
);
	always @(*) begin
        case (opcode)
			`R_I_TYPE: begin // 7'b0010011
				case (funct3)
					3'b000: begin // ADDI
						alu_res[31:0] = reg_1[31:0] + imm[31:0];
					end
				    3'b010: begin // SLTI
			            alu_res[31:0] = ($signed(reg_1[31:0]) < $signed(imm[31:0])) ? 1 : 0;
		            end
	                3'b011: begin // SLTIU
                        alu_res[31:0] = ($unsigned(reg_1[31:0]) < $unsigned(imm[31:0])) ? 1 : 0;
					end
					3'b100: begin // XORI
                        alu_res[31:0] = reg_1[31:0] ^ imm[31:0];
                    end
                    3'b110: begin // ORI
                        alu_res[31:0] = reg_1[31:0] | imm[31:0];
                    end
					3'b111: begin // ANDI
                        alu_res[31:0] = reg_1[31:0] & imm[31:0];
                    end
					3'b001: begin // SLLI
						alu_res[31:0] = reg_1[31:0] << { 27'b0, imm[4:0] };
					end
					3'b101: begin
	                    case(funct7)
		                    7'b0000000: begin //SRLI
								alu_res[31:0] = reg_1[31:0] >> $unsigned({27'b0, imm[4:0]});
					        end
				            7'b0100000: begin //SRAI
								alu_res[31:0] = $signed(reg_1[31:0]) >>> $signed({27'b0, imm[4:0]});
							end
							default: alu_res[31:0] = 32'h0000;
						endcase
					end
					default alu_res[31:0] = 32'h0000;
				endcase
			end
			`R_TYPE: begin // 7'b0110011
                case(funct3)
                    3'b000: begin // ADD & SUB
                        case(funct7)
							7'b0000000: begin // ADD
								alu_res[31:0] = reg_1[31:0] + reg_2[31:0];
							end
							7'b0100000: begin // SUB
								alu_res[31:0] = reg_1[31:0] - reg_2[31:0];
							end
							default: alu_res[31:0] = 32'h0000;
                        endcase
                    end
                    3'b001: begin // SLL
						alu_res[31:0] = reg_1[31:0] << reg_2[4:0];
                    end
                    3'b010: begin // SLT
						alu_res[31:0] = ($signed(reg_1[31:0]) < $signed(reg_2[31:0])) ? 1 : 0;
                    end
                    3'b011: begin // SLTU
						alu_res[31:0] = ($unsigned(reg_1[31:0]) < $unsigned(reg_2[31:0])) ? 1 : 0;
                    end
                    3'b100: begin // XOR
						alu_res[31:0] = reg_1[31:0] ^ reg_2[31:0];
                    end
                    3'b101: begin // SRL & SRA
                        case(funct7)
                            7'b0000000: begin //SRL
								alu_res = reg_1 >> reg_2[4:0];
							end
                            7'b0100000: begin //SRA
								alu_res = $signed(reg_1) >>> (reg_2[4:0]);	
                            end
							default: 
								alu_res[31:0] = 32'd0;
                        endcase
                    end
                    3'b110: begin // OR
						alu_res[31:0] = reg_1[31:0] | reg_2[31:0];
                    end
                    3'b111: begin // AND
						alu_res[31:0] = reg_1[31:0] & reg_2[31:0];
                    end
                endcase
            end
            `I_TYPE: begin
				case (opcode)
					7'b1100111: begin // JALR
						alu_res[31:0] = (reg_1[31:0] + imm[31:0]) & ~({ 31'b0, 1'b1 });
					end
					7'b0000011: begin // LB LH LW LBU LHU
						alu_res[31:0] = reg_1[31:0] + $signed(imm[31:0]);
					end
					7'b1110011: begin // ECALL
						alu_res[31:0] = 32'b0;
					end
					default alu_res[31:0] = 32'h0000;
				endcase
            end
            `S_TYPE: begin // SB SH SW
				alu_res[31:0] = reg_1[31:0] + imm[31:0];
            end
            `B_TYPE: begin // BEQ BNE BLT BGE BLTU BGEU
				alu_res[31:0] = pc[31:0] + imm[31:0];            
			end
            `U_TYPE: begin // LUI AUIPC
				case (opcode)
					7'b0110111: alu_res[31:0] = imm[31:0];
					7'b0010111: alu_res[31:0] = pc[31:0] + imm[31:0];
					default alu_res[31:0] = 32'h0000;
				endcase
            end
            `J_TYPE: begin // JAL
				alu_res[31:0] = pc[31:0] + imm[31:0];
            end
            default: alu_res[31:0] = 32'h0000;
        endcase
    end

	always @(*) begin
		if (reset || !valid) begin
			br_taken = 0;
		end else begin
			case (opcode)
				`B_TYPE: begin
					case(funct3)
						3'b000: begin //BEQ
							br_taken = (reg_1 == reg_2) ? 1:0;
						end
					    3'b001: begin //BNE
				            br_taken = (reg_1 != reg_2) ? 1:0;
					    end
						3'b100: begin //BLT
							br_taken = ($signed(reg_1) < $signed(reg_2)) ? 1:0;
						end
			            3'b101: begin //BGE
							br_taken = ($signed(reg_1) >= $signed(reg_2)) ? 1:0;
						end
						3'b110: begin //BLTU
							br_taken = ($unsigned(reg_1) < $unsigned(reg_2)) ? 1:0;
						end
					    3'b111: begin //BGEU
					        br_taken = ($unsigned(reg_1) >= $unsigned(reg_2)) ? 1:0;
					    end
						default: begin
							br_taken = 0;
						end
					endcase
				end
				7'b1100111, 7'b1101111: begin
					br_taken = 1;
				end
				default: begin
					br_taken = 0;
				end
			endcase
		end
	end
endmodule



