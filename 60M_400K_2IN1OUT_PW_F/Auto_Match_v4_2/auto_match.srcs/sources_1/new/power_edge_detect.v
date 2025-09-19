`timescale 1ns / 1ps
module power_edge_detect(
    input                clk_i           ,
    input                rst_i           ,
    input                power_filter_vld, 		
    input   [15: 0]      vf_power_filter , 
    input   [ 9: 0]      rise_jump       ,
    input   [ 9: 0]      fall_jump       ,//max:1023;
	input                power_buf0_vld  ,//rise detecr vld;
	input                power_buf1_vld  ,
	input                power_buf2_vld  ,
	input                power_buf3_vld  ,	
	input                power_sub_vld   ,
	
	input                power0_buf0_vld ,//fall detect vld;
	input                power0_buf1_vld ,
	input                power0_buf2_vld ,
	input                power0_buf3_vld ,	
	input                power0_sub_vld  ,
	
	input   [35:0]       detect_keep_dly ,
   input   [35:0]	      rise_delay_cnt  ,
   input   [35:0]	      fall_delay_cnt  ,
	
   input   [15:0]       pulse_start     ,
	input   [15:0]       pulse_end       ,
   output  reg          power_keep      ,
	output               power_fall      ,
	output               power_rise      ,
	output  reg          avg_keep        ,

    output reg [35:0]    keep_dly        ,
    output reg [35:0]    pulse_on_cnt	
	
);


assign      power_fall = avg_fall ;
assign      power_rise = avg_rise ;
//assign      power_keep = ( (pulse_on_cnt > pulse_start-1) && ( pulse_on_cnt< END-1) )?  1 : 0;



reg         avg_rise       ; 
//reg         avg_keep       ;
reg         avg_fall       ;
//rise buf
reg [15:0]  buf0_temp_power;
reg [15:0]  buf1_temp_power;
reg [15:0]  buf2_temp_power;
reg [15:0]  buf3_temp_power;
//fall buf
reg [15:0]  buf0_temp_power0;
reg [15:0]  buf1_temp_power0;
reg [15:0]  buf2_temp_power0;
reg [15:0]  buf3_temp_power0;

reg [15:0]  sub_buf2_buf0  ;//上升的差值
reg [15:0]  sub_buf0_buf2  ;
reg [15:0]  sub_buf3_buf1  ;
reg [15:0]  sub_buf1_buf3  ;

reg [15:0]  sub0_buf2_buf0  ;
reg [15:0]  sub0_buf0_buf2  ;
reg [15:0]  sub0_buf3_buf1  ;
reg [15:0]  sub0_buf1_buf3  ;



always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      power_keep <= 1'd0;   
   else if( (pulse_on_cnt > pulse_start-1) && ( pulse_on_cnt< pulse_end-1) )
      power_keep <= 1'b1;
   else 
      power_keep <= 1'b0; 	
end	  
//buf detect fall  ;
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf0_temp_power0 <= 1'd0;   
   else if(power0_buf0_vld)
      buf0_temp_power0 <= vf_power_filter;
   else 
      buf0_temp_power0 <= buf0_temp_power0; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf1_temp_power0 <= 1'd0;   
   else if(power0_buf1_vld)
      buf1_temp_power0 <= vf_power_filter;
   else 
      buf1_temp_power0 <= buf1_temp_power0; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf2_temp_power0 <= 1'd0;   
   else if(power0_buf2_vld)
      buf2_temp_power0 <= vf_power_filter;
   else 
      buf2_temp_power0 <= buf2_temp_power0; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf3_temp_power0 <= 1'd0;   
   else if(power0_buf3_vld)
      buf3_temp_power0 <= vf_power_filter;
   else 
      buf3_temp_power0 <= buf3_temp_power0; 
end
// vld to sub result;//为负不使用
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub0_buf2_buf0 <= 1'd0;   
   else if(power0_sub_vld)
      sub0_buf2_buf0 <= buf2_temp_power0 - buf0_temp_power0;
   else 
      sub0_buf2_buf0 <= sub0_buf2_buf0; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub0_buf0_buf2 <= 1'd0;   
   else if(power0_sub_vld)
      sub0_buf0_buf2 <= buf0_temp_power0 - buf2_temp_power0;
   else 
      sub0_buf0_buf2 <= sub0_buf0_buf2; 
end
//为负不使用
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub0_buf3_buf1 <= 1'd0;   
   else if(power0_sub_vld)
      sub0_buf3_buf1 <= buf3_temp_power0 - buf1_temp_power0;
   else 
      sub0_buf3_buf1 <= sub0_buf3_buf1; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub0_buf1_buf3 <= 1'd0;   
   else if(power0_sub_vld)
      sub0_buf1_buf3 <= buf1_temp_power0 - buf3_temp_power0;
   else 
      sub0_buf1_buf3 <= sub0_buf1_buf3;     
end		
//**************************************************************
//buf detect rise  ;
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf0_temp_power <= 1'd0;   
   else if(power_buf0_vld)
      buf0_temp_power <= vf_power_filter;
   else 
      buf0_temp_power <= buf0_temp_power; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf1_temp_power <= 1'd0;   
   else if(power_buf1_vld)
      buf1_temp_power <= vf_power_filter;
   else 
      buf1_temp_power <= buf1_temp_power; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf2_temp_power <= 1'd0;   
   else if(power_buf2_vld)
      buf2_temp_power <= vf_power_filter;
   else 
      buf2_temp_power <= buf2_temp_power; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      buf3_temp_power <= 1'd0;   
   else if(power_buf3_vld)
      buf3_temp_power <= vf_power_filter;
   else 
      buf3_temp_power <= buf3_temp_power; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub_buf2_buf0 <= 1'd0;   
   else if(power_sub_vld)
      sub_buf2_buf0 <= buf2_temp_power - buf0_temp_power;
   else 
      sub_buf2_buf0 <= sub_buf2_buf0; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub_buf0_buf2 <= 1'd0;   
   else if(power_sub_vld)
      sub_buf0_buf2 <= buf0_temp_power - buf2_temp_power;
   else 
      sub_buf0_buf2 <= sub_buf0_buf2; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub_buf3_buf1 <= 1'd0;   
   else if(power_sub_vld)
      sub_buf3_buf1 <= buf3_temp_power - buf1_temp_power;
   else 
      sub_buf3_buf1 <= sub_buf3_buf1; 
end
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
      sub_buf1_buf3 <= 1'd0;   
   else if(power_sub_vld)
      sub_buf1_buf3 <= buf1_temp_power - buf3_temp_power;
   else 
      sub_buf1_buf3 <= sub_buf1_buf3;     
end

//**********************rise or fall result output************************
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)begin
      avg_rise     <= 1'd0;
	  avg_keep     <= 1'd1;
	  avg_fall     <= 1'd0;
   end   
   else if( ($signed(sub_buf2_buf0) > $signed(rise_jump)) && ($signed(sub_buf3_buf1) > $signed(rise_jump)))begin
      avg_rise     <= 1'd1;
	  avg_keep     <= 1'd0;
	  avg_fall     <= 1'd0;
   end   
   else if(($signed(sub0_buf0_buf2) >= $signed(fall_jump)) &&($signed(sub0_buf1_buf3) >= $signed(fall_jump)))begin
      avg_rise     <= 1'd0;
	  avg_keep     <= 1'd0;
	  avg_fall     <= 1'd1;
   end
   else begin
      avg_rise     <= 1'd0 ;
	  avg_keep     <= 1'd1 ;
	  avg_fall     <= 1'd0 ;
   end
end

//reg [35:0] keep_cnt;

reg        neg_rise_r0, neg_rise_r1;

wire       keep_start;
assign     keep_start = (!neg_rise_r0) && neg_rise_r1;

always@(posedge clk_i or posedge rst_i)begin
    if(rst_i)begin
	   neg_rise_r0 <=1'd0;
	   neg_rise_r1 <=1'd0;
	end
	else begin
	   neg_rise_r0 <= avg_rise;
	   neg_rise_r1 <= neg_rise_r0;
	end
end
//****************************************pwm_on detect***********************//

reg         pulse_pwm_status;
reg         pwm_status_r0, pwm_status_r1;
// reg         ch_sel_r0,ch_sel_r1;
//reg [35:0]  pulse_period_cnt;


// wire	    pos_ch_sel;
// assign      pos_ch_sel = (pwm_status_r0) &&(!pwm_status_r1);

// wire	    neg_ch_sel;
// assign      neg_ch_sel = (!pwm_status_r0) &&(pwm_status_r1);

wire	    pos_pwm_status;
assign      pos_pwm_status = (pwm_status_r0) &&(!pwm_status_r1);

wire	    neg_pwm_status;
assign      neg_pwm_status = (!pwm_status_r0) &&(pwm_status_r1);

// always@(posedge clk_i or posedge rst_i)begin
    // if(rst_i)begin
	   // ch_sel_r0 <=1'd0;
	   // ch_sel_r1 <=1'd0;
	// end
	// else begin
	   // ch_sel_r0 <= ch_sel;
	   // ch_sel_r1 <= ch_sel_r0;
	// end
// end

always@(posedge clk_i or posedge rst_i)begin
    if(rst_i)begin
	   pwm_status_r0 <=1'd0;
	   pwm_status_r1 <=1'd0;
	end
	else begin
	   pwm_status_r0 <= pulse_pwm_status;
	   pwm_status_r1 <= pwm_status_r0;
	end
end

always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       pulse_pwm_status <= 1'd0;
   // else if(pos_ch_sel||neg_ch_sel)
       // pulse_pwm_status <= 1'd0;
   else if(keep_start)
       pulse_pwm_status <= 1'd1;
   else if(power_fall)
       pulse_pwm_status <= 1'd0;
end 

always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       keep_dly <= 36'd0;
   // else if(pos_ch_sel||neg_ch_sel)
       // keep_dly <= 36'd0;
   else if(neg_pwm_status) 
       keep_dly <=  pulse_on_cnt ;  // 1-1/4
end 


always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       pulse_on_cnt <= 36'd0;
   else if(!pulse_pwm_status)
       pulse_on_cnt <= 36'd0;
   else 
       pulse_on_cnt <= pulse_on_cnt + 36'd1;
end 

//no use;
// always@(posedge clk_i or posedge rst_i)begin
   // if(rst_i)
       // pulse_period_cnt <= 36'd0;
   // else if(pos_pwm_status)
       // pulse_period_cnt <= 36'd0;
   // else 
       // pulse_period_cnt <= pulse_period_cnt + 36'd1;
// end 

// ila_2 ila_power_detect (
	// .clk(clk_i), // input wire clk
	// .probe0(power_filter_vld), // input wire [0:0]  probe0  
	// .probe1(vf_power_filter), // input wire [15:0]  probe1 
	// .probe2(pulse_pwm_status   ),       // input wire [9:0]  probe2 
	// .probe3(pos_pwm_status   ),        // input wire [9:0]  probe3 
	// .probe4(keep_dly ), // input wire [0:0]  probe4 
	// .probe5(pulse_period_cnt ), // input wire [0:0]  probe5 
	// .probe6(pulse_on_cnt     ), // input wire [0:0]  probe6 
	// .probe7( CW_MODE), // input wire [0:0]  probe7 
	// .probe8(power_sub_vld  ), // input wire [0:0]  probe8 
	// .probe9 (avg_rise), // input wire [0:0]  probe9 
	// .probe10(ch_sel), // input wire [0:0]  probe10 
	// .probe11(avg_fall), // input wire [0:0]  probe11 
	// .probe12( buf0_temp_power), // input wire [15:0]  probe12 
	// .probe13( buf1_temp_power), // input wire [15:0]  probe13 
	// .probe14( buf2_temp_power), // input wire [15:0]  probe14 
	// .probe15( buf3_temp_power), // input wire [15:0]  probe15 
	// .probe16( sub_buf2_buf0  ), // input wire [15:0]  probe16 
	// .probe17( sub_buf0_buf2  ), // input wire [15:0]  probe17 
	// .probe18( sub_buf3_buf1  ), // input wire [15:0]  probe18 
	// .probe19( sub_buf1_buf3  ), // input wire [15:0]  probe19
    // .probe20(fall_delay_cnt  ),
    // .probe21(rise_delay_cnt  ),
    // .probe22(power_calib_vld ),
    // .probe23(power_calib     ),
    // .probe24(filtering_value ),
    // .probe25( buf0_temp_power0),
    // .probe26( buf1_temp_power0),
    // .probe27( buf2_temp_power0),
    // .probe28( buf3_temp_power0),
    // .probe29( sub0_buf2_buf0  ),
    // .probe30( sub0_buf0_buf2  ),
    // .probe31( sub0_buf3_buf1  ),
    // .probe32( sub0_buf1_buf3  ),
    // .probe33(power0_buf0_vld  ),
    // .probe34(power0_buf1_vld  ),
    // .probe35(power0_buf2_vld  ),
    // .probe36(power0_buf3_vld  ),	
    // .probe37(power0_sub_vld   ),
	// .probe38(keep_start),
	// .probe39(PW_MODE   ),
	// .probe40(power_keep)
// );


endmodule

