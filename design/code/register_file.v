module register_file #(
    parameter MEM_START = 32'h01000000
) (
    input clock,
	input reset,
	input[31:0] instruction,

	input wb_enable,
	input[4:0] rs_d,
    input[31:0] reg_d,

	output reg [31:0] reg_1,
    output reg [31:0] reg_2
);
	wire[4:0] rs_2;
	wire[4:0] rs_1;
	assign rs_2[4:0] = instruction[24:20];
	assign rs_1[4:0] = instruction[19:15];

	(* ram_style = "block" *) reg[31:0] reg_file_mem[31:0];
	always @(*) begin reg_file_mem[0][31:0] = { 32'b0 }; end

    // read with combinational logic
    always @(*) begin
        reg_1 = reg_file_mem[rs_1];
        reg_2 = reg_file_mem[rs_2];
    end

    // write with sequential logic
	integer j;
	always @(posedge clock) begin
		if (reset) begin
			for (j = 0; j <= 31; j = j + 1) begin
				if (i == 2) reg_file_mem[i] = MEM_START + `MEM_DEPTH; // R2
				else reg_file_mem[i] = 32'd0;
			end
		end else begin // check for valid? or is valid in WB good enough
			if (wb_enable && rs_d != 0) begin // R0 is always 0
				reg_file_mem[rs_d] <= reg_d;
			end
		end
    end

	// initialize registers
	integer i;
    initial begin
        for (i = 0; i <= 31; i = i + 1) begin
            if (i == 2) begin // x2
                reg_file_mem[i] = MEM_START + `MEM_DEPTH;
            end else begin
                reg_file_mem[i] = 32'b0;
            end
        end
    end
endmodule


