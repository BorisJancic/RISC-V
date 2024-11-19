
module ME_WB(
	input clock,
	input reset,
	input valid_in,
	input[31:0] pc_in,

	input wb_enable_in,
	input[4:0] rs_d_in,
	input[31:0] reg_d_in,

	output reg[31:0] pc_out,
	output reg wb_enable_out,
	output reg[4:0] rs_d_out,
	output reg[31:0] reg_d_out
);
	always @(posedge clock) begin
		if (reset || !valid_in) begin
			wb_enable_out <= 0;
		end else begin
			wb_enable_out <= wb_enable_in;
		end

		if (reset) begin
			pc_out[31:0] <= 32'd0;
			rs_d_out[4:0] <= 5'd0;
			reg_d_out[31:0] <= 32'd0;
		end else begin
			pc_out[31:0] <= pc_in[31:0];
			rs_d_out[4:0] <= rs_d_in[4:0];
			reg_d_out[31:0] <= reg_d_in[31:0];
		end
	end
endmodule


