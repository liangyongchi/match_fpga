module r_jx_calib(
	input 		           clk_i         ,	//125m 
	input 		           rst_i         ,
	input 			       RF_ON_FPGA    ,		//0开1关 
	input			       bias_on       ,		//0开1关
	input      [31:0]	   R_IN	         ,	
	input      [31:0]	   JX_IN	     ,	
	input      [31:0]	   K1            ,		//8位定点数
	input      [31:0]	   K2            ,		//=K1
	output reg [31:0]	   R_OUT         ,	//15位定点数
	output reg [31:0]	   JX_OUT	     
);	//Z = (a + j(k2+b)) / ((1-bk) + jak1)

reg [31:0]	dividend_i,dividend_q;	//被除数
reg [31:0]	divisor_i,divisor_q;	//除数
reg [31:0]	R_IN_r0;	
reg [31:0]	JX_IN_r0;	
wire [63:0]	AC,BD,BC,AD;
wire [63:0]	C2,D2;
reg [63:0]  add_AC_BD,add_C2_D2,sub_BC_AD;
reg [31:0]  add_AC_BD_r,add_C2_D2_r,sub_BC_AD_r;
wire [47:0]	dout_i;
wire 		o_tvalid_i;
wire 		tuser_i;
wire [47:0]	dout_q;
wire 		o_tvalid_q;
wire 		tuser_q;

wire [63:0]	mult_ak1,mult_bk1;
mult_32x32 uak (	
  .CLK	(clk_i),  // input wire CLK
  .A	(R_IN),      // input wire [31 : 0] A
  .B	(K1),      // input wire [31 : 0] B
  .P	(mult_ak1)      // output wire [63 : 0] P
);

mult_32x32 ubk (	
  .CLK	(clk_i),  // input wire CLK
  .A	(JX_IN),      // input wire [31 : 0] A
  .B	(K1),      // input wire [31 : 0] B
  .P	(mult_bk1)      // output wire [63 : 0] P
);

always @(posedge clk_i) begin 	
	R_IN_r0 <= R_IN;
	JX_IN_r0 <= JX_IN;
	end 

always @(posedge clk_i) begin 
	dividend_i <= R_IN_r0;					//A
	dividend_q <= K1 + JX_IN_r0;			//B
	
	divisor_i <= 32'd32768 - {mult_bk1[63],mult_bk1[45:15]};	//C
	divisor_q <= {mult_ak1[63],mult_ak1[45:15]};					//D
	end 

mult_32x32 uAC (	
  .CLK(clk_i),  // input wire CLK
  .A(dividend_i),      // input wire [31 : 0] A
  .B(divisor_i),      // input wire [31 : 0] B
  .P(AC)      // output wire [63 : 0] P
);
mult_32x32 uBD (
  .CLK(clk_i),  // input wire CLK
  .A(dividend_q),      // input wire [31 : 0] A
  .B(divisor_q),      // input wire [31 : 0] B
  .P(BD)      // output wire [63 : 0] P
);
mult_32x32 uBC (
  .CLK(clk_i),  // input wire CLK
  .A(dividend_q),      // input wire [31 : 0] A
  .B(divisor_i),      // input wire [31 : 0] B
  .P(BC)      // output wire [63 : 0] P
);
mult_32x32 uAD (
  .CLK(clk_i),  // input wire CLK
  .A(dividend_i),      // input wire [31 : 0] A
  .B(divisor_q),      // input wire [31 : 0] B
  .P(AD)      // output wire [63 : 0] P
);
mult_32x32 uC2 (
  .CLK(clk_i),  // input wire CLK
  .A(divisor_i),      // input wire [31 : 0] A
  .B(divisor_i),      // input wire [31 : 0] B
  .P(C2)      // output wire [63 : 0] P
);
mult_32x32 uD2 (
  .CLK(clk_i),  // input wire CLK
  .A(divisor_q),      // input wire [31 : 0] A
  .B(divisor_q),      // input wire [31 : 0] B
  .P(D2)      // output wire [63 : 0] P
);

always @(posedge clk_i) 
	begin 
	add_AC_BD <= (AC + BD) ;	
	add_C2_D2 <= (C2 + D2) ;
	sub_BC_AD <= (BC - AD) ;
	end 

always @(posedge clk_i) 
	begin 
	add_AC_BD_r <= {add_AC_BD[63],add_AC_BD[51:21]} ;	
	add_C2_D2_r <= {add_C2_D2[63],add_C2_D2[51:21]} ;
	sub_BC_AD_r <= {sub_BC_AD[63],sub_BC_AD[51:21]} ;
	end

div_32_32 div_i (	//延时36个clk输出结果
  .aclk						(clk_i),		// input wire aclk
  .s_axis_divisor_tvalid	(1'b1),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata		(add_C2_D2_r),    // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid	(1'b1), 	 	// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata	(add_AC_BD_r),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid		(o_tvalid_i),   // output wire m_axis_dout_tvalid
  .m_axis_dout_tuser		(tuser_i),      // output wire [0 : 0] m_axis_dout_tuser,除数是0输出1
  .m_axis_dout_tdata		(dout_i)        // output wire [63 : 0] m_axis_dout_tdata,bit[15]是符号位
);

div_32_32 div_q (	//延时36个clk输出结果
  .aclk						(clk_i),		// input wire aclk
  .s_axis_divisor_tvalid	(1'b1),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata		(add_C2_D2_r),	// input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid	(1'b1),  		// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata	(sub_BC_AD_r),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid		(o_tvalid_q),	// output wire m_axis_dout_tvalid
  .m_axis_dout_tuser		(tuser_q),      // output wire [0 : 0] m_axis_dout_tuser
  .m_axis_dout_tdata		(dout_q)		// output wire [63 : 0] m_axis_dout_tdata
);
 
always @(posedge clk_i) 
	if(!bias_on && !RF_ON_FPGA) //0开1关
	begin 
	    if(!tuser_i) 
	        R_OUT <={dout_i[32:16],15'd0} + {{17{dout_i[15]}},dout_i[14:0]};
	    else
	    	R_OUT <= R_OUT;
	end 
	
	// begin 
	    // if(!tuser_i && CW_MODE && ~ch_sel) 
	        // R_OUT <={dout_i[32:16],15'd0} + {{17{dout_i[15]}},dout_i[14:0]};
		// else if(!tuser_i && PW_MODE && pulse_pwn_on && ~ch_sel)
		    // R_OUT <={dout_i[32:16],15'd0} + {{17{dout_i[15]}},dout_i[14:0]};
	    // else
	    	// R_OUT <= R_OUT;
	// end 

always @(posedge clk_i) 
	if(!bias_on && !RF_ON_FPGA) 
	begin 
	    if(!tuser_q) 
	    	JX_OUT <={dout_q[32:16],15'd0} + {{17{dout_q[15]}},dout_q[14:0]};
	    else
	    	JX_OUT <= JX_OUT;
	end 
	// begin 
	    // if(!tuser_q  && CW_MODE && ~ch_sel) 
	    	// JX_OUT <={dout_q[32:16],15'd0} + {{17{dout_q[15]}},dout_q[14:0]};
		// else if(!tuser_q && PW_MODE && pulse_pwn_on  && ~ch_sel)
		    // JX_OUT <={dout_q[32:16],15'd0} + {{17{dout_q[15]}},dout_q[14:0]};
	    // else
	    	// JX_OUT <= JX_OUT;
	// end 


endmodule 