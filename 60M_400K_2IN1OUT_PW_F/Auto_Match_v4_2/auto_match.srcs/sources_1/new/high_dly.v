module high_dly(
	input 			clk_i,
	input 			rst_i,
	input 			din,
	output reg 		dout
);

reg [15:0]	cnt;	//50_000 / 20 = 2_500;

parameter CNT_MAX = 2_500-1;

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		cnt <= 0;
	else if(din==0)
		cnt <= 0;
	else if(cnt < CNT_MAX)
		cnt <= cnt+1;

always @(posedge clk_i or posedge rst_i)
	if(rst_i) 
		dout <= din;
	else if(din==0)
		dout <= 0;
	else if(cnt == CNT_MAX)
		dout <= 1;



endmodule 