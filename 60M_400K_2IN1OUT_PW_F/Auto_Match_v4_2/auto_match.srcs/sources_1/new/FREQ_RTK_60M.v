`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 10:53:12
// Design Name: 
// Module Name: FREQ_RTK
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

//REAL TIME KINEMATIC;//verilog补码形式看待数据   
module FREQ_RTK_60M
(
    input                i_clk             , //64M == 15.625ns;
	input                i_rst             ,
	input                i_adc_vld         , //invalid;
    input      [13:0]    i_adc_data        ,
	input      [15:0]    i_threshold2on    ,
	input      [31:0]    i_measure_period  ,
	output reg [31:0]    o_period_total    ,
	output reg [31:0]    o_period_pos_cnt          //测量周期个数；        
);

localparam WAIT_NUM = 0;//确定超过阈值的周期个数；
localparam HALF_FREQ_NUM = 34  ; //64/(12.882-13.56-14.238) = 4.45-4.96;  4.96/2 近似2.5  '//60M的时候adc波形的 lock_cnt 半个周期最大是8 ，超过8认为是pw的低电平 不计数；



(* mark_debug="true" *)wire   pos_pwm,neg_pwm;
assign pos_pwm = pwm & ~r_pwm;
assign neg_pwm = ~pwm & r_pwm;

(* mark_debug="true" *)reg  [13:0]  ri_adc_data; 
(* mark_debug="true" *)reg  [7:0]   wait_on_cnt,wait_off_cnt  ;

(* mark_debug="true" *)reg  [15:0]  ri_threshold2on;
(* mark_debug="true" *)reg  [15:0]  ri_oppsite_threshold2on;

(* mark_debug="true" *)reg          pwm        ;
(* mark_debug="true" *)reg          r_pwm      ;
(* mark_debug="true" *)reg  [31:0]  period_cnt ;  
(* mark_debug="true" *)reg  [31:0]  pos_cnt    ; 

(* mark_debug="true" *)reg          LOCK       ;
(* mark_debug="true" *)reg  [31:0]  lock_cnt   ; 

(* mark_debug="true" *)reg  [31:0]  period_total;


always@(posedge i_clk or posedge i_rst)begin //计数上升沿下降沿的周期个数，超过了3（13.56）则认为开了PW，因为正常CW是不会超过2的；   012 01 012 012 01 01234....则开始是脉冲模式了
    if(i_rst)
	      lock_cnt <= 32'b0;
    else if(pos_pwm || neg_pwm)	  
	      lock_cnt <= 32'b0;  //+8191
    else 
	      lock_cnt <= lock_cnt + 32'b1;
end	

always@(posedge i_clk or posedge i_rst)begin  //lock : 64M时 13.56 有5个点；pwm上下沿各自2/3个clk；而当lock计数器大于占空比的空间
    if(i_rst)
	      LOCK <= 1'b0;
    else if(lock_cnt > HALF_FREQ_NUM-1)	  
	      LOCK <= 1'b1;  //+8191
    else 
	      LOCK <= 1'b0;
end	
//注：取的threshold2on越大越准，从波峰开始计数。一个脉冲上升沿一个周期；
//buf;

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
	      ri_adc_data <= 14'b0;
    else 		  
	      ri_adc_data <= i_adc_data + 2047;  //+8191   ；此处要随着adc的量程变化

end		

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
	      ri_threshold2on         <= 32'b0;
		  ri_oppsite_threshold2on <= 32'd0;
    end
    else  begin
	      ri_threshold2on <= i_threshold2on+ 2047;
		  ri_oppsite_threshold2on <=( ~i_threshold2on + 1) + 2047;//按位取反；
    end
end		

//取一段时间做循环设置；并且可以循环长度；
always@(posedge i_clk or posedge i_rst)begin //周期循环计数
    if(i_rst)
	      period_cnt <= 32'd0;
	else if(period_cnt >= i_measure_period - 1 )
	      period_cnt <= 32'd0;
	else 
	      period_cnt <=  period_cnt + 32'd1;
end 

always@(posedge i_clk or posedge i_rst)begin //CW和PW的有效周期计数  ，lock不超出 HALF_FREQ_NUM 则认为在脉冲有效期间（ pwm =1 ），或者CW工作期间
    if(i_rst)
	      period_total <= 32'd0;
	else if(period_cnt >= i_measure_period - 1 )
	      period_total  <= 32'd0;
	else if(~LOCK)
	      period_total  <= period_total + 'd1;
	      
end

//拟合方波；
always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
	      pwm <= 1'd0;
	else if(ri_adc_data > ri_threshold2on)
	      pwm <= 1'd1;
	else if(ri_adc_data < ri_oppsite_threshold2on)
	      pwm <= 1'd0;
end 

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
	      r_pwm <= 1'b0;
    else 	  
	      r_pwm <= pwm;
end		

//计数器计数检测周期时间内的周期个数；
always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
	      pos_cnt <= 1'd0;
	else if(period_cnt >= i_measure_period - 1)
	      pos_cnt <= 1'd0;
	else if(pos_pwm)
	      pos_cnt <= pos_cnt + 1'd1;
    else
	      pos_cnt <= pos_cnt;
end 

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
	      o_period_pos_cnt <= 32'd0;
	else if(period_cnt >= i_measure_period - 2)
          o_period_pos_cnt <= pos_cnt;
end 

always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
	      o_period_total <= 32'd0;
	else if(period_cnt >= i_measure_period - 2)
          o_period_total <= period_total;
end 


// always@(posedge i_clk or posedge i_rst)begin
    // if(i_rst)
	      // pwm_on  <= 1'd0;
    // else if (wait_on_cnt > WAIT_NUM-1 )
		  // pwm_on  <= 1'd1;
    // else 
	      // pwm_on  <= 1'd0;
// end 

// always@(posedge i_clk or posedge i_rst)begin
    // if(i_rst)
	      // pwm_off  <= 1'd0;
    // else if (wait_off_cnt > WAIT_NUM-1 )
		  // pwm_off  <= 1'd1;
    // else 
	      // pwm_off  <= 1'd0;
// end 
// //多周期确认超阈值，除去毛刺噪声；
// always@(posedge i_clk or posedge i_rst)begin
    // if(i_rst)
	      // wait_on_cnt <= 8'd0;
     // else if(pos_pwm_off)
	      // wait_on_cnt <= 8'd0;
	// else if( ri_adc_data > ri_threshold2on )
	      // wait_on_cnt <= wait_on_cnt + 8'd1;
     // else 
	      // wait_on_cnt <= wait_on_cnt;
// end 

// always@(posedge i_clk or posedge i_rst)begin
    // if(i_rst)
	      // wait_off_cnt <= 8'd0;
     // else if(pos_pwm_on)
	      // wait_off_cnt <= 8'd0;
	// else if( ri_adc_data < ri_oppsite_threshold2on) //signed 把补码转化成原码来比较；
	      // wait_off_cnt <= wait_off_cnt + 8'd1;
     // else 
	      // wait_off_cnt <= wait_off_cnt;
// end 


// always@(posedge i_clk or posedge i_rst)begin
    // if(i_rst)begin
	     // r_pwm_on <= 'd0;
		 // r_pwm_off<= 'd0;
    // end
    // else begin
	     // r_pwm_on <= pwm_on;
		 // r_pwm_off<= pwm_off;
    // end 	  

// end	

// ila_freq_detect ila_freq_detect (
	// .clk(i_clk), // input wire clk

	// .probe0(o_period_total   ), // input wire [31:0]  probe0  
	// .probe1(i_adc_data       ), // input wire [13:0]  probe1 
	// .probe2(i_threshold2on   ), // input wire [15:0]  probe2 
	// .probe3(i_measure_period ), // input wire [31:0]  probe3 
	// .probe4(o_period_pos_cnt ), // input wire [31:0]  probe4 
	// .probe5(lock_cnt), // input wire [7:0]  probe5 
	// .probe6(pos_pwm), // input wire [0:0]  probe7 
	// .probe7(neg_pwm), // input wire [0:0]  probe8 
	// .probe8(ri_adc_data), // input wire [13:0]  probe9 
	// .probe9(ri_threshold2on), // input wire [15:0]  probe12 
	// .probe10(ri_oppsite_threshold2on), // input wire [15:0]  probe13 
	// .probe11(r_pwm), // input wire [0:0]  probe14 
	// .probe12(period_cnt), // input wire [31:0]  probe15 
	// .probe13(pwm), // input wire [0:0]  probe16 
	// .probe14(pos_cnt), // input wire [31:0]  probe19 
	// .probe15(period_total),
	// .probe16(LOCK)
// );

endmodule
