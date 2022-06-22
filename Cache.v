module Cache (rst, MEM_R_EN, MEM_W_EN, SRAM_ready, address, SRAM_read_data, read_data, hit);
	input             rst;
	input             MEM_R_EN;
	input             MEM_W_EN;
	input			  SRAM_ready;
	input [31:0]      address;
	
	input [63:0]      SRAM_read_data;
	output [31:0]     read_data;
	output            hit;
	
	/*
	Cache
	---------------------------------------------------------------
	|           set 0           |           set 1           | LRU |
	---------------------------------------------------------------
	| data | data | tag | valid | data | data | tag | valid | LRU |
	---------------------------------------------------------------
	|  32  |  32  | 10  |   1   |  32  |  32  | 10  |   1   |  1  |
	---------------------------------------------------------------
	|                            151                              |
	---------------------------------------------------------------
	*/
	
	/*
	Address
	-----------------------
	| tag | index | offset|
	-----------------------
	| 10  |   6   |   3   |
	-----------------------
	|         19          |
	-----------------------
	*/
	
	reg [31:0] fst_data_set_0[0:63];
	reg [31:0] sec_data_set_0[0:63];
	reg [9:0] tag_set_0[0:63];
	reg valid_set_0[0:63];
	
	reg [31:0] fst_data_set_1[0:63];
	reg [31:0] sec_data_set_1[0:63];
	reg [9:0] tag_set_1[0:63];
	reg valid_set_1[0:63];
	
	reg LRU[0:63];

	
	wire [31:0] data_address;
	wire [31:0] cache_address;
	assign data_address = address - 32'd1024;
	assign cache_address = data_address;
	
	wire [9:0] tag;
	wire [5:0] index;
	wire [2:0] offset;
	
	assign tag = cache_address[18:9];
	assign index = cache_address[8:3];
	assign offset = cache_address[2:0];
	
	// reg select_set_0;
	// reg select_set_1;

	wire select_set_0, select_set_1;
	
	// valid bit should be initialized with 0
	integer i;

	initial begin
		for (i = 0; i < 64; i = i + 1) begin
			valid_set_0[i] <= 1'b0;
			valid_set_1[i] <= 1'b0;
			LRU[i] <= 1'b0;
		end
	end
	
	wire [31:0] data_set_0;
	wire [31:0] data_set_1;
	
	assign data_set_0 = offset[2] ? sec_data_set_0[index] : fst_data_set_0[index];
	assign data_set_1 = offset[2] ? sec_data_set_1[index] : fst_data_set_1[index];
	
	assign read_data = select_set_0 ? data_set_0 : (select_set_1 ? data_set_1 : read_data);

	assign hit = (select_set_0 | select_set_1);
	

	assign select_set_0 = ((tag_set_0[index] == tag) && (valid_set_0[index] == 1'b1)) ? 1'b1 : 1'b0;
	assign select_set_1 = ((tag_set_1[index] == tag) && (valid_set_1[index] == 1'b1)) ? 1'b1 : 1'b0;


	always @ (*) begin
		if (rst) begin
			for (i = 0; i < 64; i = i + 1) begin
				valid_set_0[i] <= 1'b0;
				valid_set_1[i] <= 1'b0;
				LRU[i] <= 1'b0;
			end
		end

		// if (tag_set_0[index] == tag) begin
		// 	if (valid_set_0[index] == 1'b1) 
		// 		select_set_0 = 1'b1;
		// 	else  
		// 		select_set_0 = 1'b0;
		// end 
		// else if (tag_set_1[index] == tag) begin
		// 	if (valid_set_1[index] == 1'b1) 
		// 		select_set_1 = 1'b1;
		// 	else  
		// 		select_set_1 = 1'b0;
		// end 
		// else begin
		// 	select_set_0 = 1'b0;
		// 	select_set_1 = 1'b0;
		// end

		// Read
		// if hit = 0 then we should go to sram -> sram_r_en = 1 -> after 6 clk give result -> write it in cache and next stage
		if((MEM_R_EN == 1'b1) && (SRAM_ready==1'b1) && (hit == 1'b0) && LRU[index] == 1'b1) begin
			fst_data_set_0[index] <= SRAM_read_data[63:32];
			sec_data_set_0[index] <= SRAM_read_data[31:0];
			tag_set_0[index] <= tag;
			valid_set_0[index] <= 1'b1;
		end
		
		else if((MEM_R_EN == 1'b1) && (SRAM_ready==1'b1) && (hit == 1'b0) && LRU[index] == 1'b0) begin
			fst_data_set_1[index] <= SRAM_read_data[63:32];
			sec_data_set_1[index] <= SRAM_read_data[31:0];
			tag_set_1[index] <= tag;
			valid_set_1[index] <= 1'b1;
		end

		// Write
		else if(select_set_0 && MEM_W_EN == 1'b1)
			valid_set_0[index] = 1'b0;
		else if  (select_set_1 && MEM_W_EN == 1'b1)
			valid_set_1[index] = 1'b0;
		else if(hit)
			LRU[index] = select_set_1;
		
	end

endmodule
