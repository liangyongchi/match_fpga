`timescale 1ns / 1ps

//Module and Port Listing;
module  RF_MODE_SENSOR
// #(
        // // parameter        FIFO_LEN   = 'd16,
	                     // // FIFO_WIDTH = 'd4 
// )//Inputs and Outputs declaration;
(
	    input            clk               ,
        input            rst               ,
		input [31:0]     vf_power          , 
	    input            calib_vf_vld      , 
		input [31:0]     power_threshold   , 
		input            power_rise        , 
		input            power_fall        ,
	    input [31:0]     match_on_dly      ,//10ms
		input [31:0]     detect_pulse_width,
		input [31:0]     OFF_NUM           ,
		output           open_status       ,
        output           CW_MODE           ,
        output           PW_MODE           ,   
		output reg       power_status     
);

assign open_status = up_threshold_vld;
reg         CW_ON  ;
assign      CW_MODE = power_status && CW_ON;
reg         PW_ON  ;
assign      PW_MODE = power_status && PW_ON;

reg         power_rise_r0,power_rise_r1;
reg         power_fall_r0,power_fall_r1;
reg         detect_stage0   ;
reg [31:0]  stage0_cnt      ;
reg [31:0]  stage0_neg_cnt  ;   
reg [31:0]  stage1_neg_cnt  ; 

reg [31:0]  stage1_cnt      ;
wire        pos_power_fall  ;
wire        pos_power_rise  ;

reg  [31:0] detect_end_cnt;
wire        up_threshold_vld;
assign      up_threshold_vld = (vf_power >= power_threshold);

reg         detect_end ;
wire        off_flag   ;
assign      off_flag = (detect_end_cnt > OFF_NUM);// power nosie can not stop //60ms;60ms 的低值，认为是关

assign pos_power_fall = power_fall_r0&&(~power_fall_r1);
assign pos_power_rise = power_rise_r0&&(~power_rise_r1);

wire   stage1_sensor_clr;
assign stage1_sensor_clr = (stage1_cnt == detect_pulse_width-32'd1);//200ms

wire   power_status_refresh;
assign power_status_refresh = (stage1_cnt == detect_pulse_width-32'd2);//200ms

wire   stage1_sensor_result;
assign stage1_sensor_result = (stage1_cnt == detect_pulse_width-32'd2);//200ms

// //***********************************MODE SELECT********************************************/
	wire   stage0_neg_cmp;
	assign stage0_neg_cmp = (stage0_neg_cnt > 32'd0);
	wire   stage1_neg_cmp;
	assign stage1_neg_cmp = (stage1_neg_cnt > 32'd3);

	always@(posedge clk or posedge rst)begin
		if(rst)begin
			CW_ON <= 1'd0;
			PW_ON <= 1'd0;
		end
		else if(detect_end) begin
				CW_ON <= 1'd0;
				PW_ON <= 1'd0;
		end
		else if(detect_stage0)begin
			if(stage0_neg_cmp)begin
				CW_ON <= 1'd0;
				PW_ON <= 1'd1; 
			end
			else begin
				CW_ON <= 1'd1;
				PW_ON <= 1'd0;
			end
		end
		else if(power_status_refresh)begin //200ms刷新
			if(stage1_neg_cmp)begin
				CW_ON <= 1'd0;
				PW_ON <= 1'd1;
			end
			else begin
				CW_ON <= 1'd1;
				PW_ON <= 1'd0;
			end
		end  
	end
// //*****************************power on-off detect*************************************/
	always@(posedge clk or posedge rst)
	begin 
		if(rst)
			detect_stage0 <= 1'd0;
		else if(stage0_cnt == match_on_dly-1)//20ms Ttotal=N×Tclk=1000000×20ns=20000000ns
			detect_stage0 <= 1'd0;
		else if(up_threshold_vld)  //功率大于阈值,开启第一阶段的下降沿计数
			detect_stage0 <= 1'd1; //启动第一阶段的计数信号
	end
	always@(posedge clk or posedge rst)begin
		if(rst)
			stage0_cnt <= 32'd0;
		else if(detect_end)    //检测到关
			stage0_cnt <= 32'd0;
		else if(stage0_cnt >= match_on_dly-1)//20ms Ttotal=N×Tclk=1000000×20ns=20000000ns 20ms保持
			stage0_cnt <= stage0_cnt;
		else if(detect_stage0)
			stage0_cnt <= stage0_cnt + 32'd1;//计数	       
	end
	always@(posedge clk or posedge rst)begin
		if(rst)
			detect_end <= 1'd0;
		else if(stage0_cnt == match_on_dly-1)begin//20ms Ttotal=N×Tclk=1000000×20ns=20000000ns
			if(off_flag)		
				detect_end <= 1'd1; //60ms 计数才算关
			else 
				detect_end <= 1'd0;
		end	    
		else
			detect_end <= 1'd0;
	end
	always@(posedge clk or posedge rst)begin
		if(rst)
		detect_end_cnt <= 32'd0;
		else if(stage0_cnt==match_on_dly-1)begin//20ms  //已经开了功率
		if(up_threshold_vld)		
			detect_end_cnt <= 32'd0;
		else 
			detect_end_cnt <= detect_end_cnt + 32'd1; //功率小于阈值,认为关闭，则进行关闭功率进行计数。
		end	
		else 
		detect_end_cnt <= 32'd0;
	end
	always@(posedge clk or posedge rst)
	begin 
		if(rst)
			power_status <= 1'd0;
		else if(stage0_cnt==match_on_dly-1)begin	//20ms
			if(detect_end)
			power_status <= 1'd0;	
			else
			power_status <= 1'd1;//20ms后,认为功率开启了.
		end
		else 
		power_status <= 1'd0;
	end
//************************mode detect*****************************//	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			power_rise_r0 <= 1'd0;
			power_rise_r1 <= 1'd0;
		end
		else  begin
			power_rise_r0 <= power_rise;
			power_rise_r1 <= power_rise_r0;	 
		end
	end
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			power_fall_r0 <= 1'd0;
			power_fall_r1 <= 1'd0;
		end
		else  begin
			power_fall_r0 <= power_fall;
			power_fall_r1 <= power_fall_r0;	 
		end      
	end
	always@(posedge clk or posedge rst)begin
		if(rst)
			stage0_neg_cnt <= 32'd0;
		else if(detect_end)		
			stage0_neg_cnt <= 32'd0;
		else if(detect_stage0)begin
			if(pos_power_fall)
			stage0_neg_cnt <= stage0_neg_cnt + 32'd1;
		end     
	end
// //*****************************stage1 detect(stage1_start to begin)******************************/
	always@(posedge clk or posedge rst)
	begin 
		if(rst)
			stage1_cnt <= 32'd0;
		else if(power_status) begin  //功率开启后，开启第二阶段的计数，循环计数
			if(stage1_cnt >= (detect_pulse_width-32'd1))//200ms
				stage1_cnt <= 32'd0;
			else
				stage1_cnt <= stage1_cnt + 32'd1;			
		end	
		else 
			stage1_cnt <= 32'd0;	
	end
	always@(posedge clk or posedge rst)begin
		if(rst)
			stage1_neg_cnt <= 32'd0;
		else if(power_status) begin
			if(stage1_sensor_clr)
				stage1_neg_cnt <= 32'd0; 	
			else if(pos_power_fall)
				stage1_neg_cnt <= stage1_neg_cnt + 32'd1;//计下降沿的个数
		end
		else
			stage1_neg_cnt <= 32'd0; 	
	end
// //******************************stage1 detect sensor****************************//

// ila_RF_MODE_SENSOR U_ila_RF_MODE_SENSOR (
	// .clk(clk), // input wire clk
	// .probe0(vf_power          ), 
	// .probe1(calib_vf_vld      ), 
	// .probe2(power_threshold   ), 
	// .probe3(power_rise        ), 
	// .probe4(power_fall        ), 
	// .probe5(match_on_dly      ), 
	// .probe6(detect_pulse_width), 
	// .probe7(CW_ON             ), 
	// .probe8(PW_ON             ), 
	// .probe9(power_status      ), 
	// .probe10(CW_MODE          ), 
	// .probe11(PW_MODE          ), 
	// .probe12(power_fall_r0    ), 
	// .probe13(power_fall_r1    ), 
	// .probe14(detect_stage0    ), 
	// .probe15(stage0_cnt       ), 
	// .probe16(stage0_neg_cnt   ), 
	// .probe17(stage1_neg_cnt   ), 
	// .probe18(detect_end       ), 
	// .probe19(stage1_cnt       ), 
	// .probe20(pos_power_fall   ), 
	// .probe21(pos_power_rise   ), 
	// .probe22(up_threshold_vld ), 
	// .probe23(off_flag           ), 
	// .probe24(detect_end_cnt     ), 
	// .probe25(stage1_sensor_clr), 
	// .probe26(power_status_refresh)

// );

endmodule
