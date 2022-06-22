module Cache_Controller (clk, rst, MEM_R_EN, MEM_W_EN, SRAM_ready, write_data, address, SRAM_read_data, ready, final_hit, read_data);
	input             clk;
	input             rst;
	
	// Memory Stage 
	input             MEM_R_EN;
	input             MEM_W_EN;
	input             SRAM_ready;
	input [31:0]      write_data;
	input [31:0]      address;
	input [63:0]      SRAM_read_data;

	output            ready;
	output            final_hit;	
	output [31:0]     read_data;

	wire hit;
	  
	Cache cache (
		.rst(rst),
		.MEM_R_EN(MEM_R_EN),
		.MEM_W_EN(MEM_W_EN),
		.SRAM_ready(SRAM_ready),
		.address(address),
		.SRAM_read_data(SRAM_read_data),
		.read_data(read_data),
		.hit(hit)
	);
  
  	assign final_hit = (MEM_R_EN) ? hit : 1'b0;

    assign ready = final_hit | SRAM_ready;

endmodule

