`timescale 1ns / 1ps
 //顺序 �? �?0 hf  1 os0�? 2 lf  3 os1 4 os2
module CW_PW_R_JX_OS(
       input                  clk              ,
	  
       input       [31 : 0]   I_R_AVG           , //os0
	   input       [31 : 0]   I_JX_AVG          ,	   
	   input                  pulse_pwm_on    , //os0 //������ϵĲ���
       input                  CW_MODE         , //os0
       input                  PW_MODE         ,	   	 
       input                  power_fall      ,     
	   input                  open_status     ,   
	   input       [15 : 0]   power_pwm_dly    , // os0 ������������ռ�ձ��ӳټ�����
	   input       [15 : 0]   pulse_gap       , //os0  ����ռ�ձ���ͬ��������
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
reg [15:0]  dly_cnt;//�ӳټ�������
reg [15:0]  gap_cnt = 0; //ʱ������������
reg r_pulse_pwm_on = 0;
reg START = 0;

assign     pos_pulse_pwm = ~r_pulse_pwm_on & pulse_pwm_on;//��������������
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
	if(PW_MODE && O_Z_pulse_pwm )begin   //input sensor�� �ӳٵĹ�����������������ЧZֵ��
	      O_R  <= I_R_AVG ;       //���岨��Ҫ��⵽������,����ʱ��������Чֵ.
	      O_JX <= I_JX_AVG;
	end
	else if(CW_MODE&&OPEN)begin   //������ֱ�ӿ�����,ֱ��������Чֵ
	      O_R  <= I_R_AVG ; 
	      O_JX <= I_JX_AVG;	
	end
//START �ڼ�⵽�������������ش����ӳټ�������ʱ�������������ֵ����
always @(posedge clk) begin             //OS
   if(gap_cnt > pulse_gap -1)//pulse_gap0  = w_IS0_PULSE_END0 - w_IS0_PULSE_START0;//700-100
      START <= 1'd0;
   else if(pos_pulse_pwm)//��������������
      START <= 1'd1;
end
/*��START=1�������ż���������ʱ��Ϊ0��������start��ʼ����С���ӳ����ֵʱ�ۼӣ�
����ʱ���֣��ȴ�ʱ�����������ﵽ���ֵ����start������*/
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
//ʱ��������ȥ���ӳټ��������������ʱ����ʼ�ۼӣ�����ʱ��������ﵽ���ֵʱ��ʱ����������㣻
always @(posedge clk) begin
    if(gap_cnt > pulse_gap -1)//pulse_gap0  = w_IS0_PULSE_END0 - w_IS0_PULSE_START0;//700-100
	     gap_cnt <= 'd0;
    else if(dly_cnt > power_pwm_dly-1)//d100
	     gap_cnt <= gap_cnt + 1; 
end
//��ʱ��������ۼ��ڼ����ߣ��ﵽʱ����������ֵʱ���ͣ�
always @(posedge clk) begin
    if(~START)
	     O_Z_pulse_pwm <= 'd0;
    else if(dly_cnt > power_pwm_dly-1)
	     O_Z_pulse_pwm <= 1'd1;
end

always @(posedge clk) 
	if( (PW_MODE && pulse_pwm_on) )begin
		  OS_V_RESULT <= OS_V_AVG ; //���岨��Ҫ��⵽������,������Чֵ.
		  OS_I_RESULT <= OS_I_AVG ;		  
    end
	else if(CW_MODE && OPEN )begin
		  OS_V_RESULT<= OS_V_AVG ;  //������ֱ�ӿ�����,ֱ��������Чֵ
		  OS_I_RESULT<= OS_I_AVG ;
	end
endmodule
