module AVG_IIR_signed(
	input 		clk_i,
	input 		rst_i,
	
	input [31:0]		din,
	input 				din_en,
	
	output reg [31:0]	dout,
	output reg 			dout_en

);

parameter N = 6;

reg [31+N:0] sum;

always @(posedge clk_i or posedge rst_i)
	if(rst_i) begin 
		sum <= 0;
		dout <= 0;
		end 
	else if(din_en) begin 
		sum <= sum + {{N{din[31]}},din} - {{N{dout[31]}},dout} ;
		dout <= sum >> N;
		end 

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		dout_en <= 0;
	else 
		dout_en <= din_en;


endmodule 