
module cpu(
	input clock,
	input reset
);
	reg read_write_imem;
	
	// Signal
	wire[6:0] ID_opcode;
	wire[4:0] ID_rd;
	wire[4:0] ID_rs1;
	wire[4:0] ID_rs2;
	wire[2:0] ID_funct3;
	wire[6:0] ID_funct7;
	wire[4:0] ID_shamt;

	wire ME_read_write;
    wire[1:0] ME_size_encoded;

	wire[4:0] ID_rs_1;
	wire[4:0] ID_rs_2;

	assign ID_opcode[6:0] = ID_instruction[6:0];
    assign ID_rd[4:0] = ID_instruction[11:7];
    assign ID_rs1[4:0] = ID_instruction[19:15];
    assign ID_rs2[4:0] = ID_instruction[24:20];
    assign ID_funct3[2:0] = ID_instruction[14:12];
    assign ID_funct7[6:0] = ID_instruction[31:25];
    assign ID_shamt[4:0] = ID_instruction[24:20];

    assign ME_size_encoded[1:0] = ME_instruction[13:12];

	assign ID_rs_1[4:0] = ID_instruction[19:15];
	assign ID_rs_2[4:0] = ID_instruction[24:20];

	// Variable name order (have wires defined at the top of the file)
	// Control signals
	wire br_taken;
	wire jp_taken;
	wire stall;

	wire stall_1;
	wire stall_2;
	wire forward_reg_1_EX;
	wire forward_reg_2_EX;
	wire forward_reg_1_ME;
	wire forward_reg_2_ME;
	wire[31:0] forward_reg_2_val_ME;

	// IF
	reg [31:0] data_in;
 
	wire IF_valid;
	wire[31:0] IF_pc;
	wire[31:0] IF_instruction;

	// ID
	wire ID_valid;
	wire[31:0] ID_pc;
    wire[31:0] ID_instruction;
	wire[31:0] ID_reg_1;
    wire[31:0] ID_reg_2;
    wire[31:0] ID_imm;

	// EX
    wire EX_valid;
    wire[31:0] EX_pc;
    wire[31:0] EX_instruction;
    wire[31:0] EX_reg_1;
    wire[31:0] EX_reg_2;
    wire[31:0] EX_imm;
	wire[31:0] EX_alu_res;

	// ME
	wire ME_valid;
    wire[31:0] ME_pc;
    wire[31:0] ME_instruction;
    wire[31:0] ME_alu_res;
    wire[31:0] ME_reg_2;
	wire[31:0] ME_mem_res;

	wire ME_wb_enable;
    wire[4:0] ME_rs_d;
    wire[31:0] ME_reg_d;

	// WB
	wire[31:0] WB_pc;
	wire WB_wb_enable;
    wire[4:0] WB_rs_d;
	wire[31:0] WB_reg_d;

	fetch fetch_0(
		.clock(clock),
		.reset(reset),
		.br_taken(br_taken),
		.jp_taken(jp_taken),
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
		.branch(br_taken || jp_taken),
		.stall(stall),

		.valid_out(ID_valid),
		.pc_out(ID_pc),
		.instruction_out(ID_instruction)
	);
	register_file register_file_0(
		.clock(clock),
		.reset(reset),
		.instruction(ID_instruction),
		
		.wb_enable(WB_wb_enable),
		.rs_d(WB_rs_d),
		.reg_d(WB_reg_d),

		.reg_1(ID_reg_1),
		.reg_2(ID_reg_2)
	);
	decode decode_0(
		.instruction(ID_instruction),
		
		.imm(ID_imm)
	);
	ID_EX ID_EX_0(
		.clock(clock),
		.reset(reset),
		.valid_in(ID_valid),
		.pc_in(ID_pc),
		.instruction_in(ID_instruction),
		.reg_1_in(ID_reg_1),
		.reg_2_in(ID_reg_2),
		.imm_in(ID_imm),
		.branch(br_taken || jp_taken),

		.EX_valid(EX_valid),
	    .EX_instruction(EX_instruction),
		.EX_alu_res(EX_alu_res),

		.ME_valid(ME_valid),
		.ME_wb_enable(ME_wb_enable),
        .ME_rs_d(ME_rs_d),
        .ME_reg_d(ME_reg_d),

		.WB_wb_enable(WB_wb_enable),
		.WB_rs_d(WB_rs_d),

		.valid_out(EX_valid),
		.pc_out(EX_pc),
		.instruction_out(EX_instruction),
		.reg_1_out(EX_reg_1),
		.reg_2_out(EX_reg_2),
		.imm_out(EX_imm),
		.stall_out(stall)
/*		.stall_1_out(stall_1),
		.stall_2_out(stall_2),
		.forward_reg_1_EX_out(forward_reg_1_EX),
		.forward_reg_2_EX_out(forward_reg_2_EX),
		.forward_reg_1_ME_out(forward_reg_1_ME),
		.forward_reg_2_ME_out(forward_reg_2_ME),
		.forward_reg_2_val_ME(forward_reg_2_val_ME)*/
	);
	execute execute_0(
		.reset(reset),
		.valid(EX_valid),
		.pc(EX_pc),
		.instruction(EX_instruction),
		.reg_1(EX_reg_1),
		.reg_2(EX_reg_2),
		.imm(EX_imm),

		.alu_res(EX_alu_res),
		.br_taken(br_taken),
		.jp_taken(jp_taken)
	);
	EX_ME EX_ME_0(
		.clock(clock),
		.reset(reset),
		.valid_in(EX_valid),
		.pc_in(EX_pc),
		.instruction_in(EX_instruction),
		.alu_res_in(EX_alu_res),
		.reg_2_in(EX_reg_2),

		.ME_valid(ME_valid),
		.ME_instruction(ME_instruction),
		.ME_alu_res(ME_alu_res),
		.ME_mem_res(ME_mem_res),

		.valid_out(ME_valid),
		.pc_out(ME_pc),
		.instruction_out(ME_instruction),
		.alu_res_out(ME_alu_res),
		.reg_2_out(ME_reg_2)
	);
	memory memory_0(
		.clock(clock),
		.reset(reset),
		.valid(ME_valid),
		.instruction(ME_instruction),
		.alu_res(ME_alu_res),
		.reg_2(ME_reg_2),

		.read_write_out(ME_read_write),		
		.mem_res(ME_mem_res)
	);
	writeback writeback_0(
		.clock(clock),
		.reset(reset),
		.valid(ME_valid),
		.pc(ME_pc),
		.instruction(ME_instruction),
		.mem_res(ME_mem_res),
		.alu_res(ME_alu_res),

		.wb_enable(ME_wb_enable),
		.rs_d(ME_rs_d),
		.reg_d(ME_reg_d)
	);
	ME_WB ME_WB_0(
		.clock(clock),
		.reset(reset),
		.pc_in(ME_pc),
		.valid_in(ME_valid),
		.wb_enable_in(ME_wb_enable),
		.rs_d_in(ME_rs_d),
		.reg_d_in(ME_reg_d),
		
		.pc_out(WB_pc),
		.wb_enable_out(WB_wb_enable),
		.rs_d_out(WB_rs_d),
		.reg_d_out(WB_reg_d)
	);
endmodule


