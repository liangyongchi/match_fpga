`timescale 1ns / 1ps
 //椤哄簭 锛? 锛?0 hf  1 os0锛? 2 lf  3 os1 4 os2
module CW_PW_R_JX_OS(
       input                  clk              ,
	  
       input       [31 : 0]   I_R_AVG           , //os0
	   input       [31 : 0]   I_JX_AVG          ,	   
	   input                  pulse_pwm_on    , //os0 //功率拟合的波形
       input                  CW_MODE         , //os0
       input                  PW_MODE         ,	   	 
       input                  power_fall      ,     
	   input                  open_status     ,   
	   input       [15 : 0]   power_pwm_dly    , // os0 相对于脉冲拟合占空比延迟计数器
	   input       [15 : 0]   pulse_gap       , //os0  功率占空比相同的脉冲间隔
	   output  reg            O_Z_pulse_pwm     ,
	   output  reg [31 : 0]   O_R               ,
	   output  reg [31 : 0]   O_JX              ,	
	   
       input       [31 : 0]   OS_V_AVG        ,
   	   input       [31 : 0]   OS_I_AVG        ,	   
	   output  reg [31 : 0]   OS_V_RESULT     ,
	   output  reg [31 : 0]   OS_I_RESULT     	   
);

wire        pos_pulse_pwm;
reg         OPEN;//OS0;
reg [15:0]  dly_cnt;//延迟计数器；
reg [15:0]  gap_cnt = 0; //时间间隔计数器；
reg r_pulse_pwm_on = 0;
reg START = 0;

assign     pos_pulse_pwm = ~r_pulse_pwm_on & pulse_pwm_on;//功率脉冲上升沿
always @(posedge clk) begin
	r_pulse_pwm_on <= pulse_pwm_on;
end
always @(posedge clk) begin
	if(CW_MODE && power_fall)
	   OPEN <= 1'd0;
    else if(open_status)
	   OPEN <= 1'd1;
end
 //OS
 always @(posedge clk) 
	if(PW_MODE && O_Z_pulse_pwm )begin   //input sensor在 延迟的功率拟合脉冲出锁存有效Z值；
	      O_R  <= I_R_AVG ;       //脉冲波需要检测到上升沿,做延时再锁存有效值.
	      O_JX <= I_JX_AVG;
	end
	else if(CW_MODE&&OPEN)begin   //连续波直接开功率,直接锁存有效值
	      O_R  <= I_R_AVG ; 
	      O_JX <= I_JX_AVG;	
	end
//START 在检测到功率脉冲上升沿触发延迟计数，在时间间隔计数器最大值拉低
always @(posedge clk) begin             //OS
   if(gap_cnt > pulse_gap -1)//pulse_gap0  = w_IS0_PULSE_END0 - w_IS0_PULSE_START0;//700-100
      START <= 1'd0;
   else if(pos_pulse_pwm)//功率脉冲上升沿
      START <= 1'd1;
end
/*在START=1计数器才计数，其他时候为0；并且在start开始并且小于延迟最大值时累加，
大于时保持，等待时间间隔计数器达到最大值拉低start并清零*/
always @(posedge clk) begin   //0-100
	if(START)begin
	   if(dly_cnt > power_pwm_dly-1)//power_pwm_dly=d100
	       dly_cnt <= dly_cnt;
	   else 
	       dly_cnt <= dly_cnt + 1; 
    end
	else 
	   dly_cnt <= 'd0;
end
//时间间隔技术去在延迟计数器计数到最大时，开始累加，而当时间计数器达到最大值时，时间计数器清零；
always @(posedge clk) begin
    if(gap_cnt > pulse_gap -1)//pulse_gap0  = w_IS0_PULSE_END0 - w_IS0_PULSE_START0;//700-100
	     gap_cnt <= 'd0;
    else if(dly_cnt > power_pwm_dly-1)//d100
	     gap_cnt <= gap_cnt + 1; 
end
//在时间计数器累加期间拉高，达到时间计数器最大值时拉低；
always @(posedge clk) begin
    if(~START)
	     O_Z_pulse_pwm <= 'd0;
    else if(dly_cnt > power_pwm_dly-1)
	     O_Z_pulse_pwm <= 1'd1;
end

always @(posedge clk) 
	if( (PW_MODE && pulse_pwm_on) )begin
		  OS_V_RESULT <= OS_V_AVG ; //脉冲波需要检测到上升沿,锁存有效值.
		  OS_I_RESULT <= OS_I_AVG ;		  
    end
	else if(CW_MODE && OPEN )begin
		  OS_V_RESULT<= OS_V_AVG ;  //连续波直接开功率,直接锁存有效值
		  OS_I_RESULT<= OS_I_AVG ;
	end
endmodule
