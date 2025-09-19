module data_ext(
	input 				i_clk,	//128m
	input 				clk_50m,
	input [63:0]		i_data,
	input 				i_valid,	//16M采样率一个valid
	input [13:0]		r_demod_rd_addr,
	output reg [31:0]	o_data_i,
	output reg [31:0]	o_data_q,
	output reg 			o_valid		//50M时钟，要对标16M采样率
);

reg 		wr_en;
reg 		rd_en;
reg [63:0]	wr_data;
wire 		full;
wire 		empty;
wire [63 : 0] dout;
wire 		valid;

always @(posedge i_clk) 
	if(i_valid)
		wr_data <= i_data;
	else 
		wr_data <= wr_data;

always @(posedge i_clk)
	if(r_demod_rd_addr<=15 || r_demod_rd_addr>=80)	//15-80的数据不要
		wr_en <= i_valid;
	else 
		wr_en <= 0;


//----------50M时钟域--------------
always @(posedge clk_50m)
begin 
	o_data_i <= dout[63:32];
	o_data_q <= dout[31:0 ];
end 

always @(posedge clk_50m)
	o_valid <= valid;

fifo_ASYNC fifo_ASYNC (
  .wr_clk(i_clk),  // input wire wr_clk
  .rd_clk(clk_50m),  // input wire rd_clk
  .din(wr_data),        // input wire [63 : 0] din
  .wr_en(wr_en),    // input wire wr_en
  .rd_en(1'b1),    // input wire rd_en
  .dout(dout),      // output wire [63 : 0] dout
  .full(full),      // output wire full
  .empty(empty),    // output  wire empty
  .valid(valid)    // output wire valid
);

/*
ila_1 ila_vf (
    .clk    (clk_50m),
    .probe0 ({
			i_data[63:32],
			i_valid,
			i_data[31:0],
			r_demod_rd_addr,
			
			o_data_i,
			o_data_q,
			o_valid			
			
			})
);
*/

endmodule 
































// module data_ext(
	// input 				i_clk,	//32m
	// input 				clk_50m,
	// input [63:0]		i_data,
	// input 				i_valid,
	// input [13:0]		r_demod_rd_addr,	
	// output reg [31:0]	o_data_i,
	// output reg [31:0]	o_data_q,
	// output reg 			o_valid

// );
// //32M时钟域
// reg [31:0] 	data_i;
// reg [31:0] 	data_q;
// reg 		valid;

// //50M时钟域
// reg [31:0]  data_i_r0;
// reg [31:0]  data_q_r0;

// reg 		valid_r0,valid_r1 ;
// reg [13:0]	r_demod_rd_addr_r0,r_demod_rd_addr_r1;

// always @(posedge i_clk) 
	// if(i_valid) begin  
		// data_i <= i_data[63:32];
		// data_q <= i_data[31:0 ];
	// end 

// always @(posedge i_clk) 		
	// valid <= i_valid;

// //跨时钟域
// always @(posedge clk_50m)
// begin 
	// r_demod_rd_addr_r0 <= r_demod_rd_addr;
	// r_demod_rd_addr_r1 <= r_demod_rd_addr_r0;
// end 

// always @(posedge clk_50m) begin // valid data filter;
	    // if(r_demod_rd_addr_r1<=15 || r_demod_rd_addr_r1>=80)	//15-80的数据不要
            // begin
                	// data_i_r0 <= data_i;
                    // data_q_r0 <= data_q;
                    // valid_r0  <= valid ;
                	
                	// o_data_i <= data_i_r0 ;
                	// o_data_q <= data_q_r0 ;
                	// o_valid  <= valid_r0;
            // end 
// end

// // ila_1 ila_data_ext(
	// // .clk(i_clk), // input wire clk

	// // .probe0(r_demod_rd_addr_r1), // input wire [13:0]  probe0  
	// // .probe1(i_valid), // input wire [0:0]  probe1 
	// // .probe2(i_data), // input wire [63:0]  probe2 
	// // .probe3(data_i), // input wire [31:0]  probe3 
	// // .probe4(data_q), // input wire [31:0]  probe4 
	// // .probe5(o_valid), // input wire [0:0]  probe5 
	// // .probe6(o_data_i), // input wire [31:0]  probe6 
	// // .probe7(o_data_q) // input wire [31:0]  probe7
// // );


// endmodule 