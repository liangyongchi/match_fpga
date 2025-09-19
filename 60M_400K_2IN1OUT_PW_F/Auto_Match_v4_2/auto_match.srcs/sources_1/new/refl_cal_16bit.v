
module refl_cal_16bit(
	input 		i_clk,	//125m 

	input [15:0]	vr_i,	//A 
	input [15:0]	vr_q,	//B
	input [15:0]	vf_i,	//C
	input [15:0]	vf_q,	//D
	
	output reg [31:0]		refl_i,	//15位定点数
	output reg [31:0]		refl_q

);	//反射/入射  

wire [32:0]	AC,BD,BC,AD;
wire [32:0]	C2,D2;

mult_16x16 uAC (	//位宽改为16bit
  .CLK(i_clk),  // input wire CLK
  .A(vr_i),      // input wire [31 : 0] A
  .B(vf_i),      // input wire [31 : 0] B
  .P(AC)      // output wire [63 : 0] P
);

mult_16x16 uBD (
  .CLK(i_clk),  // input wire CLK
  .A(vr_q),      // input wire [31 : 0] A
  .B(vf_q),      // input wire [31 : 0] B
  .P(BD)      // output wire [63 : 0] P
);

mult_16x16 uBC (
  .CLK(i_clk),  // input wire CLK
  .A(vr_q),      // input wire [31 : 0] A
  .B(vf_i),      // input wire [31 : 0] B
  .P(BC)      // output wire [63 : 0] P
);

mult_16x16 uAD (
  .CLK(i_clk),  // input wire CLK
  .A(vr_i),      // input wire [31 : 0] A
  .B(vf_q),      // input wire [31 : 0] B
  .P(AD)      // output wire [63 : 0] P
);

mult_16x16 uC2 (
  .CLK(i_clk),  // input wire CLK
  .A(vf_i),      // input wire [31 : 0] A
  .B(vf_i),      // input wire [31 : 0] B
  .P(C2)      // output wire [63 : 0] P
);

mult_16x16 uD2 (
  .CLK(i_clk),  // input wire CLK
  .A(vf_q),      // input wire [31 : 0] A
  .B(vf_q),      // input wire [31 : 0] B
  .P(D2)      // output wire [63 : 0] P
);

reg [31:0] add_AC_BD,add_C2_D2,sub_BC_AD;
always @(posedge i_clk) 
	begin 
	add_AC_BD <= (AC + BD) ;	
	add_C2_D2 <= (C2 + D2) ;
	sub_BC_AD <= (BC - AD) ;
	end 

wire [48:0]	dout_i;
wire 		o_tvalid_i;
wire 		tuser_i;
div_32_32 div_i (	//延时36个clk输出结果
  .aclk						(i_clk),		// input wire aclk
  .s_axis_divisor_tvalid	(1'b1),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata		(add_C2_D2),    // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid	(1'b1), 	 	// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata	(add_AC_BD),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid		(o_tvalid_i),   // output wire m_axis_dout_tvalid
  .m_axis_dout_tuser		(tuser_i),      // output wire [0 : 0] m_axis_dout_tuser,除数是0输出1
  .m_axis_dout_tdata		(dout_i)        // output wire [63 : 0] m_axis_dout_tdata,bit[15]是符号位
);

wire [48:0]	dout_q;
wire 		o_tvalid_q;
wire 		tuser_q;
div_32_32 div_q (	//延时36个clk输出结果
  .aclk						(i_clk),		// input wire aclk
  .s_axis_divisor_tvalid	(1'b1),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata		(add_C2_D2),	// input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid	(1'b1),  		// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata	(sub_BC_AD),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid		(o_tvalid_q),	// output wire m_axis_dout_tvalid
  .m_axis_dout_tuser		(tuser_q),      // output wire [0 : 0] m_axis_dout_tuser
  .m_axis_dout_tdata		(dout_q)		// output wire [63 : 0] m_axis_dout_tdata
);
 
always @(posedge i_clk) 
	if(!tuser_i) 
		refl_i <= {dout_i[32:16],15'd0} + {{17{dout_i[15]}},dout_i[14:0]};
	else
		refl_i <= refl_i;

always @(posedge i_clk) 
	if(!tuser_q) 
		refl_q <= {dout_q[32:16],15'd0} + {{17{dout_q[15]}},dout_q[14:0]};
	else
		refl_q <= refl_q;


endmodule 