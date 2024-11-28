
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                IF_pc
`define F_INSN              IF_instruction

`define D_PC                ID_pc
`define D_OPCODE            ID_opcode
`define D_RD                ID_rd
`define D_RS1               ID_rs1
`define D_RS2               ID_rs2
`define D_FUNCT3            ID_funct3
`define D_FUNCT7            ID_funct7
`define D_IMM               ID_imm
`define D_SHAMT             ID_shamt
//`define D_STALL				stall
//`define D_STALL_1           stall0.stall_1
//`define D_STALL_2           stall0.stall_2
//`define	D_F_R1_ME			forward_EX0.forward_reg_1_ME
//`define	D_F_R2_ME			forward_EX0.forward_reg_2_ME
//`define	D_F_R1_WB			forward_EX0.forward_reg_1_WB
//`define	D_F_R2_WB			forward_EX0.forward_reg_2_WB
/*
`define D_F_REG_2_ME		forward_reg_2_val_ME*/

`define R_WRITE_ENABLE      WB_wb_enable
`define R_WRITE_DESTINATION WB_rd
`define R_WRITE_DATA        WB_reg_d
`define R_READ_RS1          ID_rs1
`define R_READ_RS2          ID_rs2
`define R_READ_RS1_DATA     ID_reg_1
`define R_READ_RS2_DATA     ID_reg_2

`define E_PC                EX_pc
`define E_ALU_RES           EX_alu_res
`define E_BR_TAKEN			branch
// `define E_OPCODE			EX_opcode
// `define E_REG_1				EX_reg_1
// `define E_REG_2				EX_reg_2

`define M_PC                ME_pc
`define M_ADDRESS           ME_alu_res
`define M_RW                ME_read_write
`define M_SIZE_ENCODED      ME_size_encoded
`define M_DATA              ME_reg_2_selected //ME_mem_res

`define W_PC                WB_pc
`define W_ENABLE            WB_wb_enable
`define W_DESTINATION       WB_rd
`define W_DATA              WB_reg_d

`define IMEMORY             fetch_0.imemory_0
`define DMEMORY             memory_0.dmemory_0

// ----- signals -----

// ----- design -----
`define TOP_MODULE          cpu
// ----- design -----
