module FD_power_handle(
       input                clk			   , //100m SYSBUFG  drive clock;
	   input      [15:0]	AD9643_CHA     ,
	   input      [15:0]	AD9643_CHB     ,
	   input                fft_start      ,
	   input      [15:0]    fft_period     ,
	   input      [15:0]    VF_POWER_CALIB ,
	   output               fd_clk_50m     ,
       output     [31:0]    fd_r_out       ,
	   output     [31:0]    fd_jx_out 		   
);

//wire 	   fd_clk_50m ;
wire       clk_128m;
wire 	   locked  ;
reg 	   rst_50m_r0,rst_50m;
reg 	   rst_128m_r0,rst_128m;
reg        vld          ;
reg [ 3:0] cnt          ;
reg [15:0] CHA_r0,CHA_r1;
reg [15:0] CHB_r0,CHB_r1;
reg [15:0] fd_vr_i      ;
reg [15:0] fd_vr_q      ;
reg [15:0] fd_vf_i      ;
reg [15:0] fd_vf_q      ;  

clk_wiz_2 clk_wiz_2
(
    .clk_out1		(fd_clk_50m   ),  
    .clk_out2		(clk_128m     ), //128m
    .reset		    (1'B0         ), 		
    .locked		    (locked       ),  // 0->1;   
    .clk_in1		(clk          )
); 

always @(posedge fd_clk_50m)
begin 
	 rst_50m_r0 <= ~locked; //1->0
	 rst_50m <= rst_50m_r0;
end 

always @(posedge clk_128m)
begin 
	 rst_128m_r0 <= ~locked;
	 rst_128m <= rst_128m_r0;
end 

always @(posedge clk_128m)
begin 
	 CHA_r0 <= AD9643_CHA;
	 CHA_r1 <= CHA_r0;
end 

always @(posedge clk_128m)
begin 
	 CHB_r0 <= AD9643_CHB;
	 CHB_r1 <= CHB_r0;
end 

//CHA/CHB_vld;
always @(posedge clk_128m)
	if(rst_128m)begin 	
		cnt <= 0;
		vld <= 0;
	end 
	else if(cnt==1) begin     //;16m
		cnt <= 0;
		vld <= 1;
	end 
	else begin 
		cnt <= cnt+1;
		vld <= 0;
	end 

wire [15:0]		vf_fft_i;
wire [15:0]		vf_fft_q;
wire [15:0]		vr_fft_i;
wire [15:0]		vr_fft_q;
wire 			fft_vld ;
wire [15:0]     fft_abs_max;
wire [31:0]		fd_r_jx_i  ;			
wire [31:0]		fd_r_jx_q  ;
wire [31:0]		fd_refl_i  ;
wire [31:0]		fd_refl_q  ; 
wire [7: 0]     xk;
wire            pwm_fft_vld;

FFT_dual_adc	FFT_dual_adc(
	.clk_i				(clk_128m       ),
	.rst_i				(rst_128m       ),
	.vf_real			(CHB_r1         ),  //64m
	.vf_imag			(),             
	.vf_vld				(vld            ),	//(1'b1),//
	.vr_real			(CHA_r1         ),
	.vr_imag			(),             
	.vr_vld				(vld            ),	//(1'b1),//	//vf vr必须同步进入
	.fft_start          (fft_start      ),
	.fft_period         (fft_period     ),
	.clk_50m 	    (fd_clk_50m 	),
	.vf_fft_i			(vf_fft_i	    ),
	.vf_fft_q			(vf_fft_q	    ),
	.vr_fft_i			(vr_fft_i	    ),
	.vr_fft_q			(vr_fft_q	    ),
	.fft_vld 			(fft_vld 	    ),
	.xk					(xk			    ),
	.fft_abs_max        (fft_abs_max    ),
	.VF_POWER_CALIB     (VF_POWER_CALIB ),
    .pwm_fft_vld        (pwm_fft_vld    ),  
	.test_data			({fd_r_jx_i,fd_r_jx_q})
);

always @(posedge fd_clk_50m or posedge rst_50m)
	if(rst_50m) begin 
		fd_vr_i <= 0;
        fd_vr_q <= 0;
        fd_vf_i <= 0;
        fd_vf_q <= 0;
	end 
	else if(fft_vld)begin 
		fd_vr_i <= vr_fft_i;
        fd_vr_q <= vr_fft_q;
        fd_vf_i <= vf_fft_i;
        fd_vf_q <= vf_fft_q;
	end 

refl_cal_16bit	FD_refl_cal_16bit(
	.i_clk				(fd_clk_50m        ),	
	.i_rstn				(rst_50m        ),
	.vr_i				(fd_vr_i	    ),	//A 
	.vr_q				(fd_vr_q	    ),	//B
	.vf_i				(fd_vf_i	    ),	//C
	.vf_q				(fd_vf_q	    ),	//D
	.refl_i				(fd_refl_i	    ),
	.refl_q				(fd_refl_q	    )
);	//反射/入射  


r_jx	FD_r_jx(
	.i_clk			    (fd_clk_50m     ),	
	.i_rstn			    (rst_50m        ),
	.refl_i			    (fd_refl_i      ),	//15位定点数
	.refl_q			    (fd_refl_q      ),	//15位定点数
									    
	.r_jx_i			    (fd_r_jx_i      ),	//15位定点数
	.r_jx_q			    (fd_r_jx_q      )    //15位定点数
);	//R+jX = Z0*(1+r)/(1-r) , Z0 = 50

r_jx_extract	r_jx_extract(
	.clk_i			    (fd_clk_50m     ),
	.rst_i			    (rst_50m        ),
	.xk				    (xk             ),
	.din			    ({fd_r_jx_i,fd_r_jx_q}),
	.r_out			    (fd_r_out       ),
	.jx_out			    (fd_jx_out      )
);




endmodule
