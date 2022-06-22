module SRAM(clk, rst, SRAM_WE_N, SRAM_ADDR, SRAM_DQ, SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N);
	input clk, rst, SRAM_WE_N;
	input [18:0]SRAM_ADDR;
	inout [15:0]SRAM_DQ;
	input SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N;

	reg [15:0]memory[0:63];
	
	assign SRAM_DQ = SRAM_WE_N ? memory[SRAM_ADDR] : 16'bzzzz_zzzz_zzzz_zzzz;
	
	always@(posedge clk) begin
		if(~SRAM_WE_N) begin
			memory[SRAM_ADDR] <= SRAM_DQ;
		end
	end
endmodule
