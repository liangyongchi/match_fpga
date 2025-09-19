
module RF_MODE_SENOR_400K(

    input            clk               , //50m；
    input            rst               ,
	input [31:0]     vf_power          , 

	input [31:0]     power_threshold   , 
	input [31:0]     OFF_NUM           , //检测区间长度，关闭的最大计数；
    input [31:0]     ON_KEEP_NUM       , //开始有功率到延迟启动的拟合脉冲的起始时间；
    input [31:0]     OFF_KEEP_NUM      , //开始有功率到延迟启动的拟合脉冲的结束时间；
    output reg       pwm_on            ,
    output reg       CW_MODE           ,
    output reg       PW_MODE           ,   
    output reg       power_status     
);

wire pulse_ok;
assign pulse_ok = ( (on_cnt >= (ON_KEEP_NUM-1) ) && (on_cnt <= (OFF_KEEP_NUM -1) ) ) ;

wire    up_threshold ,down_threshold;
assign  up_threshold   = (vf_power > power_threshold) ;
assign  down_threshold = (vf_power < power_threshold) ;

reg  [31:0]  on_cnt;
reg  [31:0]  off_cnt;

always@(posedge clk or posedge rst)begin
       if(rst)
	       on_cnt <= 32'd0;
	   else if (down_threshold)      //如果是PW,下降的时候清零，此时计数不会大于OFF_NUM
	       on_cnt <= 32'd0;
	   else if(on_cnt >= OFF_NUM -1 )//如果大于这个数OFF_NUM，就认为是CW波，
	       on_cnt <= on_cnt ;	     
	   else if(up_threshold) 
		   on_cnt <= on_cnt + 'd1;
end

always@(posedge clk or posedge rst)begin
       if(rst)
	       off_cnt <= 32'd0;
	   else if(up_threshold)           //脉冲有效 清零；
	       off_cnt <= 32'd0;
	   else if(off_cnt >= OFF_NUM -1 ) //超数 关闭；
	      off_cnt <= off_cnt;	   
	   else if(down_threshold) 
		   off_cnt <= off_cnt + 'd1;
end

always@(posedge clk or posedge rst)begin
       if(rst)
	       power_status <= 'd0;
	   else if (off_cnt >= OFF_NUM -1)
	       power_status <= 'd0;		   
	   else if(up_threshold)
	       power_status <= 'd1;
end

//CW PW SELECT;
always@(posedge clk or posedge rst)begin
      if(rst)begin
	      CW_MODE <= 1'd0;
		  PW_MODE <= 1'd0;
      end
	  else if(off_cnt >= OFF_NUM -1) begin //关;
		  CW_MODE <= 1'd0;
		  PW_MODE <= 1'd0;
	  end
	  else if(up_threshold) begin //power on;
	       if(on_cnt >= OFF_NUM -1)begin
		       CW_MODE <= 1'd1;
		       PW_MODE <= 1'd0;
           end
	       else begin   
		       CW_MODE <= 1'd0;
		       PW_MODE <= 1'd1;
		   end
	  end
	  // else  begin //关;
		   // CW_MODE <= 1'd0;
		   // PW_MODE <= 1'd0;
	  // end	  
end
always@(posedge clk or posedge rst)begin
       if(rst)
	       pwm_on <= 'd0;
	   else if(PW_MODE) begin
	       if(pulse_ok)
      		   pwm_on <= 'd1;
		   else  
		       pwm_on <= 'd0;  
       end	   	   
	   else 
		   pwm_on <= 'd0;
end
endmodule
