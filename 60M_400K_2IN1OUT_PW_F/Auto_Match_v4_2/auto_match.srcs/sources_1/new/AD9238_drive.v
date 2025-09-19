`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/15 09:16:13
// Design Name: 
// Module Name: ad9238_drive
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AD9238_drive(
	input                       i_clk       ,
	input                       i_adc_clk   ,
	input                       i_rst       ,
	
	input  [11:0]               i_adc_data0 ,
	input  [11:0]               i_adc_data1 ,
	
	output reg 			        vld         ,	
    output reg [11:0]           o_CHA       ,//signed 
	output reg [11:0]           o_CHB        //signed

);

reg [11:0]	CHA_reg0;
reg [11:0]	CHB_reg0;
reg [11:0]  o_CHA_r0,o_CHA_r1;
reg [11:0]  o_CHB_r0,o_CHB_r1;

reg [3:0]	cnt;



always @(posedge i_adc_clk) 
begin 
	CHA_reg0 <= i_adc_data0 - 'd2048;	
	CHB_reg0 <= i_adc_data1 - 'd2048;    
end 

always @(posedge i_clk or posedge i_rst)begin
	if(i_rst)	begin 	
		cnt <= 0;
		vld <= 0;
		end 
	else if(cnt==3) begin 
		cnt <= 0;
		vld <= 1;
		end 
	else begin 
		cnt <= cnt+1;
		vld <= 0;
		end 
end


always @(posedge i_clk)
begin 
	o_CHA_r0 <= CHA_reg0;
	o_CHB_r0 <= CHB_reg0;
	o_CHA_r1 <= o_CHA_r0;
	o_CHB_r1 <= o_CHB_r0;
end 

always @(posedge i_clk or posedge i_rst)begin
	if(i_rst) begin 
		o_CHA <= 0;
		o_CHB <= 0;
		end 
	else begin 
		o_CHA <= o_CHA_r1;	//CHA_reg0;
		o_CHB <= o_CHB_r1;	//CHB_reg0;
	end 
end

endmodule
