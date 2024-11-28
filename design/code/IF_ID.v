
module IF_ID (
	input clock,
	input reset,
	input valid_in,
	input[31:0] pc_in,
	input[31:0] instruction_in,
	input branch,
	input stall,

	output reg valid_out,
	output reg[31:0] pc_out,
	output wire[31:0] instruction_out
);
	assign instruction_out = instruction_in;

	always @(posedge clock) begin
		if (reset || branch) begin
			valid_out <= 0;
			pc_out[31:0] <= pc_in[31:0];
			// pc_out[31:0] <= 32'd0;
		end else if (stall) begin
			// keep the same
			// keep the same
		end else begin
			valid_out <= valid_in;
			pc_out[31:0] <= pc_in[31:0];
		end
	end
endmodule



