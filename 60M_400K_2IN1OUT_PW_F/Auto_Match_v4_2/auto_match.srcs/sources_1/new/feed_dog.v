module feed_dog(
	input 		i_clk,	//10m 
	input 		i_rstn,

	output reg 	dout
);

reg [7:0]	cnt;	//10_000k / 100k = 100

parameter CNT_MAX = 100-1;

always @(posedge i_clk or negedge i_rstn)
	if(!i_rstn)
		cnt <= 0;
	else if(cnt == CNT_MAX)
		cnt <= 0;
	else 
		cnt <= cnt + 1;

always @(posedge i_clk or negedge i_rstn)
	if(!i_rstn)
		dout <= 0;
	else if(cnt == CNT_MAX)
		dout <= ~dout;

endmodule 