//
module power_k_sel(
	input 			clk_i           ,
	input 			rst_i           ,
	
	input [31:0]	freq_in         ,
	input 			FREQ_CALIB_MODE	,
	input [23:0]	ORIG_K	        ,	
	
	input [23:0]	POWER_CALIB_K0	,
    input [23:0]	POWER_CALIB_K1	,
    input [23:0]	POWER_CALIB_K2	,
    input [23:0]	POWER_CALIB_K3	,
    input [23:0]	POWER_CALIB_K4	,
    input [23:0]	POWER_CALIB_K5	,
    input [23:0]	POWER_CALIB_K6	,
    input [23:0]	POWER_CALIB_K7	,
    input [23:0]	POWER_CALIB_K8	,
    input [23:0]	POWER_CALIB_K9	,
	input [23:0]	POWER_CALIB_K10	,
    input [23:0]	POWER_CALIB_K11	,
    input [23:0]	POWER_CALIB_K12	,
    input [23:0]	POWER_CALIB_K13	,
    input [23:0]	POWER_CALIB_K14	,
    input [23:0]	POWER_CALIB_K15	,
    input [23:0]	POWER_CALIB_K16	,
    input [23:0]	POWER_CALIB_K17	,
    input [23:0]	POWER_CALIB_K18	,
    input [23:0]	POWER_CALIB_K19	,
	input [23:0]	POWER_CALIB_K20	,
    input [23:0]	POWER_CALIB_K21	,
    input [23:0]	POWER_CALIB_K22	,
    input [23:0]	POWER_CALIB_K23	,
    input [23:0]	POWER_CALIB_K24	,
    input [23:0]	POWER_CALIB_K25	,
    input [23:0]	POWER_CALIB_K26	,
    input [23:0]	POWER_CALIB_K27	,
    input [23:0]	POWER_CALIB_K28	,
    input [23:0]	POWER_CALIB_K29	,
	
	input [31:0]	FREQ_THR0 		,
	input [31:0]	FREQ_THR1 		,
	input [31:0]	FREQ_THR2 		,
	input [31:0]	FREQ_THR3 		,
	input [31:0]	FREQ_THR4 		,
	input [31:0]	FREQ_THR5 		,
	input [31:0]	FREQ_THR6 		,
	input [31:0]	FREQ_THR7 		,
	input [31:0]	FREQ_THR8 		,
	input [31:0]	FREQ_THR9 		,
	input [31:0]	FREQ_THR10		,
	input [31:0]	FREQ_THR11		,
	input [31:0]	FREQ_THR12		,
	input [31:0]	FREQ_THR13		,
	input [31:0]	FREQ_THR14		,
	input [31:0]	FREQ_THR15		,
	input [31:0]	FREQ_THR16		,
	input [31:0]	FREQ_THR17		,
	input [31:0]	FREQ_THR18		,
	input [31:0]	FREQ_THR19		,
	input [31:0]	FREQ_THR20		,
	input [31:0]	FREQ_THR21		,
	input [31:0]	FREQ_THR22		,
	input [31:0]	FREQ_THR23		,
	input [31:0]	FREQ_THR24		,
	input [31:0]	FREQ_THR25		,
	input [31:0]	FREQ_THR26		,
	input [31:0]	FREQ_THR27		,
	input [31:0]	FREQ_THR28		,
	input [31:0]	FREQ_THR29		,
	input [31:0]	FREQ_THR30		,
	
	input [23:0]	K_THR0 			,
	input [23:0]	K_THR1 			,
	input [23:0]	K_THR2 			,
	input [23:0]	K_THR3 			,
	input [23:0]	K_THR4 			,
	input [23:0]	K_THR5 			,
	input [23:0]	K_THR6 			,
	input [23:0]	K_THR7 			,
	input [23:0]	K_THR8 			,
	input [23:0]	K_THR9 			,
	input [23:0]	K_THR10			,
	input [23:0]	K_THR11			,
	input [23:0]	K_THR12			,
	input [23:0]	K_THR13			,
	input [23:0]	K_THR14			,
	input [23:0]	K_THR15			,
	input [23:0]	K_THR16			,
	input [23:0]	K_THR17			,
	input [23:0]	K_THR18			,
	input [23:0]	K_THR19			,
	input [23:0]	K_THR20			,
	input [23:0]	K_THR21			,
	input [23:0]	K_THR22			,
	input [23:0]	K_THR23			,
	input [23:0]	K_THR24			,
	input [23:0]	K_THR25			,
	input [23:0]	K_THR26			,
	input [23:0]	K_THR27			,
	input [23:0]	K_THR28			,
	input [23:0]	K_THR29			,
	
	output reg [23:0]	K_out	     //24定点数
);

reg [31:0]	freq_in_reg0,freq_in_reg1;
reg [31:0]	freq_sub;
reg [31:0]	THR_NOW,THR_NOW_r0,THR_NOW_r1;
reg [23:0]	POW_K,POW_K_r0,POW_K_r1;
reg [23:0]	K_NOW,K_NOW_r0,K_NOW_r1;
reg [23:0]	calib_y;

always @(posedge clk_i)	
begin 
	freq_in_reg0 <= freq_in;
	freq_in_reg1 <= freq_in_reg0;
end 
	
always @(posedge clk_i)
	if(freq_in <= FREQ_THR1)
		THR_NOW_r0 <= FREQ_THR0;	//1.8M
	else if(freq_in <= FREQ_THR2)
		THR_NOW_r0 <= FREQ_THR1;
	else if(freq_in <= FREQ_THR3)
		THR_NOW_r0 <= FREQ_THR2;
	else if(freq_in <= FREQ_THR4)
		THR_NOW_r0 <= FREQ_THR3;
	else if(freq_in <= FREQ_THR5)
		THR_NOW_r0 <= FREQ_THR4;
	else if(freq_in <= FREQ_THR6)
		THR_NOW_r0 <= FREQ_THR5;
	else if(freq_in <= FREQ_THR7)
		THR_NOW_r0 <= FREQ_THR6;
	else if(freq_in <= FREQ_THR8)
		THR_NOW_r0 <= FREQ_THR7;
	else if(freq_in <= FREQ_THR9)
		THR_NOW_r0 <= FREQ_THR8;
	else if(freq_in <= FREQ_THR10)
		THR_NOW_r0 <= FREQ_THR9;
	else if(freq_in <= FREQ_THR11)
		THR_NOW_r0 <= FREQ_THR10;
	else if(freq_in <= FREQ_THR12)
		THR_NOW_r0 <= FREQ_THR11;
	else if(freq_in <= FREQ_THR13)
		THR_NOW_r0 <= FREQ_THR12;
	else if(freq_in <= FREQ_THR14)
		THR_NOW_r0 <= FREQ_THR13;
	else if(freq_in <= FREQ_THR15)
		THR_NOW_r0 <= FREQ_THR14;

always @(posedge clk_i)		
	if(freq_in <= FREQ_THR16)
		THR_NOW_r1 <= FREQ_THR15;
	else if(freq_in <= FREQ_THR17)
		THR_NOW_r1 <= FREQ_THR16;
	else if(freq_in <= FREQ_THR18)
		THR_NOW_r1 <= FREQ_THR17;
	else if(freq_in <= FREQ_THR19)
		THR_NOW_r1 <= FREQ_THR18;
	else if(freq_in <= FREQ_THR20)
		THR_NOW_r1 <= FREQ_THR19;
	else if(freq_in <= FREQ_THR21)
		THR_NOW_r1 <= FREQ_THR20;
	else if(freq_in <= FREQ_THR22)
		THR_NOW_r1 <= FREQ_THR21;
	else if(freq_in <= FREQ_THR23)
		THR_NOW_r1 <= FREQ_THR22;
	else if(freq_in <= FREQ_THR24)
		THR_NOW_r1 <= FREQ_THR23;
	else if(freq_in <= FREQ_THR25)
		THR_NOW_r1 <= FREQ_THR24;
	else if(freq_in <= FREQ_THR26)
		THR_NOW_r1 <= FREQ_THR25;
	else if(freq_in <= FREQ_THR27)
		THR_NOW_r1 <= FREQ_THR26;
	else if(freq_in <= FREQ_THR28)
		THR_NOW_r1 <= FREQ_THR27;	
	else if(freq_in <= FREQ_THR29)
		THR_NOW_r1 <= FREQ_THR28;	
	else if(freq_in <= FREQ_THR30)
		THR_NOW_r1 <= FREQ_THR29;	
//

always @(posedge clk_i)
	if(freq_in <= FREQ_THR1)
		K_NOW_r0 <= K_THR0;	//1.8M
	else if(freq_in <= FREQ_THR2)
		K_NOW_r0 <= K_THR1;
	else if(freq_in <= FREQ_THR3)
		K_NOW_r0 <= K_THR2;
	else if(freq_in <= FREQ_THR4)
		K_NOW_r0 <= K_THR3;
	else if(freq_in <= FREQ_THR5)
		K_NOW_r0 <= K_THR4;
	else if(freq_in <= FREQ_THR6)
		K_NOW_r0 <= K_THR5;
	else if(freq_in <= FREQ_THR7)
		K_NOW_r0 <= K_THR6;
	else if(freq_in <= FREQ_THR8)
		K_NOW_r0 <= K_THR7;
	else if(freq_in <= FREQ_THR9)
		K_NOW_r0 <= K_THR8;
	else if(freq_in <= FREQ_THR10)
		K_NOW_r0 <= K_THR9;
	else if(freq_in <= FREQ_THR11)
		K_NOW_r0 <= K_THR10;
	else if(freq_in <= FREQ_THR12)
		K_NOW_r0 <= K_THR11;
	else if(freq_in <= FREQ_THR13)
		K_NOW_r0 <= K_THR12;
	else if(freq_in <= FREQ_THR14)
		K_NOW_r0 <= K_THR13;
	else if(freq_in <= FREQ_THR15)
		K_NOW_r0 <= K_THR14;
		
always @(posedge clk_i)		
	if(freq_in <= FREQ_THR16)
		K_NOW_r1 <= K_THR15;
	else if(freq_in <= FREQ_THR17)
		K_NOW_r1 <= K_THR16;
	else if(freq_in <= FREQ_THR18)
		K_NOW_r1 <= K_THR17;
	else if(freq_in <= FREQ_THR19)
		K_NOW_r1 <= K_THR18;
	else if(freq_in <= FREQ_THR20)
		K_NOW_r1 <= K_THR19;
	else if(freq_in <= FREQ_THR21)
		K_NOW_r1 <= K_THR20;
	else if(freq_in <= FREQ_THR22)
		K_NOW_r1 <= K_THR21;	
	else if(freq_in <= FREQ_THR23)
		K_NOW_r1 <= K_THR22;	
	else if(freq_in <= FREQ_THR24)
		K_NOW_r1 <= K_THR23;	
	else if(freq_in <= FREQ_THR25)
		K_NOW_r1 <= K_THR24;	
	else if(freq_in <= FREQ_THR26)
		K_NOW_r1 <= K_THR25;	
	else if(freq_in <= FREQ_THR27)
		K_NOW_r1 <= K_THR26;
	else if(freq_in <= FREQ_THR28)
		K_NOW_r1 <= K_THR27;
	else if(freq_in <= FREQ_THR29)
		K_NOW_r1 <= K_THR28;
	else if(freq_in <= FREQ_THR30)
		K_NOW_r1 <= K_THR29;
//		

always @(posedge clk_i)
	if(freq_in <= FREQ_THR1)
		POW_K_r0 <= POWER_CALIB_K0;	//1.8M
	else if(freq_in <= FREQ_THR2)
		POW_K_r0 <= POWER_CALIB_K1;
	else if(freq_in <= FREQ_THR3)
		POW_K_r0 <= POWER_CALIB_K2;
	else if(freq_in <= FREQ_THR4)
		POW_K_r0 <= POWER_CALIB_K3;
	else if(freq_in <= FREQ_THR5)
		POW_K_r0 <= POWER_CALIB_K4;
	else if(freq_in <= FREQ_THR6)
		POW_K_r0 <= POWER_CALIB_K5;
	else if(freq_in <= FREQ_THR7)
		POW_K_r0 <= POWER_CALIB_K6;
	else if(freq_in <= FREQ_THR8)
		POW_K_r0 <= POWER_CALIB_K7;
	else if(freq_in <= FREQ_THR9)
		POW_K_r0 <= POWER_CALIB_K8;
	else if(freq_in <= FREQ_THR10)
		POW_K_r0 <= POWER_CALIB_K9;
	else if(freq_in <= FREQ_THR11)
		POW_K_r0 <= POWER_CALIB_K10;
	else if(freq_in <= FREQ_THR12)
		POW_K_r0 <= POWER_CALIB_K11;
	else if(freq_in <= FREQ_THR13)
		POW_K_r0 <= POWER_CALIB_K12;
	else if(freq_in <= FREQ_THR14)
		POW_K_r0 <= POWER_CALIB_K13;
	else if(freq_in <= FREQ_THR15)
		POW_K_r0 <= POWER_CALIB_K14;

always @(posedge clk_i)		
	if(freq_in <= FREQ_THR16)
		POW_K_r1 <= POWER_CALIB_K15;
	else if(freq_in <= FREQ_THR17)
		POW_K_r1 <= POWER_CALIB_K16;
	else if(freq_in <= FREQ_THR18)
		POW_K_r1 <= POWER_CALIB_K17;
	else if(freq_in <= FREQ_THR19)
		POW_K_r1 <= POWER_CALIB_K18;
	else if(freq_in <= FREQ_THR20)
		POW_K_r1 <= POWER_CALIB_K19;
	else if(freq_in <= FREQ_THR21)
		POW_K_r1 <= POWER_CALIB_K20;	
	else if(freq_in <= FREQ_THR22)
		POW_K_r1 <= POWER_CALIB_K21;	
	else if(freq_in <= FREQ_THR23)
		POW_K_r1 <= POWER_CALIB_K22;	
	else if(freq_in <= FREQ_THR24)
		POW_K_r1 <= POWER_CALIB_K23;	
	else if(freq_in <= FREQ_THR25)
		POW_K_r1 <= POWER_CALIB_K24;	
	else if(freq_in <= FREQ_THR26)
		POW_K_r1 <= POWER_CALIB_K25;	
	else if(freq_in <= FREQ_THR27)
		POW_K_r1 <= POWER_CALIB_K26;	
	else if(freq_in <= FREQ_THR28)
		POW_K_r1 <= POWER_CALIB_K27;	
	else if(freq_in <= FREQ_THR29)
		POW_K_r1 <= POWER_CALIB_K28;	
	else if(freq_in <= FREQ_THR30)
		POW_K_r1 <= POWER_CALIB_K29;	
		
always @(posedge clk_i)	
	if(freq_in_reg0 <= FREQ_THR15) begin 
		THR_NOW <= THR_NOW_r0;
		K_NOW <= K_NOW_r0;
		POW_K <= POW_K_r0;
		end 
	else begin 
		THR_NOW <= THR_NOW_r1;
		K_NOW <= K_NOW_r1;
		POW_K <= POW_K_r1;
		end 

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		freq_sub <= 0;	//不会是负数
	else 
		freq_sub <= freq_in_reg1 - THR_NOW;	//1.8M,延2拍对齐

wire [55 : 0] P;	//23定点数
//mult_unsigned_32x24 u0 (
mult_signed_32x24 u0 (
  .CLK		(clk_i),  // input wire CLK
  .A		(freq_sub),      // input wire [31 : 0] A，无符号
  .B		(K_NOW),      // input wire [23 : 0] B，有符号
  .P		(P)      // output wire [55 : 0] P	有符号
);

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		calib_y <= ORIG_K;
		//calib_y <= 0;
	else 
		calib_y <= POW_K - {P[55],P[45:23]};

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		K_out <= ORIG_K;
	else if(FREQ_CALIB_MODE)
		K_out <= ORIG_K;
	else 
		K_out <= calib_y;

/*	
ila_1 ila_lpf (
    .clk    (clk_i),
    .probe0 ({
			freq_in_reg0,
			THR_NOW,
			freq_sub,
			K_NOW,
			P[47:24],
			K_out
			})
);			
*/

endmodule