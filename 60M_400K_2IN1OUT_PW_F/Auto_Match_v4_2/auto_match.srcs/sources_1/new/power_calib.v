module power_calib(
	input 		    i_clk,	//125m 
	input 		    i_rst,
	input [31:0]	power_in,
	input [23:0]	POWER_CALIB_K,	//2^24
	output [15:0]	dout	//
);

wire [55 : 0] P;
mult_unsigned_32x24 u0 (
  .CLK(i_clk),            // input wire CLK
  .A(power_in),           // input wire [31 : 0] A
  .B(POWER_CALIB_K),      // input wire [17 : 0] B
  .P(P)                   // output wire [49 : 0] P
);

assign dout = P >> 24;


endmodule 