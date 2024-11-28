
module fetch(
	input clock,
	input reset,
	input branch,
	input stall,
	input[31:0] alu_res,

	input read_write_imem,
	input[31:0] imem_data_in,

	output reg valid,
	output[31:0] pc_out,
	output[31:0] instruction
);
	reg[31:0] pc = 32'h01000000;
	assign pc_out = pc;

	always @(*) begin
		if (reset) begin
			valid = 0;
		end else begin
			valid = 1;
		end
	end

	always @(posedge clock) begin
		if (reset) begin
			pc <= 32'h01000000;
		end else if (branch) begin
			pc <= alu_res;
		end else if (stall) begin
			pc <= pc;
		end else begin
		    pc <= pc + 4;
		end
	end

	imemory imemory_0(
		.clock(clock),
		.enable(!stall),
		.read_write(read_write_imem),
		.address(pc),
		.data_in(imem_data_in),
		.data_out(instruction)
	);

endmodule

