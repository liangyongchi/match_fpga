`timescale 1ns / 1ps

module FFT_dual_adc(
	input			    clk_i          ,
	input			    rst_i          ,						     
	input [15:0]		vf_real        ,
	input [15:0]		vf_imag        ,
	input				vf_vld         ,						     
	input [15:0]		vr_real        ,
	input [15:0]		vr_imag        ,
	input				vr_vld         ,   //vf vr必须同步进入	
    input               fft_start      ,
    input [15:0]        fft_period     ,	
	input 				clk_50m        ,
	input [63:0]		test_data      ,
    input [15:0]        VF_POWER_CALIB , //UES TO MAKE SURE POWER TO TOP;			       
	output reg [15:0]	vf_fft_i       ,
	output reg [15:0]	vf_fft_q       ,
	output reg [15:0]	vr_fft_i       ,
	output reg [15:0]	vr_fft_q       ,
	output reg 			fft_vld        ,
	output reg [7:0]	xk             ,
	output reg [15:0]   fft_abs_max    ,
    output reg          pwm_fft_vld    
);

wire 		 s_axis_data_tready        ;
wire 		 m_axis_data_tvalid        ;  
wire [31:0]  m_axis_data_tdata_temp    ;
wire [ 7:0]	 m_axis_data_tuser_temp    ;
reg  [31:0]  m_axis_data_tdata         ;
reg  [ 7:0]	 m_axis_data_tuser         ;
reg 		 s_axis_data_tlast         ;
reg  [ 7:0]	 xk_r0,xk_r1               ;								       
reg  [ 7:0]	 data_cnt                  ;
reg  [15:0]	 RE_ABS,IM_ABS             ;	//高IM，低RE
reg  [15:0]	 fft_abs                   ;
reg  [ 7:0]	 fft_a_r0,fft_a_r1,fft_a_r2;
reg  [ 7:0]	 xk_tem                    ;
reg  [15:0]  fft_period_cnt            ; 
//reg          pwm_fft_vld               ; 


always @(posedge clk_i or posedge rst_i)begin
	if(rst_i)
		data_cnt <= 0;
	else if(!s_axis_data_tready)
		data_cnt <= 0;
	else if(s_axis_data_tready && vf_vld && data_cnt==255)
		data_cnt <= 0;
	else if(s_axis_data_tready && vf_vld)
		data_cnt <= data_cnt + 1;
end

always @(posedge clk_i or posedge rst_i)begin
	if(rst_i)
		s_axis_data_tlast <= 0;
	else if(s_axis_data_tready && vf_vld && data_cnt==255)
		s_axis_data_tlast <= 1;
	else
		s_axis_data_tlast <= 0;
end 

//fft period transform tick;
always @(posedge clk_i or posedge rst_i)begin
    if(rst_i)
	    fft_period_cnt <= 16'd0;
    else if(!fft_start)
	    fft_period_cnt <= 16'd0;
    else if(fft_start&&(fft_period_cnt >= fft_period+'d2))
	    fft_period_cnt <= fft_period_cnt;
	else if(fft_start&&s_axis_data_tlast)
	    fft_period_cnt <= fft_period_cnt + 16'd1;
end 

//pwm vld to do fft several periods;
always@(posedge clk_i or posedge rst_i)begin
    if(rst_i)
	    pwm_fft_vld <= 1'd0;
    else if((data_cnt == 255)&&(fft_period_cnt > 0)&&(fft_period_cnt < fft_period+'d2)) //此处由于实际是从开始起第二个2周期做fft 后面补2周期回来
	    pwm_fft_vld <= 1'd1;
    else if(fft_period_cnt >= fft_period +'d2)
	    pwm_fft_vld <= 1'd0;
end

// 1=forward FFT, 0=inverse FFT (IFFT)
xfft_0 xfft_VF (
  .aclk(clk_i),                                              // input wire aclk
  .aresetn(~rst_i),                                          // input wire aresetn
  .s_axis_config_tdata(24'B00000_001_0_1000000_000_01000),   // input wire [23 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b0),                               // input wire s_axis_config_tvalid
  .s_axis_config_tready(	),                               // output wire s_axis_config_tready
  
  .s_axis_data_tdata({vf_imag,vf_real}),                     // input wire [31 : 0] s_axis_data_tdata,高虚部，低实部
  .s_axis_data_tvalid(pwm_fft_vld&vf_vld),                   // input wire s_axis_data_tvalid
  .s_axis_data_tready(s_axis_data_tready),                   // output wire s_axis_data_tready
  .s_axis_data_tlast(s_axis_data_tlast),                     // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(m_axis_data_tdata_temp),                // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tuser(m_axis_data_tuser_temp),                // output wire [7 : 0] m_axis_data_tuser
  .m_axis_data_tvalid(m_axis_data_tvalid),                   // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                                 // input wire m_axis_data_tready
  .m_axis_data_tlast(	),                                   // output wire m_axis_data_tlast
  .event_frame_started(	),                                   // output wire event_frame_started
  .event_tlast_unexpected(	),                               // output wire event_tlast_unexpected
  .event_tlast_missing(	),                                   // output wire event_tlast_missing
  .event_data_in_channel_halt(	)                            // output wire event_data_in_channel_halt
);


      
always @(posedge clk_i or posedge rst_i)
	if(rst_i) begin 
		m_axis_data_tdata <= 0;
		m_axis_data_tuser <= 0;
		end 
	else if(m_axis_data_tvalid) begin 
		m_axis_data_tdata <= m_axis_data_tdata_temp;
		m_axis_data_tuser <= m_axis_data_tuser_temp;
		end 

always @(posedge clk_i)
begin 
	fft_a_r0 <= m_axis_data_tuser;
	fft_a_r1 <= fft_a_r0;
	fft_a_r2 <= fft_a_r1;
end 

always @(posedge clk_i or posedge rst_i)
	if(rst_i) begin 
		RE_ABS <= 0;
		IM_ABS <= 0;
		end 
	else 
	begin 
		if(m_axis_data_tdata[15])
			RE_ABS <= ~m_axis_data_tdata[15:0]+1;
		else 
			RE_ABS <= m_axis_data_tdata[15:0];
			
		if(m_axis_data_tdata[31])
			IM_ABS <= ~m_axis_data_tdata[31:16]+1;
		else 
			IM_ABS <= m_axis_data_tdata[31:16];
	end 

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		fft_abs <= 0;
	else 
		fft_abs <= RE_ABS + IM_ABS;

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		fft_abs_max <= 0;
	else if(fft_a_r1 <= 125+3 && fft_abs > fft_abs_max)
		fft_abs_max <= fft_abs;
	else if(fft_a_r1 == 255)
		fft_abs_max <= 0;

always @(posedge clk_i or posedge rst_i)
	if(rst_i)
		xk_tem <= 0;
	else if(fft_a_r1 <= 125+3 && fft_abs > fft_abs_max)
		xk_tem <= fft_a_r1;

always @(posedge clk_50m)
begin 
	xk_r0 <= xk_tem;
	xk_r1 <= xk_r0;
end 

always @(posedge clk_50m or posedge rst_i)
	if(rst_i)
		xk <= 0;
	else if(fft_a_r1>=255-50)
		xk <= xk_r1;

wire [31 : 0] doutb;
fft_dual_ram fft_dual_ram (
  .clka(clk_i),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(pwm_fft_vld&&m_axis_data_tvalid),      // input wire [0 : 0] wea
  .addra(m_axis_data_tuser),  // input wire [7 : 0] addra
  .dina(m_axis_data_tdata),    // input wire [31 : 0] dina
  
  .clkb(clk_50m),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(xk),  // input wire [7 : 0] addrb
  .doutb(doutb)  // output wire [31 : 0] doutb
);

always @(posedge clk_50m or posedge rst_i)
	if(rst_i) begin 
		vf_fft_i <= 0;
		vf_fft_q <= 0;
		end 
	else if(fft_a_r1>=255-40) begin 
		vf_fft_i <= doutb[15:0];
		vf_fft_q <= doutb[31:16];
		end 
reg 	fft_vld_temp;	
always @(posedge clk_50m or posedge rst_i)
	if(rst_i)  		
		fft_vld_temp <= 0;
	else if(fft_a_r1>=255-40)
		fft_vld_temp <= 1;
	else 
		fft_vld_temp <= 0;
		
reg 	fft_vld_r0,fft_vld_r1;
always @(posedge clk_50m)
begin 
	fft_vld_r0 <= fft_vld_temp;
	fft_vld_r1 <= fft_vld_r0;
end 

always @(posedge clk_50m or posedge rst_i)
	if(rst_i)  
		fft_vld <= 0;
	else if(fft_vld_r0 && !fft_vld_r1)	//posedge
		fft_vld <= 1;
	else 
		fft_vld <= 0;

//

//反射fft
wire [31 : 0]	vr_axis_data_tdata;
wire [7 : 0] 	vr_axis_data_tuser;
wire 			vr_axis_data_tvalid;

xfft_0 xfft_VR (
  .aclk(clk_i),                                              // input wire aclk
  .aresetn(~rst_i),                                        // input wire aresetn
  .s_axis_config_tdata(24'B00000_001_0_1000000_000_01000),                // input wire [23 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b0),              // input wire s_axis_config_tvalid
  .s_axis_config_tready(	),              // output wire s_axis_config_tready
  
  .s_axis_data_tdata({vr_imag,vr_real}),    // input wire [31 : 0] s_axis_data_tdata,高虚部，低实部
  .s_axis_data_tvalid(pwm_fft_vld&vr_vld),  // input wire s_axis_data_tvalid
  .s_axis_data_tready(	),                  // output wire s_axis_data_tready
  .s_axis_data_tlast(s_axis_data_tlast),    // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(vr_axis_data_tdata),   // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tuser(vr_axis_data_tuser),   // output wire [7 : 0] m_axis_data_tuser
  .m_axis_data_tvalid(vr_axis_data_tvalid), // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                // input wire m_axis_data_tready
  .m_axis_data_tlast(	),                  // output wire m_axis_data_tlast
  .event_frame_started(	),                  // output wire event_frame_started
  .event_tlast_unexpected(	),              // output wire event_tlast_unexpected
  .event_tlast_missing(	),                  // output wire event_tlast_missing
  .event_data_in_channel_halt(	)           // output wire event_data_in_channel_halt
);

wire [31 : 0] vr_doutb;
fft_dual_ram fft_dual_ram_vr (
  .clka(clk_i),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(pwm_fft_vld&vr_axis_data_tvalid),      // input wire [0 : 0] wea
  .addra(vr_axis_data_tuser),  // input wire [7 : 0] addra
  .dina(vr_axis_data_tdata),    // input wire [31 : 0] dina
  
  .clkb(clk_50m),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(xk),  // input wire [7 : 0] addrb
  .doutb(vr_doutb)  // output wire [31 : 0] doutb
);

always @(posedge clk_50m or posedge rst_i)
	if(rst_i) begin 
		vr_fft_i <= 0;
		vr_fft_q <= 0;
		end 
	else if(fft_a_r1>=255-40) begin 
		vr_fft_i <= vr_doutb[15:0];
		vr_fft_q <= vr_doutb[31:16];
		end 

// ila_fft_dual_test u_ila_fft_dual_test(
	// .clk(clk_i), // input wire clk


	// .probe0(vf_real        ), // input wire [15:0]  probe0  
	// .probe1(vf_imag        ), // input wire [15:0]  probe1 
	// .probe2(vf_vld         ), // input wire [0:0]  probe2 
	// .probe3(vr_real        ), // input wire [15:0]  probe3 
	// .probe4(vr_imag        ), // input wire [15:0]  probe4 
	// .probe5(vr_vld         ), // input wire [0:0]  probe5 
	// .probe6(fft_start      ), // input wire [0:0]  probe6 
	// .probe7(fft_period     ), // input wire [15:0]  probe7 
	// .probe8(clk_50m        ), // input wire [0:0]  probe8 
	// .probe9(VF_POWER_CALIB), // input wire [15:0]  probe9 
	// .probe10(fft_vld        ), // input wire [0:0]  probe10 
	// .probe11(xk             ), // input wire [7:0]  probe11 
	// .probe12(fft_abs_max    ), // input wire [15:0]  probe12 
	// .probe13(pwm_fft_vld    ), // input wire [0:0]  probe13 
	// .probe14(s_axis_data_tready        ), // input wire [0:0]  probe14 
	// .probe15(m_axis_data_tvalid        ), // input wire [0:0]  probe15 
	// .probe16(m_axis_data_tdata_temp    ), // input wire [31:0]  probe16 
	// .probe17(m_axis_data_tuser_temp    ), // input wire [7:0]  probe17 
	// .probe18(m_axis_data_tdata         ), // input wire [31:0]  probe18 
	// .probe19(m_axis_data_tuser         ), // input wire [7:0]  probe19 
	// .probe20(s_axis_data_tlast         ), // input wire [0:0]  probe20 
	// .probe21(xk_r0), // input wire [7:0]  probe21 
	// .probe22(xk_r1), // input wire [7:0]  probe22 
	// .probe23(data_cnt), // input wire [7:0]  probe23 
	// .probe24(RE_ABS), // input wire [15:0]  probe24 
	// .probe25(IM_ABS), // input wire [15:0]  probe25 
	// .probe26(fft_abs), // input wire [15:0]  probe26 
	// .probe27(fft_a_r0), // input wire [7:0]  probe27 
	// .probe28(fft_a_r1), // input wire [7:0]  probe28 
	// .probe29(fft_a_r2), // input wire [7:0]  probe29 
	// .probe30(xk_tem), // input wire [7:0]  probe30 
	// .probe31(fft_period_cnt) // input wire [15:0]  probe31
// );
	

endmodule
