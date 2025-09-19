module average_signed(
	input 		        clk_i,
	input 		        rst_i,
    
	input [31:0]	    din,
	input			    en_in,
	
	output reg [31:0]	dout,
	output reg 			en_out
);

parameter N = 7;

reg [31+N:0]	sum;	//2^N
reg [31:0]
data_tem0 ,	data_tem16,	data_tem32,	data_tem48,	data_tem64,	data_tem80,	data_tem96 ,	data_tem112,
data_tem1 ,	data_tem17,	data_tem33,	data_tem49, data_tem65,	data_tem81,	data_tem97 ,	data_tem113,
data_tem2 ,	data_tem18,	data_tem34,	data_tem50, data_tem66,	data_tem82,	data_tem98 ,	data_tem114,
data_tem3 ,	data_tem19,	data_tem35,	data_tem51, data_tem67,	data_tem83,	data_tem99 ,	data_tem115,
data_tem4 ,	data_tem20,	data_tem36,	data_tem52, data_tem68,	data_tem84,	data_tem100,	data_tem116,
data_tem5 ,	data_tem21,	data_tem37,	data_tem53, data_tem69,	data_tem85,	data_tem101,	data_tem117,
data_tem6 ,	data_tem22,	data_tem38,	data_tem54, data_tem70,	data_tem86,	data_tem102,	data_tem118,
data_tem7 ,	data_tem23,	data_tem39,	data_tem55, data_tem71,	data_tem87,	data_tem103,	data_tem119,
data_tem8 ,	data_tem24,	data_tem40,	data_tem56, data_tem72,	data_tem88,	data_tem104,	data_tem120,
data_tem9 ,	data_tem25,	data_tem41,	data_tem57, data_tem73,	data_tem89,	data_tem105,	data_tem121,
data_tem10,	data_tem26,	data_tem42,	data_tem58, data_tem74,	data_tem90,	data_tem106,	data_tem122,
data_tem11,	data_tem27,	data_tem43,	data_tem59, data_tem75,	data_tem91,	data_tem107,	data_tem123,
data_tem12,	data_tem28,	data_tem44,	data_tem60, data_tem76,	data_tem92,	data_tem108,	data_tem124,
data_tem13,	data_tem29,	data_tem45,	data_tem61, data_tem77,	data_tem93,	data_tem109,	data_tem125,
data_tem14,	data_tem30,	data_tem46,	data_tem62, data_tem78,	data_tem94,	data_tem110,	data_tem126,
data_tem15,	data_tem31,	data_tem47,	data_tem63, data_tem79,	data_tem95,	data_tem111,	data_tem127,

data_tem128,	data_tem144,	data_tem160,	data_tem176, data_tem192,	data_tem208,	data_tem224,	data_tem240,
data_tem129,	data_tem145,	data_tem161,	data_tem177, data_tem193,	data_tem209,	data_tem225,	data_tem241,
data_tem130,	data_tem146,	data_tem162,	data_tem178, data_tem194,	data_tem210,	data_tem226,	data_tem242,
data_tem131,	data_tem147,	data_tem163,	data_tem179, data_tem195,	data_tem211,	data_tem227,	data_tem243,
data_tem132,	data_tem148,	data_tem164,	data_tem180, data_tem196,	data_tem212,	data_tem228,	data_tem244,
data_tem133,	data_tem149,	data_tem165,	data_tem181, data_tem197,	data_tem213,	data_tem229,	data_tem245,
data_tem134,	data_tem150,	data_tem166,	data_tem182, data_tem198,	data_tem214,	data_tem230,	data_tem246,
data_tem135,	data_tem151,	data_tem167,	data_tem183, data_tem199,	data_tem215,	data_tem231,	data_tem247,
data_tem136,	data_tem152,	data_tem168,	data_tem184, data_tem200,	data_tem216,	data_tem232,	data_tem248,
data_tem137,	data_tem153,	data_tem169,	data_tem185, data_tem201,	data_tem217,	data_tem233,	data_tem249,
data_tem138,	data_tem154,	data_tem170,	data_tem186, data_tem202,	data_tem218,	data_tem234,	data_tem250,
data_tem139,	data_tem155,	data_tem171,	data_tem187, data_tem203,	data_tem219,	data_tem235,	data_tem251,
data_tem140,	data_tem156,	data_tem172,	data_tem188, data_tem204,	data_tem220,	data_tem236,	data_tem252,
data_tem141,	data_tem157,	data_tem173,	data_tem189, data_tem205,	data_tem221,	data_tem237,	data_tem253,
data_tem142,	data_tem158,	data_tem174,	data_tem190, data_tem206,	data_tem222,	data_tem238,	data_tem254,
data_tem143,	data_tem159,	data_tem175,	data_tem191, data_tem207,	data_tem223,	data_tem239,	data_tem255;


always @(posedge clk_i or posedge rst_i)
	if(rst_i) begin 
	data_tem0  <= 0;	data_tem16 <= 0;	data_tem32 <= 0;	data_tem48 <= 0;	data_tem64 <= 0;	data_tem80 <= 0;	data_tem96  <= 0;	data_tem112 <= 0;
	data_tem1  <= 0;	data_tem17 <= 0;	data_tem33 <= 0;	data_tem49 <= 0;    data_tem65 <= 0;	data_tem81 <= 0;	data_tem97  <= 0;	data_tem113 <= 0;
	data_tem2  <= 0;	data_tem18 <= 0;	data_tem34 <= 0;	data_tem50 <= 0;    data_tem66 <= 0;	data_tem82 <= 0;	data_tem98  <= 0;	data_tem114 <= 0;
	data_tem3  <= 0;	data_tem19 <= 0;	data_tem35 <= 0;	data_tem51 <= 0;    data_tem67 <= 0;	data_tem83 <= 0;	data_tem99  <= 0;	data_tem115 <= 0;
	data_tem4  <= 0;	data_tem20 <= 0;	data_tem36 <= 0;	data_tem52 <= 0;    data_tem68 <= 0;	data_tem84 <= 0;	data_tem100 <= 0;	data_tem116 <= 0;
	data_tem5  <= 0;	data_tem21 <= 0;	data_tem37 <= 0;	data_tem53 <= 0;    data_tem69 <= 0;	data_tem85 <= 0;	data_tem101 <= 0;	data_tem117 <= 0;
	data_tem6  <= 0;	data_tem22 <= 0;	data_tem38 <= 0;	data_tem54 <= 0;    data_tem70 <= 0;	data_tem86 <= 0;	data_tem102 <= 0;	data_tem118 <= 0;
	data_tem7  <= 0;	data_tem23 <= 0;	data_tem39 <= 0;	data_tem55 <= 0;    data_tem71 <= 0;	data_tem87 <= 0;	data_tem103 <= 0;	data_tem119 <= 0;
	data_tem8  <= 0;	data_tem24 <= 0;	data_tem40 <= 0;	data_tem56 <= 0;    data_tem72 <= 0;	data_tem88 <= 0;	data_tem104 <= 0;	data_tem120 <= 0;
	data_tem9  <= 0;	data_tem25 <= 0;	data_tem41 <= 0;	data_tem57 <= 0;    data_tem73 <= 0;	data_tem89 <= 0;	data_tem105 <= 0;	data_tem121 <= 0;
	data_tem10 <= 0;	data_tem26 <= 0;	data_tem42 <= 0;	data_tem58 <= 0;    data_tem74 <= 0;	data_tem90 <= 0;	data_tem106 <= 0;	data_tem122 <= 0;
	data_tem11 <= 0;	data_tem27 <= 0;	data_tem43 <= 0;	data_tem59 <= 0;    data_tem75 <= 0;	data_tem91 <= 0;	data_tem107 <= 0;	data_tem123 <= 0;
	data_tem12 <= 0;	data_tem28 <= 0;	data_tem44 <= 0;	data_tem60 <= 0;    data_tem76 <= 0;	data_tem92 <= 0;	data_tem108 <= 0;	data_tem124 <= 0;
	data_tem13 <= 0;	data_tem29 <= 0;	data_tem45 <= 0;	data_tem61 <= 0;    data_tem77 <= 0;	data_tem93 <= 0;	data_tem109 <= 0;	data_tem125 <= 0;
	data_tem14 <= 0;	data_tem30 <= 0;	data_tem46 <= 0;	data_tem62 <= 0;    data_tem78 <= 0;	data_tem94 <= 0;	data_tem110 <= 0;	data_tem126 <= 0;
	data_tem15 <= 0;	data_tem31 <= 0;	data_tem47 <= 0;	data_tem63 <= 0;    data_tem79 <= 0;	data_tem95 <= 0;	data_tem111 <= 0;	data_tem127 <= 0;
	
	data_tem128 <= 0;	data_tem144 <= 0;	data_tem160 <= 0;	data_tem176 <= 0;	 data_tem192 <= 0;	data_tem208 <= 0;	data_tem224 <= 0;	data_tem240 <= 0;
	data_tem129 <= 0;	data_tem145 <= 0;	data_tem161 <= 0;	data_tem177 <= 0;    data_tem193 <= 0;	data_tem209 <= 0;	data_tem225 <= 0;	data_tem241 <= 0;
	data_tem130 <= 0;	data_tem146 <= 0;	data_tem162 <= 0;	data_tem178 <= 0;    data_tem194 <= 0;	data_tem210 <= 0;	data_tem226 <= 0;	data_tem242 <= 0;
	data_tem131 <= 0;	data_tem147 <= 0;	data_tem163 <= 0;	data_tem179 <= 0;    data_tem195 <= 0;	data_tem211 <= 0;	data_tem227 <= 0;	data_tem243 <= 0;
	data_tem132 <= 0;	data_tem148 <= 0;	data_tem164 <= 0;	data_tem180 <= 0;    data_tem196 <= 0;	data_tem212 <= 0;	data_tem228 <= 0;	data_tem244 <= 0;
	data_tem133 <= 0;	data_tem149 <= 0;	data_tem165 <= 0;	data_tem181 <= 0;    data_tem197 <= 0;	data_tem213 <= 0;	data_tem229 <= 0;	data_tem245 <= 0;
	data_tem134 <= 0;	data_tem150 <= 0;	data_tem166 <= 0;	data_tem182 <= 0;    data_tem198 <= 0;	data_tem214 <= 0;	data_tem230 <= 0;	data_tem246 <= 0;
	data_tem135 <= 0;	data_tem151 <= 0;	data_tem167 <= 0;	data_tem183 <= 0;    data_tem199 <= 0;	data_tem215 <= 0;	data_tem231 <= 0;	data_tem247 <= 0;
	data_tem136 <= 0;	data_tem152 <= 0;	data_tem168 <= 0;	data_tem184 <= 0;    data_tem200 <= 0;	data_tem216 <= 0;	data_tem232 <= 0;	data_tem248 <= 0;
	data_tem137 <= 0;	data_tem153 <= 0;	data_tem169 <= 0;	data_tem185 <= 0;    data_tem201 <= 0;	data_tem217 <= 0;	data_tem233 <= 0;	data_tem249 <= 0;
	data_tem138 <= 0;	data_tem154 <= 0;	data_tem170 <= 0;	data_tem186 <= 0;    data_tem202 <= 0;	data_tem218 <= 0;	data_tem234 <= 0;	data_tem250 <= 0;
	data_tem139 <= 0;	data_tem155 <= 0;	data_tem171 <= 0;	data_tem187 <= 0;    data_tem203 <= 0;	data_tem219 <= 0;	data_tem235 <= 0;	data_tem251 <= 0;
	data_tem140 <= 0;	data_tem156 <= 0;	data_tem172 <= 0;	data_tem188 <= 0;    data_tem204 <= 0;	data_tem220 <= 0;	data_tem236 <= 0;	data_tem252 <= 0;
	data_tem141 <= 0;	data_tem157 <= 0;	data_tem173 <= 0;	data_tem189 <= 0;    data_tem205 <= 0;	data_tem221 <= 0;	data_tem237 <= 0;	data_tem253 <= 0;
	data_tem142 <= 0;	data_tem158 <= 0;	data_tem174 <= 0;	data_tem190 <= 0;    data_tem206 <= 0;	data_tem222 <= 0;	data_tem238 <= 0;	data_tem254 <= 0;
	data_tem143 <= 0;	data_tem159 <= 0;	data_tem175 <= 0;	data_tem191 <= 0;    data_tem207 <= 0;	data_tem223 <= 0;	data_tem239 <= 0;	data_tem255 <= 0;
	end 
	else if(en_in) begin 
		data_tem0  <= din		;	data_tem64  <= data_tem63 ;	data_tem128 <= data_tem127;	data_tem192 <= data_tem191;
		data_tem1  <= data_tem0 ;	data_tem65  <= data_tem64 ;	data_tem129 <= data_tem128;	data_tem193 <= data_tem192;
		data_tem2  <= data_tem1 ;	data_tem66  <= data_tem65 ;	data_tem130 <= data_tem129;	data_tem194 <= data_tem193;
		data_tem3  <= data_tem2 ;	data_tem67  <= data_tem66 ;	data_tem131 <= data_tem130;	data_tem195 <= data_tem194;
		data_tem4  <= data_tem3 ;	data_tem68  <= data_tem67 ;	data_tem132 <= data_tem131;	data_tem196 <= data_tem195;
		data_tem5  <= data_tem4 ;	data_tem69  <= data_tem68 ;	data_tem133 <= data_tem132;	data_tem197 <= data_tem196;
		data_tem6  <= data_tem5 ;	data_tem70  <= data_tem69 ;	data_tem134 <= data_tem133;	data_tem198 <= data_tem197;
		data_tem7  <= data_tem6 ;	data_tem71  <= data_tem70 ;	data_tem135 <= data_tem134;	data_tem199 <= data_tem198;
		data_tem8  <= data_tem7 ;	data_tem72  <= data_tem71 ;	data_tem136 <= data_tem135;	data_tem200 <= data_tem199;
		data_tem9  <= data_tem8 ;	data_tem73  <= data_tem72 ;	data_tem137 <= data_tem136;	data_tem201 <= data_tem200;
		data_tem10 <= data_tem9 ;	data_tem74  <= data_tem73 ;	data_tem138 <= data_tem137;	data_tem202 <= data_tem201;
		data_tem11 <= data_tem10;	data_tem75  <= data_tem74 ;	data_tem139 <= data_tem138;	data_tem203 <= data_tem202;
		data_tem12 <= data_tem11;	data_tem76  <= data_tem75 ;	data_tem140 <= data_tem139;	data_tem204 <= data_tem203;
		data_tem13 <= data_tem12;	data_tem77  <= data_tem76 ;	data_tem141 <= data_tem140;	data_tem205 <= data_tem204;
		data_tem14 <= data_tem13;	data_tem78  <= data_tem77 ;	data_tem142 <= data_tem141;	data_tem206 <= data_tem205;
		data_tem15 <= data_tem14;	data_tem79  <= data_tem78 ;	data_tem143 <= data_tem142;	data_tem207 <= data_tem206;
		data_tem16 <= data_tem15;   data_tem80  <= data_tem79 ; data_tem144 <= data_tem143; data_tem208 <= data_tem207;
		data_tem17 <= data_tem16;   data_tem81  <= data_tem80 ; data_tem145 <= data_tem144; data_tem209 <= data_tem208;
		data_tem18 <= data_tem17;   data_tem82  <= data_tem81 ; data_tem146 <= data_tem145; data_tem210 <= data_tem209;
		data_tem19 <= data_tem18;   data_tem83  <= data_tem82 ; data_tem147 <= data_tem146; data_tem211 <= data_tem210;
		data_tem20 <= data_tem19;   data_tem84  <= data_tem83 ; data_tem148 <= data_tem147; data_tem212 <= data_tem211;
		data_tem21 <= data_tem20;   data_tem85  <= data_tem84 ; data_tem149 <= data_tem148; data_tem213 <= data_tem212;
		data_tem22 <= data_tem21;   data_tem86  <= data_tem85 ; data_tem150 <= data_tem149; data_tem214 <= data_tem213;
		data_tem23 <= data_tem22;   data_tem87  <= data_tem86 ; data_tem151 <= data_tem150; data_tem215 <= data_tem214;
		data_tem24 <= data_tem23;   data_tem88  <= data_tem87 ; data_tem152 <= data_tem151; data_tem216 <= data_tem215;
		data_tem25 <= data_tem24;   data_tem89  <= data_tem88 ; data_tem153 <= data_tem152; data_tem217 <= data_tem216;
		data_tem26 <= data_tem25;   data_tem90  <= data_tem89 ; data_tem154 <= data_tem153; data_tem218 <= data_tem217;
		data_tem27 <= data_tem26;   data_tem91  <= data_tem90 ; data_tem155 <= data_tem154; data_tem219 <= data_tem218;
		data_tem28 <= data_tem27;   data_tem92  <= data_tem91 ; data_tem156 <= data_tem155; data_tem220 <= data_tem219;
		data_tem29 <= data_tem28;   data_tem93  <= data_tem92 ; data_tem157 <= data_tem156; data_tem221 <= data_tem220;
		data_tem30 <= data_tem29;   data_tem94  <= data_tem93 ; data_tem158 <= data_tem157; data_tem222 <= data_tem221;
		data_tem31 <= data_tem30;   data_tem95  <= data_tem94 ; data_tem159 <= data_tem158; data_tem223 <= data_tem222;
		data_tem32 <= data_tem31;   data_tem96  <= data_tem95 ; data_tem160 <= data_tem159; data_tem224 <= data_tem223;
		data_tem33 <= data_tem32;   data_tem97  <= data_tem96 ; data_tem161 <= data_tem160; data_tem225 <= data_tem224;
		data_tem34 <= data_tem33;   data_tem98  <= data_tem97 ; data_tem162 <= data_tem161; data_tem226 <= data_tem225;
		data_tem35 <= data_tem34;   data_tem99  <= data_tem98 ; data_tem163 <= data_tem162; data_tem227 <= data_tem226;
		data_tem36 <= data_tem35;   data_tem100 <= data_tem99 ; data_tem164 <= data_tem163; data_tem228 <= data_tem227;
		data_tem37 <= data_tem36;   data_tem101 <= data_tem100; data_tem165 <= data_tem164; data_tem229 <= data_tem228;
		data_tem38 <= data_tem37;   data_tem102 <= data_tem101; data_tem166 <= data_tem165; data_tem230 <= data_tem229;
		data_tem39 <= data_tem38;   data_tem103 <= data_tem102; data_tem167 <= data_tem166; data_tem231 <= data_tem230;
		data_tem40 <= data_tem39;   data_tem104 <= data_tem103; data_tem168 <= data_tem167; data_tem232 <= data_tem231;
		data_tem41 <= data_tem40;   data_tem105 <= data_tem104; data_tem169 <= data_tem168; data_tem233 <= data_tem232;
		data_tem42 <= data_tem41;   data_tem106 <= data_tem105; data_tem170 <= data_tem169; data_tem234 <= data_tem233;
		data_tem43 <= data_tem42;   data_tem107 <= data_tem106; data_tem171 <= data_tem170; data_tem235 <= data_tem234;
		data_tem44 <= data_tem43;   data_tem108 <= data_tem107; data_tem172 <= data_tem171; data_tem236 <= data_tem235;
		data_tem45 <= data_tem44;   data_tem109 <= data_tem108; data_tem173 <= data_tem172; data_tem237 <= data_tem236;
		data_tem46 <= data_tem45;   data_tem110 <= data_tem109; data_tem174 <= data_tem173; data_tem238 <= data_tem237;
		data_tem47 <= data_tem46;   data_tem111 <= data_tem110; data_tem175 <= data_tem174; data_tem239 <= data_tem238;
		data_tem48 <= data_tem47;   data_tem112 <= data_tem111; data_tem176 <= data_tem175; data_tem240 <= data_tem239;
		data_tem49 <= data_tem48;   data_tem113 <= data_tem112; data_tem177 <= data_tem176; data_tem241 <= data_tem240;
		data_tem50 <= data_tem49;   data_tem114 <= data_tem113; data_tem178 <= data_tem177; data_tem242 <= data_tem241;
		data_tem51 <= data_tem50;   data_tem115 <= data_tem114; data_tem179 <= data_tem178; data_tem243 <= data_tem242;
		data_tem52 <= data_tem51;   data_tem116 <= data_tem115; data_tem180 <= data_tem179; data_tem244 <= data_tem243;
		data_tem53 <= data_tem52;   data_tem117 <= data_tem116; data_tem181 <= data_tem180; data_tem245 <= data_tem244;
		data_tem54 <= data_tem53;   data_tem118 <= data_tem117; data_tem182 <= data_tem181; data_tem246 <= data_tem245;
		data_tem55 <= data_tem54;   data_tem119 <= data_tem118; data_tem183 <= data_tem182; data_tem247 <= data_tem246;
		data_tem56 <= data_tem55;   data_tem120 <= data_tem119; data_tem184 <= data_tem183; data_tem248 <= data_tem247;
		data_tem57 <= data_tem56;   data_tem121 <= data_tem120; data_tem185 <= data_tem184; data_tem249 <= data_tem248;
		data_tem58 <= data_tem57;   data_tem122 <= data_tem121; data_tem186 <= data_tem185; data_tem250 <= data_tem249;
		data_tem59 <= data_tem58;   data_tem123 <= data_tem122; data_tem187 <= data_tem186; data_tem251 <= data_tem250;
		data_tem60 <= data_tem59;   data_tem124 <= data_tem123; data_tem188 <= data_tem187; data_tem252 <= data_tem251;
		data_tem61 <= data_tem60;   data_tem125 <= data_tem124; data_tem189 <= data_tem188; data_tem253 <= data_tem252;
		data_tem62 <= data_tem61;   data_tem126 <= data_tem125; data_tem190 <= data_tem189; data_tem254 <= data_tem253;
		data_tem63 <= data_tem62;   data_tem127 <= data_tem126; data_tem191 <= data_tem190; data_tem255 <= data_tem254;
		
	
	end 

always @(posedge clk_i or posedge rst_i)
	if(rst_i) begin 
		sum <= 0;
		dout <= 0;
	end 
	else if(en_in) begin 
		sum <= sum + {{N{din[31]}},din} - {{N{data_tem127[31]}},data_tem127};
		dout <= sum>>N;
	end 
	
always @(posedge clk_i or posedge rst_i)
    if(rst_i) 
        en_out <= 0;
    else 
        en_out <= en_in;
		

endmodule 



// module average_signed(
	// input 		clk_i,
	// input 		rst_i,

	// input [31:0]	din,
	// input			en_in,
	
	// output reg [31:0]	dout,
	// output reg 			en_out
// );

// reg [37:0]	sum;	//2^6
// reg [31:0]
// data_tem0 ,	data_tem16,	data_tem32,	data_tem48,
// data_tem1 ,	data_tem17,	data_tem33,	data_tem49,
// data_tem2 ,	data_tem18,	data_tem34,	data_tem50,
// data_tem3 ,	data_tem19,	data_tem35,	data_tem51,
// data_tem4 ,	data_tem20,	data_tem36,	data_tem52,
// data_tem5 ,	data_tem21,	data_tem37,	data_tem53,
// data_tem6 ,	data_tem22,	data_tem38,	data_tem54,
// data_tem7 ,	data_tem23,	data_tem39,	data_tem55,
// data_tem8 ,	data_tem24,	data_tem40,	data_tem56,
// data_tem9 ,	data_tem25,	data_tem41,	data_tem57,
// data_tem10,	data_tem26,	data_tem42,	data_tem58,
// data_tem11,	data_tem27,	data_tem43,	data_tem59,
// data_tem12,	data_tem28,	data_tem44,	data_tem60,
// data_tem13,	data_tem29,	data_tem45,	data_tem61,
// data_tem14,	data_tem30,	data_tem46,	data_tem62,
// data_tem15,	data_tem31,	data_tem47,	data_tem63;


// always @(posedge clk_i or posedge rst_i)
	// if(rst_i) begin 
		// data_tem0  <= 0;	data_tem16 <= 0;	data_tem32 <= 0;	data_tem48 <= 0;
		// data_tem1  <= 0;	data_tem17 <= 0;	data_tem33 <= 0;	data_tem49 <= 0;
		// data_tem2  <= 0;	data_tem18 <= 0;	data_tem34 <= 0;	data_tem50 <= 0;
		// data_tem3  <= 0;	data_tem19 <= 0;	data_tem35 <= 0;	data_tem51 <= 0;
		// data_tem4  <= 0;	data_tem20 <= 0;	data_tem36 <= 0;	data_tem52 <= 0;
		// data_tem5  <= 0;	data_tem21 <= 0;	data_tem37 <= 0;	data_tem53 <= 0;
		// data_tem6  <= 0;	data_tem22 <= 0;	data_tem38 <= 0;	data_tem54 <= 0;
		// data_tem7  <= 0;	data_tem23 <= 0;	data_tem39 <= 0;	data_tem55 <= 0;
		// data_tem8  <= 0;	data_tem24 <= 0;	data_tem40 <= 0;	data_tem56 <= 0;
		// data_tem9  <= 0;	data_tem25 <= 0;	data_tem41 <= 0;	data_tem57 <= 0;
		// data_tem10 <= 0;	data_tem26 <= 0;	data_tem42 <= 0;	data_tem58 <= 0;
		// data_tem11 <= 0;	data_tem27 <= 0;	data_tem43 <= 0;	data_tem59 <= 0;
		// data_tem12 <= 0;	data_tem28 <= 0;	data_tem44 <= 0;	data_tem60 <= 0;
		// data_tem13 <= 0;	data_tem29 <= 0;	data_tem45 <= 0;	data_tem61 <= 0;
		// data_tem14 <= 0;	data_tem30 <= 0;	data_tem46 <= 0;	data_tem62 <= 0;
		// data_tem15 <= 0;	data_tem31 <= 0;	data_tem47 <= 0;	data_tem63 <= 0;
	// end 
	// else if(en_in) begin 
		// data_tem0  <= din		;	data_tem16 <= data_tem15;	data_tem32 <= data_tem31;	data_tem48 <= data_tem47;
		// data_tem1  <= data_tem0 ;	data_tem17 <= data_tem16;	data_tem33 <= data_tem32;	data_tem49 <= data_tem48;
		// data_tem2  <= data_tem1 ;	data_tem18 <= data_tem17;	data_tem34 <= data_tem33;	data_tem50 <= data_tem49;
		// data_tem3  <= data_tem2 ;	data_tem19 <= data_tem18;	data_tem35 <= data_tem34;	data_tem51 <= data_tem50;
		// data_tem4  <= data_tem3 ;	data_tem20 <= data_tem19;	data_tem36 <= data_tem35;	data_tem52 <= data_tem51;
		// data_tem5  <= data_tem4 ;	data_tem21 <= data_tem20;	data_tem37 <= data_tem36;	data_tem53 <= data_tem52;
		// data_tem6  <= data_tem5 ;	data_tem22 <= data_tem21;	data_tem38 <= data_tem37;	data_tem54 <= data_tem53;
		// data_tem7  <= data_tem6 ;	data_tem23 <= data_tem22;	data_tem39 <= data_tem38;	data_tem55 <= data_tem54;
		// data_tem8  <= data_tem7 ;	data_tem24 <= data_tem23;	data_tem40 <= data_tem39;	data_tem56 <= data_tem55;
		// data_tem9  <= data_tem8 ;	data_tem25 <= data_tem24;	data_tem41 <= data_tem40;	data_tem57 <= data_tem56;
		// data_tem10 <= data_tem9 ;	data_tem26 <= data_tem25;	data_tem42 <= data_tem41;	data_tem58 <= data_tem57;
		// data_tem11 <= data_tem10;	data_tem27 <= data_tem26;	data_tem43 <= data_tem42;	data_tem59 <= data_tem58;
		// data_tem12 <= data_tem11;	data_tem28 <= data_tem27;	data_tem44 <= data_tem43;	data_tem60 <= data_tem59;
		// data_tem13 <= data_tem12;	data_tem29 <= data_tem28;	data_tem45 <= data_tem44;	data_tem61 <= data_tem60;
		// data_tem14 <= data_tem13;	data_tem30 <= data_tem29;	data_tem46 <= data_tem45;	data_tem62 <= data_tem61;
		// data_tem15 <= data_tem14;	data_tem31 <= data_tem30;	data_tem47 <= data_tem46;	data_tem63 <= data_tem62;
	// end 

// always @(posedge clk_i or posedge rst_i)
	// if(rst_i) begin 
		// sum <= 0;
		// dout <= 0;
	// end 
	// else if(en_in) begin 
		// sum <= sum + {{6{din[31]}},din} - {{6{data_tem63[31]}},data_tem63};
		// dout <= sum>>6;
	// end 
	
// always @(posedge clk_i or posedge rst_i)
    // if(rst_i) 
        // en_out <= 0;
    // else 
        // en_out <= en_in;
		

// endmodule 