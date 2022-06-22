`timescale 1ns/1ns

module TB();

	reg clk = 1, rst = 0;
	reg Forward_EN = 1;
	
	wire NN, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N;
  wire [15:0] SRAM_DQ;
  wire [18:0] SRAM_ADDR;

	SRAM sram(
		.clk(clk),
		.rst(rst),
		.SRAM_WE_N(SRAM_WE_N),
		.SRAM_ADDR(SRAM_ADDR),
		.SRAM_DQ(SRAM_DQ),
		.SRAM_UB_N(SRAM_UB_N),
		.SRAM_LB_N(SRAM_LB_N),
		.SRAM_CE_N(SRAM_CE_N),
		.SRAM_OE_N(SRAM_OE_N)
	);

	ARM_Pr arm (
		.clk(clk),
		.rst(rst),
		.Forward_EN(Forward_EN),
		.NoName(NN),
		.SRAM_DQ(SRAM_DQ), 
		.SRAM_ADDR(SRAM_ADDR), 
		.SRAM_UB_N(SRAM_UB_N), 
		.SRAM_LB_N(SRAM_LB_N), 
		.SRAM_WE_N(SRAM_WE_N), 
		.SRAM_CE_N(SRAM_CE_N), 
		.SRAM_OE_N(SRAM_OE_N)
		);

	
	integer cyclenum = 0;
	always #150 clk = ~clk;
	always #300 cyclenum = cyclenum + 1;

	initial begin
		#100
		rst = 1;
		#300
		rst = 0;

		#1000000
		$stop;
	end

endmodule 