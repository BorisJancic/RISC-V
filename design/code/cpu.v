
module cpu(
	input clock,
	input reset
);
	reg read_write_imem;
	
	// Signal
	(* dont_touch = "true" *) wire[4:0] ID_shamt;

	// Variable name order (have wires defined at the top of the file)
	// Control signals
	(* dont_touch = "true" *) wire branch;
	wire stall;

	/*wire stall_1;
	wire stall_2;
	wire forward_reg_1_EX;
	wire forward_reg_2_EX;
	wire forward_reg_1_ME;
	wire forward_reg_2_ME;
	wire[31:0] forward_reg_2_val_ME;*/

	// IF
	reg [31:0] data_in;
 
	wire IF_valid;
	(* dont_touch = "true" *) wire[31:0] IF_pc;
	(* dont_touch = "true" *) wire[31:0] IF_instruction;

	// ID
	wire ID_valid;
	(* dont_touch = "true" *) wire[31:0] ID_pc;
	wire[31:0] ID_instruction;

	(* dont_touch = "true" *) wire[6:0] ID_opcode;
	(* dont_touch = "true" *) wire[2:0] ID_funct3;
	(* dont_touch = "true" *) wire[6:0] ID_funct7;
	(* dont_touch = "true" *) wire[4:0] ID_rs1;
	(* dont_touch = "true" *) wire[4:0] ID_rs2;
	(* dont_touch = "true" *) wire[4:0] ID_rd;
	(* dont_touch = "true" *) wire[31:0] ID_imm;
	(* dont_touch = "true" *) wire[31:0] ID_reg_1;
    (* dont_touch = "true" *) wire[31:0] ID_reg_2;

	// EX
    wire EX_valid;
    (* dont_touch = "true" *) wire[31:0] EX_pc;
	wire[6:0] EX_opcode;
	wire[2:0] EX_funct3;
	wire[6:0] EX_funct7;
	wire[4:0] EX_rs1;
	wire[4:0] EX_rs2;
	wire[4:0] EX_rd;
	wire[31:0] EX_imm;

	wire[31:0] EX_reg_1;
    wire[31:0] EX_reg_2;
	wire[31:0] EX_reg_1_selected;
	wire[31:0] EX_reg_2_selected;
	(* dont_touch = "true" *) wire[31:0] EX_alu_res;
	
	// ME
	wire ME_valid;
    (* dont_touch = "true" *) wire[31:0] ME_pc;
	wire[6:0] ME_opcode;
	wire[2:0] ME_funct3;
	wire[4:0] ME_rs2;
	wire[4:0] ME_rd;
    (* dont_touch = "true" *) wire[31:0] ME_alu_res;
	wire[31:0] ME_reg_2;
    (* dont_touch = "true" *) wire[31:0] ME_reg_2_selected;
	wire[31:0] ME_mem_res;
	(* dont_touch = "true" *) wire ME_read_write;
	(* dont_touch = "true" *) wire[1:0] ME_size_encoded;

	// WB
	wire WB_valid;
	(* dont_touch = "true" *) wire[31:0] WB_pc;
	wire[6:0] WB_opcode;
	(* dont_touch = "true" *) wire[4:0] WB_rd;
	wire[2:0] WB_funct3;
	wire[31:0] WB_alu_res;
	wire[31:0] WB_mem_res;

	(* dont_touch = "true" *) wire WB_wb_enable;
	(* dont_touch = "true" *) wire[31:0] WB_reg_d;

	// Signals
	assign ID_shamt[4:0] = ID_instruction[24:20];
	assign ME_size_encoded[1:0] = ME_funct3[1:0];

	fetch fetch_0(
		.clock(clock),
		.reset(reset),
		.branch(branch),
		.stall(stall),
		.alu_res(EX_alu_res),
		.read_write_imem(read_write_imem),
		.imem_data_in(data_in),
		
		.valid(IF_valid),
		.pc_out(IF_pc),
		.instruction(IF_instruction)
	);
	IF_ID IF_ID_0(
		.clock(clock),
		.reset(reset),
		.valid_in(IF_valid),
		.pc_in(IF_pc),
		.instruction_in(IF_instruction),
		.branch(branch),
		.stall(stall),

		.valid_out(ID_valid),
		.pc_out(ID_pc),
		.instruction_out(ID_instruction)
	);
	decode decode_0(
		.instruction(ID_instruction),
				
		.opcode_out(ID_opcode),
		.funct3_out(ID_funct3),
		.funct7_out(ID_funct7),
		.rs1_out(ID_rs1),
		.rs2_out(ID_rs2),
		.rd_out(ID_rd),
		.imm(ID_imm)
	);
	register_file register_file_0(
		.clock(clock),
		.reset(reset),
		.rs1(ID_rs1),
		.rs2(ID_rs2),

		.wb_enable(WB_wb_enable),
		.rd(WB_rd),
		.reg_d(WB_reg_d),

		.reg_1(ID_reg_1),
		.reg_2(ID_reg_2)
	);
	ID_EX ID_EX_0(
		.clock(clock),
		.reset(reset),
		.branch(branch),
		.stall(stall),
		.valid_in(ID_valid),
		.pc_in(ID_pc),
		.opcode_in(ID_opcode),
		.funct3_in(ID_funct3),
		.funct7_in(ID_funct7),
		.rs1_in(ID_rs1),
		.rs2_in(ID_rs2),
		.rd_in(ID_rd),
		.imm_in(ID_imm),
		.reg_1_in(ID_reg_1),
		.reg_2_in(ID_reg_2),

		.valid_out(EX_valid),
		.pc_out(EX_pc),
		.opcode_out(EX_opcode),
		.funct3_out(EX_funct3),
		.funct7_out(EX_funct7),
		.rs1_out(EX_rs1),
		.rs2_out(EX_rs2),
		.rd_out(EX_rd),
		.imm_out(EX_imm),
		.reg_1_out(EX_reg_1),
		.reg_2_out(EX_reg_2)
	);
	stall stall0(
		.ID_valid(ID_valid),
		.ID_opcode(ID_opcode),
		.ID_rs1(ID_rs1),
		.ID_rs2(ID_rs2),
		
		.EX_valid(EX_valid),
		.EX_opcode(EX_opcode),
		.EX_rd(EX_rd),

		.ME_rd(ME_rd),

		.WB_wb_enable(WB_wb_enable),
		.WB_rd(WB_rd),

		.stall(stall)
	);
	forward_EX forward_EX0(
		.EX_opcode(EX_opcode),
		.EX_rs1(EX_rs1),
		.EX_rs2(EX_rs2),
		.EX_reg_1(EX_reg_1),
		.EX_reg_2(EX_reg_2),
	
		.ME_opcode(ME_opcode),
		.ME_rd(ME_rd),
		.ME_alu_res(ME_alu_res),

		.WB_wb_enable(WB_wb_enable),
		.WB_rd(WB_rd),
		.WB_reg_d(WB_reg_d),

		.reg_1_selected(EX_reg_1_selected),
		.reg_2_selected(EX_reg_2_selected)
	);
	execute execute_0(
		.reset(reset),
		.valid(EX_valid),
		.pc(EX_pc),
		.opcode(EX_opcode),
		.funct3(EX_funct3),
		.funct7(EX_funct7),
		.imm(EX_imm),
		.reg_1(EX_reg_1_selected),
		.reg_2(EX_reg_2_selected),

		.alu_res(EX_alu_res),
		.br_taken(branch)
	);
	EX_ME EX_ME_0(
		.clock(clock),
		.reset(reset),
		.valid_in(EX_valid),
		.pc_in(EX_pc),
		.opcode_in(EX_opcode),
		.funct3_in(EX_funct3),
		.rs2_in(EX_rs2),
		.rd_in(EX_rd),

		.alu_res_in(EX_alu_res),
		.reg_2_in(EX_reg_2_selected),
		
		.valid_out(ME_valid),
		.pc_out(ME_pc),
		.opcode_out(ME_opcode),
		.funct3_out(ME_funct3),
		.rs2_out(ME_rs2),
		.rd_out(ME_rd),

		.alu_res_out(ME_alu_res),
		.reg_2_out(ME_reg_2)
	);
	forward_ME forward_ME0(
		.ME_opcode(ME_opcode),
		.ME_rs2(ME_rs2),
		.ME_reg_2(ME_reg_2),
	
		.WB_wb_enable(WB_wb_enable),
		.WB_rd(WB_rd),
		.WB_reg_d(WB_reg_d),

		.reg_2_selected(ME_reg_2_selected)
	);
	memory memory_0(
		.clock(clock),
		.reset(reset),
		.valid(ME_valid),
		.opcode(ME_opcode),
		.funct3(ME_funct3),
		.alu_res(ME_alu_res),
		.reg_2(ME_reg_2_selected),

		.read_write_out(ME_read_write),		
		.mem_res(ME_mem_res)
	);
	ME_WB ME_WB_0(
		.clock(clock),
		.reset(reset),
		.valid_in(ME_valid),
		.pc_in(ME_pc),
		.opcode_in(ME_opcode),
		.funct3_in(ME_funct3),
		.rd_in(ME_rd),
		
		.alu_res_in(ME_alu_res),
		.mem_res_in(ME_mem_res),
	
		.valid_out(WB_valid),	
		.pc_out(WB_pc),
		.opcode_out(WB_opcode),
		.funct3_out(WB_funct3),
		.rd_out(WB_rd),

		.alu_res_out(WB_alu_res),
		.mem_res_out(WB_mem_res)
	);
	writeback writeback_0(
		.clock(clock),
		.reset(reset),
		.valid(WB_valid),
		.pc(WB_pc),
		.opcode(WB_opcode),
		.rd(WB_rd),
		.funct3(WB_funct3),
		
		.mem_res(WB_mem_res),
		.alu_res(WB_alu_res),

		.wb_enable(WB_wb_enable),
		.reg_d(WB_reg_d)
	);

endmodule


