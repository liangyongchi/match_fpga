
module r_jx(
	input 		i_clk,	//125m 
	
	input [31:0]	refl_i,	//15位定点数
	input [31:0]	refl_q, //15位定点数
	
	output reg [31:0]	r_jx_i,	//15位定点数
	output reg [31:0]	r_jx_q  //15位定点数
	
);	//R+jX = Z0*(1+r)/(1-r) , Z0 = 50

reg [31:0]	dividend_i,dividend_q;
reg [31:0]	divisor_i,divisor_q;

always@(posedge i_clk) begin 
	dividend_i <= 32768 + refl_i;	//A
	dividend_q <= refl_q;			//B
	
	divisor_i <= 32768 - refl_i;	//C
	divisor_q <= -refl_q;			//D
	end 

wire [63:0]	AC,BD,BC,AD;
wire [63:0]	C2,D2;

mult_32x32 uAC (	
  .CLK(i_clk),  // input wire CLK
  .A(dividend_i),      // input wire [31 : 0] A
  .B(divisor_i),      // input wire [31 : 0] B
  .P(AC)      // output wire [63 : 0] P
);
mult_32x32 uBD (
  .CLK(i_clk),  // input wire CLK
  .A(dividend_q),      // input wire [31 : 0] A
  .B(divisor_q),      // input wire [31 : 0] B
  .P(BD)      // output wire [63 : 0] P
);
mult_32x32 uBC (
  .CLK(i_clk),  // input wire CLK
  .A(dividend_q),      // input wire [31 : 0] A
  .B(divisor_i),      // input wire [31 : 0] B
  .P(BC)      // output wire [63 : 0] P
);
mult_32x32 uAD (
  .CLK(i_clk),  // input wire CLK
  .A(dividend_i),      // input wire [31 : 0] A
  .B(divisor_q),      // input wire [31 : 0] B
  .P(AD)      // output wire [63 : 0] P
);
mult_32x32 uC2 (
  .CLK(i_clk),  // input wire CLK
  .A(divisor_i),      // input wire [31 : 0] A
  .B(divisor_i),      // input wire [31 : 0] B
  .P(C2)      // output wire [63 : 0] P
);
mult_32x32 uD2 (
  .CLK(i_clk),  // input wire CLK
  .A(divisor_q),      // input wire [31 : 0] A
  .B(divisor_q),      // input wire [31 : 0] B
  .P(D2)      // output wire [63 : 0] P
);

reg [63:0] add_AC_BD,add_C2_D2,sub_BC_AD;
always @(posedge i_clk) 
	begin 
	add_AC_BD <= (AC + BD) ;	
	add_C2_D2 <= (C2 + D2) ;
	sub_BC_AD <= (BC - AD) ;
	end 

reg [31:0] add_AC_BD_r,add_C2_D2_r,sub_BC_AD_r;
always @(posedge i_clk) 
	begin 
	add_AC_BD_r <= {add_AC_BD[48],add_AC_BD[38:32],add_AC_BD[31:8]} ;	
	add_C2_D2_r <= {add_C2_D2[48],add_C2_D2[38:32],add_C2_D2[31:8]} ;
	sub_BC_AD_r <= {sub_BC_AD[48],sub_BC_AD[38:32],sub_BC_AD[31:8]} ;
	end

wire [47:0]	dout_i;
wire 		o_tvalid_i;
wire 		tuser_i;
div_32_32 div_i (	//延时36个clk输出结果
  .aclk						(i_clk),		// input wire aclk
  .s_axis_divisor_tvalid	(1'b1),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata		(add_C2_D2_r),    // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid	(1'b1), 	 	// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata	(add_AC_BD_r),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid		(o_tvalid_i),   // output wire m_axis_dout_tvalid
  .m_axis_dout_tuser		(tuser_i),      // output wire [0 : 0] m_axis_dout_tuser,除数是0输出1
  .m_axis_dout_tdata		(dout_i)        // output wire [63 : 0] m_axis_dout_tdata,bit[15]是符号位
);

wire [47:0]	dout_q;
wire 		o_tvalid_q;
wire 		tuser_q;
div_32_32 div_q (	//延时36个clk输出结果
  .aclk						(i_clk),		// input wire aclk
  .s_axis_divisor_tvalid	(1'b1),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata		(add_C2_D2_r),	// input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid	(1'b1),  		// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata	(sub_BC_AD_r),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid		(o_tvalid_q),	// output wire m_axis_dout_tvalid
  .m_axis_dout_tuser		(tuser_q),      // output wire [0 : 0] m_axis_dout_tuser
  .m_axis_dout_tdata		(dout_q)		// output wire [63 : 0] m_axis_dout_tdata
);
 
always @(posedge i_clk) 
	if(!tuser_i) 
		r_jx_i <= {dout_i[32:16],15'd0} + {{17{dout_i[15]}},dout_i[14:0]};
	else
		r_jx_i <= r_jx_i;

always @(posedge i_clk) 
	if(!tuser_q) 
		r_jx_q <= {dout_q[32:16],15'd0} + {{17{dout_q[15]}},dout_q[14:0]};
	else
		r_jx_q <= r_jx_q;

/*
`ifndef SIM
ila_1 ila_r_jx (
    .clk    (i_clk),
    .probe0 ({
			add_AC_BD_r,
			sub_BC_AD_r,
			add_C2_D2_r,
			tuser_i,
			r_jx_i,
			dout_i,
			tuser_q,
			r_jx_q,
			vr_i,
			vr_q,
			vf_i,
			vf_q
			})
);
`endif
*/

endmodule 