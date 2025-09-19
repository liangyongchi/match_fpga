module led(
	input 		clk_i,	//10m
	input 		rstn_i,
	
	output reg 	led

);

reg [23:0]	cnt;	//500_000_000 / 100 = 5_000_000

parameter CNT_MAX = 5_000_000-1;

always @(posedge clk_i or negedge rstn_i)
	if(!rstn_i)
		cnt <= 0;
	else if(cnt == CNT_MAX)
		cnt <= 0;
	else 
		cnt <= cnt + 1;
		
always @(posedge clk_i or negedge rstn_i)
	if(!rstn_i)
		led <= 0;
	else if(cnt == CNT_MAX) 
		led <= ~led;


endmodule 