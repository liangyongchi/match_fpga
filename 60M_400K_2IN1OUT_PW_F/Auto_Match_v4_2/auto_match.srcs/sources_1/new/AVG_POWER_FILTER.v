`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/24 16:57:42
// Design Name: 
// Module Name: AVG_POWER_BUF
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

module AVG_POWER_FILTER(  //移动窗口
    input               clk_i              ,
    input               rst_i              ,
    input               power_calib_vld    ,
	input [15:0]        power_calib        ,
    input [15:0]        filtering_value    ,	
    input [23:0]        detect_rise_dly         ,
	input [23:0]        detect_fall_dly    ,
    output reg [15:0]   power_filter       ,
    output reg          power_filter_vld   ,

	output reg          power_buf0_vld     ,  //缓存窗口参考值；
	output reg          power_buf1_vld     ,
	output reg          power_buf2_vld     ,
	output reg          power_buf3_vld     ,
	
	output reg          power0_buf0_vld    ,  //缓存窗口参考值；
	output reg          power0_buf1_vld    ,
	output reg          power0_buf2_vld    ,
	output reg          power0_buf3_vld    ,
	
	output reg          power_sub_vld      ,
	output reg          power0_sub_vld     ,    
    output reg [35:0]       fall_delay_cnt     ,	
    output reg [35:0]       rise_delay_cnt 
);

//fall delay detect;
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       fall_delay_cnt <= 16'd0;
   else if(power_calib_vld&&(fall_delay_cnt >= detect_fall_dly))
       fall_delay_cnt <= 16'd0;
   else if(power_calib_vld)
       fall_delay_cnt <= fall_delay_cnt + 'd1;
end

always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       power0_sub_vld <= 1'd0; 
   else if(power_calib_vld && (fall_delay_cnt == detect_fall_dly))
       power0_sub_vld <= 1'd1;
   else 
       power0_sub_vld <= 1'd0;
end

always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)begin
       power0_buf0_vld <= 1'd0;
	   power0_buf1_vld <= 1'd0;
	   power0_buf2_vld <= 1'd0;
	   power0_buf3_vld <= 1'd0;
   end
   else if(power_calib_vld && (fall_delay_cnt == 36'd0))begin
       power0_buf0_vld <= 1'd1;    
       power0_buf1_vld <= 1'd0;  
	   power0_buf2_vld <= 1'd0;	
	   power0_buf3_vld <= 1'd0;	   
   end
   else if(power_calib_vld && (fall_delay_cnt == 36'd1))begin
       power0_buf0_vld <= 1'd0;    
       power0_buf1_vld <= 1'd1;
	   power0_buf2_vld <= 1'd0;
	   power0_buf3_vld <= 1'd0;
   end
   else if(power_calib_vld && (fall_delay_cnt == detect_fall_dly - 2))begin
       power0_buf0_vld <= 1'd0;    
       power0_buf1_vld <= 1'd0;
	   power0_buf2_vld <= 1'd1;
	   power0_buf3_vld <= 1'd0;
   end   
   else if(power_calib_vld && (fall_delay_cnt == detect_fall_dly - 1))begin
       power0_buf0_vld <= 1'd0;    
       power0_buf1_vld <= 1'd0;
	   power0_buf2_vld <= 1'd0;
	   power0_buf3_vld <= 1'd1;
   end
   else begin
	   power0_buf0_vld <= 1'd0;   
       power0_buf1_vld <= 1'd0;    
       power0_buf2_vld <= 1'd0;
	   power0_buf3_vld <= 1'd0;
   end
end

//rise delay detect;
always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       rise_delay_cnt <= 16'd0;
   else if(power_calib_vld&&(rise_delay_cnt >= detect_rise_dly))
       rise_delay_cnt <= 16'd0;
   else if(power_calib_vld)
       rise_delay_cnt <= rise_delay_cnt + 'd1;
end

always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       power_sub_vld <= 1'd0; 
   else if(power_calib_vld && (rise_delay_cnt == detect_rise_dly))
       power_sub_vld <= 1'd1;
   else 
       power_sub_vld <= 1'd0;
end


always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)begin
       power_buf0_vld <= 1'd0;
	   power_buf1_vld <= 1'd0;
	   power_buf2_vld <= 1'd0;
	   power_buf3_vld <= 1'd0;
   end
   else if(power_calib_vld && (rise_delay_cnt == 36'd0))begin
       power_buf0_vld <= 1'd1;    
       power_buf1_vld <= 1'd0;  
	   power_buf2_vld <= 1'd0;	
	   power_buf3_vld <= 1'd0;	   
   end
   else if(power_calib_vld && (rise_delay_cnt == 36'd2))begin
       power_buf0_vld <= 1'd0;    
       power_buf1_vld <= 1'd1;
	   power_buf2_vld <= 1'd0;
	   power_buf3_vld <= 1'd0;
   end
   else if(power_calib_vld && (rise_delay_cnt == detect_rise_dly - 3))begin
       power_buf0_vld <= 1'd0;    
       power_buf1_vld <= 1'd0;
	   power_buf2_vld <= 1'd1;
	   power_buf3_vld <= 1'd0;
   end   
   else if(power_calib_vld && (rise_delay_cnt == detect_rise_dly - 1))begin
       power_buf0_vld <= 1'd0;    
       power_buf1_vld <= 1'd0;
	   power_buf2_vld <= 1'd0;
	   power_buf3_vld <= 1'd1;
   end
   else begin
	   power_buf0_vld <= 1'd0;   
       power_buf1_vld <= 1'd0;    
       power_buf2_vld <= 1'd0;
	   power_buf3_vld <= 1'd0;
   end
end



always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       power_filter <= 16'd0;
   else if(power_calib > filtering_value)
       power_filter <= power_filter;
   else 
       power_filter <= power_calib;
end

always@(posedge clk_i or posedge rst_i)begin
   if(rst_i)
       power_filter_vld <= 16'd0;
   else 
       power_filter_vld <= power_calib_vld;
end

// ila_average_result your_instance_name (
	// .clk(clk_i), // input wire clk


	// .probe0(power_calib_vld    ), // input wire [0:0]  probe0  
	// .probe1(power_calib        ), // input wire [15:0]  probe1 
	// .probe2(filtering_value    ), // input wire [15:0]  probe2 
	// .probe3(detect_rise_dly         ), // input wire [23:0]  probe3 
	// .probe4(power_filter       ), // input wire [15:0]  probe4 
	// .probe5(power_filter_vld   ), // input wire [0:0]  probe5 
	// .probe6(power_buf0_vld     ), // input wire [0:0]  probe6 
	// .probe7(power_buf1_vld     ), // input wire [0:0]  probe7 
	// .probe8(power_sub_vld      ), // input wire [0:0]  probe8 
	// .probe9(rise_delay_cnt           ) // input wire [35:0]  probe9
// );

endmodule

