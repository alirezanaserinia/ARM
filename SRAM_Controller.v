module SRAM_Controller (clk, rst, read_en, write_en, address, write_data, read_data, ready, SRAM_DQ, 
                            SRAM_ADDR, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N);
  input             clk;
  input             rst;

  //From Memory Stage
  input             read_en;
  input             write_en; 
  input [31:0]      address;
  input [31:0]      write_data;
  
  //To Next Stage
  output [63:0]     read_data;

  //For Freeze Other Stage
  output            ready;

  inout [15:0]         SRAM_DQ;    // SRAM Data bus 16 Bits
  output  [18:0]    SRAM_ADDR;  // SRAM Address Bus 18 Bits
  output            SRAM_UB_N;  // SRAM High-Byte Data Mask
  output            SRAM_LB_N;  // SRAM Low-Byte Data Mask
  output            SRAM_WE_N;  // SRAM Write Enable
  output            SRAM_CE_N;  // SRAM Chip Enable
  output            SRAM_OE_N;  // SRAM Output Enable
  
  
reg [2:0] counter;

  always @ (posedge clk, posedge rst) begin
    if (rst) 
		  counter <= 3'b000;
    else begin
      if ((write_en || read_en) && (counter < 3'b101))
	  	  counter <= counter + 3'b001;
      else 
	  	  counter <= 3'b000;
    end
  end
  
  assign ready = ((write_en || read_en) && (counter < 3'b101)) ? 1'b0 : 1'b1;
  
  wire [31:0] data_address;
  assign data_address = address - 1024;

  
  // LDR
  wire [15:0] temp1_high, temp1_low, temp2_high, temp2_low;

  Reg #(.WIDTH(16)) Reg1 (
		.clk(clk),
		.rst(rst),
		.d(SRAM_DQ),
		.en((read_en) && (counter == 3'b001)),
		.q(temp1_high)
		);

  Reg #(.WIDTH(16)) Reg2 (
		.clk(clk),
		.rst(rst),
		.d(SRAM_DQ),
		.en((read_en) && (counter == 3'b010)),
		.q(temp1_low)
		);

  Reg #(.WIDTH(16)) Reg3 (
		.clk(clk),
		.rst(rst),
		.d(SRAM_DQ),
		.en((read_en) && (counter == 3'b011)),
		.q(temp2_high)
		);

  Reg #(.WIDTH(16)) Reg4 (
		.clk(clk),
		.rst(rst),
		.d(SRAM_DQ),
		.en((read_en) && (counter == 3'b100)),
		.q(temp2_low)
		);
  
	assign read_data = {temp1_high, temp1_low, temp2_high, temp2_low} ;

  // STR
  assign SRAM_WE_N = ((write_en) && ((counter == 3'b001) || (counter == 3'b010))) ? 1'b0 : 1'b1;

  assign SRAM_DQ = ((write_en) && (counter == 3'b001)) ? write_data[31:16] : 
					((write_en) && (counter == 3'b010)) ? write_data[15:0] : 16'bzzzz_zzzz_zzzz_zzzz;

	// assign SRAM_ADDR =  ((write_en) && (counter == 3'b001)) ? data_address[19:1] :
  //                     ((write_en) && (counter == 3'b010)) ? data_address[19:1] + 19'b0000_0000_0000_0000_01 :
  //                     ((read_en) &&  (counter == 3'b001)) ? data_address[19:1] :
  //                     ((read_en) &&  (counter == 3'b010)) ? data_address[19:1] + 19'b0000_0000_0000_0000_01 :

  //                     // ((write_en) && (counter == 3'b011)) ? data_address[19:1] + 19'b0000_0000_0000_0000_10 :
  //                     // ((write_en) && (counter == 3'b100)) ? data_address[19:1] + 19'b0000_0000_0000_0000_11 :
  //                     ((read_en) &&  (counter == 3'b011)) ? data_address[19:1] + 19'b0000_0000_0000_0000_10 :
  //                     ((read_en) &&  (counter == 3'b100)) ? data_address[19:1] + 19'b0000_0000_0000_0000_11 :
  //                     18'bzzzz_zzzz_zzzz_zzzz;

  assign SRAM_ADDR =  ((write_en) && (counter == 3'b001)) ? {data_address[19:1]} :
                      ((write_en) && (counter == 3'b010)) ? {data_address[19:1]} + 19'b0000_0000_0000_0000_01 :
                      
                      ((read_en) &&  (counter == 3'b001)) ? {data_address[19:3], 2'b00} :
                      ((read_en) &&  (counter == 3'b010)) ? {data_address[19:3], 2'b01} :
                      ((read_en) &&  (counter == 3'b011)) ? {data_address[19:3], 2'b10} :
                      ((read_en) &&  (counter == 3'b100)) ? {data_address[19:3], 2'b11} :
                      19'bzzzz_zzzz_zzzz_zzzz_zzz;

endmodule
