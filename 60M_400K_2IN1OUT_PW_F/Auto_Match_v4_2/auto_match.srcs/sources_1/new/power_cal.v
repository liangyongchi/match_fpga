module power_cal(
	input 		    i_clk,	//125m 
	input 		    i_rstn,
	
	input [31:0]	data_i,	//16位定点数
	input [31:0]	data_q,
	
	output [31:0]	fixed_data,	//15位定点数		
	output [31:0]	dout	//p = q^2 + i^2
);

wire [63:0]	P0,P1;
mult_32x32 u0 (
  .CLK		(i_clk),  // input wire CLK
  .A		(data_i),      // input wire [31 : 0] A
  .B		(data_i),      // input wire [31 : 0] B
  .P		(P0)      // output wire [63 : 0] P
);

mult_32x32 u1 (
  .CLK		(i_clk),  // input wire CLK
  .A		(data_q),      // input wire [31 : 0] A
  .B		(data_q),      // input wire [31 : 0] B
  .P		(P1)      // output wire [63 : 0] P
);

reg [63:0]	sum;
always @(posedge i_clk)
	sum <= P0 + P1;

assign fixed_data = sum>>17;
assign dout = sum>>32;


// ila_1 ILA_AD9643 (
    // .clk    (i_clk),
    // .probe0 ({
			// data_i,
			// data_q,
			
			// P0,
			// P1,
			// sum
			
			
			
			// })
// );

endmodule 