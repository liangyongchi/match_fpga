`timescale 1ns / 1ps

module CW_PW_R_JX_RESULT(
       input                  clk              ,
	   input                  ch_sel           ,
	   
       input       [31 : 0]   R0_AVG           ,
	   input       [31 : 0]   JX0_AVG          ,
	
       input       [31 : 0]   R1_AVG           ,//os0
	   input       [31 : 0]   JX1_AVG          ,
	   
	   input       [31 : 0]   R2_AVG           , //lf
	   input       [31 : 0]   JX2_AVG          ,
       input       [31 : 0]   R3_AVG           ,
	   input       [31 : 0]   JX3_AVG          , 
	   
       input       [31 : 0]   R3_400K_AVG      ,
	   input       [31 : 0]   JX3_400K_AVG     , 
	   
	   input       [31 : 0]   R4_AVG           ,
	   input       [31 : 0]   JX4_AVG          ,	   

	   input       [31 : 0]   R4_400K_AVG      ,
	   input       [31 : 0]   JX4_400K_AVG     ,

  
       input       [31 : 0]   OS0_V_AVG        ,
   	   input       [31 : 0]   OS0_I_AVG        ,


       input       [31 : 0]   OS1_V_AVG        ,
   	   input       [31 : 0]   OS1_I_AVG        ,
	   
	   input       [31 : 0]   OS1_400K_V_AVG   ,
   	   input       [31 : 0]   OS1_400K_I_AVG   ,   
	   
       input       [31 : 0]   OS2_V_AVG        ,
   	   input       [31 : 0]   OS2_I_AVG        ,	   
	   
       input       [31 : 0]   OS2_400K_V_AVG   ,
   	   input       [31 : 0]   OS2_400K_I_AVG   ,

	   
	   input                  pulse0_pwm_on    , //功率拟合的波形；
	   input                  pulse1_pwm_on    , 
	   input                  pulse2_pwm_on    , 
	   input                  pulse3_pwm_on    , 
	   input                  pulse3_400k_pwm_on, 
	   input                  pulse4_pwm_on    ,
	   input                  pulse4_400k_pwm_on, 
	   
       input                  CW_MODE0         ,
       input                  PW_MODE0         ,   
       input                  CW_MODE1         , //os0
       input                  PW_MODE1         ,	   
       input                  CW_MODE2         , //lf
       input                  PW_MODE2         ,   
	   
       input                  CW_MODE3         ,
       input                  PW_MODE3         ,	   
       input                  CW_MODE3_400K    ,
       input                  PW_MODE3_400K    ,	
	   
       input                  CW_MODE4         ,
       input                  PW_MODE4         ,	 
       input                  CW_MODE4_400K    ,
       input                  PW_MODE4_400K    ,	
	   
       input                  power_fall0      ,     
	   input                  open_status0     ,
       input                  power_fall1      ,     
	   input                  open_status1     ,	        
       input                  power_fall2      ,     
	   input                  open_status2     ,
       input                  power_fall3      ,     
	   input                  open_status3     ,
       input                  power_fall3_400k ,     
	   input                  open_status3_400k,
       input                  power_fall4      ,     
	   input                  open_status4     ,	   
       input                  power_fall4_400k ,     
	   input                  open_status4_400k,	   

 
       input       [15 : 0]   power_pwm_dly0   , //相对于脉冲拟合占空比延迟计数器
       input       [15 : 0]   power_pwm_dly2   ,	   
       input       [15 : 0]   i_pwm_dly0       , //相对于电压波形脉冲拟合占空比延迟计数器
       input       [15 : 0]   i_pwm_dly1       , 
       input       [15 : 0]   i_pwm_dly1_400k  , 
       input       [15 : 0]   i_pwm_dly2       , 	   
       input       [15 : 0]   i_pwm_dly2_400k  , 
	   
	   input       [15 : 0]   pulse_gap0       , //功率占空比相同的脉冲间隔；
	   input       [15 : 0]   pulse_gap1       ,
	   input       [15 : 0]   pulse_gap2       ,  
	   input       [15 : 0]   pulse_gap3       ,
	   input       [15 : 0]   pulse_gap3_400k  ,
	   input       [15 : 0]   pulse_gap4       , 	   
	   input       [15 : 0]   pulse_gap4_400k  , 	
	   
       output  reg            Z_pulse0_pwm     ,
	   output  reg            Z_pulse1_pwm     ,
	   output  reg            Z_pulse2_pwm     ,
	   output  reg            Z_pulse3_pwm     ,
	   output  reg            Z_pulse3_pwm_400k,
	   output  reg            Z_pulse4_pwm     ,	   
	   output  reg            Z_pulse4_pwm_400k,

	   
       output  reg [31 : 0]   R0               ,
	   output  reg [31 : 0]   JX0              ,
	   output  reg [31 : 0]   R1               ,
	   output  reg [31 : 0]   JX1              ,
	   output  reg [31 : 0]   R2               ,
	   output  reg [31 : 0]   JX2              ,	   
	   output  reg [31 : 0]   R3               ,
	   output  reg [31 : 0]   JX3              ,
	   output  reg [31 : 0]   R3_400K          ,
	   output  reg [31 : 0]   JX3_400K         ,
	   output  reg [31 : 0]   R4               ,
	   output  reg [31 : 0]   JX4              ,		     
	   output  reg [31 : 0]   R4_400K          ,
	   output  reg [31 : 0]   JX4_400K         ,	
	   
	   output  reg [31 : 0]   OS0_V_RESULT     ,
	   output  reg [31 : 0]   OS0_I_RESULT     ,
	   output  reg [31 : 0]   OS1_V_RESULT     ,
	   output  reg [31 : 0]   OS1_I_RESULT     ,
	   output  reg [31 : 0]   OS1_400K_V_RESULT,
	   output  reg [31 : 0]   OS1_400K_I_RESULT,
	   
	   output  reg [31 : 0]   OS2_V_RESULT     ,
	   output  reg [31 : 0]   OS2_I_RESULT     ,	     
	   output  reg [31 : 0]   OS2_400K_V_RESULT,
	   output  reg [31 : 0]   OS2_400K_I_RESULT     
   
);

wire       pos_pulse0_pwm;
wire       pos_pulse1_pwm;
wire       pos_pulse2_pwm;
wire       pos_pulse3_pwm;
wire       pos_pulse4_pwm;
wire       pos_pulse3_400k_pwm;
wire       pos_pulse4_400k_pwm;

assign     pos_pulse0_pwm = ~r_pulse0_pwm_on&pulse0_pwm_on;
assign     pos_pulse1_pwm = ~r_pulse1_pwm_on&pulse1_pwm_on;
assign     pos_pulse2_pwm = ~r_pulse2_pwm_on&pulse2_pwm_on;
assign     pos_pulse3_pwm = ~r_pulse3_pwm_on&pulse3_pwm_on;
assign     pos_pulse4_pwm = ~r_pulse4_pwm_on&pulse4_pwm_on;
assign     pos_pulse3_400k_pwm = ~r_pulse3_400k_pwm_on&pulse3_400k_pwm_on;
assign     pos_pulse4_400k_pwm = ~r_pulse4_400k_pwm_on&pulse4_400k_pwm_on;


reg         OPEN0;//HF;
reg         OPEN1;//OS0;
reg         OPEN2;//LF;
reg         OPEN3;//OS1;
reg         OPEN4;//OS2;
reg         OPEN3_400K;//OS1;
reg         OPEN4_400K;//OS2;


reg [15:0]  dly_cnt; //延迟计数器；
reg [15:0]  dly_cnt1;//延迟计数器；
reg [15:0]  dly_cnt2;//延迟计数器；
reg [15:0]  dly_cnt3;//延迟计数器；
reg [15:0]  dly_cnt4;//延迟计数器；
reg [15:0]  dly_400k_cnt3;//延迟计数器；
reg [15:0]  dly_400k_cnt4;//延迟计数器；


reg [15:0]  gap_cnt=0; //时间间隔计数器；
reg [15:0]  gap_cnt1=0;//时间间隔计数器；
reg [15:0]  gap_cnt2=0;//时间间隔计数器；
reg [15:0]  gap_cnt3=0;//时间间隔计数器；
reg [15:0]  gap_cnt4=0;//时间间隔计数器；
reg [15:0]  gap_400k_cnt3=0;//时间间隔计数器；
reg [15:0]  gap_400k_cnt4=0;//时间间隔计数器；


reg r_pulse0_pwm_on=0;
reg START = 0;
reg r_pulse1_pwm_on=0;
reg START1 = 0;
reg r_pulse2_pwm_on=0;
reg START2 = 0;
reg r_pulse3_pwm_on=0;
reg START3 = 0;
reg r_pulse4_pwm_on=0;
reg START4 = 0;

reg r_pulse3_400k_pwm_on=0;
reg START3_400K = 0;
reg r_pulse4_400k_pwm_on=0;
reg START4_400K = 0;

//HF
always @(posedge clk) begin
	if(CW_MODE0&&power_fall0)
	   OPEN0 <= 1'd0;
    else if(open_status0)
	   OPEN0 <= 1'd1;
end

always @(posedge clk) begin
	if(CW_MODE1&&power_fall1)
	   OPEN1 <= 1'd0;
    else if(open_status1)
	   OPEN1 <= 1'd1;
end

//LF
always @(posedge clk) begin
	if(CW_MODE2&&power_fall2)
	   OPEN2 <= 1'd0;
    else if(open_status2)
	   OPEN2 <= 1'd1;
end

always @(posedge clk) begin
	if(CW_MODE3&&power_fall3)
	   OPEN3 <= 1'd0;
    else if(open_status3)
	   OPEN3 <= 1'd1;
end

always @(posedge clk) begin
	if(CW_MODE4&&power_fall4)
	   OPEN4 <= 1'd0;
    else if(open_status4)
	   OPEN4 <= 1'd1;
end


always @(posedge clk) begin
	if(CW_MODE3_400K&&power_fall3_400k)
	   OPEN3_400K <= 1'd0;
    else if(open_status3_400k)
	   OPEN3_400K <= 1'd1;
end

always @(posedge clk) begin
	if(CW_MODE4_400K&&power_fall4_400k)
	   OPEN4_400K <= 1'd0;
    else if(open_status4_400k)
	   OPEN4_400K <= 1'd1;
end



always @(posedge clk) 
	if(PW_MODE0 && Z_pulse0_pwm )begin  //input sensor在 延迟的功率拟合脉冲出锁存有效Z值；
	      R0  <= R0_AVG ; 
	      JX0 <= JX0_AVG;
	end
	else if(CW_MODE0&&OPEN0)begin
	      R0  <= R0_AVG ; 
	      JX0 <= JX0_AVG;	
	end

 //OS
 
 always @(posedge clk) 
	if(PW_MODE1 && Z_pulse1_pwm )begin  //input sensor在 延迟的功率拟合脉冲出锁存有效Z值；
	      R1  <= R1_AVG ; 
	      JX1 <= JX1_AVG;
	end
	else if(CW_MODE1&&OPEN1)begin
	      R1  <= R1_AVG ; 
	      JX1 <= JX1_AVG;	
	end
 


 //LF  
always @(posedge clk) 
	if(PW_MODE2 &&pulse2_pwm_on)begin  
	      R2  <= R2_AVG ; 
	      JX2 <= JX2_AVG;
	end
	else if(CW_MODE2)begin
	      R2  <= R2_AVG ; 
	      JX2 <= JX2_AVG;	
	end

always @(posedge clk) 
	if(PW_MODE3 && Z_pulse3_pwm )begin  //input sensor在 延迟的功率拟合脉冲出锁存有效Z值；
	      R3  <= R3_AVG ; 
	      JX3 <= JX3_AVG;
	end
	else if(CW_MODE3&&OPEN3)begin
	      R3  <= R3_AVG ; 
	      JX3 <= JX3_AVG;	
	end
	
always @(posedge clk) 
	if(PW_MODE4 && Z_pulse4_pwm )begin  //input sensor在 延迟的功率拟合脉冲出锁存有效Z值；
	      R4  <= R4_AVG ; 
	      JX4 <= JX4_AVG;
	end
	else if(CW_MODE4&&OPEN4)begin
	      R4  <= R4_AVG ; 
	      JX4 <= JX4_AVG;	
	end

always @(posedge clk) 
	if(PW_MODE3_400K && Z_pulse3_pwm_400k )begin  //input sensor在 延迟的功率拟合脉冲出锁存有效Z值；
	      R3_400K  <= R3_400K_AVG ; 
	      JX3_400K <= JX3_400K_AVG;
	end
	else if(CW_MODE3_400K&&OPEN3_400K)begin
	      R3_400K   <= R3_400K_AVG ; 
	      JX3_400K  <= JX3_400K_AVG;	
	end
	
always @(posedge clk) 
	if(PW_MODE4_400K && Z_pulse4_pwm_400k )begin  //input sensor在 延迟的功率拟合脉冲出锁存有效Z值；
	      R4_400K  <= R4_400K_AVG ; 
	      JX4_400K <= JX4_400K_AVG;
	end
	else if(CW_MODE4_400K&&OPEN4_400K)begin
	      R4_400K   <= R4_400K_AVG ; 
	      JX4_400K  <= JX4_400K_AVG;	
	end



always @(posedge clk) 
	if( (PW_MODE2 && pulse2_pwm_on) )begin
		  OS0_V_RESULT<= OS0_V_AVG ;
		  OS0_I_RESULT<= OS0_I_AVG ;		  
    end
	else if( CW_MODE2&&OPEN2 )begin
		  OS0_V_RESULT<= OS0_V_AVG ;
		  OS0_I_RESULT<= OS0_I_AVG ;
	end

always @(posedge clk) 
	if( (PW_MODE3 && pulse3_pwm_on) )begin
		  OS1_V_RESULT<= OS1_V_AVG ;
		  OS1_I_RESULT<= OS1_I_AVG ;		  
    end
	else if( CW_MODE3&&OPEN3 )begin
		  OS1_V_RESULT<= OS1_V_AVG ;
		  OS1_I_RESULT<= OS1_I_AVG ;
	end
	
always @(posedge clk) 
	if( (PW_MODE4 && pulse4_pwm_on) )begin
		  OS2_V_RESULT<= OS2_V_AVG ;
		  OS2_I_RESULT<= OS2_I_AVG ;		  
    end
	else if( CW_MODE4&&OPEN4 )begin
		  OS2_V_RESULT<= OS2_V_AVG ;
		  OS2_I_RESULT<= OS2_I_AVG ;
	end
	
always @(posedge clk) 
	if( (PW_MODE3_400K && pulse3_400k_pwm_on) )begin
		  OS1_400K_V_RESULT<= OS1_400K_V_AVG ;
		  OS1_400K_I_RESULT<= OS1_400K_I_AVG ;		  
    end
	else if( CW_MODE3_400K&&OPEN3_400K )begin
		  OS1_400K_V_RESULT<= OS1_400K_V_AVG ;
		  OS1_400K_I_RESULT<= OS1_400K_I_AVG ;	
	end
	
always @(posedge clk) 
	if( (PW_MODE4_400K && pulse4_400k_pwm_on) )begin
		  OS2_400K_V_RESULT<= OS2_400K_V_AVG ;
		  OS2_400K_I_RESULT<= OS2_400K_I_AVG ;		  
    end
	else if( CW_MODE4_400K&&OPEN4_400K )begin
		  OS2_400K_V_RESULT<= OS2_400K_V_AVG ;
		  OS2_400K_I_RESULT<= OS2_400K_I_AVG ;	
	end
	
/*************updata：2024.12.14；***********************************************************/

always @(posedge clk) begin
	r_pulse0_pwm_on <= pulse0_pwm_on;
	r_pulse1_pwm_on <= pulse1_pwm_on;
	r_pulse2_pwm_on <= pulse2_pwm_on;
	r_pulse3_pwm_on <= pulse3_pwm_on;
	r_pulse4_pwm_on <= pulse4_pwm_on;
	r_pulse3_400k_pwm_on <= pulse3_400k_pwm_on;
	r_pulse4_400k_pwm_on <= pulse4_400k_pwm_on;	
	
end

//start 在检测到功率脉冲上升沿触发延迟计数，在时间间隔计数器最大值拉低
always @(posedge clk) begin             //HF
   if(gap_cnt > pulse_gap0 -1)
      START <= 1'd0;
   else if(pos_pulse0_pwm)
      START <= 1'd1;
end

always @(posedge clk) begin             //OS
   if(gap_cnt1 > pulse_gap1 -1)
      START1 <= 1'd0;
   else if(pos_pulse1_pwm)
      START1 <= 1'd1;
end

always @(posedge clk) begin            //LF
   if(gap_cnt2 > pulse_gap2 -1)
      START2 <= 1'd0;
   else if(pos_pulse2_pwm)
      START2 <= 1'd1;
end

always @(posedge clk) begin             //OS
   if(gap_cnt3 > pulse_gap3 -1)
      START3 <= 1'd0;
   else if(pos_pulse3_pwm)
      START3 <= 1'd1;
end

always @(posedge clk) begin             //OS
   if(gap_cnt4 > pulse_gap4 -1)
      START4 <= 1'd0;
   else if(pos_pulse4_pwm)
      START4 <= 1'd1;
end


always @(posedge clk) begin             //OS
   if(gap_400k_cnt3 > pulse_gap3_400k -1)
      START3_400K <= 1'd0;
   else if(pos_pulse3_400k_pwm)
      START3_400K <= 1'd1;
end

always @(posedge clk) begin             //OS
   if(gap_400k_cnt4 > pulse_gap4_400k -1)
      START4_400K <= 1'd0;
   else if(pos_pulse4_400k_pwm)
      START4_400K <= 1'd1;
end

/*在START=1计数器才计数，其他时候为0；并且在start开始并且小于延迟最大值时累加，
                                        大于时保持，等待时间间隔计数器达到最大值拉低start并清零*/
always @(posedge clk) begin
	if(START)begin
	   if(dly_cnt > power_pwm_dly0-1)
	       dly_cnt <= dly_cnt;
	   else 
	       dly_cnt <= dly_cnt + 1; 
    end
	else 
	   dly_cnt <= 'd0;
end

always @(posedge clk) begin
	if(START1)begin
	   if(dly_cnt1 > i_pwm_dly0-1)
	       dly_cnt1 <= dly_cnt1;
	   else 
	       dly_cnt1 <= dly_cnt1 + 1; 
    end
	else 
	   dly_cnt1 <= 'd0;
end

always @(posedge clk) begin
	if(START2)begin
	   if(dly_cnt2 > power_pwm_dly2-1)
	       dly_cnt2 <= dly_cnt2;
	   else 
	       dly_cnt2 <= dly_cnt2 + 1; 
    end
	else 
	   dly_cnt2 <= 'd0;
end

always @(posedge clk) begin
	if(START3)begin
	   if(dly_cnt3 > i_pwm_dly1-1)
	       dly_cnt3 <= dly_cnt3;
	   else 
	       dly_cnt3 <= dly_cnt3 + 1; 
    end
	else 
	   dly_cnt3 <= 'd0;
end

always @(posedge clk) begin
	if(START4)begin
	   if(dly_cnt4 > i_pwm_dly2-1)
	       dly_cnt4 <= dly_cnt4;
	   else 
	       dly_cnt4 <= dly_cnt4 + 1; 
    end
	else 
	   dly_cnt4 <= 'd0;
end

always @(posedge clk) begin
	if(START3_400K)begin
	   if(dly_400k_cnt3 > i_pwm_dly1_400k-1)
	       dly_400k_cnt3 <= dly_400k_cnt3;
	   else 
	       dly_400k_cnt3 <= dly_400k_cnt3 + 1; 
    end
	else 
	   dly_400k_cnt3 <= 'd0;
end

always @(posedge clk) begin
	if(START4_400K)begin
	   if(dly_400k_cnt4 > i_pwm_dly2_400k-1)
	       dly_400k_cnt4 <= dly_400k_cnt4;
	   else 
	       dly_400k_cnt4 <= dly_400k_cnt4 + 1; 
    end
	else 
	   dly_400k_cnt4 <= 'd0;
end




//时间间隔技术去在延迟计数器计数到最大时，开始累加，而当时间计数器达到最大值时，时间计数器清零；
always @(posedge clk) begin
    if(gap_cnt > pulse_gap0 -1)
	     gap_cnt <= 'd0;
    else if(dly_cnt > power_pwm_dly0-1)
	     gap_cnt <= gap_cnt + 1; 
end

always @(posedge clk) begin
    if(gap_cnt1 > pulse_gap1 -1)
	     gap_cnt1 <= 'd0;
    else if(dly_cnt1 > i_pwm_dly0-1)
	     gap_cnt1 <= gap_cnt1 + 1; 
end

always @(posedge clk) begin
    if(gap_cnt2 > pulse_gap2 -1)
	     gap_cnt2 <= 'd0;
    else if(dly_cnt2 > power_pwm_dly2-1)
	     gap_cnt2 <= gap_cnt2 + 1; 
end

always @(posedge clk) begin
    if(gap_cnt3 > pulse_gap3 -1)
	     gap_cnt3 <= 'd0;
    else if(dly_cnt3 > i_pwm_dly1-1)
	     gap_cnt3 <= gap_cnt3 + 1; 
end

always @(posedge clk) begin
    if(gap_cnt4 > pulse_gap4 -1)
	     gap_cnt4 <= 'd0;
    else if(dly_cnt4 > i_pwm_dly2-1)
	     gap_cnt4 <= gap_cnt4 + 1; 
end

always @(posedge clk) begin
    if(gap_400k_cnt3 > pulse_gap3_400k -1)
	     gap_400k_cnt3 <= 'd0;
    else if(dly_400k_cnt3 > i_pwm_dly1_400k-1)
	     gap_400k_cnt3 <= gap_400k_cnt3 + 1; 
end

always @(posedge clk) begin
    if(gap_400k_cnt4 > pulse_gap4_400k -1)
	     gap_400k_cnt4 <= 'd0;
    else if(dly_400k_cnt4 > i_pwm_dly2_400k-1)
	     gap_400k_cnt4 <= gap_400k_cnt4 + 1; 
end


//在时间计数器累加期间拉高，达到时间计数器最大值时拉低；
always @(posedge clk) begin
    if(~START)
	     Z_pulse0_pwm <= 'd0;
    else if(dly_cnt > power_pwm_dly0-1)
	     Z_pulse0_pwm <= 1'd1;
end

always @(posedge clk) begin
    if(~START1)
	     Z_pulse1_pwm <= 'd0;
    else if(dly_cnt1 > i_pwm_dly0-1)
	     Z_pulse1_pwm <= 1'd1;
end

always @(posedge clk) begin
    if(~START2)
	     Z_pulse2_pwm <= 'd0;
    else if(dly_cnt2 > power_pwm_dly2-1)
	     Z_pulse2_pwm <= 1'd1;
end

always @(posedge clk) begin
    if(~START3)
	     Z_pulse3_pwm <= 'd0;
    else if(dly_cnt3 > i_pwm_dly1-1)
	     Z_pulse3_pwm <= 1'd1;
end

always @(posedge clk) begin
    if(~START4)
	     Z_pulse4_pwm <= 'd0;
    else if(dly_cnt4 > i_pwm_dly2-1)
	     Z_pulse4_pwm <= 1'd1;
end

always @(posedge clk) begin
    if(~START3_400K)
	     Z_pulse3_pwm_400k <= 'd0;
    else if(dly_400k_cnt3 > i_pwm_dly1_400k-1)
	     Z_pulse3_pwm_400k <= 1'd1;
end

always @(posedge clk) begin
    if(~START4_400K)
	     Z_pulse4_pwm_400k <= 'd0;
    else if(dly_400k_cnt4 > i_pwm_dly2_400k-1)
	     Z_pulse4_pwm_400k <= 1'd1;
end



// ila_sel_ch_Z u_ila_sel_ch_Z (
    // .clk                 (clk              ),
	
	// .probe0              (power_V_dly           ),
	// .probe1              (pulse_gap1              ),	//64
	// .probe2              (pulse1_pwm_on               ), 
	// .probe3              (Z_pulse1_pwm          ), //14
	// .probe4              (  gap_cnt1      ), //32
	// .probe5              (dly_cnt1  ), //32
	// .probe6              ( pos_pulse1_pwm ),	
	// .probe7              (r_pulse1_pwm_on    ),	//  32
	// .probe8              (START1 )	//24
// );	

// ila_sel_ch_Z u_ila_sel_ch_Z (
    // .clk                 (clk              ),
	
	// .probe0              (power_pwm_dly0           ),
	// .probe1              (pulse_gap0               ),	//64
	// .probe2              (pulse0_pwm_on               ), 
	// .probe3              (Z_pulse0_pwm          ), //14
	// .probe4              (  gap_cnt      ), //32
	// .probe5              (dly_cnt  ), //32
	// .probe6              ( pos_pulse0_pwm ),	
	// .probe7              (r_pulse0_pwm_on    ),	//  32
	// .probe8              (START )	//24
// );	

endmodule
