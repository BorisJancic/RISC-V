module ME_WB(
	input clock,
	input reset,
	input valid_in,
	input[31:0] pc_in,
	input[6:0] opcode_in,
	input[2:0] funct3_in,
    input[4:0] rd_in,
	
    input[31:0] alu_res_in,
	input[31:0] mem_res_in,

	output reg valid_out,
	output reg[31:0] pc_out,
	output reg[6:0] opcode_out,
	output reg[2:0] funct3_out,
    output reg[4:0] rd_out,
	
	output reg[31:0] alu_res_out,
	output wire[31:0] mem_res_out
);
	assign mem_res_out = mem_res_in;
	
	always @(posedge clock) begin
		if (reset || !valid_in) begin
			valid_out <= 0;
			pc_out[31:0] <= pc_in[31:0];
			// pc_out <= 32'd0;
			opcode_out <= 7'd0;
			funct3_out <= 3'd0;
			rd_out <= 5'd0;

			alu_res_out <= 32'd0;
		end else begin
			valid_out <= 1;
			pc_out <= pc_in;
			opcode_out <= opcode_in;
			funct3_out <= funct3_in;
			rd_out <= rd_in;
			
			alu_res_out <= alu_res_in;
		end
	end
endmodule


