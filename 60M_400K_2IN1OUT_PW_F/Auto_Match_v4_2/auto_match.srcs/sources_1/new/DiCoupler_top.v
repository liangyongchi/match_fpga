`timescale 1ns / 1ps



`define DEFINE_IS0_CH0
`define DEFINE_IS1_CH2
//`define NO_OS0_CH1
`define DEFINE_OS2_CH4

`define IS0_POWER0_EDGE_DETECT
`define IS1_POWER2_EDGE_DETECT
//`define NO_OS0_POWER_EDGE_DETECT
//`define NO_OS1_POWER_EDGE_DETECT
`define OS2_POWER_EDGE_DETECT
`define MOTO_CTRL_FUNCTION

`define IS_CW_PW_POWER_FUNCTION
`define CW_PW_R_JX_FUNCTION
//`define CW_PW_R_JX_RESULT_S
//////////////////////////////////////////////////////////////////////////////////
module DiCoupler_top(
    input                       i_sys_reset      ,
    input                       i_clk_64m        ,
    input                       i_clk_128m       ,
    input                       i_clk_50m        ,	

											     
	//  HF/LF/OS_AD9238  12bit;                             
	input                       i_adc_clk        ,   //ADC 参考时钟,三路都用 同一个16M参考;
											     
	input  [11:0]               i_adc0_data0     ,   //HF   
	input  [11:0]               i_adc0_data1     ,			
	
	input  [11:0]               i_adc1_data0     ,   //OS0   
	input  [11:0]               i_adc1_data1     ,	 //NO USED	    
								     
	input  [11:0]               i_adc2_data0     ,   //lF  
	input  [11:0]               i_adc2_data1     ,          


	input  [11:0]               i_adc3_data0     ,   //OS1  
	input  [11:0]               i_adc3_data1     ,          
	
	input  [11:0]               i_adc4_data0     ,   //OS2  
	input  [11:0]               i_adc4_data1     ,          	
	
	
	//other about power system : feeddog &&on-off fpga with mcu;
	input 				        INTLOCK_IN       ,
	output 				        INTLOCK_OUT      ,
	output 				        bias_on          ,	//0接S1，1接S2，0开1关
    output 				        RF_ON_FPGA_DLY   ,	//0开1关 
	output reg			        RF_ON_MCU        ,	//开关信号给MCU,需要取反,1开0关
	output 				        FPGA_DOG_WAVE    ,	//输出100 kHz
	output [5:0]		        debug_led        ,
    output                      FPGA_T25          , // pin：B17;
    output                      FPGA_T24          ,
		
	//moto ctrl ;
    input   [7:0]               MOTO_ALM         , 
	output  [7:0]               MOTO_PWM         ,           
    output  [7:0]               MOTO_DIR         , 
    output  [7:0]               MOTO_EN          ,
	// MCU --FPGA Tspi bus 
    input				        SPI_CS	         ,
    input				        SPI_SDI	         ,
    input				        SPI_SCLK         ,
    output  			        SPI_SDO	         
		
);

assign  FPGA_T25 = power_status0;
assign  FPGA_T24 = power_status2; //此处记得更改LF的开关给mcu；（待确定）


//====================================================
wire                    RD              ;
wire                    decor_pulse     ;
reg                     r_decor_pulse   ;
wire                    r_decor_pulse_pos ;

always@(posedge clk_50m) r_decor_pulse <= decor_pulse;
assign r_decor_pulse_pos = ~r_decor_pulse & decor_pulse;

/*<---------------------DEBUG CORE NAME PORT------------------->*/
wire                    rst_125         ;
wire                    clk_64m         ;
wire                    clk_128m        ;
wire 					clk_50m			;
wire                    pll_locked      ;

//-----------------CH0 HF IS0--------------------	
    wire                    open_status0    ;
    wire                    power_status0   ;
    (* mark_debug="false" *)wire                    sys0_start_demod    ;
    (* mark_debug="false" *)wire                    sys0_start_lpf      ;
    (* mark_debug="false" *)wire                    adc0_ch0_calib_vld  ;
    (* mark_debug="false" *)wire  [63:0]            adc0_ch0_calib_data ;
    (* mark_debug="false" *)wire                    adc1_ch0_calib_vld  ; //hf
    (* mark_debug="false" *)wire  [63:0]            adc1_ch0_calib_data ;

    (* mark_debug="false" *)wire                    adc0_ch0_lpf_vld    ;
    (* mark_debug="true" *)wire  [63:0]            adc0_ch0_lpf_data   ;
    (* mark_debug="false" *)wire                    adc1_ch0_lpf_vld    ;
    (* mark_debug="true" *)wire  [63:0]            adc1_ch0_lpf_data   ;
    wire [31:0]		        freq_out0     	      ;//无用
    (* mark_debug="false" *)wire                   FREQ0_CALIB_MODE       ;  
    (* mark_debug="false" *)wire [3:0]              RF_FREQ0              ;
    (* mark_debug="false" *)wire [31:0]		        ch0_r_jx_i			  ;			
    (* mark_debug="false" *)wire [31:0]		        ch0_r_jx_q			  ;	
    (* mark_debug="false" *)wire [31:0]		        ch0_refl_i			  ;
    (* mark_debug="false" *)wire [31:0]		        ch0_refl_q			  ;
    (* mark_debug="false" *)wire [31:0]		        VR_POWER0		      ;
    (* mark_debug="false" *)wire [31:0]		        VF_POWER0		      ;
    (* mark_debug="false" *)wire [15:0]             VF_POWER_CALIB_K0     ; 
    (* mark_debug="false" *)wire [15:0]             VR_POWER_CALIB_K0     ; 
    (* mark_debug="false" *)wire [15:0]             VF_POWER0_K_AVG       ; //SENSOR1 VF
    (* mark_debug="false" *)wire [31:0]		        CALIB_R0 		      ;
    (* mark_debug="false" *)wire [31:0]		        CALIB_JX0		      ;
    (* mark_debug="false" *)wire [31:0]		        R_DOUT0			      ;//is0
    (* mark_debug="false" *)wire [31:0]		        JX_DOUT0			  ;//is0

    (* mark_debug="false" *)wire [31:0]		        INPUT_SENSOR0_R_AVG	  ;
    (* mark_debug="false" *)wire [31:0]		        INPUT_SENSOR0_JX_AVG  ;
    wire [23:0]		        ORIG_K0			      ; 
    (* mark_debug="false" *)wire                     CW_MODE0             ;
    wire                     PW_MODE0             ;
    (* mark_debug="false" *)wire                     IS0_power_rise   ;
    (* mark_debug="false" *)wire                     IS0_power_fall   ;
    (* mark_debug="false" *)wire                     sensor0_avg_keep     ;
    (* mark_debug="false" *)wire [35:0]              sensor0_keep_dly     ;
    (* mark_debug="false" *)wire [35:0]              sensor0_pulse_on_cnt ;

    (* mark_debug="false" *)wire 		             AD9238_CH0_vld	      ;
    (* mark_debug="true" *)wire [11:0]	             AD9238_CH0_CHA	      ;  //vr
    (* mark_debug="true" *)wire [11:0]	             AD9238_CH0_CHB	      ;  //vf

    (* mark_debug="false" *)wire                     ch0_start_adc      ;//HF
    (* mark_debug="false" *)wire                     ad9238_da0_vld     ;//HF
    (* mark_debug="false" *)wire [31:0]              ad9238_da0         ;//HF
    (* mark_debug="false" *)wire                     ad9238_db0_vld     ;//HF
    (* mark_debug="false" *)wire [31:0]              ad9238_db0         ;//HF
    (* mark_debug="false" *)wire                     adc0_ch0_bpf_vld   ;//HF
    (* mark_debug="false" *)wire [63:0]              adc0_ch0_bpf_data  ;//HF
    (* mark_debug="false" *)wire                     adc1_ch0_bpf_vld   ;//HF
    (* mark_debug="false" *)wire [63:0]              adc1_ch0_bpf_data  ;//HF
    (* mark_debug="false" *)wire                     ch0_start_bpf      ;//HF
    wire [31:0]		         adc0_mean0		      ;    	
    wire [31:0]		         adc1_mean0		      ;   

    (* mark_debug="false" *)wire                     adc0_ch0_demod_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc0_ch0_demod_data ;
    (* mark_debug="false" *)wire                     adc1_ch0_demod_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc1_ch0_demod_data ;
    (* mark_debug="false" *)wire  [13:0]             demod_rd_addr0	;

    //sensor1;		         	    
    (* mark_debug="false" *)wire  [31:0]             m1a00_ch0 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a01_ch0 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a10_ch0 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a11_ch0 ; 

    (* mark_debug="false" *)wire [31:0]              DETECT_PULSE_WIDTH;
    (* mark_debug="false" *)wire [31:0]              MATCH_ON_DLY;
    wire [31:0]              demod_freq_coef0;	

    (* mark_debug="false" *)wire [9:0]               RISE_JUMP          ;//sensor1 波形拟合检测
    (* mark_debug="false" *)wire [9:0]               FALL_JUMP          ;
    (* mark_debug="false" *)wire [23:0]              DETECT_RISE_DLY    ;
    (* mark_debug="false" *)wire [23:0]              DETECT_FALL_DLY    ;
    (* mark_debug="false" *)wire [15:0]              VF_POWER0_FILTER        ;

    (* mark_debug="false" *)wire [31:0]              OFF_NUM                 ;//检测功率关闭的计数器
    //-----------------iS0------------------------
    (* mark_debug="false" *)wire                     IS0_power_buf0_vld  ;
    (* mark_debug="false" *)wire                     IS0_power_buf1_vld  ;
    (* mark_debug="false" *)wire                     IS0_power_buf2_vld  ;
    (* mark_debug="false" *)wire                     IS0_power_buf3_vld  ;
    (* mark_debug="false" *)wire                     IS0_power_sub_vld   ;
                            
    (* mark_debug="false" *)wire                     IS0_power0_buf0_vld ;
    (* mark_debug="false" *)wire                     IS0_power0_buf1_vld ;
    (* mark_debug="false" *)wire                     IS0_power0_buf2_vld ;
    (* mark_debug="false" *)wire                     IS0_power0_buf3_vld ;
    (* mark_debug="false" *)wire                     IS0_power0_sub_vld  ;
    (* mark_debug="false" *)wire                     pulse0_pwm_on       ;

    (* mark_debug="false" *)wire [31:0]	             ch0_calib_vr_i     ;	
    (* mark_debug="false" *)wire [31:0]	             ch0_calib_vr_q     ;	
    (* mark_debug="false" *)wire 		             calib_vr_vld0      ;
    (* mark_debug="false" *)wire [31:0]	             ch0_calib_vf_i     ;	
    (* mark_debug="false" *)wire [31:0]	             ch0_calib_vf_q     ;	
    (* mark_debug="false" *)wire 		             calib_vf_vld0      ;
    (* mark_debug="false" *)wire [31:0]              R0_result          ;
    (* mark_debug="false" *)wire [31:0]              JX0_result         ;
    (* mark_debug="false" *)wire [31:0]              AVG_IIR_R0         ; //hf
    (* mark_debug="false" *)wire [31:0]              AVG_IIR_JX0        ;

    (* mark_debug="false" *) wire [31:0]              AVG_IIR_pf0        ;
    (* mark_debug="false" *) wire [31:0]              AVG_IIR_pr0        ;

    (* mark_debug="false" *)wire [15:0]             HF_threshold2on      ;
    wire [31:0]             HF_measure_period    ;
    wire [31:0]             HF_period_cnt        ;
    wire [31:0]             HF_period_total      ;

    wire [15:0]             w_IS0_PULSE_START0   ;//ch0
    wire [15:0]             w_IS0_PULSE_END0     ;//ch0
    (* mark_debug="false" *)wire [15:0]             w_pulse_gap0         ;
    (* mark_debug="false" *)wire                    w_Z_pulse0_pwm; //HF
    (* mark_debug="false" *)wire [15:0]             w_IS0_power_pwm_dly0;		

//-----------------CH2 LF IS1--------------------
    wire                    open_status2     ;
    wire                    power_status2    ;
    (* mark_debug="false" *)wire                    sys2_start_demod    ;
    (* mark_debug="false" *)wire                    sys2_start_lpf      ;

    (* mark_debug="false" *)wire                    adc0_ch2_calib_vld  ;
    (* mark_debug="false" *)wire  [63:0]            adc0_ch2_calib_data ;
    (* mark_debug="false" *)wire                    adc1_ch2_calib_vld  ;
    (* mark_debug="false" *)wire  [63:0]            adc1_ch2_calib_data ;//lf

    (* mark_debug="false" *)wire                    adc0_ch2_lpf_vld    ;
    (* mark_debug="true" *)wire  [63:0]            adc0_ch2_lpf_data   ;
    (* mark_debug="false" *)wire                    adc1_ch2_lpf_vld    ;
    (* mark_debug="true" *)wire  [63:0]            adc1_ch2_lpf_data   ;
    wire [31:0]		        freq_out2     	      ;//无用
    (* mark_debug="false" *)wire                   FREQ2_CALIB_MODE       ;  
    (* mark_debug="false" *)wire [3:0]              RF_FREQ2              ; 
    (* mark_debug="false" *)wire [31:0]		        ch2_r_jx_i			  ;			
    (* mark_debug="false" *)wire [31:0]		        ch2_r_jx_q			  ;	
    (* mark_debug="false" *)wire [31:0]		        ch2_refl_i			  ;
    (* mark_debug="false" *)wire [31:0]		        ch2_refl_q			  ;
    (* mark_debug="false" *)wire [31:0]		        VR_POWER2		      ;
    (* mark_debug="false" *)wire [31:0]		        VF_POWER2		      ;
    wire [15:0]             VF_POWER_CALIB_K2     ; 
    wire [15:0]             VR_POWER_CALIB_K2     ; 
    (* mark_debug="false" *)wire [15:0]             VF_POWER2_K_AVG       ; //SENSOR1 VR
    (* mark_debug="false" *)wire [31:0]		        CALIB_R2 		      ;
    (* mark_debug="false" *)wire [31:0]		        CALIB_JX2		      ;
    (* mark_debug="false" *)wire [31:0]		        R_DOUT2 ;//is1
    (* mark_debug="false" *)wire [31:0]		        JX_DOUT2;//is1

    (* mark_debug="false" *)wire [31:0]	INPUT_SENSOR1_R_AVG	  ;
    (* mark_debug="false" *)wire [31:0]	INPUT_SENSOR1_JX_AVG  ;
    wire [23:0]		        ORIG_K2			      ; 
    (* mark_debug="false" *)wire                     CW_MODE2             ;
    wire                     PW_MODE2             ;
    (* mark_debug="false" *)wire                     IS1_power_rise   ;
    (* mark_debug="false" *)wire                     IS1_power_fall   ;
    (* mark_debug="false" *)wire                     sensor2_avg_keep     ;
    (* mark_debug="false" *)wire [35:0]              sensor2_keep_dly     ;
    (* mark_debug="false" *)wire [35:0]              sensor2_pulse_on_cnt ;

    (* mark_debug="false" *)wire 		             AD9238_CH2_vld	      ;
    (* mark_debug="true" *)wire [11:0]	             AD9238_CH2_CHA	      ;
    (* mark_debug="true" *)wire [11:0]	             AD9238_CH2_CHB	      ;	

    (* mark_debug="false" *)wire                     ch2_start_adc      ;//LF
    (* mark_debug="false" *)wire                     ad9238_da2_vld     ;//LF
    (* mark_debug="false" *)wire [31:0]              ad9238_da2         ;//LF
    (* mark_debug="false" *)wire                     ad9238_db2_vld     ;//LF
    (* mark_debug="false" *)wire [31:0]              ad9238_db2         ;//LF
    (* mark_debug="false" *)wire                     adc0_ch2_bpf_vld   ;//LF
    (* mark_debug="false" *)wire [63:0]              adc0_ch2_bpf_data  ;//LF
    (* mark_debug="false" *)wire                     adc1_ch2_bpf_vld   ;//LF
    (* mark_debug="false" *)wire [63:0]              adc1_ch2_bpf_data  ;//LF
    (* mark_debug="false" *)wire                     ch2_start_bpf      ;//LF
    wire [31:0]		         adc0_mean2		      ;    	
    wire [31:0]		         adc1_mean2		      ;  

    (* mark_debug="false" *)wire                     adc0_ch2_demod_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc0_ch2_demod_data ;
    (* mark_debug="false" *)wire                     adc1_ch2_demod_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc1_ch2_demod_data ;
    (* mark_debug="false" *)wire  [13:0]             demod_rd_addr2	;

    (* mark_debug="false" *)wire  [31:0]             m1a00_ch2 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a01_ch2 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a10_ch2 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a11_ch2 ; 

    (* mark_debug="false" *)wire [31:0]              DETECT_PULSE_WIDTH2;
    (* mark_debug="false" *)wire [31:0]              MATCH_ON_DLY2;
    (* mark_debug="false" *)wire [31:0]  demod_freq_coef2;		 
    
    (* mark_debug="false" *)wire [9:0]               RISE_JUMP2         ;
    (* mark_debug="false" *)wire [9:0]               FALL_JUMP2         ;
    (* mark_debug="false" *)wire [23:0]              DETECT_RISE_DLY2   ;
    (* mark_debug="false" *)wire [23:0]              DETECT_FALL_DLY2   ;

    (* mark_debug="false" *)wire [15:0]              VF_POWER2_FILTER        ;
    (* mark_debug="false" *)wire [31:0]              OFF_NUM2;
    //--------------------is1------------------------
    (* mark_debug="false" *)wire                     IS1_power_buf0_vld  ;
    (* mark_debug="false" *)wire                     IS1_power_buf1_vld  ;
    (* mark_debug="false" *)wire                     IS1_power_buf2_vld  ;
    (* mark_debug="false" *)wire                     IS1_power_buf3_vld  ;
    (* mark_debug="false" *)wire                     IS1_power_sub_vld   ;
                            
    (* mark_debug="false" *)wire                     IS1_power0_buf0_vld ;
    (* mark_debug="false" *)wire                     IS1_power0_buf1_vld ;
    (* mark_debug="false" *)wire                     IS1_power0_buf2_vld ;
    (* mark_debug="false" *)wire                     IS1_power0_buf3_vld ;
    (* mark_debug="false" *)wire                     IS1_power0_sub_vld  ;
    (* mark_debug="false" *)wire                     pulse2_pwm_on      ;

    (* mark_debug="false" *)wire [31:0]	             ch2_calib_vr_i     ;	
    (* mark_debug="false" *)wire [31:0]	             ch2_calib_vr_q     ;	
    (* mark_debug="false" *)wire 		             calib_vr_vld2      ;
    (* mark_debug="false" *)wire [31:0]	             ch2_calib_vf_i     ;	
    (* mark_debug="false" *)wire [31:0]	             ch2_calib_vf_q     ;	
    (* mark_debug="false" *)wire 		             calib_vf_vld2      ;
    (* mark_debug="false" *)wire [31:0]              R2_result          ;
    (* mark_debug="false" *)wire [31:0]              JX2_result         ;
    (* mark_debug="false" *)wire [31:0]              AVG_IIR_R2         ; //lf
    (* mark_debug="false" *)wire [31:0]              AVG_IIR_JX2        ;

    (* mark_debug="false" *)wire [31:0]              AVG_IIR_pf2        ;
    (* mark_debug="false" *)wire [31:0]              AVG_IIR_pr2        ;

    (* mark_debug="false" *)wire [15:0]             LF_threshold2on      ;
    wire [31:0]             LF_measure_period    ;
    wire [31:0]             LF_period_cnt        ;
    wire [31:0]             LF_period_total      ;

    wire [15:0]             w_IS1_PULSE_START2   ;//ch2
    wire [15:0]             w_IS1_PULSE_END2     ;//ch2
    (* mark_debug="false" *)wire [15:0]             w_pulse_gap2         ;
    (* mark_debug="false" *)wire                    w_Z_pulse2_pwm;  //LF
    (* mark_debug="false" *)wire [15:0]             w_IS1_power_pwm_dly2;	

//-----------------CH1 0S0--------------------
    wire                    open_status1    ;
    wire                    power_status1   ;
    wire                    sys1_start_demod    ;
    wire                    sys1_start_lpf      ;
    //OUTPUT sensor2 :Vt;It;
    wire                    OS0_V_calib_vld ;
    wire  [63:0]            OS0_V_calib_data;
    wire                    OS0_I_calib_vld ;
    wire  [63:0]            OS0_I_calib_data;

    wire                    adc0_ch1_lpfx_vld    ;
    wire  [63:0]            adc0_ch1_lpfx_data   ;
    wire                    adc1_ch1_lpfx_vld    ;
    wire  [63:0]            adc1_ch1_lpfx_data   ;
    wire [31:0]		        freq_out1     	      ;//无用
    wire [3:0]		        RF_FREQ1              ; 
    wire [31:0]		        OS0_V	              ;
    wire [31:0]		        OS0_I	              ; 
    wire [31:0]             OS0_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
    wire [31:0]             OS0_I_AVG             ;
    wire [31:0]             OS0_V_RESULT          ;
    wire [31:0]             OS0_I_RESULT          ;
    wire [31:0]		        OS0_R			      ;
    wire [31:0]		        OS0_JX			      ;
    wire [31:0]		        OUPUT_SENSOR0_R_AVG	  ;
    wire [31:0]		        OUPUT_SENSOR0_JX_AVG  ;
    wire                     CW_MODE1             ;
    wire                     PW_MODE1             ;
    wire                     OS0_I_rise           ;
    wire                     OS0_I_fall           ;
    wire                     OS0_avg_keep         ;
    wire [35:0]              OS0_keep_dly         ;
    wire [35:0]              OS0_pulse_on_cnt     ;

    wire 		             AD9238_CH1_vld	      ;
    wire [11:0]	             AD9238_CH1_CHA	      ;
    wire [11:0]	             AD9238_CH1_CHB	      ;

    wire                     ch1_start_adc      ;
    wire                     ad9238_da1_vld     ;
    wire [31:0]              ad9238_da1         ;
    wire                     ad9238_db1_vld     ;
    wire [31:0]              ad9238_db1         ;
    wire                     adc0_ch1_bpf_vld   ;
    wire [63:0]              adc0_ch1_bpf_data  ;
    wire                     adc1_ch1_bpf_vld   ;
    wire [63:0]              adc1_ch1_bpf_data  ;
    wire                     ch1_start_bpf      ;

    wire [31:0]		         adc0_mean1		      ;    	
    wire [31:0]		         adc1_mean1		      ; 

    wire                     adc0_ch1_demod_vld  ;
    wire  [63:0]             adc0_ch1_demod_data ;
    wire                     adc1_ch1_demod_vld  ;
    wire  [63:0]             adc1_ch1_demod_data ;
    wire  [13:0]             demod_rd_addr1	;

    wire  [31:0]             m1a00_ch1 ;    	
    wire  [31:0]             m1a01_ch1 ;    	
    wire  [31:0]             m1a10_ch1 ;    	
    wire  [31:0]             m1a11_ch1 ; 	

    wire [31:0]              DETECT_PULSE_WIDTH1;
    wire [31:0]              MATCH_ON_DLY1;
    wire [31:0]              demod_freq_coef1;	

    wire [9:0]               OS0_RISE_JUMP          ;
    wire [9:0]               OS0_FALL_JUMP          ;
    wire [23:0]              OS0_DETECT_RISE_DLY    ;
    wire [23:0]              OS0_DETECT_FALL_DLY    ;
    wire [15:0]              OS0_FILTER_THRESHOLD   ;

    wire [15:0]              w_OS0_filter_I       ;
    wire [31:0]              OFF_NUM1                ;//检测功率关闭的计数器
    //-----------------OS-------------------------
    wire                     OS0_I_buf0_vld          ;
    wire                     OS0_I_buf1_vld          ;
    wire                     OS0_I_buf2_vld          ;
    wire                     OS0_I_buf3_vld          ;
    wire                     OS0_I_sub_vld           ;
                                        
    wire                     OS0_I1_buf0_vld         ;
    wire                     OS0_I1_buf1_vld         ;
    wire                     OS0_I1_buf2_vld         ;
    wire                     OS0_I1_buf3_vld         ;
    wire                     OS0_I1_sub_vld          ;
    wire                     pulse1_pwm_on      ; 

    wire [31:0]	             OS0_calib_I_i  ;	
    wire [31:0]	             OS0_calib_I_q  ;	
    wire 		             OS0_calib_I_vld;
    wire [31:0]	             OS0_calib_V_i  ;	
    wire [31:0]	             OS0_calib_V_q  ;	
    wire 		             OS0_calib_V_vld;
    wire [31:0]              R1_result          ;
    wire [31:0]              JX1_result         ;
    wire [31:0]              AVG_IIR_R1         ; //os;
    wire [31:0]              AVG_IIR_JX1        ;
    //---------------------------------------------
    wire [31:0]             SENSOR1_ADC0_I      ;//CH1
    wire [31:0]             SENSOR1_ADC0_Q      ;//CH1
    wire [31:0]             SENSOR1_ADC1_I      ;//CH1
    wire [31:0]             SENSOR1_ADC1_Q      ;//CH1

    reg [31:0]              r_SENSOR1_ADC0_I    ;
    reg [31:0]              r_SENSOR1_ADC0_Q    ;
    reg [31:0]              r_SENSOR1_ADC1_I    ;
    reg [31:0]              r_SENSOR1_ADC1_Q    ;
                        
    reg [31:0]              r2_SENSOR1_ADC0_I   ;
    reg [31:0]              r2_SENSOR1_ADC0_Q   ;
    reg [31:0]              r2_SENSOR1_ADC1_I   ;
    reg [31:0]              r2_SENSOR1_ADC1_Q   ;

    wire                    OS0_demod_vld0       ;
    wire                    OS0_demod_vld1       ;

    wire [15:0]             OS0_threshold2on     ;
    wire [31:0]             OS0_measure_period   ;
    wire [31:0]             OS0_period_cnt       ;
    wire [31:0]             OS0_period_total     ;

    wire [15:0]             w_OS0_PULSE_START1    ;//ch1
    wire [15:0]             w_OS0_PULSE_END1      ;//ch1
    wire [15:0]             w_pulse_gap1         ;
    wire                    w_Z_pulse1_pwm; //os0
    wire [15:0]             w_OS0_pwm_dly;	 

//-----------------CH3 OS1--------------------
    wire                    open_status3     ;
    wire                    open_status3_400k;
    wire                    power_status3    ;
    wire                    power_status3_400k;
    wire                    sys3_start_demod    ;
    wire                    sys3_start_lpf      ;

    wire                    sys3_start_400k_demod ;
    wire                    sys3_start_400k_lpf   ;

    wire                    OS1_V_calib_vld ;
    wire  [63:0]            OS1_V_calib_data;
    wire                    OS1_I_calib_vld ;
    wire  [63:0]            OS1_I_calib_data;

    wire                    OS1_V_calib_400k_vld ;
    wire  [63:0]            OS1_V_calib_400k_data;
    wire                    OS1_I_calib_400k_vld ;
    wire  [63:0]            OS1_I_calib_400k_data;

    wire                    adc0_ch3_lpf_vld    ;
    wire  [63:0]            adc0_ch3_lpf_data   ;
    wire                    adc1_ch3_lpf_vld    ;
    wire  [63:0]            adc1_ch3_lpf_data   ;
    wire                    adc0_ch3_lpf_400k_vld    ;
    wire  [63:0]            adc0_ch3_lpf_400k_data   ;
    wire                    adc1_ch3_lpf_400k_vld    ;
    wire  [63:0]            adc1_ch3_lpf_400k_data   ;
    wire [31:0]		        freq_out3     	      ;//无用
    wire [3:0]		        RF_FREQ3              ; 
    wire [31:0]		        OS1_V	              ;
    wire [31:0]		        OS1_I	              ; 
    wire [31:0]		        OS1_400K_V	          ;
    wire [31:0]		        OS1_400K_I	          ; 

    wire [31:0]             OS1_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
    wire [31:0]             OS1_I_AVG             ;
    wire [31:0]             OS1_400K_V_AVG        ; //SENSOR2 Vt i2+q2 AVG;
    wire [31:0]             OS1_400K_I_AVG        ;
    wire [31:0]             OS1_V_RESULT          ;
    wire [31:0]             OS1_I_RESULT          ;
    wire [31:0]             OS1_400K_V_RESULT     ;
    wire [31:0]             OS1_400K_I_RESULT     ;
    wire [31:0]		        OS1_R			      ;
    wire [31:0]		        OS1_JX			      ;
    wire [31:0]		        OS1_400K_R			  ;
    wire [31:0]		        OS1_400K_JX			  ;
    wire [31:0]		        OUPUT_SENSOR1_R_AVG	  ;
    wire [31:0]		        OUPUT_SENSOR1_JX_AVG  ;
    wire [31:0]		        OUPUT_SENSOR1_400K_R_AVG ;
    wire [31:0]		        OUPUT_SENSOR1_400K_JX_AVG;
    wire                     CW_MODE3             ;
    wire                     CW_MODE3_400K        ;
    wire                     PW_MODE3             ;
    wire                     PW_MODE3_400K        ;
    wire                     OS1_I_rise           ;
    wire                     OS1_I_fall           ;
    wire                     OS1_avg_keep         ;

    wire                     OS1_400k_I_rise      ;
    wire                     OS1_400k_I_fall      ;
    wire                     OS1_400k_avg_keep    ;
    wire [35:0]              OS1_keep_dly         ;
    wire [35:0]              OS1_pulse_on_cnt     ;
    wire [35:0]              OS1_400k_keep_dly    ;
    wire [35:0]              OS1_400k_pulse_on_cnt;

    wire 		             AD9238_CH3_vld	      ;
    wire [11:0]	             AD9238_CH3_CHA	      ;
    wire [11:0]	             AD9238_CH3_CHB	      ;		

    wire                     ch3_start_adc      ;
    wire                     ad9238_da3_vld     ;
    wire [31:0]              ad9238_da3         ;
    wire                     ad9238_db3_vld     ;
    wire [31:0]              ad9238_db3         ;
    wire                     adc0_ch3_bpf_vld   ;
    wire [63:0]              adc0_ch3_bpf_data  ;
    wire                     adc1_ch3_bpf_vld   ;
    wire [63:0]              adc1_ch3_bpf_data  ;
    wire                     ch3_start_bpf      ;
    ////
    wire                     ch3_start_adc_400k ;
    wire                     ad9238_400k_da3_vld;
    wire [31:0]              ad9238_400k_da3    ;
    wire                     ad9238_400k_db3_vld;
    wire [31:0]              ad9238_400k_db3    ;
    wire                     adc0_ch3_bpf_400k_vld ;
    wire [63:0]              adc0_ch3_bpf_400k_data;
    wire                     adc1_ch3_bpf_400k_vld ;
    wire [63:0]              adc1_ch3_bpf_400k_data;
    wire                     ch3_start_bpf_400k    ;

    wire [31:0]		         adc0_mean3		      ;    	
    wire [31:0]		         adc1_mean3		      ;  
    wire [31:0]		         adc0_mean3_400k	  ;    	
    wire [31:0]		         adc1_mean3_400k	  ; 

    wire                     adc0_ch3_demod_vld  ;
    wire  [63:0]             adc0_ch3_demod_data ;
    wire                     adc1_ch3_demod_vld  ;
    wire  [63:0]             adc1_ch3_demod_data ;

    wire                     adc0_ch3_demod_400k_vld  ;
    wire  [63:0]             adc0_ch3_demod_400k_data ;
    wire                     adc1_ch3_demod_400k_vld  ;
    wire  [63:0]             adc1_ch3_demod_400k_data ;

    wire  [13:0]             demod_rd_addr3	;
    wire  [13:0]             demod_rd_400k_addr3 ;

    wire  [31:0]             m1a00_ch3 ;    	
    wire  [31:0]             m1a01_ch3 ;    	
    wire  [31:0]             m1a10_ch3 ;    	
    wire  [31:0]             m1a11_ch3 ; 	
                                    
    wire  [31:0]            m1a00_ch3_400k;
    wire  [31:0]            m1a01_ch3_400k;
    wire  [31:0]            m1a10_ch3_400k;
    wire  [31:0]            m1a11_ch3_400k;

    wire [31:0]              DETECT_PULSE_WIDTH3;
    wire [31:0]              MATCH_ON_DLY3;
    wire [31:0]              DETECT_PULSE_WIDTH3_400K;
    wire [31:0]              MATCH_ON_DLY3_400K;
    wire [31:0]              demod_freq_coef3;	

    wire [9:0]               OS1_RISE_JUMP          ;
    wire [9:0]               OS1_FALL_JUMP          ;
    wire [23:0]              OS1_DETECT_RISE_DLY    ;
    wire [23:0]              OS1_DETECT_FALL_DLY    ;
    wire [15:0]              OS1_FILTER_THRESHOLD   ;

    wire [9:0]               OS1_400K_RISE_JUMP          ;
    wire [9:0]               OS1_400K_FALL_JUMP          ;
    wire [23:0]              OS1_400K_DETECT_RISE_DLY    ;
    wire [23:0]              OS1_400K_DETECT_FALL_DLY    ;
    wire [15:0]              OS1_400K_FILTER_THRESHOLD   ;

    wire [15:0]              w_OS1_filter_I       ;
    wire [15:0]              w_OS1_400k_filter_I  ;

    wire [31:0]              OFF_NUM3                ;
    wire [31:0]              OFF_NUM3_400K           ;
    //13.56m
    wire                     OS1_I_buf0_vld          ;
    wire                     OS1_I_buf1_vld          ;
    wire                     OS1_I_buf2_vld          ;
    wire                     OS1_I_buf3_vld          ;
    wire                     OS1_I_sub_vld           ;
                                        
    wire                     OS1_I1_buf0_vld         ;
    wire                     OS1_I1_buf1_vld         ;
    wire                     OS1_I1_buf2_vld         ;
    wire                     OS1_I1_buf3_vld         ;
    wire                     OS1_I1_sub_vld          ;
    //400k
    wire                     OS1_400K_I_buf0_vld     ;
    wire                     OS1_400K_I_buf1_vld     ;
    wire                     OS1_400K_I_buf2_vld     ;
    wire                     OS1_400K_I_buf3_vld     ;
    wire                     OS1_400K_I_sub_vld      ;
                                    
    wire                     OS1_400K_I1_buf0_vld    ;
    wire                     OS1_400K_I1_buf1_vld    ;
    wire                     OS1_400K_I1_buf2_vld    ;
    wire                     OS1_400K_I1_buf3_vld    ;
    wire                     OS1_400K_I1_sub_vld     ;
    wire                     pulse3_pwm_on      ;
    wire                     pulse3_400k_pwm_on ;

    wire [31:0]	             OS1_calib_I_i  ;	
    wire [31:0]	             OS1_calib_I_q  ;	
    wire 		             OS1_calib_I_vld;
    wire [31:0]	             OS1_calib_V_i  ;	
    wire [31:0]	             OS1_calib_V_q  ;	
    wire 		             OS1_calib_V_vld;

    wire [31:0]	             OS1_calib_I_400k_i  ;	
    wire [31:0]	             OS1_calib_I_400k_q  ;	
    wire 		             OS1_calib_I_400k_vld;
    wire [31:0]	             OS1_calib_V_400k_i  ;	
    wire [31:0]	             OS1_calib_V_400k_q  ;	
    wire 		             OS1_calib_V_400k_vld;
    wire [31:0]              R3_result          ;
    wire [31:0]              JX3_result         ;
    wire [31:0]              R3_400k_result     ;
    wire [31:0]              JX3_400k_result    ;

    wire [31:0]              AVG_IIR_R3         ; //os;
    wire [31:0]              AVG_IIR_JX3        ;

    wire [31:0]              AVG_IIR_400K_R3    ; 
    wire [31:0]              AVG_IIR_400K_JX3   ;

    //13.56m
    wire [31:0]             SENSOR3_ADC0_I      ;
    wire [31:0]             SENSOR3_ADC0_Q      ;
    wire [31:0]             SENSOR3_ADC1_I      ;
    wire [31:0]             SENSOR3_ADC1_Q      ;

    reg [31:0]              r_SENSOR3_ADC0_I    ;
    reg [31:0]              r_SENSOR3_ADC0_Q    ;
    reg [31:0]              r_SENSOR3_ADC1_I    ;
    reg [31:0]              r_SENSOR3_ADC1_Q    ;
                        
    reg [31:0]              r2_SENSOR3_ADC0_I   ;
    reg [31:0]              r2_SENSOR3_ADC0_Q   ;
    reg [31:0]              r2_SENSOR3_ADC1_I   ;
    reg [31:0]              r2_SENSOR3_ADC1_Q   ;
    //400k
    wire [31:0]             SENSOR3_ADC0_400K_I      ;
    wire [31:0]             SENSOR3_ADC0_400K_Q      ;
    wire [31:0]             SENSOR3_ADC1_400K_I      ;
    wire [31:0]             SENSOR3_ADC1_400K_Q      ;

    reg [31:0]              r_SENSOR3_ADC0_400K_I    ;
    reg [31:0]              r_SENSOR3_ADC0_400K_Q    ;
    reg [31:0]              r_SENSOR3_ADC1_400K_I    ;
    reg [31:0]              r_SENSOR3_ADC1_400K_Q    ;
                        
    reg [31:0]              r2_SENSOR3_ADC0_400K_I   ;
    reg [31:0]              r2_SENSOR3_ADC0_400K_Q   ;
    reg [31:0]              r2_SENSOR3_ADC1_400K_I   ;
    reg [31:0]              r2_SENSOR3_ADC1_400K_Q   ;

    wire                    OS1_demod_vld0       ;
    wire                    OS1_demod_vld1       ;

    wire                    OS1_demod_400k_vld0  ;
    wire                    OS1_demod_400k_vld1  ;

    wire [15:0]             OS1_threshold2on     ;
    wire [31:0]             OS1_measure_period   ;
    wire [31:0]             OS1_period_cnt       ;
    wire [31:0]             OS1_period_total     ;

    wire [15:0]             w_OS1_PULSE_START     ; //ch3
    wire [15:0]             w_OS1_PULSE_END       ; //ch3
    wire [15:0]             w_OS1_400K_PULSE_START; //ch3
    wire [15:0]             w_OS1_400K_PULSE_END  ; //ch3

    wire [15:0]             w_pulse_gap3         ;
    wire [15:0]             w_pulse_gap3_400k     ;
    wire                    w_Z_pulse3_pwm; //OS1
    wire [15:0]             w_OS1_pwm_dly;
    wire                    w_Z_pulse3_pwm_400k; //OS1
    wire [15:0]             w_OS1_pwm_dly_400k;

//-----------------CH4 OS2--------------------
    wire                    open_status4     ;
    wire                    open_status4_400k;
    wire                    power_status4    ;
    wire                    power_status4_400k;
    wire                    sys4_start_demod    ;
    wire                    sys4_start_lpf      ;

    wire                    sys4_start_400k_demod ;
    wire                    sys4_start_400k_lpf   ;

    (* mark_debug="true" *)wire                    OS2_V_calib_vld ;
    (* mark_debug="true" *)wire  [63:0]            OS2_V_calib_data;
    (* mark_debug="true" *)wire                    OS2_I_calib_vld ;
    (* mark_debug="true" *)wire  [63:0]            OS2_I_calib_data;

    (* mark_debug="true" *)wire                    OS2_V_calib_400k_vld ;
    (* mark_debug="true" *)wire  [63:0]            OS2_V_calib_400k_data;
    (* mark_debug="true" *)wire                    OS2_I_calib_400k_vld ;
    (* mark_debug="true" *)wire  [63:0]            OS2_I_calib_400k_data;
															    
    (* mark_debug="false" *)wire                    adc0_ch4_lpf_vld     ;
    (* mark_debug="false" *)wire  [63:0]            adc0_ch4_lpf_data    ;
    (* mark_debug="false" *)wire                    adc1_ch4_lpf_vld     ;
    (* mark_debug="false" *)wire  [63:0]            adc1_ch4_lpf_data    ;
                                                ;
    (* mark_debug="false" *)wire                    adc0_ch4_lpf_400k_vld    ;
    (* mark_debug="false" *)wire  [63:0]            adc0_ch4_lpf_400k_data   ;
    (* mark_debug="false" *)wire                    adc1_ch4_lpf_400k_vld    ;
    (* mark_debug="false" *)wire  [63:0]            adc1_ch4_lpf_400k_data   ;
    wire [31:0]		        freq_out4     	      ;//无用
    wire [3:0]		        RF_FREQ4              ; 
    (* mark_debug="false" *)wire [31:0]		        OS2_V	              ;
    (* mark_debug="false" *)wire [31:0]		        OS2_I	              ; 
    (* mark_debug="false" *)wire [31:0]		        OS2_400K_V	          ;
    (* mark_debug="false" *)wire [31:0]		        OS2_400K_I	          ; 

    (* mark_debug="false" *)wire [31:0]             OS2_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
    (* mark_debug="false" *)wire [31:0]             OS2_I_AVG             ;
    (* mark_debug="false" *)wire [31:0]             OS2_400K_V_AVG        ; //SENSOR2 Vt i2+q2 AVG;
    (* mark_debug="false" *)wire [31:0]             OS2_400K_I_AVG        ;
    (* mark_debug="false" *)wire [31:0]             OS2_V_RESULT          ;
    (* mark_debug="false" *)wire [31:0]             OS2_I_RESULT          ;
    (* mark_debug="false" *)wire [31:0]             OS2_400K_V_RESULT          ;
    (* mark_debug="false" *)wire [31:0]             OS2_400K_I_RESULT          ;

    (* mark_debug="false" *)wire [31:0]		        OS2_R			      ;
    (* mark_debug="false" *)wire [31:0]		        OS2_JX			      ;
    (* mark_debug="false" *)wire [31:0]		        OS2_400K_R			  ;
    (* mark_debug="false" *)wire [31:0]		        OS2_400K_JX			  ;
    wire [31:0]		        OUPUT_SENSOR2_R_AVG	  ;
    wire [31:0]		        OUPUT_SENSOR2_JX_AVG  ;
    wire [31:0]		        OUPUT_SENSOR2_400K_R_AVG ;
    wire [31:0]		        OUPUT_SENSOR2_400K_JX_AVG;

    wire                     CW_MODE4             ;
    wire                     CW_MODE4_400K        ;
    wire                     PW_MODE4             ;
    wire                     PW_MODE4_400K        ;

    (* mark_debug="false" *)wire                     OS2_I_rise           ;
    (* mark_debug="false" *)wire                     OS2_I_fall           ;
    (* mark_debug="false" *)wire                     OS2_avg_keep         ;
    (* mark_debug="false" *)wire                     OS2_400k_I_rise      ;
    (* mark_debug="false" *)wire                     OS2_400k_I_fall      ;
    (* mark_debug="false" *)wire                     OS2_400k_avg_keep    ;

    (* mark_debug="false" *)wire [35:0]              OS2_keep_dly         ;
    (* mark_debug="false" *)wire [35:0]              OS2_pulse_on_cnt     ;	
    (* mark_debug="false" *)wire [35:0]              OS2_400k_keep_dly    ;
    (* mark_debug="false" *)wire [35:0]              OS2_400k_pulse_on_cnt;	

    wire 		             AD9238_CH4_vld	      ;
    (* mark_debug="true" *)wire [11:0]	             AD9238_CH4_CHA	      ;
    (* mark_debug="true" *)wire [11:0]	             AD9238_CH4_CHB	      ;	

    (* mark_debug="true" *)wire                     ch4_start_adc      ;
    (* mark_debug="false" *)wire                     ad9238_da4_vld     ;
    (* mark_debug="false" *)wire [31:0]              ad9238_da4         ;
    (* mark_debug="false" *)wire                     ad9238_db4_vld     ;
    (* mark_debug="false" *)wire [31:0]              ad9238_db4         ;
    (* mark_debug="true" *)wire                     adc0_ch4_bpf_vld   ;
    (* mark_debug="true" *)wire [63:0]              adc0_ch4_bpf_data  ;
    (* mark_debug="true" *)wire                     adc1_ch4_bpf_vld   ;
    (* mark_debug="true" *)wire [63:0]              adc1_ch4_bpf_data  ;
    (* mark_debug="true" *)wire                     ch4_start_bpf      ;	
    ////	
    (* mark_debug="false" *)wire                     ch4_start_adc_400k      ;
    (* mark_debug="false" *)wire                     ad9238_400k_da4_vld     ;
    (* mark_debug="false" *)wire [31:0]              ad9238_400k_da4         ;
    (* mark_debug="false" *)wire                     ad9238_400k_db4_vld     ;
    (* mark_debug="false" *)wire [31:0]              ad9238_400k_db4         ;
    (* mark_debug="false" *)wire                     adc0_ch4_bpf_400k_vld   ;
    (* mark_debug="false" *)wire [63:0]              adc0_ch4_bpf_400k_data  ;
    (* mark_debug="false" *)wire                     adc1_ch4_bpf_400k_vld   ;
    (* mark_debug="false" *)wire [63:0]              adc1_ch4_bpf_400k_data  ;
    (* mark_debug="false" *)wire                     ch4_start_bpf_400k      ;

    wire [31:0]		         adc0_mean4		      ;    	
    wire [31:0]		         adc1_mean4		      ;  
    wire [31:0]		         adc0_mean4_400k	  ;    	
    wire [31:0]		         adc1_mean4_400k	  ;  

    (* mark_debug="false" *)wire                     adc0_ch4_demod_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc0_ch4_demod_data ;
    (* mark_debug="false" *)wire                     adc1_ch4_demod_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc1_ch4_demod_data ;

    (* mark_debug="false" *)wire                     adc0_ch4_demod_400k_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc0_ch4_demod_400k_data ;
    (* mark_debug="false" *)wire                     adc1_ch4_demod_400k_vld  ;
    (* mark_debug="false" *)wire  [63:0]             adc1_ch4_demod_400k_data ;

    wire  [13:0]             demod_rd_addr4	;    
    wire  [13:0]             demod_rd_400k_addr4 ;

    (* mark_debug="false" *)wire  [31:0]             m1a00_ch4 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a01_ch4 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a10_ch4 ;    	
    (* mark_debug="false" *)wire  [31:0]             m1a11_ch4 ; 	   
                                                                            
    (* mark_debug="false" *)wire  [31:0]            m1a00_ch4_400k;
    (* mark_debug="false" *)wire  [31:0]            m1a01_ch4_400k;
    (* mark_debug="false" *)wire  [31:0]            m1a10_ch4_400k;
    (* mark_debug="false" *)wire  [31:0]            m1a11_ch4_400k;

    wire [31:0]              DETECT_PULSE_WIDTH4;
    wire [31:0]              MATCH_ON_DLY4;
    wire [31:0]              DETECT_PULSE_WIDTH4_400K;
    wire [31:0]              MATCH_ON_DLY4_400K;
    wire [31:0]              demod_freq_coef4;	

    (* mark_debug="false" *)wire [9:0]               OS2_RISE_JUMP          ;
    (* mark_debug="false" *)wire [9:0]               OS2_FALL_JUMP          ;
    (* mark_debug="false" *)wire [23:0]              OS2_DETECT_RISE_DLY    ;
    (* mark_debug="false" *)wire [23:0]              OS2_DETECT_FALL_DLY    ;
    (* mark_debug="false" *)wire [15:0]              OS2_FILTER_THRESHOLD   ;

    (* mark_debug="false" *)wire [9:0]               OS2_400K_RISE_JUMP          ;
    (* mark_debug="false" *)wire [9:0]               OS2_400K_FALL_JUMP          ;
    (* mark_debug="false" *)wire [23:0]              OS2_400K_DETECT_RISE_DLY    ;
    (* mark_debug="false" *)wire [23:0]              OS2_400K_DETECT_FALL_DLY    ;
    (* mark_debug="false" *)wire [15:0]              OS2_400K_FILTER_THRESHOLD   ;

    (* mark_debug="false" *)wire [15:0]              w_OS2_filter_I       ;			
    (* mark_debug="false" *)wire [15:0]              w_OS2_400k_filter_I  ;	

    wire [31:0]              OFF_NUM4                ;
    wire [31:0]              OFF_NUM4_400K           ;

    wire                     OS2_I_buf0_vld          ;
    wire                     OS2_I_buf1_vld          ;
    wire                     OS2_I_buf2_vld          ;
    wire                     OS2_I_buf3_vld          ;
    wire                     OS2_I_sub_vld           ;
                                    
    wire                     OS2_I1_buf0_vld         ;
    wire                     OS2_I1_buf1_vld         ;
    wire                     OS2_I1_buf2_vld         ;
    wire                     OS2_I1_buf3_vld         ;
    wire                     OS2_I1_sub_vld          ;

    (* mark_debug="false" *)wire                     OS2_400K_I_buf0_vld     ;
    (* mark_debug="false" *)wire                     OS2_400K_I_buf1_vld     ;
    (* mark_debug="false" *)wire                     OS2_400K_I_buf2_vld     ;
    (* mark_debug="false" *)wire                     OS2_400K_I_buf3_vld     ;
    (* mark_debug="false" *)wire                     OS2_400K_I_sub_vld      ;
                        
    (* mark_debug="false" *)wire                     OS2_400K_I1_buf0_vld    ;
    (* mark_debug="false" *)wire                     OS2_400K_I1_buf1_vld    ;
    (* mark_debug="false" *)wire                     OS2_400K_I1_buf2_vld    ;
    (* mark_debug="false" *)wire                     OS2_400K_I1_buf3_vld    ;
    (* mark_debug="false" *)wire                     OS2_400K_I1_sub_vld     ;
    wire                     pulse4_pwm_on      ;
    wire                     pulse4_400k_pwm_on ;

    (* mark_debug="false" *)wire [31:0]	             OS2_calib_I_i  ;	
    (* mark_debug="false" *)wire [31:0]	             OS2_calib_I_q  ;	
    (* mark_debug="false" *)wire 		             OS2_calib_I_vld;
    (* mark_debug="false" *)wire [31:0]	             OS2_calib_V_i  ;	
    (* mark_debug="false" *)wire [31:0]	             OS2_calib_V_q  ;	
    (* mark_debug="false" *)wire 		             OS2_calib_V_vld;

    (* mark_debug="false" *)wire [31:0]	             OS2_calib_I_400k_i  ;	
    (* mark_debug="false" *)wire [31:0]	             OS2_calib_I_400k_q  ;	
    (* mark_debug="false" *)wire 		             OS2_calib_I_400k_vld;
    (* mark_debug="false" *)wire [31:0]	             OS2_calib_V_400k_i  ;	
    (* mark_debug="false" *)wire [31:0]	             OS2_calib_V_400k_q  ;	
    (* mark_debug="false" *)wire 		             OS2_calib_V_400k_vld;
    wire [31:0]              R4_result          ;
    wire [31:0]              JX4_result         ;
    wire [31:0]              R4_400k_result     ;
    wire [31:0]              JX4_400k_result    ;

    wire [31:0]              AVG_IIR_R4         ; 
    wire [31:0]              AVG_IIR_JX4        ;

    wire [31:0]              AVG_IIR_400K_R4    ; 
    wire [31:0]              AVG_IIR_400K_JX4   ;

    //13.56m
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC0_I      ;    
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC0_Q      ;
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC1_I      ;
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC1_Q      ;

    reg [31:0]              r_SENSOR4_ADC0_I    ;
    reg [31:0]              r_SENSOR4_ADC0_Q    ;
    reg [31:0]              r_SENSOR4_ADC1_I    ;
    reg [31:0]              r_SENSOR4_ADC1_Q    ;
                        
    reg [31:0]              r2_SENSOR4_ADC0_I   ;
    reg [31:0]              r2_SENSOR4_ADC0_Q   ;
    reg [31:0]              r2_SENSOR4_ADC1_I   ;
    reg [31:0]              r2_SENSOR4_ADC1_Q   ;
    //400k
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC0_400K_I    ;    
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC0_400K_Q    ;
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC1_400K_I    ;
    (* mark_debug="false" *)wire [31:0]             SENSOR4_ADC1_400K_Q    ;

    reg [31:0]              r_SENSOR4_ADC0_400K_I  ;
    reg [31:0]              r_SENSOR4_ADC0_400K_Q  ;
    reg [31:0]              r_SENSOR4_ADC1_400K_I  ;
    reg [31:0]              r_SENSOR4_ADC1_400K_Q  ;
                        
    reg [31:0]              r2_SENSOR4_ADC0_400K_I ;
    reg [31:0]              r2_SENSOR4_ADC0_400K_Q ;
    reg [31:0]              r2_SENSOR4_ADC1_400K_I ;
    reg [31:0]              r2_SENSOR4_ADC1_400K_Q ;

    (* mark_debug="false" *)wire                    OS2_demod_vld0       ;
    (* mark_debug="false" *)wire                    OS2_demod_vld1       ;

    (* mark_debug="false" *)wire                    OS2_demod_400k_vld0  ;
    (* mark_debug="false" *)wire                    OS2_demod_400k_vld1  ;	

    (* mark_debug="false" *)wire [15:0]             OS2_threshold2on     ;
    (* mark_debug="false" *)wire [31:0]             OS2_measure_period   ;
    (* mark_debug="false" *)wire [31:0]             OS2_period_cnt       ;
    (* mark_debug="false" *)wire [31:0]             OS2_period_total     ;	

    (* mark_debug="false" *)wire [15:0]             w_OS2_PULSE_START;  //ch4
    (* mark_debug="false" *)wire [15:0]             w_OS2_PULSE_END  ;  //ch4
    (* mark_debug="false" *)wire [15:0]             w_OS2_400K_PULSE_START; //ch4
    (* mark_debug="false" *)wire [15:0]             w_OS2_400K_PULSE_END  ; //ch4

    wire [15:0]             w_pulse_gap4          ;
    wire [15:0]             w_pulse_gap4_400k     ;
    (* mark_debug="false" *)wire                    w_Z_pulse4_pwm; //OS2
    (* mark_debug="false" *)wire [15:0]             w_OS2_pwm_dly;

    (* mark_debug="false" *)wire                    w_Z_pulse4_pwm_400k; //OS2
    (* mark_debug="false" *)wire [15:0]             w_OS2_pwm_dly_400k;

//---------------------------------------------
    // wire  [31:0]            o_adc0_mean           ;
    // wire  [31:0]            o_adc1_mean           ;
    //---------------------------------------------
    reg 			        RF_ON_FPGA		      ;
    wire 			        RF_EN			      ;//射频功率开关,1开0关
    wire [15:0]		        SET_POINT_VAL	      ;//PID功率设置 
    wire 			        ERR				      ;
    //---------------------------------------------
    wire [15:0]		        VR_POWER_CALIB	      ;  //NO USE;
    wire [15:0]		        VF_POWER_CALIB	      ;  //NO USE;

    wire 			        ADC_RAM_EN		      ;	
    wire [11:0]		        ADC_RAM_RD_ADDR	      ;	
    wire [31:0]		        ADC_RAM_RD_DATA	      ;
    //wire [31:0]		        ADC_RAM_RD_DATA1	  ;
    wire [31:0]		        ADC_RAM_RD_DATA2	  ;
    // wire [31:0]		        ADC_RAM_RD_DATA3	  ;
    // wire [31:0]		        ADC_RAM_RD_DATA4	  ;
    //---------------------------------------------
    wire 		            BIAS_SET              ;
    wire [31:0]             POWER_THRESHOLD       ;
    wire [15:0]             FFT_PERIOD            ;
    //wire                  power_status_dly      ;
    //====================================================
    wire                     sysclk_bufg          ;
    //---------------------------------------------							  
    wire [5:0]	             dco_dly              ;//NOT USED
    wire [5:0]	             dco_dly_ch0	      ;//NOT USED
    wire [5:0]	             dco_dly_ch1	      ;//NOT USED
    wire [5:0]	             dco_dly_ch2	      ;//NOT USED
    wire [5:0]	             dco_dly_ch3	      ;//NOT USED										  
    //---------------------------------------------											  
    wire                     fft_start            ;
    wire                     FD_CLK_50M           ;
    wire  [31:0]             FD_R_OUT             ;
    wire  [31:0]             FD_JX_OUT            ;
    //---------------------------------------------											  											  									  											  
    wire  [31:0]             TDM_DIV_COEF         ; //1250 10ms;
    wire  [31:0]             TDM_PERIOD           ;			
    //---------------------------------------------
    wire [15:0]              MATCH_DETECT; //NO USE
    //---------------------------------------------
    wire [15:0]              FILTER_THRESHOLD   ;
    //---------------------------------------------								     
    wire [35:0]              KEEP_DLY                ;//NO USE;
    //---------------------------------------------
    (* mark_debug="false" *)wire [31:0]              ON_KEEP_NUM             ;
    (* mark_debug="false" *)wire [31:0]              OFF_KEEP_NUM            ;
    wire [31:0]              PULSE_FREQ              ;
    //---------------------------------------------
    wire [31:0]              tdm_period_cnt     ;
    //---------------------------------------------
    wire [31:0]              POWER_CALLAPSE     ; //NO USE
    wire [31:0]              R_JX_CALLAPSE      ; //NO USE
    //----------------------
    reg [31:0]              SENSOR2_I_DECOR_I   ;////no use
    reg [31:0]              SENSOR2_I_DECOR_Q   ;////no use
    reg [31:0]              SENSOR2_V_DECOR_I   ;////no use
    reg [31:0]              SENSOR2_V_DECOR_Q   ;////no use
//---------------------------------------------
//wire                    IS1_power_vld;
//---------------------------------------------
//------------POWER0_CALIB_K----FREQ0_THR---K0_THR----------
    wire [23:0]	            POWER0_CALIB_K0  ,POWER2_CALIB_K0   ; 
    wire [23:0]	            POWER0_CALIB_K1  ,POWER2_CALIB_K1   ;  
    wire [23:0]	            POWER0_CALIB_K2  ,POWER2_CALIB_K2   ; 
    wire [23:0]	            POWER0_CALIB_K3  ,POWER2_CALIB_K3   ; 
    wire [23:0]	            POWER0_CALIB_K4  ,POWER2_CALIB_K4   ; 
    wire [23:0]	            POWER0_CALIB_K5  ,POWER2_CALIB_K5   ; 
    wire [23:0]	            POWER0_CALIB_K6  ,POWER2_CALIB_K6   ; 
    wire [23:0]	            POWER0_CALIB_K7  ,POWER2_CALIB_K7   ; 
    wire [23:0]	            POWER0_CALIB_K8  ,POWER2_CALIB_K8   ; 
    wire [23:0]	            POWER0_CALIB_K9  ,POWER2_CALIB_K9   ; 
    wire [23:0]	            POWER0_CALIB_K10 ,POWER2_CALIB_K10  ;
    wire [23:0]	            POWER0_CALIB_K11 ,POWER2_CALIB_K11  ;
    wire [23:0]	            POWER0_CALIB_K12 ,POWER2_CALIB_K12  ;
    wire [23:0]	            POWER0_CALIB_K13 ,POWER2_CALIB_K13  ;
    wire [23:0]	            POWER0_CALIB_K14 ,POWER2_CALIB_K14  ;
    wire [23:0]	            POWER0_CALIB_K15 ,POWER2_CALIB_K15  ;
    wire [23:0]	            POWER0_CALIB_K16 ,POWER2_CALIB_K16  ;
    wire [23:0]	            POWER0_CALIB_K17 ,POWER2_CALIB_K17  ;
    wire [23:0]	            POWER0_CALIB_K18 ,POWER2_CALIB_K18  ;
    wire [23:0]	            POWER0_CALIB_K19 ,POWER2_CALIB_K19  ;
    wire [23:0]	            POWER0_CALIB_K20 ,POWER2_CALIB_K20  ;
    wire [23:0]	            POWER0_CALIB_K21 ,POWER2_CALIB_K21  ;
    wire [23:0]	            POWER0_CALIB_K22 ,POWER2_CALIB_K22  ;
    wire [23:0]	            POWER0_CALIB_K23 ,POWER2_CALIB_K23  ;
    wire [23:0]	            POWER0_CALIB_K24 ,POWER2_CALIB_K24  ;
    wire [23:0]	            POWER0_CALIB_K25 ,POWER2_CALIB_K25  ;
    wire [23:0]	            POWER0_CALIB_K26 ,POWER2_CALIB_K26  ;
    wire [23:0]	            POWER0_CALIB_K27 ,POWER2_CALIB_K27  ;
    wire [23:0]	            POWER0_CALIB_K28 ,POWER2_CALIB_K28  ;
    wire [23:0]	            POWER0_CALIB_K29 ,POWER2_CALIB_K29  ;
    //---------------------------------------------										 									 					 
    wire [31:0]	            FREQ0_THR0   ,FREQ2_THR0      ;		
    wire [31:0]	            FREQ0_THR1   ,FREQ2_THR1      ;		
    wire [31:0]	            FREQ0_THR2   ,FREQ2_THR2      ;		
    wire [31:0]	            FREQ0_THR3   ,FREQ2_THR3      ;		
    wire [31:0]	            FREQ0_THR4   ,FREQ2_THR4      ;		
    wire [31:0]	            FREQ0_THR5   ,FREQ2_THR5      ;		
    wire [31:0]	            FREQ0_THR6   ,FREQ2_THR6      ;		
    wire [31:0]	            FREQ0_THR7   ,FREQ2_THR7      ;		
    wire [31:0]	            FREQ0_THR8   ,FREQ2_THR8      ;		
    wire [31:0]	            FREQ0_THR9   ,FREQ2_THR9      ;		
    wire [31:0]	            FREQ0_THR10  ,FREQ2_THR10     ;		
    wire [31:0]	            FREQ0_THR11  ,FREQ2_THR11     ;		
    wire [31:0]	            FREQ0_THR12  ,FREQ2_THR12     ;		
    wire [31:0]	            FREQ0_THR13  ,FREQ2_THR13     ;		
    wire [31:0]	            FREQ0_THR14  ,FREQ2_THR14     ;		
    wire [31:0]	            FREQ0_THR15  ,FREQ2_THR15     ;		
    wire [31:0]	            FREQ0_THR16  ,FREQ2_THR16     ;		
    wire [31:0]	            FREQ0_THR17  ,FREQ2_THR17     ;		
    wire [31:0]	            FREQ0_THR18  ,FREQ2_THR18     ;		
    wire [31:0]	            FREQ0_THR19  ,FREQ2_THR19     ;		
    wire [31:0]	            FREQ0_THR20  ,FREQ2_THR20     ;		
    wire [31:0]	            FREQ0_THR21  ,FREQ2_THR21     ;		
    wire [31:0]	            FREQ0_THR22  ,FREQ2_THR22     ;		
    wire [31:0]	            FREQ0_THR23  ,FREQ2_THR23     ;		
    wire [31:0]	            FREQ0_THR24  ,FREQ2_THR24     ;		
    wire [31:0]	            FREQ0_THR25  ,FREQ2_THR25     ;		
    wire [31:0]	            FREQ0_THR26  ,FREQ2_THR26     ;		
    wire [31:0]	            FREQ0_THR27  ,FREQ2_THR27     ;		
    wire [31:0]	            FREQ0_THR28  ,FREQ2_THR28     ;		
    wire [31:0]	            FREQ0_THR29  ,FREQ2_THR29     ;		
    wire [31:0]	            FREQ0_THR30  ,FREQ2_THR30     ;		
    //---------------------------------------------										 
    wire [23:0]	            K0_THR0   	,K2_THR0  	  ;
    wire [23:0]	            K0_THR1 	,K2_THR1 	  ;
    wire [23:0]	            K0_THR2 	,K2_THR2 	  ;
    wire [23:0]	            K0_THR3 	,K2_THR3 	  ;
    wire [23:0]	            K0_THR4 	,K2_THR4 	  ;
    wire [23:0]	            K0_THR5 	,K2_THR5 	  ;
    wire [23:0]	            K0_THR6 	,K2_THR6 	  ;
    wire [23:0]	            K0_THR7 	,K2_THR7 	  ;
    wire [23:0]	            K0_THR8 	,K2_THR8 	  ;
    wire [23:0]	            K0_THR9 	,K2_THR9 	  ;
    wire [23:0]	            K0_THR10	,K2_THR10	  ;
    wire [23:0]	            K0_THR11	,K2_THR11	  ;
    wire [23:0]	            K0_THR12	,K2_THR12	  ;
    wire [23:0]	            K0_THR13	,K2_THR13	  ;
    wire [23:0]	            K0_THR14	,K2_THR14	  ;
    wire [23:0]	            K0_THR15	,K2_THR15	  ;
    wire [23:0]	            K0_THR16	,K2_THR16	  ;
    wire [23:0]	            K0_THR17	,K2_THR17	  ;
    wire [23:0]	            K0_THR18	,K2_THR18	  ;
    wire [23:0]	            K0_THR19	,K2_THR19	  ;
    wire [23:0]	            K0_THR20	,K2_THR20	  ;
    wire [23:0]	            K0_THR21	,K2_THR21	  ;
    wire [23:0]	            K0_THR22	,K2_THR22	  ;
    wire [23:0]	            K0_THR23	,K2_THR23	  ;
    wire [23:0]	            K0_THR24	,K2_THR24	  ;
    wire [23:0]	            K0_THR25	,K2_THR25	  ;
    wire [23:0]	            K0_THR26	,K2_THR26	  ;
    wire [23:0]	            K0_THR27	,K2_THR27	  ;
    wire [23:0]	            K0_THR28	,K2_THR28	  ;
    wire [23:0]	            K0_THR29	,K2_THR29	  ;
			             
    (* mark_debug="false" *)wire [23:0]             AUTO_POWER_CALIB_K0       ;
    (* mark_debug="false" *)wire [23:0]             AUTO_POWER_CALIB_K2       ;
    wire [14:0]             RDAddr                    ;
										          
    (* mark_debug="false" *)wire [15:0]             vf_power0_calib_disp      ;
    (* mark_debug="false" *)wire [15:0]             vr_power0_calib_disp      ;
    (* mark_debug="false" *)wire [15:0]             vf_power0_disp_avg        ;
    (* mark_debug="false" *)wire [15:0]             vr_power0_disp_avg        ;
    
    (* mark_debug="false" *)wire [15:0]             vf_power2_calib_disp      ;
    (* mark_debug="false" *)wire [15:0]             vr_power2_calib_disp      ;
    (* mark_debug="false" *)wire [15:0]             vf_power2_disp_avg        ;
    (* mark_debug="false" *)wire [15:0]             vr_power2_disp_avg        ;
//---------------------------------------------	
    wire [47:0]             MOTO1_PARA1;
    wire [47:0]             MOTO1_PARA2;
    wire [47:0]             MOTO2_PARA1;
    wire [47:0]             MOTO2_PARA2;
    wire [47:0]             MOTO3_PARA1;
    wire [47:0]             MOTO3_PARA2;
    wire [47:0]             MOTO4_PARA1;
    wire [47:0]             MOTO4_PARA2;
    wire [47:0]             MOTO5_PARA1;
    wire [47:0]             MOTO5_PARA2;
    wire [47:0]             MOTO6_PARA1;
    wire [47:0]             MOTO6_PARA2;
    wire [47:0]             MOTO7_PARA1;
    wire [47:0]             MOTO7_PARA2;
    wire [47:0]             MOTO8_PARA1;
    wire [47:0]             MOTO8_PARA2;
    wire [47:0]             PL_STATE;    

    wire [15:0]             moto_state;
    reg [7:0]               ONLINE_STATE;
    assign PL_STATE[47:0] = {24'd0 , ONLINE_STATE, moto_state};
//---------------------------------------------	   			   	            
    assign INTLOCK_OUT = INTLOCK_IN;
    assign w_pulse_gap0  = w_IS0_PULSE_END0 - w_IS0_PULSE_START0;
    assign w_pulse_gap1 = w_OS0_PULSE_END1 - w_OS0_PULSE_START1;
    assign w_pulse_gap2 = w_IS1_PULSE_END2 - w_IS1_PULSE_START2;
    assign w_pulse_gap3 = w_OS1_PULSE_END - w_OS1_PULSE_START;
    assign w_pulse_gap3_400k = w_OS1_400K_PULSE_END - w_OS1_400K_PULSE_START;
    assign w_pulse_gap4 = w_OS2_PULSE_END - w_OS2_PULSE_START;
    assign w_pulse_gap4_400k = w_OS2_400K_PULSE_END - w_OS2_400K_PULSE_START;

    assign adc0_ch0_bpf_data  = {ad9238_da0,32'd0};  //32bit补到64bit;
    assign adc1_ch0_bpf_data  = {ad9238_db0,32'd0};
    assign adc0_ch0_bpf_vld   = ad9238_da0_vld;
    assign adc1_ch0_bpf_vld   = ad9238_db0_vld;
    assign ch0_start_bpf      = ch0_start_adc;

    assign adc0_ch1_bpf_data = {ad9238_da1,32'd0};  //32bit补到64bit;
    assign adc1_ch1_bpf_data = {ad9238_db1,32'd0};
    assign adc0_ch1_bpf_vld  = ad9238_da1_vld;
    assign adc1_ch1_bpf_vld  = ad9238_db1_vld;
    assign ch1_start_bpf = ch1_start_adc;

    assign adc0_ch2_bpf_data = {ad9238_da2,32'd0};  //32bit补到64bit;
    assign adc1_ch2_bpf_data = {ad9238_db2,32'd0};
    assign adc0_ch2_bpf_vld  = ad9238_da2_vld;
    assign adc1_ch2_bpf_vld  = ad9238_db2_vld;
    assign ch2_start_bpf = ch2_start_adc;

    assign adc0_ch3_bpf_data = {ad9238_da3,32'd0};  //32bit补到64bit;
    assign adc1_ch3_bpf_data = {ad9238_db3,32'd0};
    assign adc0_ch3_bpf_vld  = ad9238_da3_vld;
    assign adc1_ch3_bpf_vld  = ad9238_db3_vld;
    assign ch3_start_bpf = ch3_start_adc;

    assign adc0_ch3_bpf_400k_data = {ad9238_400k_da3,32'd0};  //32bit补到64bit;
    assign adc1_ch3_bpf_400k_data = {ad9238_400k_db3,32'd0};
    assign adc0_ch3_bpf_400k_vld  = ad9238_400k_da3_vld;
    assign adc1_ch3_bpf_400k_vld  = ad9238_400k_db3_vld;
    assign ch3_start_bpf_400k = ch3_start_adc_400k;

    assign adc0_ch4_bpf_data = {ad9238_da4,32'd0};  //32bit补到64bit;
    assign adc1_ch4_bpf_data = {ad9238_db4,32'd0};
    assign adc0_ch4_bpf_vld  = ad9238_da4_vld;
    assign adc1_ch4_bpf_vld  = ad9238_db4_vld;
    assign ch4_start_bpf = ch4_start_adc;

    assign adc0_ch4_bpf_400k_data = {ad9238_400k_da4,32'd0};  //32bit补到64bit;
    assign adc1_ch4_bpf_400k_data = {ad9238_400k_db4,32'd0};
    assign adc0_ch4_bpf_400k_vld  = ad9238_400k_da4_vld;
    assign adc1_ch4_bpf_400k_vld  = ad9238_400k_db4_vld;
    assign ch4_start_bpf_400k = ch4_start_adc_400k;

    assign clk_64m   = i_clk_64m  ;
    assign clk_128m  = i_clk_128m ;
    assign clk_50m   = i_clk_50m  ;	
//---------------------------------------------
    always@(clk_50m)begin
        if(!i_sys_reset)begin //LAGA
            ONLINE_STATE <= 8'hAA;//给MCU判断逻辑是否已经跑起来了
        end
    end

    always@(*)
        if(ERR)
            RF_ON_MCU <= 0;
        else 
            RF_ON_MCU <= RF_EN;

    always@(*)
        if(ERR || SET_POINT_VAL==0)
            RF_ON_FPGA = 1;//0开1关  // set point为0时关闭rf on
        else 
            RF_ON_FPGA = ~RF_EN;
            
    high_dly	high_dly(
        .clk_i		(clk_50m       ),
        .rst_i		(rst_125	   ),
        .din		(RF_ON_FPGA    ),
        .dout		(RF_ON_FPGA_DLY)
    );		

    gen_sync_reset #(
        .CLK_FREQ               ( 125000      ),
        .DLY_TIME               ( 1000        )
    )u_gen_sync_reset1 (
        .i_clk                  ( clk_128m    ),
        .i_rst                  ( i_sys_reset),


        .o_rst                  ( rst_125     ),
        .o_rstn                 (             )
    );
//---------------------------------------------
`ifdef DEFINE_IS0_CH0 
    AD9238_drive   AD9238_HF(//ADC原始数据通常为无符号格式（范围0–4095）.减去2048后,数据转换为有符号补码形式（范围-2048~+2047）,便于后续数字信号处理
        /*input            */     .i_clk                    (clk_64m             ),
        /*input            */     .i_adc_clk                (i_adc_clk           ),
        /*input            */     .i_rst                    (rst_125             ),
        /*input  [11:0]    */     .i_adc_data0              (i_adc0_data0        ),
        /*input  [11:0]    */     .i_adc_data1              (i_adc0_data1        ),
        /*output reg       */     .vld	                    (AD9238_CH0_vld      ),
        /*output reg [11:0]*/     .o_CHA                    (AD9238_CH0_CHA      ),
        /*output reg [11:0]*/     .o_CHB                    (AD9238_CH0_CHB      )  //VF
    );
    ADC_DATA_RAM	ADC0_DATA_RAM(                        
        /*input        */	.i_clk_64m				(clk_64m              ),
        /*input        */	.i_clk					(clk_50m              ),		
        /*input        */	.i_rstn					(~rst_125             ),
        /*input        */	.vld					(AD9238_CH0_vld       ),	
        /*input [15:0] */	.CHA					({AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA}),	// V
        /*input [15:0] */	.CHB					({AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB}),	//vf
        /*input        */	.ADC_RAM_EN				(ADC_RAM_EN		      ),		//拉高1个周期
        /*input [11:0] */   .ADC_RAM_RD_ADDR		(ADC_RAM_RD_ADDR      ),
        /*output [31:0]*/   .ADC_RAM_RD_DATA		(ADC_RAM_RD_DATA      )	
    );
    //The first pcs adc;  // 13.56M
    FREQ_RTK_1356M  FREQ_RTK_MEASURE_HF  //13.56M
    (
        /*input            */.i_clk                     (clk_64m             ), //64M == 15.628ns;
        /*input            */.i_rst                     (rst_125             ),
        /*input            */.i_adc_vld                 (AD9238_CH0_vld      ), 
        /*input      [13:0]*/.i_adc_data                ({AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB} ), //input sensor VF;
        /*input      [15:0]*/.i_threshold2on            (HF_threshold2on     ),//测频的阈值
        /*input      [31:0]*/.i_measure_period          (HF_measure_period   ),
        /*output reg [31:0]*/.o_period_total            (HF_period_total     ), //MCU读取，用于计算频率,计算出频率后下发demod_freq_coef0
        /*output reg [31:0]*/.o_period_pos_cnt          (HF_period_cnt       )  //测量周期个数 
    );
    // FREQ_RTK_60M  FREQ_RTK_MEASURE_HF
        // (
        //     /*input            */    .i_clk                     (clk_64m             ), //64M == 15.628ns;
        //     /*input            */    .i_rst                     (rst_125             ),
        //     /*input            */    .i_adc_vld                 (AD9238_CH0_vld      ), 
        //     /*input      [13:0]*/    .i_adc_data                ({AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB} ), //input sensor VF;
        //     /*input      [15:0]*/    .i_threshold2on            (HF_threshold2on     ),
        //     /*input      [31:0]*/    .i_measure_period          (HF_measure_period   ),
        //     /*output reg [31:0]*/    .o_period_total            (HF_period_total     ),
        //     /*output reg [31:0]*/    .o_period_pos_cnt          (HF_period_cnt       )  //测量周期个数     
    // );
    //////
    daq9248 daq9248_adc0(
        /*input  wire       */    .i_clk_62p5             ( clk_64m             ),//adc_sync_fifo 64M转128M
        /*input  wire       */    .i_clk_250              ( clk_128m            ),//adc_sync_fifo 64M转128M
        /*input  wire       */    .i_rst_62p5             ( rst_125             ),
        /**/
        /*input  wire [31:0]*/    .i_adc0_mean            ( adc0_mean0          ),	//输入 入射mean 上位机dico校准 计算出来的mean值
        /*input  wire [31:0]*/    .i_adc1_mean            ( adc1_mean0          ),	//输入 反射mean 上位机dico校准 计算出来的mean值
        /*output reg        */    .o_sys_start            ( ch0_start_adc       ),
        /**/
        /*input             */	  .vld					  ( AD9238_CH0_vld      ),
        /*input  wire [13:0]*/    .i_ad9248_da            ( {AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB}  ),//AD9643数据,入射
        /*input  wire [13:0]*/    .i_ad9248_db            ( {AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA}  ),//AD9643数据，反射
        /**/
        /*output reg        */    .o_ad9248_da_vld        ( ad9238_da0_vld      ),
        /*output reg  [31:0]*/    .o_ad9248_da            ( ad9238_da0          ), //2个14bit补齐到32bit signed
        /*output reg        */    .o_ad9248_db_vld        ( ad9238_db0_vld      ),
        /*output reg  [31:0]*/    .o_ad9248_db            ( ad9238_db0          )  //2个14bit补齐到32bit signed
    );
    //////
    adc_demod adc_demod_HF(
        /*input               */   .i_clk                     ( clk_128m               ),
        /*input               */   .i_rst                     ( rst_125                ),
        /*input   [15:0]      */   .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数
        /*input               */   .i_sys_start               ( ch0_start_bpf          ),	
        /*output              */   .o_sys_start               ( sys0_start_demod       ),
        /*input   [3:0]       */   .RF_FREQ				      ( RF_FREQ0			   ),
        /*input   [31:0]      */	//.freq_data				   ( freq_out0			    ),
        // adc bpf data           
        /*input               */    .i_adc0_vld                ( adc0_ch0_bpf_vld      ),
        /*input   [63:0]      */    .i_adc0_data               ( adc0_ch0_bpf_data     ),//32bit补齐到64bit
        /*input               */    .i_adc1_vld                ( adc1_ch0_bpf_vld      ),
        /*input   [63:0]      */    .i_adc1_data               ( adc1_ch0_bpf_data     ),//32bit补齐到64bit
        // adc lpf data           
        /*output              */     .o_adc0_demod_vld          ( adc0_ch0_demod_vld    ),  
        /*output  [63:0]      */     .o_adc0_demod_data         ( adc0_ch0_demod_data   ),  // {Vmi ,Vmq}					      
        /*output              */     .o_adc1_demod_vld          ( adc1_ch0_demod_vld    ),
        /*output [63:0]       */     .o_adc1_demod_data         ( adc1_ch0_demod_data   ),  // {Imi ,Imq}
        /*output reg     [13:0]*/	.r_demod_rd_addr		    ( demod_rd_addr0	    ),
        /*input   [31:0]       */    .i_demod_freq_coef         ( demod_freq_coef0      )  //需要MCU获取到 ID_period_total0 ID_period_num0 算出频率，将频率值下发，根据这个频率值进行解调
    );
    //////
    adc_lpf adc_lpf_HF(
        /*input          */     .i_clk_250                 ( clk_128m              ),
        /*input          */     .i_rst                     ( rst_125               ),
        /**/		     							      
        /*input          */     .i_sys_start               ( sys0_start_demod      ),
        /*output         */     .o_sys_start               ( sys0_start_lpf        ),
        /**/		  	  														   
        /*input          */     .i_adc0_demod_vld          ( adc0_ch0_demod_vld    ),
        /*input   [63:0] */     .i_adc0_demod_data         ( adc0_ch0_demod_data   ),						      
        /*input          */     .i_adc1_demod_vld          ( adc1_ch0_demod_vld    ),
        /*input   [63:0] */     .i_adc1_demod_data         ( adc1_ch0_demod_data   ),
        /**/										                
        /*output         */     .o_adc0_lpf_vld            ( adc0_ch0_lpf_vld     ), //V
        /*output  [63:0] */     .o_adc0_lpf_data           ( adc0_ch0_lpf_data    ),						      
        /*output         */     .o_adc1_lpf_vld            ( adc1_ch0_lpf_vld     ), //I
        /*output  [63:0] */     .o_adc1_lpf_data           ( adc1_ch0_lpf_data    )
    ); 
    Decor_Calib Decor_Calib_HF(
        /*input          */.i_clk                   ( clk_128m              ),
        /*input          */.i_rst                   ( rst_125               ),
                                                                        
        /*input          */.i_sys_start             ( sys0_start_lpf        ),
        /*output         */.o_sys_start             ( sys0_start_calib      ),
                                                                        
        /*input          */.i_calib_en              ( 1'b1                  ),
            
        // .o_adc0_mean             ( adc0_mean0            ),//从SPI发来
        // .o_adc1_mean             ( adc1_mean0            ),
        
        /*input          */.i_adc0_lpf_vld          ( adc0_ch0_lpf_vld      ), //Vf
        /*input   [63:0] */.i_adc0_lpf_data         ( adc0_ch0_lpf_data     ),
        /*input          */.i_adc1_lpf_vld          ( adc1_ch0_lpf_vld      ), //Vr
        /*input   [63:0] */.i_adc1_lpf_data         ( adc1_ch0_lpf_data     ),
                                                            
        /*output         */ .o_adc0_calib_vld        ( adc0_ch0_calib_vld    ), 
        /*output  [63:0] */ .o_adc0_calib_data       ( adc0_ch0_calib_data   ),	   
        /*output         */ .o_adc1_calib_vld        ( adc1_ch0_calib_vld    ),	
        /*output  [63:0] */ .o_adc1_calib_data       ( adc1_ch0_calib_data   ),	

        /*input [31:0]   */.m1a00					 ( m1a00_ch0		     ),//A
        /*input [31:0]   */.m1a01					 ( m1a01_ch0		     ),//B
        /*input [31:0]   */.m1a10					 ( m1a10_ch0		     ),//C
        /*input [31:0]   */.m1a11					 ( m1a11_ch0		     ) //D
    );
    ///////HF �?? INPUT SENSOR 计算功率
    data_ext	data_ext_HF_vf(     //128M转50M fifo输出                        
        /*input 			*/	.i_clk				     (clk_128m             ),
        /*input 			*/	.clk_50m			     (clk_50m              ),
        /*input [63:0]		*/	.i_data				     (adc0_ch0_calib_data  ),	
        /*input 			*/	.i_valid			     (adc0_ch0_calib_vld   ), 
        /*input [13:0]		*/	.r_demod_rd_addr	     (demod_rd_addr0       ),
        /*output reg [31:0]	*/	.o_data_i			     (ch0_calib_vf_i       ), 
        /*output reg [31:0]	*/	.o_data_q			     (ch0_calib_vf_q       ),
        /*output reg 		*/	.o_valid			     (calib_vf_vld0        )
    );                                                 
                                                    
    data_ext	data_ext_HF_vr(   //128M转50M fifo输出                            
        /*input 			*/	.i_clk				     (clk_128m 		       ),
        /*input 			*/	.clk_50m			     (clk_50m		       ),
        /*input [63:0]		*/	.i_data				     (adc1_ch0_calib_data  ),	
        /*input 			*/	.i_valid			     (adc1_ch0_calib_vld   ),
        /*input [13:0]		*/	.r_demod_rd_addr	     (demod_rd_addr0       ),
        /*output reg [31:0]	*/	.o_data_i			     (ch0_calib_vr_i       ),
        /*output reg [31:0]	*/	.o_data_q			     (ch0_calib_vr_q       ),
        /*output reg 		*/	.o_valid			     (calib_vr_vld0        )
    );                                                 
                                                    
    power_cal	power_HF_pf(    //INPUT SENSOR vf;          
        /*input        */	.i_clk				     (clk_50m              ),	//125m 
        /*input        */	.i_rstn				     (~rst_125		       ),
        /*input [31:0] */	.data_i				     (ch0_calib_vf_i       ),	//16位定点数 
        /*input [31:0] */	.data_q				     (ch0_calib_vf_q       ),
        /*output [31:0]*/	.dout				     (VF_POWER0            )	//p = q^2 + i^2  
    );                                                 
                                                    
    power_cal	power_HF_pr(                                
        /*input        */	.i_clk				     (clk_50m              ),	//125m 
        /*input        */	.i_rstn				     (~rst_125             ),
        /*input [31:0] */	.data_i				     (ch0_calib_vr_i       ),	//16位定点数
        /*input [31:0] */	.data_q				     (ch0_calib_vr_q       ),
        /*output [31:0]*/	.dout				     (VR_POWER0            )	//p = q^2 + i^2
    );  
    power_k_sel   power_k_sel_HF(
        /*input 		    */    .clk_i                  (clk_50m             ),
        /*input 		    */    .rst_i                  (rst_125             ),
                                                            
        /*input [31:0]      */    .freq_in                (demod_freq_coef0    ),
        /*input 		    */    .FREQ_CALIB_MODE        (FREQ0_CALIB_MODE    ),
        /*input [23:0]      */    .ORIG_K	                (ORIG_K0             ),	
                            
        /*input [23:0]      */    .POWER_CALIB_K0	        (POWER0_CALIB_K0	 ),
        /*input [23:0]      */    .POWER_CALIB_K1	        (POWER0_CALIB_K1	 ),
        /*input [23:0]      */    .POWER_CALIB_K2	        (POWER0_CALIB_K2	 ),
        /*input [23:0]      */    .POWER_CALIB_K3	        (POWER0_CALIB_K3	 ),
        /*input [23:0]      */    .POWER_CALIB_K4	        (POWER0_CALIB_K4	 ),
        /*input [23:0]      */    .POWER_CALIB_K5	        (POWER0_CALIB_K5	 ),
        /*input [23:0]      */    .POWER_CALIB_K6	        (POWER0_CALIB_K6	 ),
        /*input [23:0]      */    .POWER_CALIB_K7	        (POWER0_CALIB_K7	 ),
        /*input [23:0]      */    .POWER_CALIB_K8	        (POWER0_CALIB_K8	 ),
        /*input [23:0]      */    .POWER_CALIB_K9	        (POWER0_CALIB_K9	 ),
        /*input [23:0]      */    .POWER_CALIB_K10	    (POWER0_CALIB_K10    ),      
        /*input [23:0]      */    .POWER_CALIB_K11	    (POWER0_CALIB_K11    ),      
        /*input [23:0]      */    .POWER_CALIB_K12	    (POWER0_CALIB_K12    ),      
        /*input [23:0]      */    .POWER_CALIB_K13	    (POWER0_CALIB_K13    ),      
        /*input [23:0]      */    .POWER_CALIB_K14	    (POWER0_CALIB_K14    ),      
        /*input [23:0]      */    .POWER_CALIB_K15	    (POWER0_CALIB_K15    ),      
        /*input [23:0]      */    .POWER_CALIB_K16	    (POWER0_CALIB_K16    ),      
        /*input [23:0]      */    .POWER_CALIB_K17	    (POWER0_CALIB_K17    ),      
        /*input [23:0]      */    .POWER_CALIB_K18	    (POWER0_CALIB_K18    ),      
        /*input [23:0]      */    .POWER_CALIB_K19	    (POWER0_CALIB_K19    ),      
        /*input [23:0]      */    .POWER_CALIB_K20	    (POWER0_CALIB_K20    ),      
        /*input [23:0]      */    .POWER_CALIB_K21	    (POWER0_CALIB_K21    ),      
        /*input [23:0]      */    .POWER_CALIB_K22	    (POWER0_CALIB_K22    ),      
        /*input [23:0]      */    .POWER_CALIB_K23	    (POWER0_CALIB_K23    ),      
        /*input [23:0]      */    .POWER_CALIB_K24	    (POWER0_CALIB_K24    ),      
        /*input [23:0]      */    .POWER_CALIB_K25	    (POWER0_CALIB_K25    ),      
        /*input [23:0]      */    .POWER_CALIB_K26	    (POWER0_CALIB_K26    ),      
        /*input [23:0]      */    .POWER_CALIB_K27	    (POWER0_CALIB_K27    ),      
        /*input [23:0]      */    .POWER_CALIB_K28	    (POWER0_CALIB_K28    ),      
        /*input [23:0]      */    .POWER_CALIB_K29	    (POWER0_CALIB_K29    ),      
                            
        /*input [31:0]      */    .FREQ_THR0              (FREQ0_THR0          ),		
        /*input [31:0]      */    .FREQ_THR1              (FREQ0_THR1          ),		
        /*input [31:0]      */    .FREQ_THR2              (FREQ0_THR2          ),		
        /*input [31:0]      */    .FREQ_THR3              (FREQ0_THR3          ),		
        /*input [31:0]      */    .FREQ_THR4              (FREQ0_THR4          ),		
        /*input [31:0]      */    .FREQ_THR5              (FREQ0_THR5          ),		
        /*input [31:0]      */    .FREQ_THR6              (FREQ0_THR6          ),		
        /*input [31:0]      */    .FREQ_THR7              (FREQ0_THR7          ),		
        /*input [31:0]      */    .FREQ_THR8              (FREQ0_THR8          ),		
        /*input [31:0]      */    .FREQ_THR9              (FREQ0_THR9          ),		
        /*input [31:0]      */    .FREQ_THR10             (FREQ0_THR10         ),		
        /*input [31:0]      */    .FREQ_THR11             (FREQ0_THR11         ),		
        /*input [31:0]      */    .FREQ_THR12             (FREQ0_THR12         ),		
        /*input [31:0]      */    .FREQ_THR13             (FREQ0_THR13         ),		
        /*input [31:0]      */    .FREQ_THR14             (FREQ0_THR14         ),		
        /*input [31:0]      */    .FREQ_THR15             (FREQ0_THR15         ),		
        /*input [31:0]      */    .FREQ_THR16             (FREQ0_THR16         ),		
        /*input [31:0]      */    .FREQ_THR17             (FREQ0_THR17         ),		
        /*input [31:0]      */    .FREQ_THR18             (FREQ0_THR18         ),		
        /*input [31:0]      */    .FREQ_THR19             (FREQ0_THR19         ),		
        /*input [31:0]      */    .FREQ_THR20             (FREQ0_THR20         ),		
        /*input [31:0]      */    .FREQ_THR21             (FREQ0_THR21         ),		
        /*input [31:0]      */    .FREQ_THR22             (FREQ0_THR22         ),		
        /*input [31:0]      */    .FREQ_THR23             (FREQ0_THR23         ),		
        /*input [31:0]      */    .FREQ_THR24             (FREQ0_THR24         ),		
        /*input [31:0]      */    .FREQ_THR25             (FREQ0_THR25         ),		
        /*input [31:0]      */    .FREQ_THR26             (FREQ0_THR26         ),		
        /*input [31:0]      */    .FREQ_THR27             (FREQ0_THR27         ),		
        /*input [31:0]      */    .FREQ_THR28             (FREQ0_THR28         ),		
        /*input [31:0]      */    .FREQ_THR29             (FREQ0_THR29         ),		
        /*input [31:0]      */    .FREQ_THR30             (FREQ0_THR30         ),		
                                                                            
        /*input [23:0]      */    .K_THR0 			    (K0_THR0 		     ),
        /*input [23:0]      */    .K_THR1 			    (K0_THR1 		     ),
        /*input [23:0]      */    .K_THR2 			    (K0_THR2 		     ),
        /*input [23:0]      */    .K_THR3 			    (K0_THR3 		     ),
        /*input [23:0]      */    .K_THR4 			    (K0_THR4 		     ),
        /*input [23:0]      */    .K_THR5 			    (K0_THR5 		     ),
        /*input [23:0]      */    .K_THR6 			    (K0_THR6 		     ),
        /*input [23:0]      */    .K_THR7 			    (K0_THR7 		     ),
        /*input [23:0]      */    .K_THR8 			    (K0_THR8 		     ),
        /*input [23:0]      */    .K_THR9 			    (K0_THR9 		     ),
        /*input [23:0]      */    .K_THR10			    (K0_THR10		     ),
        /*input [23:0]      */    .K_THR11			    (K0_THR11		     ),
        /*input [23:0]      */    .K_THR12			    (K0_THR12		     ),
        /*input [23:0]      */    .K_THR13			    (K0_THR13		     ),
        /*input [23:0]      */    .K_THR14			    (K0_THR14		     ),
        /*input [23:0]      */    .K_THR15			    (K0_THR15		     ),
        /*input [23:0]      */    .K_THR16			    (K0_THR16		     ),
        /*input [23:0]      */    .K_THR17			    (K0_THR17		     ),
        /*input [23:0]      */    .K_THR18			    (K0_THR18		     ),
        /*input [23:0]      */    .K_THR19			    (K0_THR19		     ),
        /*input [23:0]      */    .K_THR20			    (K0_THR20		     ),
        /*input [23:0]      */    .K_THR21			    (K0_THR21		     ),
        /*input [23:0]      */    .K_THR22			    (K0_THR22		     ),
        /*input [23:0]      */    .K_THR23			    (K0_THR23		     ),
        /*input [23:0]      */    .K_THR24			    (K0_THR24		     ),
        /*input [23:0]      */    .K_THR25			    (K0_THR25		     ),
        /*input [23:0]      */    .K_THR26			    (K0_THR26		     ),
        /*input [23:0]      */    .K_THR27			    (K0_THR27		     ),
        /*input [23:0]      */    .K_THR28			    (K0_THR28		     ),
        /*input [23:0]      */    .K_THR29			    (K0_THR29		     ),
                                                        
        /*output reg [23:0] */	.K_out                  (AUTO_POWER_CALIB_K0 )	//默认 orig_k =69300;
    );
    ///////
    power_calib	calib_pf_k_HF(                      
        /*input 	   */	.i_clk				    (clk_50m             ),
        /*input 	   */	.i_rst				    (rst_125             ),
        /*input [31:0] */	.power_in			    (VF_POWER0           ),
        /*input [23:0] */	.POWER_CALIB_K		    (AUTO_POWER_CALIB_K0 ),	
        /*output [15:0]*/	.dout				    (VF_POWER_CALIB_K0   )	///16bit 乘上K值,输出的校准值
    );
                            
    power_calib	calib_pr_k_HF(                         
        /*input 	   */	.i_clk				    (clk_50m             ),
        /*input 	   */	.i_rst				    (rst_125             ),
        /*input [31:0] */	.power_in			    (VR_POWER0           ),
        /*input [23:0] */	.POWER_CALIB_K		    (AUTO_POWER_CALIB_K0 ),	
        /*output [15:0]*/	.dout				    (VR_POWER_CALIB_K0   )	 //16bit
    );  

    //用于 edge_detect ;Input sensor 功率波形拟合�??
    AVG_FIFO_32	AVG32_pf_k_HF(                         //滑动平均
        /*input            */    .clk_i			       (clk_50m              ),
        /*input            */    .rst_i			       (rst_125              ),
        /*input [31:0]     */    .data_in		       (VF_POWER_CALIB_K0    ),
        /*input            */    .den_in			   (calib_vf_vld0        ),
        /*output reg [31:0]*/    .data_out		       (VF_POWER0_K_AVG      ),
        /*output reg       */    .den_out		       ()
    );
    /*-------------> lF INPUT SENSOR 计算阻抗业务   -------------------*/
    refl_cal_16bit	refl_cal_16bit_HF(
        /*input            */	.i_clk				 (clk_50m               ),	//125m 
        /**/	           	
        /*input [15:0]     */	.vr_i				 (ch0_calib_vr_i[31:16] ),	//A 
        /*input [15:0]     */	.vr_q				 (ch0_calib_vr_q[31:16] ),	//B
        /*input [15:0]     */	.vf_i				 (ch0_calib_vf_i[31:16] ),	//C
        /*input [15:0]     */	.vf_q				 (ch0_calib_vf_q[31:16] ),	//D
        /*output reg [31:0]*/	.refl_i				 (ch0_refl_i            ),
        /*output reg [31:0]*/	.refl_q				 (ch0_refl_q	        )
    );	//反射/入射   
       						 
    r_jx	r_jx_HF(            
        .i_clk				 (clk_50m           ),	//125m 
        .refl_i				 (ch0_refl_i        ),	//31位定点数
        .refl_q				 (ch0_refl_q        ),	//31位定点数
                                            
        .r_jx_i				 (ch0_r_jx_i        ),	//31位定点数
        .r_jx_q				 (ch0_r_jx_q        )    //15位定点数
    );	//R+jX = Z0*(1+r)/(1-r) , Z0 = 50
    //校准阻抗
    r_jx_calib	r_jx_calib_HF(	//射频�??启后才输出R+JX
        /*input            */	.clk_i				 (clk_50m           ),	
        /*input            */	.rst_i				 (rst_125           ),
        /*input            */	.RF_ON_FPGA			 (0),//(RF_ON_FPGA  ,	//0开1关 
        /*input            */	.bias_on			 (0),//(bias_on),      //0开1关 
        /*input      [31:0]*/	.R_IN				 (ch0_r_jx_i        ),	
        /*input      [31:0]*/	.JX_IN				 (ch0_r_jx_q        ),	
        /*input      [31:0]*/	.K1					 (CALIB_R0          ), //给0，没影响的参数
        /*input      [31:0]*/	.K2					 (),                	

        /*output reg [31:0]*/	.R_OUT				 (R_DOUT0            ),	//15位定点数
        /*output reg [31:0]*/	.JX_OUT				 (JX_DOUT0           )
    );	//Z = (a + j(50k+b)) / ((50-bk) + jak)  

    //HF--INPUT SENSOR;					    
    average_signed	R0_AVG256_HF(    //256个数据窗口的滑动平均                      
        /*input            */	.clk_i			     (clk_50m             ),
        /*input            */	.rst_i			     (rst_125             ),
        /*input [31:0]     */	.din			     (R_DOUT0             ),
        /*input            */	.en_in			     (1                   ),
        /*output reg [31:0]*/	.dout			     (INPUT_SENSOR0_R_AVG ),
        /*output reg       */	.en_out			     ()                 
    );

    average_signed	JX0_AVG256_HF( //256个数据窗口的滑动平均   
        /*input            */	.clk_i			     (clk_50m             ),
        /*input            */	.rst_i			     (rst_125             ),
        /*input [31:0]     */	.din			     (JX_DOUT0            ),
        /*input            */	.en_in			     (1                   ),
        /*output reg [31:0]*/	.dout			     (INPUT_SENSOR0_JX_AVG),
        /*output reg       */	.en_out			     ()
    );
`endif

`ifdef DEFINE_IS1_CH2  
    AD9238_drive   AD9238_LF(
        /*input            */    .i_clk                    (clk_64m              ),
        /*input            */    .i_adc_clk                (i_adc_clk            ),
        /*input            */    .i_rst                    (rst_125              ),
        /*input  [11:0]    */    .i_adc_data0              (i_adc2_data0         ),
        /*input  [11:0]    */    .i_adc_data1              (i_adc2_data1         ),
        /*output reg       */	.vld	                   (AD9238_CH2_vld       ),
        /*output reg [11:0]*/    .o_CHA                    (AD9238_CH2_CHA       ),
        /*output reg [11:0]*/    .o_CHB                    (AD9238_CH2_CHB       )   //VF
    );
    ADC_DATA_RAM	ADC2_DATA_RAM(                    
        /*input        */	.i_clk_64m				(clk_64m              ),
        /*input        */	.i_clk					(clk_50m              ),		
        /*input        */	.i_rstn					(~rst_125             ),
        /*input        */	.vld					(AD9238_CH2_vld       ),	
        /*input [15:0] */	.CHA					({AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA}),	
        /*input [15:0] */	.CHB					({AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB}),	
        /*input        */	.ADC_RAM_EN				(ADC_RAM_EN		      ),	//拉高1个周期
        /*input [11:0] */   .ADC_RAM_RD_ADDR		(ADC_RAM_RD_ADDR      ),
        /*output [31:0]*/   .ADC_RAM_RD_DATA		(ADC_RAM_RD_DATA2     )	
    );
    /////////
    FREQ_RTK_400K  FREQ_RTK_MEASURE_LF
    (
        /*input            */   .i_clk                     (clk_64m             ), //64M == 15.628ns;
        /*input            */   .i_rst                     (rst_125             ),
        /*input            */   .i_adc_vld                 (AD9238_CH2_vld      ), 
        /*input      [13:0]*/   .i_adc_data                ({AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB}  ), //input sensor LF;
        /*input      [15:0]*/   .i_threshold2on            (LF_threshold2on     ),
        /*input      [31:0]*/   .i_measure_period          (LF_measure_period   ),
        /*output reg [31:0]*/   .o_period_total            (LF_period_total     ),
        /*output reg [31:0]*/   .o_period_pos_cnt          (LF_period_cnt       ) //测量周期个数            
    );
    ///////////////
    daq9248 daq9248_adc2(
        /*input  wire       */    .i_clk_62p5             ( clk_64m             ),
        /*input  wire       */    .i_clk_250              ( clk_128m            ),
        /*input  wire       */    .i_rst_62p5             ( rst_125             ),
        /**/
        /*input  wire [31:0]*/    .i_adc0_mean            ( adc0_mean2          ),	//输入 入射mean
        /*input  wire [31:0]*/    .i_adc1_mean            ( adc1_mean2          ),	//输入 反射mean
        /*output reg        */    .o_sys_start            ( ch2_start_adc       ),
        /**/                                     
        /*input             */	.vld					  ( AD9238_CH2_vld      ),
        /*input  wire [13:0]*/    .i_ad9248_da            ( {AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB }  ),	//AD9643数据,入射
        /*input  wire [13:0]*/    .i_ad9248_db            ( {AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA }  ),//AD9643数据，反射
        /**/                                  
        /*output reg        */    .o_ad9248_da_vld        ( ad9238_da2_vld      ),
        /*output reg  [31:0]*/    .o_ad9248_da            ( ad9238_da2          ),//2个14bit补齐到32bit signed
        /*output reg        */    .o_ad9248_db_vld        ( ad9238_db2_vld      ),
        /*output reg  [31:0]*/    .o_ad9248_db            ( ad9238_db2          )  //2个14bit补齐到32bit signed
    );  
    adc_demod adc_demod_LF(
        /*input               */   .i_clk                     ( clk_128m               ),
        /*input               */   .i_rst                     ( rst_125                ),
        /*input   [15:0]      */   .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数
        /*input               */   .i_sys_start               ( ch2_start_bpf          ),	
        /*output              */   .o_sys_start               ( sys2_start_demod       ),
        /*input   [3:0]       */   .RF_FREQ				      ( RF_FREQ2			    ),
        /*input   [31:0]      */	//.freq_data				   ( freq_out2			    ),
            // adc bpf data                                     
        /*input               */    .i_adc0_vld                ( adc0_ch2_bpf_vld       ),
        /*input   [63:0]      */    .i_adc0_data               ( adc0_ch2_bpf_data      ),
        /*input               */    .i_adc1_vld                ( adc1_ch2_bpf_vld       ),
        /*input   [63:0]      */    .i_adc1_data               ( adc1_ch2_bpf_data      ),
                                    
            // adc lpf data           
        /*output              */     .o_adc0_demod_vld          ( adc0_ch2_demod_vld     ),  
        /*output  [63:0]      */     .o_adc0_demod_data         ( adc0_ch2_demod_data    ),  // {Vmi ,Vmq}												    
        /*output              */     .o_adc1_demod_vld          ( adc1_ch2_demod_vld     ),
        /*output [63:0]       */     .o_adc1_demod_data         ( adc1_ch2_demod_data    ),  // {Imi ,Imq}
        /*output reg     [13:0]*/	.r_demod_rd_addr		   ( demod_rd_addr2	        ),												    
        /*input   [31:0]       */    .i_demod_freq_coef         ( demod_freq_coef2       )
    );
    adc_lpf_400k adc_lpf_400k_LF(
        /*input          */     .i_clk_250                 ( clk_128m              ),
        /*input          */     .i_rst                     ( rst_125               ),
        /**/		     							      
        /*input          */     .i_sys_start               ( sys2_start_demod      ),
        /*output         */     .o_sys_start               ( sys2_start_lpf        ),
        /**/		  	  														   
        /*input          */     .i_adc0_demod_vld          ( adc0_ch2_demod_vld    ),
        /*input   [63:0] */     .i_adc0_demod_data         ( adc0_ch2_demod_data   ),						      
        /*input          */     .i_adc1_demod_vld          ( adc1_ch2_demod_vld    ),
        /*input   [63:0] */     .i_adc1_demod_data         ( adc1_ch2_demod_data   ),
        /**/																	   
        /*output         */     .o_adc0_lpf_vld            ( adc0_ch2_lpf_vld      ), //V
        /*output  [63:0] */     .o_adc0_lpf_data           ( adc0_ch2_lpf_data     ),						      
        /*output         */     .o_adc1_lpf_vld            ( adc1_ch2_lpf_vld      ), //I
        /*output  [63:0] */     .o_adc1_lpf_data           ( adc1_ch2_lpf_data     )
    ); 
    ///////////////
    Decor_Calib Decor_Calib_LF(
        /*input  */.i_clk                   ( clk_128m             ),
        /*input  */.i_rst                   ( rst_125              ),
        /* input */.i_sys_start             ( sys2_start_lpf       ),
        /* output*/.o_sys_start             ( sys2_start_calib     ),
        /* input */.i_calib_en              ( 1'b1                 ),
        /*output  [31:0] */// .o_adc0_mean             ( adc0_mean1           ),//从SPI发来
        /*output  [31:0] */// .o_adc1_mean             ( adc1_mean1           ),
        /* input         */.i_adc0_lpf_vld          ( adc0_ch2_lpf_vld     ), //V
        /* input   [63:0]*/.i_adc0_lpf_data         ( adc0_ch2_lpf_data    ),
        /* input         */.i_adc1_lpf_vld          ( adc1_ch2_lpf_vld     ), //I
        /* input   [63:0]*/.i_adc1_lpf_data         ( adc1_ch2_lpf_data    ),
                                                        
        /*output         */.o_adc0_calib_vld        ( adc0_ch2_calib_vld   ),  //V
        /*output  [63:0] */.o_adc0_calib_data       ( adc0_ch2_calib_data  ),	   
        /*output         */.o_adc1_calib_vld        ( adc1_ch2_calib_vld   ),	
        /*output  [63:0] */.o_adc1_calib_data       ( adc1_ch2_calib_data  ),	//I

        /*input [31:0]*/.m1a00					 ( m1a00_ch2		    ),
        /*input [31:0]*/.m1a01					 ( m1a01_ch2		    ),
        /*input [31:0]*/.m1a10					 ( m1a10_ch2		    ),
        /*input [31:0]*/.m1a11					 ( m1a11_ch2		    )
    );
    /************************HF power cailb**********************************/
    data_ext	data_ext_LF_vf(                            
        /*input 				*/.i_clk				 (clk_128m             ),
        /*input 				*/.clk_50m			     (clk_50m              ),//time domain cross
        /*input [63:0]		    */.i_data				 (adc0_ch2_calib_data  ),	
        /*input 				*/.i_valid			     (adc0_ch2_calib_vld   ), 
        /*input [13:0]		    */.r_demod_rd_addr	     (demod_rd_addr2       ),
        /*output reg [31:0]	    */.o_data_i			     (ch2_calib_vf_i       ), //V
        /*output reg [31:0]	    */.o_data_q			     (ch2_calib_vf_q       ),
        /*output reg 			*/.o_valid			     (calib_vf_vld2        )
    );                                                 
                                                    
    data_ext	data_ext_LF_vr(                              
        /*input 				*/.i_clk				 (clk_128m 		       ),
        /*input 				*/.clk_50m			     (clk_50m		       ),//time domain cross
        /*input [63:0]		    */.i_data				 (adc1_ch2_calib_data  ),	
        /*input 				*/.i_valid			     (adc1_ch2_calib_vld   ),  //I 
        /*input [13:0]		    */.r_demod_rd_addr	     (demod_rd_addr2       ),
        /*output reg [31:0]	    */.o_data_i			     (ch2_calib_vr_i       ),
        /*output reg [31:0]	    */.o_data_q			     (ch2_calib_vr_q       ),
        /*output reg 			*/.o_valid			     (calib_vr_vld2        )
    );                                                 
                                                    
    power_cal	power_LF_pf(    //INPUT SENSOR vf;          
         /*input 	    */.i_clk				 (clk_50m              ),	//125m 
         /*input 	    */.i_rstn				 (~rst_125		       ),
         /*input [31:0] */.data_i				 (ch2_calib_vf_i       ),	//16位定点数 
         /*input [23:0] */.data_q				 (ch2_calib_vf_q       ),
         /*output [15:0]*/.dout				     (VF_POWER2            )	//p = q^2 + i^2  
    );                                                 
                                                    
    power_cal	power_LF_pr(                                
         /*input 	    */.i_clk				 (clk_50m              ),	//125m 
         /*input 	    */.i_rstn				 (~rst_125             ),
         /*input [31:0] */.data_i				 (ch2_calib_vr_i       ),	//16位定点数
         /*input [23:0] */.data_q				 (ch2_calib_vr_q       ),
         /*output [15:0]*/.dout				     (VR_POWER2            )	//p = q^2 + i^2
    );   
    /*-------------> HF �? INPUT SENSOR 计算功率-------------------*/
    power_k_sel   power_k_sel_LF(
        .clk_i                 (clk_50m             ),
        .rst_i                 (rst_125             ),
                                                    
        /*input [31:0]*/.freq_in               (demod_freq_coef2    ),										 
        /*input 	  */.FREQ_CALIB_MODE       (FREQ2_CALIB_MODE    ),
        /*input [23:0]*/.ORIG_K	               (ORIG_K2             ),	
                        
        .POWER_CALIB_K0	       (POWER2_CALIB_K0	    ),
        .POWER_CALIB_K1	       (POWER2_CALIB_K1	    ),
        .POWER_CALIB_K2	       (POWER2_CALIB_K2	    ),
        .POWER_CALIB_K3	       (POWER2_CALIB_K3	    ),
        .POWER_CALIB_K4	       (POWER2_CALIB_K4	    ),
        .POWER_CALIB_K5	       (POWER2_CALIB_K5	    ),
        .POWER_CALIB_K6	       (POWER2_CALIB_K6	    ),
        .POWER_CALIB_K7	       (POWER2_CALIB_K7	    ),
        .POWER_CALIB_K8	       (POWER2_CALIB_K8	    ),
        .POWER_CALIB_K9	       (POWER2_CALIB_K9	    ),
        .POWER_CALIB_K10	   (POWER2_CALIB_K10    ),      
        .POWER_CALIB_K11	   (POWER2_CALIB_K11    ),      
        .POWER_CALIB_K12	   (POWER2_CALIB_K12    ),      
        .POWER_CALIB_K13	   (POWER2_CALIB_K13    ),      
        .POWER_CALIB_K14	   (POWER2_CALIB_K14    ),      
        .POWER_CALIB_K15	   (POWER2_CALIB_K15    ),      
        .POWER_CALIB_K16	   (POWER2_CALIB_K16    ),      
        .POWER_CALIB_K17	   (POWER2_CALIB_K17    ),      
        .POWER_CALIB_K18	   (POWER2_CALIB_K18    ),      
        .POWER_CALIB_K19	   (POWER2_CALIB_K19    ),      
        .POWER_CALIB_K20	   (POWER2_CALIB_K20    ),      
        .POWER_CALIB_K21	   (POWER2_CALIB_K21    ),      
        .POWER_CALIB_K22	   (POWER2_CALIB_K22    ),      
        .POWER_CALIB_K23	   (POWER2_CALIB_K23    ),      
        .POWER_CALIB_K24	   (POWER2_CALIB_K24    ),      
        .POWER_CALIB_K25	   (POWER2_CALIB_K25    ),      
        .POWER_CALIB_K26	   (POWER2_CALIB_K26    ),      
        .POWER_CALIB_K27	   (POWER2_CALIB_K27    ),      
        .POWER_CALIB_K28	   (POWER2_CALIB_K28    ),      
        .POWER_CALIB_K29	   (POWER2_CALIB_K29    ),      

        .FREQ_THR0             (FREQ2_THR0          ),		
        .FREQ_THR1             (FREQ2_THR1          ),		
        .FREQ_THR2             (FREQ2_THR2          ),		
        .FREQ_THR3             (FREQ2_THR3          ),		
        .FREQ_THR4             (FREQ2_THR4          ),		
        .FREQ_THR5             (FREQ2_THR5          ),		
        .FREQ_THR6             (FREQ2_THR6          ),		
        .FREQ_THR7             (FREQ2_THR7          ),		
        .FREQ_THR8             (FREQ2_THR8          ),		
        .FREQ_THR9             (FREQ2_THR9          ),		
        .FREQ_THR10            (FREQ2_THR10         ),		
        .FREQ_THR11            (FREQ2_THR11         ),		
        .FREQ_THR12            (FREQ2_THR12         ),		
        .FREQ_THR13            (FREQ2_THR13         ),		
        .FREQ_THR14            (FREQ2_THR14         ),		
        .FREQ_THR15            (FREQ2_THR15         ),		
        .FREQ_THR16            (FREQ2_THR16         ),		
        .FREQ_THR17            (FREQ2_THR17         ),		
        .FREQ_THR18            (FREQ2_THR18         ),		
        .FREQ_THR19            (FREQ2_THR19         ),		
        .FREQ_THR20            (FREQ2_THR20         ),		
        .FREQ_THR21            (FREQ2_THR21         ),		
        .FREQ_THR22            (FREQ2_THR22         ),		
        .FREQ_THR23            (FREQ2_THR23         ),		
        .FREQ_THR24            (FREQ2_THR24         ),		
        .FREQ_THR25            (FREQ2_THR25         ),		
        .FREQ_THR26            (FREQ2_THR26         ),		
        .FREQ_THR27            (FREQ2_THR27         ),		
        .FREQ_THR28            (FREQ2_THR28         ),		
        .FREQ_THR29            (FREQ2_THR29         ),		
        .FREQ_THR30            (FREQ2_THR30         ),		
                                                    
        .K_THR0 			   (K2_THR0 		     ),
        .K_THR1 			   (K2_THR1 		     ),
        .K_THR2 			   (K2_THR2 		     ),
        .K_THR3 			   (K2_THR3 		     ),
        .K_THR4 			   (K2_THR4 		     ),
        .K_THR5 			   (K2_THR5 		     ),
        .K_THR6 			   (K2_THR6 		     ),
        .K_THR7 			   (K2_THR7 		     ),
        .K_THR8 			   (K2_THR8 		     ),
        .K_THR9 			   (K2_THR9 		     ),
        .K_THR10			   (K2_THR10		     ),
        .K_THR11			   (K2_THR11		     ),
        .K_THR12			   (K2_THR12		     ),
        .K_THR13			   (K2_THR13		     ),
        .K_THR14			   (K2_THR14		     ),
        .K_THR15			   (K2_THR15		     ),
        .K_THR16			   (K2_THR16		     ),
        .K_THR17			   (K2_THR17		     ),
        .K_THR18			   (K2_THR18		     ),
        .K_THR19			   (K2_THR19		     ),
        .K_THR20			   (K2_THR20		     ),
        .K_THR21			   (K2_THR21		     ),
        .K_THR22			   (K2_THR22		     ),
        .K_THR23			   (K2_THR23		     ),
        .K_THR24			   (K2_THR24		     ),
        .K_THR25			   (K2_THR25		     ),
        .K_THR26			   (K2_THR26		     ),
        .K_THR27			   (K2_THR27		     ),
        .K_THR28			   (K2_THR28		     ),
        .K_THR29			   (K2_THR29		     ),
                            
        .K_out                (AUTO_POWER_CALIB_K2  )	
    );

    power_calib	calib_pf_k(                      
        /*input 	   */.i_clk				    (clk_50m             ),
        /*input 	   */.i_rst				    (rst_125             ),
        /*input [31:0] */.power_in			    (VF_POWER2           ),
        /*input [23:0] */.POWER_CALIB_K		    (AUTO_POWER_CALIB_K2 ),	
        /*output [15:0]*/.dout				    (VF_POWER_CALIB_K2   )	 //16bit
    );                         
                            
    power_calib	calib_pr_k(                         
        /*input 	   */.i_clk				    (clk_50m             ),
        /*input 	   */.i_rst				    (rst_125             ),
        /*input [31:0] */.power_in			    (VR_POWER2           ),
        /*input [23:0] */.POWER_CALIB_K		    (AUTO_POWER_CALIB_K2 ),	
        /*output [15:0]*/.dout				    (VR_POWER_CALIB_K2   )	 //16bit
    );  

    //用于 edge_detect ;Input sensor 功率波形拟合�?
    AVG_FIFO_32	AVG32_pf_k(                         
        /*input            */.clk_i			       (clk_50m             ),
        /*input            */.rst_i			       (rst_125             ),
        /*input [31:0]     */.data_in		       (VF_POWER_CALIB_K2   ),
        /*input            */.den_in			       (calib_vf_vld2       ),
        /*output reg [31:0]*/.data_out		       (VF_POWER2_K_AVG     ),
        /*output reg       */.den_out		       ()
    );
    /*-------------> lF INPUT SENSOR 计算阻抗业务   -------------------*/
    refl_cal_16bit	refl_cal_16bit_LF(
        /*input            */	.i_clk				 (clk_50m               ),	//125m 
        /**/	           	
        /*input [15:0]     */	.vr_i				 (ch2_calib_vr_i[31:16] ),	//A 
        /*input [15:0]     */	.vr_q				 (ch2_calib_vr_q[31:16] ),	//B
        /*input [15:0]     */	.vf_i				 (ch2_calib_vf_i[31:16] ),	//C
        /*input [15:0]     */	.vf_q				 (ch2_calib_vf_q[31:16] ),	//D
        /*output reg [31:0]*/	.refl_i				 (ch2_refl_i            ),
        /*output reg [31:0]*/	.refl_q				 (ch2_refl_q	        )
    );	//反射/入射   
                                
    r_jx	r_jx_LF(            
        /*input            */.i_clk				(clk_50m              ),	//125m 
        /*input [31:0]     */.refl_i		    (ch2_refl_i           ),	//31位定点数
        /*input [31:0]     */.refl_q		    (ch2_refl_q           ),	//31位定点数
                                                
        /*output reg [31:0]*/.r_jx_i		    (ch2_r_jx_i           ),	//31位定点数
        /*output reg [31:0]*/.r_jx_q		    (ch2_r_jx_q           )    //15位定点数
    );	//R+jX = Z0*(1+r)/(1-r) , Z0 = 50

    //校准阻抗
    r_jx_calib	r_jx_calib_LF(		//射频�?启后才输出R+JX
        /*input            */.clk_i				 (clk_50m             ),	
        /*input            */.rst_i				 (rst_125             ),
        /*input            */.RF_ON_FPGA		 (0),//(RF_ON_FPGA    ,	//0开1关 
        /*input            */.bias_on			 (0),//(bias_on),        //0开1关 
        /*input      [31:0]*/.R_IN				 (ch2_r_jx_i          ),	
        /*input      [31:0]*/.JX_IN				 (ch2_r_jx_q          ),	
        /*input      [31:0]*/.K1			     (CALIB_R2            ),//给0，没影响的参数
        /*input      [31:0]*/.K2			     (),                  	

        /*output reg [31:0]*/.R_OUT				 (R_DOUT2             ),	//15位定点数
        /*output reg [31:0]*/.JX_OUT			 (JX_DOUT2            )
    );	//Z = (a + j(50k+b)) / ((50-bk) + jak)  

    //HF--INPUT SENSOR;					    
    average_signed	R0_AVG256_LF(                       
        /*input            */.clk_i			     (clk_50m             ),
        /*input            */.rst_i			     (rst_125             ),
        /*input [31:0]     */.din			     (R_DOUT2             ),
        /*input            */.en_in			     (1                   ),
        /*output reg [31:0]*/.dout			     (INPUT_SENSOR1_R_AVG ),
        /*output reg       */.en_out			     ()                 
    );

    average_signed	JX0_AVG256_LF(
        .clk_i			     (clk_50m             ),
        .rst_i			     (rst_125             ),
        .din			     (JX_DOUT2            ),
        .en_in			     (1                   ),
        .dout			     (INPUT_SENSOR1_JX_AVG),
        .en_out			     ()
    );
`endif

`ifdef DEFINE_OS2_CH4    
    //The second pc;adc;Near dut;
    AD9238_drive   AD9238_OS2(
        /*input            */    .i_clk                  (clk_64m               ),
        /*input            */    .i_adc_clk              (i_adc_clk             ),
        /*input            */    .i_rst                  (rst_125               ),
        /*input  [11:0]    */    .i_adc_data0            (i_adc4_data0          ),
        /*input  [11:0]    */    .i_adc_data1            (i_adc4_data1          ),
        /*output reg       */    .vld	                 (AD9238_CH4_vld        ),
        /*output reg [11:0]*/    .o_CHA                  (AD9238_CH4_CHA        ),
        /*output reg [11:0]*/    .o_CHB                  (AD9238_CH4_CHB        )  //VF
    );
    ////////
    daq9248 daq9248_adc4(                                     //13.56M
        /*input  wire       */   .i_clk_62p5             ( clk_64m             ),
        /*input  wire       */   .i_clk_250              ( clk_128m            ),
        /*input  wire       */   .i_rst_62p5             ( rst_125             ),
        /**/
        /*input  wire [31:0]*/   .i_adc0_mean            ( adc0_mean4          ),	//输入 入射mean
        /*input  wire [31:0]*/   .i_adc1_mean            ( adc1_mean4          ),	//输入 反射mean
        /*output reg        */   .o_sys_start            ( ch4_start_adc       ),
        /**/                                                      
        /*input             */	.vld					( AD9238_CH4_vld      ),
        /*input  wire [13:0]*/   .i_ad9248_da            ( {AD9238_CH4_CHB[11],AD9238_CH4_CHB[11],AD9238_CH4_CHB }    ),	//AD9643数据,入射
        /*input  wire [13:0]*/   .i_ad9248_db            ( {AD9238_CH4_CHA[11],AD9238_CH4_CHA[11],AD9238_CH4_CHA }    ), //AD9643数据,反射
        /**/                                                        
        /*output reg        */   .o_ad9248_da_vld        ( ad9238_da4_vld      ),
        /*output reg  [31:0]*/   .o_ad9248_da            ( ad9238_da4          ), //2个14bit补齐到32bit signed
        /*output reg        */   .o_ad9248_db_vld        ( ad9238_db4_vld      ),
        /*output reg  [31:0]*/   .o_ad9248_db            ( ad9238_db4          )  //2个14bit补齐到32bit signed
    );    
    daq9248 daq9248_adc4_400k(
        /*input  wire       */   .i_clk_62p5             ( clk_64m             ),
        /*input  wire       */   .i_clk_250              ( clk_128m            ),
        /*input  wire       */   .i_rst_62p5             ( rst_125             ),
        /**/
        /*input  wire [31:0]*/   .i_adc0_mean            ( adc0_mean4_400k     ),	//输入 入射mean
        /*input  wire [31:0]*/   .i_adc1_mean            ( adc1_mean4_400k     ),	//输入 反射mean
        /*output reg        */   .o_sys_start            ( ch4_start_adc_400k  ),
        /**/                                                      
        /*input             */	.vld					( AD9238_CH4_vld      ),
        /*input  wire [13:0]*/   .i_ad9248_da            ( {AD9238_CH4_CHB[11],AD9238_CH4_CHB[11],AD9238_CH4_CHB }    ),	//AD9643数据,入射
        /*input  wire [13:0]*/   .i_ad9248_db            ( {AD9238_CH4_CHA[11],AD9238_CH4_CHA[11],AD9238_CH4_CHA }    ), //AD9643数据,反射
        /**/                                                        
        /*output reg        */   .o_ad9248_da_vld        ( ad9238_400k_da4_vld      ),
        /*output reg  [31:0]*/   .o_ad9248_da            ( ad9238_400k_da4          ), //2个14bit补齐到32bit signed�?
        /*output reg        */   .o_ad9248_db_vld        ( ad9238_400k_db4_vld      ),
        /*output reg  [31:0]*/   .o_ad9248_db            ( ad9238_400k_db4          )  //2个14bit补齐到32bit signed
    );
    ////////
    adc_demod adc_demod_OS2(
        /*input               */    .i_clk                     ( clk_128m               ),
        /*input               */    .i_rst                     ( rst_125                ),
        /*input   [15:0]      */    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数
        /*input               */    .i_sys_start               ( ch4_start_bpf          ),	
        /*output              */    .o_sys_start               ( sys4_start_demod       ),
        /*input   [3:0]       */    //.RF_FREQ				   ( RF_FREQ4			    ),
        /*input   [31:0]      */	//.freq_data				   ( freq_out4			    ),
            // adc bpf data                                     
        /*input               */   .i_adc0_vld                ( adc0_ch4_bpf_vld       ),
        /*input   [63:0]      */   .i_adc0_data               ( adc0_ch4_bpf_data      ),
        /*input               */   .i_adc1_vld                ( adc1_ch4_bpf_vld       ),
        /*input   [63:0]      */   .i_adc1_data               ( adc1_ch4_bpf_data      ),
                                                                
            // adc lpf data                                     
        /*output              */      .o_adc0_demod_vld          ( adc0_ch4_demod_vld     ),  
        /*output  [63:0]      */      .o_adc0_demod_data         ( adc0_ch4_demod_data    ),  // {Vmi ,Vmq}				      
        /*output              */      .o_adc1_demod_vld          ( adc1_ch4_demod_vld     ),
        /*output [63:0]       */      .o_adc1_demod_data         ( adc1_ch4_demod_data    ),  // {Imi ,Imq}
        /*output reg     [13:0]*/	.r_demod_rd_addr		     ( demod_rd_addr4	      ),
        /*input   [31:0]       */     .i_demod_freq_coef         ( demod_freq_coef0       )  //使用高频的值解调
    );
    adc_demod adc_demod_400k_OS2(
        /*input               */    .i_clk                     ( clk_128m               ),
        /*input               */    .i_rst                     ( rst_125                ),
        /*input   [15:0]      */    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数
        /*input               */    .i_sys_start               ( ch4_start_bpf_400k     ),	
        /*output              */    .o_sys_start               ( sys4_start_400k_demod  ),
        /*input   [3:0]       */    //.RF_FREQ				   ( RF_FREQ4			    ),
        /*input   [31:0]      */	//.freq_data				   ( freq_out4			    ),
            // adc bpf data                                     
        /*input               */   .i_adc0_vld                ( adc0_ch4_bpf_400k_vld  ),
        /*input   [63:0]      */   .i_adc0_data               ( adc0_ch4_bpf_400k_data ),
        /*input               */   .i_adc1_vld                ( adc1_ch4_bpf_400k_vld  ),
        /*input   [63:0]      */   .i_adc1_data               ( adc1_ch4_bpf_400k_data ),
                                                                
            // adc lpf data                                     
        /*output              */      .o_adc0_demod_vld          ( adc0_ch4_demod_400k_vld ),  
        /*output  [63:0]      */      .o_adc0_demod_data         ( adc0_ch4_demod_400k_data),  // {Vmi ,Vmq}				      
        /*output              */      .o_adc1_demod_vld          ( adc1_ch4_demod_400k_vld ),
        /*output [63:0]       */      .o_adc1_demod_data         ( adc1_ch4_demod_400k_data),  // {Imi ,Imq}
        /*output reg     [13:0]*/	  .r_demod_rd_addr		     ( demod_rd_400k_addr4  	),
        /*input   [31:0]       */     .i_demod_freq_coef         ( demod_freq_coef2         )  //使用低频的值解调
    );
    ////////
    adc_lpf adc_lpf_OS2(                                            //13.56m
        /*input          */     .i_clk_250                 ( clk_128m                 ),
        /*input          */     .i_rst                     ( rst_125                  ),
        		     														     
        /*input          */     .i_sys_start               ( sys4_start_demod         ),
        /*output         */     .o_sys_start               ( sys4_start_lpf           ),
        		  	  														     
        /*input          */     .i_adc0_demod_vld          ( adc0_ch4_demod_vld       ),
        /*input   [63:0] */     .i_adc0_demod_data         ( adc0_ch4_demod_data      ),						      
        /*input          */     .i_adc1_demod_vld          ( adc1_ch4_demod_vld       ),
        /*input   [63:0] */     .i_adc1_demod_data         ( adc1_ch4_demod_data      ),
        																	     
        /*output         */     .o_adc0_lpf_vld            ( adc0_ch4_lpf_vld         ), //V
        /*output  [63:0] */     .o_adc0_lpf_data           ( adc0_ch4_lpf_data        ),						      
        /*output         */     .o_adc1_lpf_vld            ( adc1_ch4_lpf_vld         ), //I
        /*output  [63:0] */     .o_adc1_lpf_data           ( adc1_ch4_lpf_data        )
    );
    adc_lpf_400k adc_lpf_400k_OS2(                                            //13.56m
        /*input          */     .i_clk_250                 ( clk_128m                 ),
        /*input          */     .i_rst                     ( rst_125                  ),
        /**/		     							      
        /*input          */     .i_sys_start               ( sys4_start_400k_demod    ),
        /*output         */     .o_sys_start               ( sys4_start_400k_lpf      ),
        /**/		  	  		        
        /*input          */     .i_adc0_demod_vld          ( adc0_ch4_demod_400k_vld  ),
        /*input   [63:0] */     .i_adc0_demod_data         ( adc0_ch4_demod_400k_data ),						      
        /*input          */     .i_adc1_demod_vld          ( adc1_ch4_demod_400k_vld  ),
        /*input   [63:0] */     .i_adc1_demod_data         ( adc1_ch4_demod_400k_data ),
        /**/										              
        /*output         */     .o_adc0_lpf_vld            ( adc0_ch4_lpf_400k_vld    ), //V
        /*output  [63:0] */     .o_adc0_lpf_data           ( adc0_ch4_lpf_400k_data   ),						      
        /*output         */     .o_adc1_lpf_vld            ( adc1_ch4_lpf_400k_vld    ), //I
        /*output  [63:0] */     .o_adc1_lpf_data           ( adc1_ch4_lpf_400k_data   )
    );
    ////////
    data_ext	OS2_data_ext_Vm(                          
        /*input 			*/	.i_clk				        (clk_128m              ),
        /*input 			*/	.clk_50m			        (clk_50m               ),
        /*input [63:0]		*/	.i_data				        (adc0_ch4_lpf_data     ),	//V
        /*input 			*/	.i_valid			        (adc0_ch4_lpf_vld      ), 
        /*input [13:0]		*/	.r_demod_rd_addr	        (demod_rd_addr4        ),
        /*output reg [31:0]	*/	.o_data_i			        (SENSOR4_ADC0_I        ),
        /*output reg [31:0]	*/	.o_data_q			        (SENSOR4_ADC0_Q        ),
        /*output reg 		*/	.o_valid			        (OS2_demod_vld0        )
    );   
    data_ext	OS2_data_ext_Im(
        /*input 			*/	.i_clk				        (clk_128m 		       ),
        /*input 			*/	.clk_50m			        (clk_50m		       ),
        /*input [63:0]		*/	.i_data				        (adc1_ch4_lpf_data     ),	//I
        /*input 			*/	.i_valid			        (adc1_ch4_lpf_vld      ),   
        /*input [13:0]		*/	.r_demod_rd_addr	        (demod_rd_addr4        ),
        /*output reg [31:0]	*/	.o_data_i			        (SENSOR4_ADC1_I        ),
        /*output reg [31:0]	*/	.o_data_q			        (SENSOR4_ADC1_Q        ),
        /*output reg 		*/	.o_valid			        (OS2_demod_vld1        )
    ); 
    data_ext	OS2_400k_data_ext_Vm(                          
        /*input 			*/	.i_clk				        (clk_128m              ),
        /*input 			*/	.clk_50m			        (clk_50m               ),
        /*input [63:0]		*/	.i_data				        (adc0_ch4_lpf_400k_data),	//V
        /*input 			*/	.i_valid			        (adc0_ch4_lpf_400k_vld ), 
        /*input [13:0]		*/	.r_demod_rd_addr	        (demod_rd_400k_addr4   ),
        /*output reg [31:0]	*/	.o_data_i			        (SENSOR4_ADC0_400K_I   ),
        /*output reg [31:0]	*/	.o_data_q			        (SENSOR4_ADC0_400K_Q   ),
        /*output reg 		*/	.o_valid			        (OS2_demod_400k_vld0   )
    );   
    data_ext	OS2_400k_data_ext_Im(
        /*input 			*/	.i_clk				        (clk_128m 		       ),
        /*input 			*/	.clk_50m			        (clk_50m		       ),
        /*input [63:0]		*/	.i_data				        (adc1_ch4_lpf_400k_data),	//I
        /*input 			*/	.i_valid			        (adc1_ch4_lpf_400k_vld ),   
        /*input [13:0]		*/	.r_demod_rd_addr	        (demod_rd_400k_addr4   ),
        /*output reg [31:0]	*/	.o_data_i			        (SENSOR4_ADC1_400K_I   ),
        /*output reg [31:0]	*/	.o_data_q			        (SENSOR4_ADC1_400K_Q   ),
        /*output reg 		*/	.o_valid			        (OS2_demod_400k_vld1   )
    ); 

    //复用在power稳定时�?�的iq 为有效�?�；提取出来；此时时钟域�?50M�?
    always@(clk_50m)begin
        if(OS2_demod_vld0)begin
            r_SENSOR4_ADC0_I <= SENSOR4_ADC0_I ;		
            r_SENSOR4_ADC0_Q <= SENSOR4_ADC0_Q ;		
        end
    end

    always@(clk_50m)begin
        if(OS2_demod_vld1)begin
            r_SENSOR4_ADC1_I <= SENSOR4_ADC1_I ;	
            r_SENSOR4_ADC1_Q <= SENSOR4_ADC1_Q ;		
        end
    end


    always@(clk_50m)begin
        if(OS2_demod_400k_vld0)begin
            r_SENSOR4_ADC0_400K_I <= SENSOR4_ADC0_400K_I ;		
            r_SENSOR4_ADC0_400K_Q <= SENSOR4_ADC0_400K_Q ;		
        end
    end

    always@(clk_50m)begin
        if(OS2_demod_400k_vld1)begin
            r_SENSOR4_ADC1_400K_I <= SENSOR4_ADC1_400K_I ;	
            r_SENSOR4_ADC1_400K_Q <= SENSOR4_ADC1_400K_Q ;	
            
        end
    end
    // syn i && q; lock ; 
    always@(clk_50m)begin
        if(r_decor_pulse_pos) begin   
            r2_SENSOR4_ADC0_I <= r_SENSOR4_ADC0_I ;
            r2_SENSOR4_ADC0_Q <= r_SENSOR4_ADC0_Q ;
            r2_SENSOR4_ADC1_I <= r_SENSOR4_ADC1_I ;		
            r2_SENSOR4_ADC1_Q <= r_SENSOR4_ADC1_Q ;

            r2_SENSOR4_ADC0_400K_I <= r_SENSOR4_ADC0_400K_I ;
            r2_SENSOR4_ADC0_400K_Q <= r_SENSOR4_ADC0_400K_Q ;
            r2_SENSOR4_ADC1_400K_I <= r_SENSOR4_ADC1_400K_I ;		
            r2_SENSOR4_ADC1_400K_Q <= r_SENSOR4_ADC1_400K_Q ;		
            
        end
        else begin
            r2_SENSOR4_ADC0_I <= r2_SENSOR4_ADC0_I ;	
            r2_SENSOR4_ADC0_Q <= r2_SENSOR4_ADC0_Q ;
            r2_SENSOR4_ADC1_I <= r2_SENSOR4_ADC1_I ;		
            r2_SENSOR4_ADC1_Q <= r2_SENSOR4_ADC1_Q ;	
            
            r2_SENSOR4_ADC0_400K_I <= r2_SENSOR4_ADC0_400K_I ;
            r2_SENSOR4_ADC0_400K_Q <= r2_SENSOR4_ADC0_400K_Q ;
            r2_SENSOR4_ADC1_400K_I <= r2_SENSOR4_ADC1_400K_I ;		
            r2_SENSOR4_ADC1_400K_Q <= r2_SENSOR4_ADC1_400K_Q ;				 
        end
    end 

    Decor_matrix  Decor_matrix_OS2(
        /*input               */ .i_clk                ( clk_128m               ),
        /*input               */ .i_rst                ( rst_125                ),	
                        
        /*input               */ .i_adc0_lpf_vld       (adc0_ch4_lpf_vld        ), //ADC0---V
        /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch4_lpf_data       ),
        /*input               */ .i_adc1_lpf_vld       (adc1_ch4_lpf_vld        ), //ADC1---I
        /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch4_lpf_data       ),

        /*input [31:0] 	    */   .m1a00				   (m1a00_ch4               ), //a
        /*input [31:0] 	    */   .m1a01				   (m1a01_ch4               ), //b
        /*input [31:0] 	    */   .m1a10				   (m1a10_ch4               ), //c
        /*input [31:0] 	    */   .m1a11				   (m1a11_ch4               ), //d

        /*output              */ .o_adc0_calib_vld     (OS2_V_calib_vld         ),   //Vt;
        /*output  [99:0]      */ .o_adc0_calib_data    (OS2_V_calib_data        ),
        /*output              */ .o_adc1_calib_vld     (OS2_I_calib_vld         ),   //It;
        /*output  [99:0]      */ .o_adc1_calib_data    (OS2_I_calib_data        )
    );   

    Decor_matrix  Decor_matrix_400k_OS2(
        /*input               */ .i_clk                ( clk_128m               ),
        /*input               */ .i_rst                ( rst_125                ),	
                        
        /*input               */ .i_adc0_lpf_vld       (adc0_ch4_lpf_400k_vld   ), //ADC0---V
        /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch4_lpf_400k_data  ),
        /*input               */ .i_adc1_lpf_vld       (adc1_ch4_lpf_400k_vld   ), //ADC1---I
        /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch4_lpf_400k_data  ),

        /*input [31:0] 	    */   .m1a00				   (m1a00_ch4_400k          ), //a
        /*input [31:0] 	    */   .m1a01				   (m1a01_ch4_400k          ), //b
        /*input [31:0] 	    */   .m1a10				   (m1a10_ch4_400k          ), //c
        /*input [31:0] 	    */   .m1a11				   (m1a11_ch4_400k          ), //d

        /*output              */ .o_adc0_calib_vld     (OS2_V_calib_400k_vld   ),   //Vt;
        /*output  [99:0]      */ .o_adc0_calib_data    (OS2_V_calib_400k_data  ),
        /*output              */ .o_adc1_calib_vld     (OS2_I_calib_400k_vld   ),   //It;
        /*output  [99:0]      */ .o_adc1_calib_data    (OS2_I_calib_400k_data  )
    );   

    //Vm经过decor出来�?? adc_calib_data 是经过单独特定的decor cali 通过IQ滤波�??
    data_ext	data_ext2_Vt(                                         
        /*input 			*/	.i_clk				     (clk_128m                 ),
        /*input 			*/	.clk_50m			     (clk_50m                  ),//time domain cross
        /*input [63:0]		*/	.i_data				     (OS2_V_calib_data         ),	//100bit
        /*input 			*/	.i_valid			     (OS2_V_calib_vld          ), 
        /*input [13:0]		*/	.r_demod_rd_addr	     (demod_rd_addr4           ),
        /*output reg [31:0]	*/	.o_data_i			     (OS2_calib_V_i            ), //V  50b
        /*output reg [31:0]	*/	.o_data_q			     (OS2_calib_V_q            ),
        /*output reg 		*/	.o_valid			     (OS2_calib_V_vld          )
    );   
    
    data_ext	data_ext2_It(                           
        /*input 			*/	.i_clk				     (clk_128m 		           ),
        /*input 			*/	.clk_50m			     (clk_50m		           ),//time domain cross
        /*input [63:0]		*/	.i_data				     (OS2_I_calib_data         ),	
        /*input 			*/	.i_valid			     (OS2_I_calib_vld          ),  //I 
        /*input [13:0]		*/	.r_demod_rd_addr	     (demod_rd_addr4           ),
        /*output reg [31:0]	*/	.o_data_i			     (OS2_calib_I_i            ),
        /*output reg [31:0]	*/	.o_data_q			     (OS2_calib_I_q            ),
        /*output reg 		*/	.o_valid			     (OS2_calib_I_vld          )
    );
        
    data_ext	data_ext2_400k_Vt(                                         
        /*input 			*/	.i_clk				     (clk_128m                 ),
        /*input 			*/	.clk_50m			     (clk_50m                  ),//time domain cross
        /*input [63:0]		*/	.i_data				     (OS2_V_calib_400k_data    ),	//100bit
        /*input 			*/	.i_valid			     (OS2_V_calib_400k_vld     ), 
        /*input [13:0]		*/	.r_demod_rd_addr	     (demod_rd_400k_addr4      ),
        /*output reg [31:0]	*/	.o_data_i			     (OS2_calib_V_400k_i       ), //V  50b
        /*output reg [31:0]	*/	.o_data_q			     (OS2_calib_V_400k_q       ),
        /*output reg 		*/	.o_valid			     (OS2_calib_V_400k_vld     )
    );   
    
    data_ext	data_ext2_400k_It(                           
        /*input 			*/	.i_clk				     (clk_128m 		           ),
        /*input 			*/	.clk_50m			     (clk_50m		           ),//time domain cross
        /*input [63:0]		*/	.i_data				     (OS2_I_calib_400k_data    ),	
        /*input 			*/	.i_valid			     (OS2_I_calib_400k_vld     ),  //I 
        /*input [13:0]		*/	.r_demod_rd_addr	     (demod_rd_400k_addr4      ),
        /*output reg [31:0]	*/	.o_data_i			     (OS2_calib_I_400k_i       ),
        /*output reg [31:0]	*/	.o_data_q			     (OS2_calib_I_400k_q       ),
        /*output reg 		*/	.o_valid			     (OS2_calib_I_400k_vld     )
    );
    /*----------------------Output sensor0 计算阻抗-----------------------*/
    //求分流出的sensor2 的i q 		  V（I + Qj�? / I（I + Qj�? ; Vt/It;
    complex_div	   DIV_OS2(                          //V/I
        /*input 		   */	.i_clk				     (clk_50m            ),	//125m 
        /*input 		   */	.i_rstn				     (rst_125            ),
        /*input [31:0]	   */	.vr_i				     (OS2_calib_V_i      ),	//V
        /*input [31:0]	   */	.vr_q				     (OS2_calib_V_q      ),	//V
        /*input [31:0]	   */	.vf_i				     (OS2_calib_I_i      ),	//I
        /*input [31:0]	   */	.vf_q				     (OS2_calib_I_q      ),	//I
        /*output reg [31:0]*/	.R				         (OS2_R              ),
        /*output reg [31:0]*/	.JX				         (OS2_JX             )
    );	//反射/入射   

    complex_div	   DIV_400K_OS2(                          //V/I
        /*input 		   */	.i_clk				     (clk_50m            ),	//125m 
        /*input 		   */	.i_rstn				     (rst_125            ),
        /*input [31:0]	   */	.vr_i				     (OS2_calib_V_400k_i ),	//V
        /*input [31:0]	   */	.vr_q				     (OS2_calib_V_400k_q ),	//V
        /*input [31:0]	   */	.vf_i				     (OS2_calib_I_400k_i ),	//I
        /*input [31:0]	   */	.vf_q				     (OS2_calib_I_400k_q ),	//I
        /*output reg [31:0]*/	.R				         (OS2_400K_R         ),
        /*output reg [31:0]*/	.JX				         (OS2_400K_JX        )
    );	//反射/入射  

    average_signed	R1_AVG256_OS2(                       
        /*input            */	.clk_i			        (clk_50m             ),
        /*input            */	.rst_i			        (rst_125             ),
        /*input [31:0]     */	.din			        (OS2_R               ),
        /*input            */	.en_in			        (1                   ),
        /*output reg [31:0]*/	.dout			        (OUPUT_SENSOR2_R_AVG ),
        /*output reg       */	.en_out			        ()                 
    );

    average_signed	JX1_AVG256_OS2(
        /*input            */	.clk_i			        (clk_50m             ),
        /*input            */	.rst_i			        (rst_125             ),
        /*input [31:0]     */	.din			        (OS2_JX              ),
        /*input            */	.en_in			        (1                   ),
        /*output reg [31:0]*/	.dout			        (OUPUT_SENSOR2_JX_AVG),
        /*output reg       */	.en_out			        ()
    );
    
    average_signed	R1_AVG256_400K_OS2(                       
        /*input            */	.clk_i			        (clk_50m             ),
        /*input            */	.rst_i			        (rst_125             ),
        /*input [31:0]     */	.din			        (OS2_400K_R          ),
        /*input            */	.en_in			        (1                   ),
        /*output reg [31:0]*/	.dout			        (OUPUT_SENSOR2_400K_R_AVG ),
        /*output reg       */	.en_out			        ()                 
    );

    average_signed	JX1_AVG256_400K_OS2(
        /*input            */	.clk_i			        (clk_50m             ),
        /*input            */	.rst_i			        (rst_125             ),
        /*input [31:0]     */	.din			        (OS2_400K_JX         ),
        /*input            */	.en_in			        (1                   ),
        /*output reg [31:0]*/	.dout			        (OUPUT_SENSOR2_400K_JX_AVG),
        /*output reg       */	.en_out			        ()
    );  
    
    /*----------------------Output sensor0 电压电流 功率-----------------------*/
    power_cal	mod_Vt_OS2(                         
        /*input        */	.i_clk				     (clk_50m            ),	//125m 
        /*input        */	.i_rstn				     (~rst_125		     ),
        /*input [31:0] */	.data_i				     (OS2_calib_V_i      ),	//16位定点数
        /*input [31:0] */	.data_q				     (OS2_calib_V_q      ),
        /*output [31:0]*/	.dout				     (OS2_V              )	//p = q^2 + i^2
    );                                               
                                                    
    power_cal	mod_It_OS2(                              
        /*input        */	.i_clk				     (clk_50m            ),	//125m 
        /*input        */	.i_rstn				     (~rst_125		     ),
        /*input [31:0] */	.data_i				     (OS2_calib_I_i      ),	//16位定点数
        /*input [31:0] */	.data_q				     (OS2_calib_I_q      ),
        /*output [31:0]*/	.dout				     (OS2_I              )	//p = q^2 + i^2
    );   


    power_cal	mod_Vt_400k_OS2(                         
        /*input        */	.i_clk				     (clk_50m            ),	//125m 
        /*input        */	.i_rstn				     (~rst_125		     ),
        /*input [31:0] */	.data_i				     (OS2_calib_V_400k_i ),	//16位定点数
        /*input [31:0] */	.data_q				     (OS2_calib_V_400k_q ),
        /*output [31:0]*/	.dout				     (OS2_400K_V         )	//p = q^2 + i^2
    );                                               
                                                    
    power_cal	mod_It_400k_OS2(                              
        /*input        */	.i_clk				     (clk_50m            ),	//125m 
        /*input        */	.i_rstn				     (~rst_125		     ),
        /*input [31:0] */	.data_i				     (OS2_calib_I_400k_i ),	//16位定点数
        /*input [31:0] */	.data_q				     (OS2_calib_I_400k_q ),
        /*output [31:0]*/	.dout				     (OS2_400K_I         )	//p = q^2 + i^2
    );   

    //平均处理
    AVG_FIFO_32	AVG32_V_OS2(
        /*input            */    .clk_i			        (clk_50m             ),
        /*input            */    .rst_i			        (rst_125             ),
        /*input [31:0]     */    .data_in		        (OS2_V               ),
        /*input            */    .den_in			        (1                   ),
        /*output reg [31:0]*/    .data_out		        (OS2_V_AVG           ),
        /*output reg       */    .den_out		        ()
    );
    AVG_FIFO_32	AVG32_I_OS2(
        /*input            */    .clk_i			        (clk_50m             ),
        /*input            */    .rst_i			        (rst_125             ),
        /*input [31:0]     */    .data_in		        (OS2_I               ),
        /*input            */    .den_in			        (1                   ),
        /*output reg [31:0]*/    .data_out		        (OS2_I_AVG           ),
        /*output reg       */    .den_out		        ()
    );
    //平均处理
    AVG_FIFO_32	AVG32_V_400K_OS2(
        /*input            */    .clk_i			        (clk_50m             ),
        /*input            */    .rst_i			        (rst_125             ),
        /*input [31:0]     */    .data_in		        (OS2_400K_V          ),
        /*input            */    .den_in			        (1                   ),
        /*output reg [31:0]*/    .data_out		        (OS2_400K_V_AVG      ),
        /*output reg       */    .den_out		        ()
    );
    AVG_FIFO_32	AVG32_I_400K_OS2(
        /*input            */   .clk_i			        (clk_50m             ),
        /*input            */   .rst_i			        (rst_125             ),
        /*input [31:0]     */   .data_in		        (OS2_400K_I          ),
        /*input            */   .den_in			        (1                   ),
        /*output reg [31:0]*/   .data_out		        (OS2_400K_I_AVG      ),
        /*output reg       */   .den_out		        ()
    );
`endif

/**********************NO USED*********************************/
`ifdef NO_OS1_CH3
    //The second pc;adc;Near dut;
    AD9238_drive   AD9238_OS1(
        /*input            */   .i_clk                   (clk_64m               ),
        /*input            */   .i_adc_clk               (i_adc_clk             ),
        /*input            */   .i_rst                   (rst_125               ),
        /*input  [11:0]    */   .i_adc_data0             (i_adc3_data0          ),
        /*input  [11:0]    */   .i_adc_data1             (i_adc3_data1          ),
        /*output reg       */   .vld	                 (AD9238_CH3_vld        ),
        /*output reg [11:0]*/   .o_CHA                   (AD9238_CH3_CHA        ),
        /*output reg [11:0]*/   .o_CHB                   (AD9238_CH3_CHB        )  //VF
    );
    ////////
    daq9248 daq9248_adc3(                               //13.56M
        /*input  wire       */    .i_clk_62p5             ( clk_64m             ),
        /*input  wire       */    .i_clk_250              ( clk_128m            ),
        /*input  wire       */    .i_rst_62p5             ( rst_125             ),
        /**/
        /*input  wire [31:0]*/    .i_adc0_mean            ( adc0_mean3          ),	//输入 入射mean
        /*input  wire [31:0]*/    .i_adc1_mean            ( adc1_mean3          ),	//输入 反射mean
        /*output reg        */    .o_sys_start            ( ch3_start_adc       ),
        /**/                                     
        /*input             */	.vld					( AD9238_CH3_vld      ),
        /*input  wire [13:0]*/    .i_ad9248_da            ( {AD9238_CH3_CHB[11],AD9238_CH3_CHB[11],AD9238_CH3_CHB }    ),	//AD9643数据,入射   V
        /*input  wire [13:0]*/    .i_ad9248_db            ( {AD9238_CH3_CHA[11],AD9238_CH3_CHA[11],AD9238_CH3_CHA }    ), //AD9643数据，反射
        /**/                                       
        /*output reg        */    .o_ad9248_da_vld        ( ad9238_da3_vld      ),
        /*output reg  [31:0]*/    .o_ad9248_da            ( ad9238_da3          ), //2个14bit补齐到32bit signed
        /*output reg        */    .o_ad9248_db_vld        ( ad9238_db3_vld      ),
        /*output reg  [31:0]*/    .o_ad9248_db            ( ad9238_db3          )  //2个14bit补齐到32bit signed
    );    
    daq9248 daq9248_adc3_400k(
        /*input  wire       */   .i_clk_62p5             ( clk_64m             ),
        /*input  wire       */   .i_clk_250              ( clk_128m            ),
        /*input  wire       */   .i_rst_62p5             ( rst_125             ),
        /**/
        /*input  wire [31:0]*/   .i_adc0_mean            ( adc0_mean3_400k     ),	//输入 入射mean
        /*input  wire [31:0]*/   .i_adc1_mean            ( adc1_mean3_400k     ),	//输入 反射mean
        /*output reg        */   .o_sys_start            ( ch3_start_adc_400k  ),
        /**/                                    
        /*input             */	.vld					( AD9238_CH3_vld      ),
        /*input  wire [13:0]*/   .i_ad9248_da            ( {AD9238_CH3_CHB[11],AD9238_CH3_CHB[11],AD9238_CH3_CHB }    ),	//AD9643数据,入射   V
        /*input  wire [13:0]*/   .i_ad9248_db            ( {AD9238_CH3_CHA[11],AD9238_CH3_CHA[11],AD9238_CH3_CHA }    ), //AD9643数据，反射
        /**/                                      
        /*output reg        */   .o_ad9248_da_vld        ( ad9238_400k_da3_vld ),
        /*output reg  [31:0]*/   .o_ad9248_da            ( ad9238_400k_da3     ), //2个14bit补齐到32bit signed
        /*output reg        */   .o_ad9248_db_vld        ( ad9238_400k_db3_vld ),
        /*output reg  [31:0]*/   .o_ad9248_db            ( ad9238_400k_db3     )  //2个14bit补齐到32bit signed
    );    
    adc_demod adc_demod_OS1(
        /*input               */    .i_clk                     ( clk_128m               ),
        /*input               */    .i_rst                     ( rst_125                ),
        /*input   [15:0]      */    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数
        /*input               */    .i_sys_start               ( ch3_start_bpf          ),	
        /*output              */    .o_sys_start               ( sys3_start_demod       ),
        /*input   [3:0]       */    //.RF_FREQ				   ( RF_FREQ3			    ),
        /*input   [31:0]      */	//.freq_data			  ( freq_out3			    ),
        // adc bpf data                                     
        /*input               */    .i_adc0_vld                ( adc0_ch3_bpf_vld       ),
        /*input   [63:0]      */    .i_adc0_data               ( adc0_ch3_bpf_data      ),
        /*input               */    .i_adc1_vld                ( adc1_ch3_bpf_vld       ),
        /*input   [63:0]      */    .i_adc1_data               ( adc1_ch3_bpf_data      ),
                                                                
            // adc lpf data                                     
        /*output              */      .o_adc0_demod_vld          ( adc0_ch3_demod_vld     ),  
        /*output  [63:0]      */      .o_adc0_demod_data         ( adc0_ch3_demod_data    ),  // {Vmi ,Vmq}				      
        /*output              */      .o_adc1_demod_vld          ( adc1_ch3_demod_vld     ),
        /*output [63:0]       */      .o_adc1_demod_data         ( adc1_ch3_demod_data    ),  // {Imi ,Imq}
        /*output reg     [13:0]*/	  .r_demod_rd_addr		     ( demod_rd_addr3         ),
        /*input   [31:0]       */     .i_demod_freq_coef         ( demod_freq_coef0       )
    );
    adc_demod adc_demod_400k_OS1(
        /*input               */    .i_clk                     ( clk_128m               ),
        /*input               */    .i_rst                     ( rst_125                ),
        /*input   [15:0]      */    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数
        /*input               */    .i_sys_start               ( ch3_start_bpf_400k     ),	
        /*output              */    .o_sys_start               ( sys3_start_400k_demod  ),
        /*input   [3:0]       */    // .RF_FREQ				   ( RF_FREQ3			    ),
        /*input   [31:0]      */	//.freq_data				   ( freq_out3			    ),
            // adc bpf data                                     
        /*input               */   .i_adc0_vld                ( adc0_ch3_bpf_400k_vld   ),
        /*input   [63:0]      */   .i_adc0_data               ( adc0_ch3_bpf_400k_data  ),
        /*input               */   .i_adc1_vld                ( adc1_ch3_bpf_400k_vld   ),
        /*input   [63:0]      */   .i_adc1_data               ( adc1_ch3_bpf_400k_data  ),
                                                                
            // adc lpf data                                     
        /*output              */      .o_adc0_demod_vld          ( adc0_ch3_demod_400k_vld ),  
        /*output  [63:0]      */      .o_adc0_demod_data         ( adc0_ch3_demod_400k_data),  // {Vmi ,Vmq}				      
        /*output              */      .o_adc1_demod_vld          ( adc1_ch3_demod_400k_vld ),
        /*output [63:0]       */      .o_adc1_demod_data         ( adc1_ch3_demod_400k_data),  // {Imi ,Imq}
        /*output reg     [13:0]*/	  .r_demod_rd_addr		     ( demod_rd_400k_addr3     ),
        /*input   [31:0]       */     .i_demod_freq_coef         ( demod_freq_coef2        )
    );
    ///////
    adc_lpf adc_lpf_OS1(                                      //13.56m
        .i_clk_250                 ( clk_128m              ),
        .i_rst                     ( rst_125               ),
                                
        .i_sys_start               ( sys3_start_demod      ),
        .o_sys_start               ( sys3_start_lpf        ),
                
        .i_adc0_demod_vld          ( adc0_ch3_demod_vld    ),
        .i_adc0_demod_data         ( adc0_ch3_demod_data   ),						      
        .i_adc1_demod_vld          ( adc1_ch3_demod_vld    ),
        .i_adc1_demod_data         ( adc1_ch3_demod_data   ),
                                        
        .o_adc0_lpf_vld            ( adc0_ch3_lpf_vld      ), //V
        .o_adc0_lpf_data           ( adc0_ch3_lpf_data     ),						      
        .o_adc1_lpf_vld            ( adc1_ch3_lpf_vld      ), //I
        .o_adc1_lpf_data           ( adc1_ch3_lpf_data     )
    ); 
    adc_lpf_400k adc_lpf_400k_OS1(
        .i_clk_250                 ( clk_128m              ),
        .i_rst                     ( rst_125               ),
                                
        .i_sys_start               ( sys3_start_400k_demod   ),
        .o_sys_start               ( sys3_start_400k_lpf     ),
                                    
        .i_adc0_demod_vld          ( adc0_ch3_demod_400k_vld ),
        .i_adc0_demod_data         ( adc0_ch3_demod_400k_data),						      
        .i_adc1_demod_vld          ( adc1_ch3_demod_400k_vld ),
        .i_adc1_demod_data         ( adc1_ch3_demod_400k_data),
                                        
        .o_adc0_lpf_vld            ( adc0_ch3_lpf_400k_vld   ), //V
        .o_adc0_lpf_data           ( adc0_ch3_lpf_400k_data  ),						      
        .o_adc1_lpf_vld            ( adc1_ch3_lpf_400k_vld   ), //I
        .o_adc1_lpf_data           ( adc1_ch3_lpf_400k_data  )
    ); 
    data_ext	OS1_data_ext_Vm(                          
        .i_clk				        (clk_128m              ),
        .clk_50m			        (clk_50m               ),
        .i_data				        (adc0_ch3_lpf_data     ),	//V
        .i_valid			        (adc0_ch3_lpf_vld      ), 
        .r_demod_rd_addr	        (demod_rd_addr3        ),
        .o_data_i			        (SENSOR3_ADC0_I        ),
        .o_data_q			        (SENSOR3_ADC0_Q        ),
        .o_valid			        (OS1_demod_vld0        )
    );   
    data_ext	OS1_data_ext_Im(
        .i_clk				        (clk_128m 		       ),
        .clk_50m			        (clk_50m		       ),
        .i_data				        (adc1_ch3_lpf_data     ),	//I
        .i_valid			        (adc1_ch3_lpf_vld      ),   
        .r_demod_rd_addr	        (demod_rd_addr3        ),
        .o_data_i			        (SENSOR3_ADC1_I        ),
        .o_data_q			        (SENSOR3_ADC1_Q        ),
        .o_valid			        (OS1_demod_vld1        )
    ); 
    data_ext	OS1_400k_data_ext_Vm(                          
        .i_clk				        (clk_128m              ),
        .clk_50m			        (clk_50m               ),
        .i_data				        (adc0_ch3_lpf_400k_data),	//V
        .i_valid			        (adc0_ch3_lpf_400k_vld ), 
        .r_demod_rd_addr	        (demod_rd_400k_addr3   ),
        .o_data_i			        (SENSOR3_ADC0_400K_I   ),
        .o_data_q			        (SENSOR3_ADC0_400K_Q   ),
        .o_valid			        (OS1_demod_400k_vld0   )
    );   
    data_ext	OS1_400k_data_ext_Im(
        .i_clk				        (clk_128m 		       ),
        .clk_50m			        (clk_50m		       ),
        .i_data				        (adc1_ch3_lpf_400k_data),	//I
        .i_valid			        (adc1_ch3_lpf_400k_vld ),   
        .r_demod_rd_addr	        (demod_rd_400k_addr3   ),
        .o_data_i			        (SENSOR3_ADC1_400K_I   ),
        .o_data_q			        (SENSOR3_ADC1_400K_Q   ),
        .o_valid			        (OS1_demod_400k_vld1   )
    ); 
    //复用在power稳定时�?�的iq 为有效�?�；提取出来；此时时钟域�??50M�??
    always@(clk_50m)begin
        if(OS1_demod_vld0)begin
            r_SENSOR3_ADC0_I <= SENSOR3_ADC0_I ;		
            r_SENSOR3_ADC0_Q <= SENSOR3_ADC0_Q ;	
        end
    end

    always@(clk_50m)begin
        if(OS1_demod_vld1)begin
            r_SENSOR3_ADC1_I <= SENSOR3_ADC1_I ;	
            r_SENSOR3_ADC1_Q <= SENSOR3_ADC1_Q ;		
        end
    end

    always@(clk_50m)begin
        if(OS1_demod_400k_vld0)begin
            r_SENSOR3_ADC0_400K_I <= SENSOR3_ADC0_400K_I ;		
            r_SENSOR3_ADC0_400K_Q <= SENSOR3_ADC0_400K_Q ;	
        end
    end

    always@(clk_50m)begin
        if(OS1_demod_400k_vld1)begin
            r_SENSOR3_ADC1_400K_I <= SENSOR3_ADC1_400K_I ;	
            r_SENSOR3_ADC1_400K_Q <= SENSOR3_ADC1_400K_Q ;		
        end
    end

    // syn i && q; lock ; 
    always@(clk_50m)begin
        if(r_decor_pulse_pos) begin   
            r2_SENSOR3_ADC0_I <= r_SENSOR3_ADC0_I ;
            r2_SENSOR3_ADC0_Q <= r_SENSOR3_ADC0_Q ;
            r2_SENSOR3_ADC1_I <= r_SENSOR3_ADC1_I ;		
            r2_SENSOR3_ADC1_Q <= r_SENSOR3_ADC1_Q ;	
            
            r2_SENSOR3_ADC0_400K_I <= r_SENSOR3_ADC0_400K_I ;
            r2_SENSOR3_ADC0_400K_Q <= r_SENSOR3_ADC0_400K_Q ;
            r2_SENSOR3_ADC1_400K_I <= r_SENSOR3_ADC1_400K_I ;		
            r2_SENSOR3_ADC1_400K_Q <= r_SENSOR3_ADC1_400K_Q ;			 
            
        end
        else begin
            r2_SENSOR3_ADC0_I <= r2_SENSOR3_ADC0_I ;
            r2_SENSOR3_ADC0_Q <= r2_SENSOR3_ADC0_Q ;
            r2_SENSOR3_ADC1_I <= r2_SENSOR3_ADC1_I ;		
            r2_SENSOR3_ADC1_Q <= r2_SENSOR3_ADC1_Q ;	
            
            r2_SENSOR3_ADC0_400K_I <= r2_SENSOR3_ADC0_400K_I ;
            r2_SENSOR3_ADC0_400K_Q <= r2_SENSOR3_ADC0_400K_Q ;
            r2_SENSOR3_ADC1_400K_I <= r2_SENSOR3_ADC1_400K_I ;		
            r2_SENSOR3_ADC1_400K_Q <= r2_SENSOR3_ADC1_400K_Q ;			 
        end
    end 
    /////////
    Decor_matrix  Decor_matrix_OS1(
        /*input               */ .i_clk                ( clk_128m                    ),
        /*input               */ .i_rst                ( rst_125                     ),	
                                                                                    
        /*input               */ .i_adc0_lpf_vld       (adc0_ch3_lpf_vld             ), //ADC0---V
        /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch3_lpf_data            ),
        /*input               */ .i_adc1_lpf_vld       (adc1_ch3_lpf_vld             ), //ADC1---I
        /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch3_lpf_data            ),
                                                                                    
        /*input [31:0] 	    */   .m1a00				   (m1a00_ch3                    ), //a
        /*input [31:0] 	    */   .m1a01				   (m1a01_ch3                    ), //b
        /*input [31:0] 	    */   .m1a10				   (m1a10_ch3                    ), //c
        /*input [31:0] 	    */   .m1a11				   (m1a11_ch3                    ), //d
                                                                                    
        /*output              */ .o_adc0_calib_vld     (OS1_V_calib_vld              ),   //Vt;
        /*output  [99:0]      */ .o_adc0_calib_data    (OS1_V_calib_data             ),
        /*output              */ .o_adc1_calib_vld     (OS1_I_calib_vld              ),   //It;
        /*output  [99:0]      */ .o_adc1_calib_data    (OS1_I_calib_data             )
    );                                                                           
                                                                                
    Decor_matrix  Decor_matrix_400k_OS1(                                         
        /*input               */ .i_clk                ( clk_128m                    ),
        /*input               */ .i_rst                ( rst_125                     ),	
                        
        /*input               */ .i_adc0_lpf_vld       (adc0_ch3_lpf_400k_vld        ), //ADC0---V
        /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch3_lpf_400k_data       ),
        /*input               */ .i_adc1_lpf_vld       (adc1_ch3_lpf_400k_vld        ), //ADC1---I
        /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch3_lpf_400k_data       ),

        /*input [31:0] 	    */   .m1a00				   (m1a00_ch3_400k               ), //a
        /*input [31:0] 	    */   .m1a01				   (m1a01_ch3_400k               ), //b
        /*input [31:0] 	    */   .m1a10				   (m1a10_ch3_400k               ), //c
        /*input [31:0] 	    */   .m1a11				   (m1a11_ch3_400k               ), //d

        /*output              */ .o_adc0_calib_vld     (OS1_V_calib_400k_vld         ),   //Vt;
        /*output  [99:0]      */ .o_adc0_calib_data    (OS1_V_calib_400k_data        ),
        /*output              */ .o_adc1_calib_vld     (OS1_I_calib_400k_vld         ),   //It;
        /*output  [99:0]      */ .o_adc1_calib_data    (OS1_I_calib_400k_data        )
    );   

    // //Vm经过decor出来�?? adc_calib_data 是经过单独特定的decor cali 通过IQ滤波�??
    // //13.56m;
    data_ext	data_ext1_Vt(                                         
        .i_clk				     (clk_128m                 ),
        .clk_50m			     (clk_50m                  ),//time domain cross
        .i_data				     (OS1_V_calib_data         ),	//100bit
        .i_valid			     (OS1_V_calib_vld          ), 
        .r_demod_rd_addr	     (demod_rd_addr3           ),
        .o_data_i			     (OS1_calib_V_i            ), //V  50b
        .o_data_q			     (OS1_calib_V_q            ),
        .o_valid			     (OS1_calib_V_vld          )
    );
    data_ext	data_ext1_It(                           
        .i_clk				     (clk_128m 		           ),
        .clk_50m			     (clk_50m		           ),//time domain cross
        .i_data				     (OS1_I_calib_data         ),	
        .i_valid			     (OS1_I_calib_vld          ),  //I 
        .r_demod_rd_addr	     (demod_rd_addr3           ),
        .o_data_i			     (OS1_calib_I_i            ),
        .o_data_q			     (OS1_calib_I_q            ),
        .o_valid			     (OS1_calib_I_vld          )
    );
        
    // //400k
    data_ext	data_ext1_400k_Vt(                                         
        .i_clk				     (clk_128m                 ),
        .clk_50m			     (clk_50m                  ),//time domain cross
        .i_data				     (OS1_V_calib_400k_data    ),	//100bit
        .i_valid			     (OS1_V_calib_400k_vld     ), 
        .r_demod_rd_addr	     (demod_rd_400k_addr3      ),
        .o_data_i			     (OS1_calib_V_400k_i       ), //V  50b
        .o_data_q			     (OS1_calib_V_400k_q       ),
        .o_valid			     (OS1_calib_V_400k_vld     )
    );   
    data_ext	data_ext1_400k_It(                           
        .i_clk				     (clk_128m 		           ),
        .clk_50m			     (clk_50m		           ),//time domain cross
        .i_data				     (OS1_I_calib_400k_data    ),	
        .i_valid			     (OS1_I_calib_400k_vld     ),  //I 
        .r_demod_rd_addr	     (demod_rd_400k_addr3      ),
        .o_data_i			     (OS1_calib_I_400k_i       ),
        .o_data_q			     (OS1_calib_I_400k_q       ),
        .o_valid			     (OS1_calib_I_400k_vld     )
    );
    
    // /*----------------------Output sensor0 计算阻抗-----------------------*/
    //求分流出的sensor2 的i q 		V（I + Qj） / I（I + Qj）  ; Vt/It;
    complex_div	   DIV_OS1(                          //V/I
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (rst_125            ),
        .vr_i				     (OS1_calib_V_i      ),	//V
        .vr_q				     (OS1_calib_V_q      ),	//V
        .vf_i				     (OS1_calib_I_i      ),	//I
        .vf_q				     (OS1_calib_I_q      ),	//I
        .R				         (OS1_R              ),
        .JX				         (OS1_JX             )
    );	//反射/入射   

    complex_div	   DIV_OS1_400k(                          //V/I
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (rst_125            ),
        .vr_i				     (OS1_calib_V_400k_i ),	//V
        .vr_q				     (OS1_calib_V_400k_q ),	//V
        .vf_i				     (OS1_calib_I_400k_i ),	//I
        .vf_q				     (OS1_calib_I_400k_q ),	//I
        .R				         (OS1_400K_R         ),
        .JX				         (OS1_400K_JX        )
    );	//反射/入射   
    average_signed	R1_AVG256_OS1(                       
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .din			        (OS1_R               ),
        .en_in			        (1                   ),
        .dout			        (OUPUT_SENSOR1_R_AVG ),
        .en_out			        ()                 
    );
    average_signed	JX1_AVG256_OS1(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .din			        (OS1_JX              ),
        .en_in			        (1                   ),
        .dout			        (OUPUT_SENSOR1_JX_AVG),
        .en_out			        ()
    );
    
    average_signed	R1_AVG256_400k_OS1(                       
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .din			        (OS1_400K_R          ),
        .en_in			        (1                   ),
        .dout			        (OUPUT_SENSOR1_400K_R_AVG ),
        .en_out			        ()                 
    );
    average_signed	JX1_AVG256_400K_OS1(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .din			        (OS1_400K_JX         ),
        .en_in			        (1                   ),
        .dout			        (OUPUT_SENSOR1_400K_JX_AVG),
        .en_out			        ()
    );

    /*----------------------Output sensor0 电压电流 功率-----------------------*/
    power_cal	mod_Vt_OS1(                         
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (~rst_125		     ),
        .data_i				     (OS1_calib_V_i      ),	//16位定点数
        .data_q				     (OS1_calib_V_q      ),
        .dout				     (OS1_V              )	//p = q^2 + i^2
    );                                               
                                                    
    power_cal	mod_It_OS1(                              
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (~rst_125		     ),
        .data_i				     (OS1_calib_I_i      ),	//16位定点数
        .data_q				     (OS1_calib_I_q      ),
        .dout				     (OS1_I              )	//p = q^2 + i^2
    );   

    power_cal	mod_Vt_400K_OS1(                         
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (~rst_125		     ),
        .data_i				     (OS1_calib_V_400k_i ),	//16位定点数
        .data_q				     (OS1_calib_V_400k_q ),
        .dout				     (OS1_400K_V         )	//p = q^2 + i^2
    );                                               
                                                    
    power_cal	mod_It_400K_OS1(                              
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (~rst_125		     ),
        .data_i				     (OS1_calib_I_400k_i ),	//16位定点数
        .data_q				     (OS1_calib_I_400k_q ),
        .dout				     (OS1_400K_I         )	//p = q^2 + i^2
    );   
    //平均处理
    AVG_FIFO_32	AVG32_V_OS1(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .data_in		        (OS1_V               ),
        .den_in			        (1                   ),
        .data_out		        (OS1_V_AVG           ),
        .den_out		        ()
    );
    AVG_FIFO_32	AVG32_I_OS1(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .data_in		        (OS1_I               ),
        .den_in			        (1                   ),
        .data_out		        (OS1_I_AVG           ),
        .den_out		        ()
    );

    AVG_FIFO_32	AVG32_V_400K_OS1(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .data_in		        (OS1_400K_V          ),
        .den_in			        (1                   ),
        .data_out		        (OS1_400K_V_AVG      ),
        .den_out		        ()
    );
    AVG_FIFO_32	AVG32_I_400K_OS1(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .data_in		        (OS1_400K_I          ),
        .den_in			        (1                   ),
        .data_out		        (OS1_400K_I_AVG      ),
        .den_out		        ()
    );
`endif

`ifdef NO_OS0_CH1 
    //The second pc;adc;Near dut;
    AD9238_drive   AD9238_OS0(
        /*input          */           .i_clk           (clk_64m           ),
        /*input          */           .i_adc_clk       (i_adc_clk         ),
        /*input          */           .i_rst           (rst_125           ),
        /*input  [11:0]  */           .i_adc_data0     (i_adc1_data0      ),
        /*input  [11:0]  */           .i_adc_data1     (i_adc1_data1      ),
        /*output reg 	 */		      .vld	           (AD9238_CH1_vld    ),
        /*output [11:0]  */           .o_CHA           (AD9238_CH1_CHA    ),
        /*output [11:0]  */           .o_CHB           (AD9238_CH1_CHB    )  //VF
    );
    FREQ_RTK_MEASURE  FREQ_RTK_MEASURE_OS0
    (
        .i_clk                     (clk_64m             ), //64M == 15.628ns;
        .i_rst                     (rst_125             ),
        .i_adc_vld                 (AD9238_CH1_vld      ), 
        .i_adc_data                ({AD9238_CH1_CHB[11],AD9238_CH1_CHB[11],AD9238_CH1_CHB}  ), //input sensor LF;
        
        .i_power_status0           (power_status0       ),
        .i_power_status2           (power_status2       ),
        
        .i_threshold2on            (OS0_threshold2on     ),
        .i_measure_period          (OS0_measure_period   ),
        .o_period_total            (OS0_period_total     ),
        .o_period_pos_cnt          (OS0_period_cnt       )  //测量周期个数        
    );
    daq9248 daq9248_adc1(
        .i_clk_62p5             ( clk_64m             ),
        .i_clk_250              ( clk_128m            ),
        .i_rst_62p5             ( rst_125             ),

        .i_adc0_mean            ( adc0_mean1          ),	//输入 入射mean
        .i_adc1_mean            ( adc1_mean1          ),	//输入 反射mean

        .o_sys_start            ( ch1_start_adc       ),
                                        
        .vld					( AD9238_CH1_vld      ),
        .i_ad9248_da            ( {AD9238_CH1_CHB[11],AD9238_CH1_CHB[11],AD9238_CH1_CHB }    ),	//AD9643数据,入射
        .i_ad9248_db            ( {AD9238_CH1_CHA[11],AD9238_CH1_CHA[11],AD9238_CH1_CHA }    ), //AD9643数据,反射
                                        
        .o_ad9248_da_vld        ( ad9238_da1_vld      ),
        .o_ad9248_da            ( ad9238_da1          ), //2个14bit补齐到32bit signed
        .o_ad9248_db_vld        ( ad9238_db1_vld      ),
        .o_ad9248_db            ( ad9238_db1          )  //2个14bit补齐到32bit signed
    ); 
    adc_demod adc_demod_OS0(
        .i_clk                     ( clk_128m               ),
        .i_rst                     ( rst_125                ),
                                                            
        .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数
                                                            
        .i_sys_start               ( ch1_start_bpf          ),	
        .o_sys_start               ( sys1_start_demod       ),
        .RF_FREQ				   ( RF_FREQ1			    ),
        .freq_data				   ( freq_out1			    ),
        // adc bpf data                                     
        .i_adc0_vld                ( adc0_ch1_bpf_vld       ),
        .i_adc0_data               ( adc0_ch1_bpf_data      ),
        .i_adc1_vld                ( adc1_ch1_bpf_vld       ),
        .i_adc1_data               ( adc1_ch1_bpf_data      ),
                                                            
        // adc lpf data                                     
        .o_adc0_demod_vld          ( adc0_ch1_demod_vld     ),  
        .o_adc0_demod_data         ( adc0_ch1_demod_data    ),  // {Vmi ,Vmq}				      
        .o_adc1_demod_vld          ( adc1_ch1_demod_vld     ),
        .o_adc1_demod_data         ( adc1_ch1_demod_data    ),  // {Imi ,Imq}
                                                            
        .r_demod_rd_addr		   ( demod_rd_addr1	        ),
        .i_demod_freq_coef         ( demod_freq_coef1       )
    );
    adc_lpf adc_lpf_OS0(
        .i_clk_250                 ( clk_128m              ),
        .i_rst                     ( rst_125               ),
                                
        .i_sys_start               ( sys1_start_demod      ),
        .o_sys_start               ( sys1_start_lpf        ),
                
        .i_adc0_demod_vld          ( adc0_ch1_demod_vld    ),
        .i_adc0_demod_data         ( adc0_ch1_demod_data   ),						      
        .i_adc1_demod_vld          ( adc1_ch1_demod_vld    ),
        .i_adc1_demod_data         ( adc1_ch1_demod_data   ),
                                        
        .o_adc0_lpf_vld            ( adc0_ch1_lpfx_vld      ), //V
        .o_adc0_lpf_data           ( adc0_ch1_lpfx_data     ),						      
        .o_adc1_lpf_vld            ( adc1_ch1_lpfx_vld      ), //I
        .o_adc1_lpf_data           ( adc1_ch1_lpfx_data     )
    ); 

    data_ext	OS0_data_ext_Vm(                          
        .i_clk				        (clk_128m              ),
        .clk_50m			        (clk_50m               ),
        .i_data				        (adc0_ch1_lpfx_data     ),	//V
        .i_valid			        (adc0_ch1_lpfx_vld      ), 
        .r_demod_rd_addr	        (demod_rd_addr1        ),
        .o_data_i			        (SENSOR1_ADC0_I        ),
        .o_data_q			        (SENSOR1_ADC0_Q        ),
        .o_valid			        (OS0_demod_vld0        )
    );   

    data_ext	OS0_data_ext_Im(
        .i_clk				        (clk_128m 		       ),
        .clk_50m			        (clk_50m		       ),
        .i_data				        (adc1_ch1_lpfx_data     ),	//I
        .i_valid			        (adc1_ch1_lpfx_vld      ),   
        .r_demod_rd_addr	        (demod_rd_addr1        ),
        .o_data_i			        (SENSOR1_ADC1_I        ),
        .o_data_q			        (SENSOR1_ADC1_Q        ),
        .o_valid			        (OS0_demod_vld1        )
    ); 
    //-----------------------------------分流出原始滤波iq计算A B C D Dicao参数---------------------------------//
    //复用在power稳定时候的iq 为有效值;提取出来;此时时钟域为50M;
    always@(clk_50m)begin
        if(OS0_demod_vld0)begin
            r_SENSOR1_ADC0_I <= SENSOR1_ADC0_I ;		
            r_SENSOR1_ADC0_Q <= SENSOR1_ADC0_Q ;		
        end
    end

    always@(clk_50m)begin
        if(OS0_demod_vld1)begin
            r_SENSOR1_ADC1_I <= SENSOR1_ADC1_I ;	
            r_SENSOR1_ADC1_Q <= SENSOR1_ADC1_Q ;		
        end
    end
    always@(clk_50m)begin
        r2_SENSOR1_ADC0_I <= r_SENSOR1_ADC0_I ;		//V
    end 
    // syn i && q; lock ; 
    always@(clk_50m)begin
        if(decor_pulse) begin          
            r2_SENSOR1_ADC0_I <= r_SENSOR1_ADC0_I ;	
            r2_SENSOR1_ADC0_Q <= r_SENSOR1_ADC0_Q ;
            r2_SENSOR1_ADC1_I <= r_SENSOR1_ADC1_I ;		
            r2_SENSOR1_ADC1_Q <= r_SENSOR1_ADC1_Q ;	
        end
        else begin
        
            r2_SENSOR1_ADC0_I <= r2_SENSOR1_ADC0_I ;	
            r2_SENSOR1_ADC0_Q <= r2_SENSOR1_ADC0_Q ;
            r2_SENSOR1_ADC1_I <= r2_SENSOR1_ADC1_I ;		
            r2_SENSOR1_ADC1_Q <= r2_SENSOR1_ADC1_Q ;	
        end
    end 
    ///////////
    Decor_matrix  Decor_matrix_OS0(
        /*input               */ .i_clk                ( clk_128m               ),
        /*input               */ .i_rst                ( rst_125                ),	
                        
        /*input               */ .i_adc0_lpf_vld       (adc0_ch1_lpfx_vld        ), //ADC0---V
        /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch1_lpfx_data       ),
        /*input               */ .i_adc1_lpf_vld       (adc1_ch1_lpfx_vld        ), //ADC1---I
        /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch1_lpfx_data       ),

        /*input [31:0] 	    */   .m1a00				   (m1a00_ch1               ), //a
        /*input [31:0] 	    */   .m1a01				   (m1a01_ch1               ), //b
        /*input [31:0] 	    */   .m1a10				   (m1a10_ch1               ), //c
        /*input [31:0] 	    */   .m1a11				   (m1a11_ch1               ), //d

        /*output              */ .o_adc0_calib_vld     (OS0_V_calib_vld         ),   //Vt;
        /*output  [99:0]      */ .o_adc0_calib_data    (OS0_V_calib_data        ),
        /*output              */ .o_adc1_calib_vld     (OS0_I_calib_vld         ),   //It;
        /*output  [99:0]      */ .o_adc1_calib_data    (OS0_I_calib_data        )
    );   
    //Vm经过decor出来的 adc_calib_data 是经过单独特定的decor cali 通过IQ滤波的
    data_ext	data_ext0_Vt(                                         
        .i_clk				     (clk_128m                 ),
        .clk_50m			     (clk_50m                  ),//time domain cross
        .i_data				     (OS0_V_calib_data         ),	//100bit
        .i_valid			     (OS0_V_calib_vld          ), 
        .r_demod_rd_addr	     (demod_rd_addr1           ),
        .o_data_i			     (OS0_calib_V_i            ), //V  50b
        .o_data_q			     (OS0_calib_V_q            ),
        .o_valid			     (OS0_calib_V_vld          )
    );   
    
    data_ext	data_ext0_It(                           
        .i_clk				     (clk_128m 		           ),
        .clk_50m			     (clk_50m		           ),//time domain cross
        .i_data				     (OS0_I_calib_data         ),	
        .i_valid			     (OS0_I_calib_vld          ),  //I 
        .r_demod_rd_addr	     (demod_rd_addr1           ),
        .o_data_i			     (OS0_calib_I_i            ),
        .o_data_q			     (OS0_calib_I_q            ),
        .o_valid			     (OS0_calib_I_vld          )
    );
    /*----------------------Output sensor0 计算阻抗-----------------------*/
    //求分流出的sensor2 的i q     V（I + Qj） / I（I + Qj） ; Vt/It;
    complex_div	   DIV_OS0(                          //V/I
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (rst_125            ),
        .vr_i				     (OS0_calib_V_i      ),	//V
        .vr_q				     (OS0_calib_V_q      ),	//V
        .vf_i				     (OS0_calib_I_i      ),	//I
        .vf_q				     (OS0_calib_I_q      ),	//I
        .R				         (OS0_R              ),
        .JX				         (OS0_JX             )
    );	//反射/入射   
    average_signed	R1_AVG256_OS0(                       
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .din			        (OS0_R               ),
        .en_in			        (1                   ),
        .dout			        (OUPUT_SENSOR0_R_AVG ),
        .en_out			        ()                 
    );
    average_signed	JX1_AVG256_OS0(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .din			        (OS0_JX              ),
        .en_in			        (1                   ),
        .dout			        (OUPUT_SENSOR0_JX_AVG),
        .en_out			        ()
    );
    /*----------------------Output sensor0 电压电流 功率-----------------------*/
    power_cal	mod_Vt_OS0(                         
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (~rst_125		     ),
        .data_i				     (OS0_calib_V_i      ),	//16位定点数
        .data_q				     (OS0_calib_V_q      ),
        .dout				     (OS0_V              )	//p = q^2 + i^2
    );                                               
                                                    
    power_cal	mod_It_OS0(                              
        .i_clk				     (clk_50m            ),	//125m 
        .i_rstn				     (~rst_125		     ),
        .data_i				     (OS0_calib_I_i      ),	//16位定点数
        .data_q				     (OS0_calib_I_q      ),
        .dout				     (OS0_I              )	//p = q^2 + i^2
    );   
    //平均处理
    AVG_FIFO_32	AVG32_V_OS0(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .data_in		        (OS0_V               ),
        .den_in			        (1                   ),
        .data_out		        (OS0_V_AVG           ),
        .den_out		        ()
    );
    AVG_FIFO_32	AVG32_I_OS0(
        .clk_i			        (clk_50m             ),
        .rst_i			        (rst_125             ),
        .data_in		        (OS0_I               ),
        .den_in			        (1                   ),
        .data_out		        (OS0_I_AVG           ),
        .den_out		        ()
    );
`endif
/**********************NO USED*********************************/

/************************HF power cailb**********************************/
`ifdef  IS_CW_PW_POWER_FUNCTION  //功率开启才会更新如下值
    CW_PW_POWER_DISPLAY  u_CW_PW_POWER_DISPLAY(  //显示input sersor的功率值,检测到开功率(ON)的才更新功率,否则不更新,保持原来的值;
        /*input            */  .i_clk                  (clk_50m             ),
        /*input            */  .i_rst                  (rst_125             ), 
        /*input   [15:0]   */  .i_vf_power_calib       (VF_POWER_CALIB_K0   ), //复用出的Input sensor vf 功率波形;
        /*input   [15:0]   */  .i_vr_power_calib       (VR_POWER_CALIB_K0   ), //复用出的Input sensor vr 功率波形;
                                                                        
        /*input   [15:0]   */  .i_vf_power2_calib      (VF_POWER_CALIB_K2   ), //复用出的Input sensor vf 功率波形;
        /*input   [15:0]   */  .i_vr_power2_calib      (VR_POWER_CALIB_K2   ), //复用出的Input sensor vr 功率波形;
                                                                        
        /*input            */  .i_pulse0_on            (pulse0_pwm_on       ), //VF 原始波形的拟合占空比�?
                               .i_pulse2_on            (pulse2_pwm_on       ),
                                                                        
        /*input            */  .i_pw_mode0             (PW_MODE0            ), 
        /*input            */  .i_pw_mode2             (PW_MODE2            ), 
        /*output reg [15:0]*/  .o_vf_power_calib       (vf_power0_calib_disp), //进行PW mode 下的功率数据滤波显示
        /*output reg [15:0]*/  .o_vr_power_calib       (vr_power0_calib_disp), //进行PW mode 下的功率数据滤波显示

        /*output reg [15:0]*/  .o_vf_power2_calib      (vf_power2_calib_disp), //进行PW mode 下的功率数据滤波显示
        /*output reg [15:0]*/  .o_vr_power2_calib      (vr_power2_calib_disp) 
    );
    /*********************  HF power disp*************************/
    AVG_FIFO_32	AVG32_HF_pf_disp(                      //显示后平均; 显示后平均  32个值的窗口滑动平均
        /*input            */    .clk_i			     (clk_50m              ),
        /*input            */    .rst_i			     (rst_125              ),
        /*input [31:0]     */    .data_in		     (vf_power0_calib_disp ),
        /*input            */    .den_in			 (calib_vf_vld0        ),
        /*output reg [31:0]*/    .data_out		     (vf_power0_disp_avg   ),
        /*output reg       */    .den_out		     ()
    );
    AVG_FIFO_32	AVG32_HF_pr_disp(
        /*input            */    .clk_i			     (clk_50m              ),
        /*input            */    .rst_i			     (rst_125              ),
        /*input [31:0]     */    .data_in		     (vr_power0_calib_disp ),
        /*input            */    .den_in			 (calib_vr_vld0        ),
        /*output reg [31:0]*/    .data_out		     (vr_power0_disp_avg   ),
        /*output reg       */    .den_out		     ()
    );

    //对功率进行小数点后两位稳定的滤波
    AVG_IIR_signed  AVG_IIR_HF_pf_avg (                //平均后小数点后两位精度提升；
        /*input 		        */     .clk_i    (clk_50m            ),
        /*input 		        */     .rst_i    (rst_125            ),
        /*input [31:0]		    */     .din      (vf_power0_disp_avg ),
        /*input 				*/     .din_en   (calib_vf_vld0      ),
        /*output reg [31:0]	    */     .dout     (AVG_IIR_pf0        ),
        /*output reg 			*/     .dout_en  (                   )
    );
    AVG_IIR_signed  AVG_IIR_HF_pr_avg (
        /*input 		        */     .clk_i   (clk_50m             ),
        /*input 		        */     .rst_i   (rst_125             ),
        /*input [31:0]		    */     .din     (vr_power0_disp_avg  ),
        /*input 				*/     .din_en  (calib_vr_vld0       ),
        /*output reg [31:0]	    */     .dout    (AVG_IIR_pr0         ),
        /*output reg 			*/     .dout_en (                    )
    );	
    /*********************  LF power disp*************************/
    AVG_FIFO_32	AVG32_LF_pf_disp(                      //显示后平均；
        /*input            */    .clk_i			     (clk_50m              ),
        /*input            */    .rst_i			     (rst_125              ),
        /*input [31:0]     */    .data_in		     (vf_power2_calib_disp ),
        /*input            */    .den_in			 (calib_vf_vld2        ),
        /*output reg [31:0]*/    .data_out		     (vf_power2_disp_avg   ),
        /*output reg       */    .den_out		     ()
    );

    AVG_FIFO_32	AVG32_LF_pr_disp(
        /*input            */     .clk_i			 (clk_50m              ),
        /*input            */     .rst_i			 (rst_125              ),
        /*input [31:0]     */     .data_in		     (vr_power2_calib_disp ),
        /*input            */     .den_in			 (calib_vr_vld2        ),
        /*output reg [31:0]*/     .data_out		     (vr_power2_disp_avg   ),
        /*output reg       */     .den_out		     ()
    );

    //对功率进行小数点后两位稳定的滤波
    AVG_IIR_signed  AVG_IIR_LF_pf_avg (                //平均后小数点后两位精度提升；
        /*input 		        */     .clk_i               (clk_50m             ),
        /*input 		        */     .rst_i               (rst_125             ),
        /*input [31:0]		    */     .din                 (vf_power2_disp_avg  ),
        /*input 				*/     .din_en              (calib_vf_vld2       ),
        /*output reg [31:0]	    */     .dout                (AVG_IIR_pf2         ),//返回上位机的值
        /*output reg 			*/     .dout_en             (                    )
    );

    AVG_IIR_signed  AVG_IIR_LF_pr_avg (
        /*input 		        */    .clk_i               (clk_50m              ),
        /*input 		        */    .rst_i               (rst_125              ),
        /*input [31:0]		    */    .din                 (vr_power2_disp_avg   ),
        /*input 				*/    .din_en              (calib_vr_vld2        ),
        /*output reg [31:0]	    */    .dout                (AVG_IIR_pr2          ),//返回上位机的值
        /*output reg 			*/    .dout_en             (                     )
    );	
`endif
/*-------------> LF INPUT SENSOR 计算阻抗业务   -------------------*/
`ifdef  CW_PW_R_JX_FUNCTION
    `ifdef CW_PW_R_JX_RESULT_S
        CW_PW_R_JX_IS CW_PW_R_JX_IS0(
            /*input                  */ .clk             (clk_50m             ),
            /*input       [31 : 0]   */ .I_R_AVG         (INPUT_SENSOR0_R_AVG ),
            /*input       [31 : 0]   */ .I_JX_AVG        (INPUT_SENSOR0_JX_AVG),
            /*input                  */ .pulse_pwm_on    (pulse0_pwm_on       ), //功率拟合的波形; hf
            /*input                  */ .CW_MODE         (CW_MODE0            ),
            /*input                  */ .PW_MODE         (PW_MODE0            ),   
            /*input                  */ .power_fall      (IS0_power_fall      ),     
            /*input                  */ .open_status     (open_status0        ),
            /*input       [15 : 0]   */ .power_pwm_dly   (w_IS0_power_pwm_dly0), //相对于脉冲拟合占空比延迟计数器  input sensor
            /*input       [15 : 0]   */ .pulse_gap       (w_pulse_gap0        ), //功率占空比相同的脉冲间隔; hf
            /*output  reg            */ .O_Z_pulse_pwm   (w_Z_pulse0_pwm      ),
            /*output  reg [31 : 0]   */ .O_R             (R0_result           ),
            /*output  reg [31 : 0]   */ .O_JX            (JX0_result          )  
        );
        CW_PW_R_JX_IS CW_PW_R_JX_IS1(
            /*input                  */ .clk             (clk_50m               ),
            /*input       [31 : 0]   */ .I_R_AVG         (INPUT_SENSOR1_R_AVG   ),
            /*input       [31 : 0]   */ .I_JX_AVG        (INPUT_SENSOR1_JX_AVG  ),
            /*input                  */ .pulse_pwm_on    (pulse2_pwm_on         ), //功率拟合的波形； hf
            /*input                  */ .CW_MODE         (CW_MODE2              ),
            /*input                  */ .PW_MODE         (PW_MODE2              ),   
            /*input                  */ .power_fall      (0                     ), //pulse2_pwm_on 是硬件波形有问题，脉冲开启后，检测稳定后，延时长时间再采样     
            /*input                  */ .open_status     (1                     ), //不需要open
            /*input       [15 : 0]   */ .power_pwm_dly   (w_IS1_power_pwm_dly2  ), //相对于脉冲拟合占空比延迟计数器  input sensor
            /*input       [15 : 0]   */ .pulse_gap       (w_pulse_gap2          ), //功率占空比相同的脉冲间隔； hf
            /*output  reg            */ .O_Z_pulse_pwm   (w_Z_pulse2_pwm        ),
            /*output  reg [31 : 0]   */ .O_R             (R2_result	            ),
            /*output  reg [31 : 0]   */ .O_JX            (JX2_result            )  
        );
        CW_PW_R_JX_OS CW_PW_R_JX_OS0(  //为了拿到稳定值 做延时
            /*input               */   .clk          (clk_50m              ),     
            /*input       [31 : 0]*/   .I_R_AVG      (OUPUT_SENSOR0_R_AVG  ),     
            /*input       [31 : 0]*/   .I_JX_AVG     (OUPUT_SENSOR0_JX_AVG ),     
            /*input               */   .pulse_pwm_on (pulse1_pwm_on        ),     
            /*input               */   .CW_MODE      (CW_MODE1             ),     
            /*input               */   .PW_MODE      (PW_MODE1             ),     
            /*input               */   .power_fall   (OS0_I_fall           ),     
            /*input               */   .open_status  (open_status1         ),     
            /*input       [15 : 0]*/   .power_pwm_dly(w_OS0_pwm_dly        ),     
            /*input       [15 : 0]*/   .pulse_gap    (w_pulse_gap1         ),     
            /*output  reg         */   .O_Z_pulse_pwm(w_Z_pulse1_pwm       ),     
            /*output  reg [31 : 0]*/   .O_R          (R1_result	           ),     
            /*output  reg [31 : 0]*/   .O_JX         (JX1_result           ),     
            /*input       [31 : 0]*/   .OS_V_AVG     (OS0_V_AVG            ),//计算电压电流的波形取pw稳定的段,Cw则持续输出     
            /*input       [31 : 0]*/   .OS_I_AVG     (OS0_I_AVG            ),     
            /*output  reg [31 : 0]*/   .OS_V_RESULT  (OS0_V_RESULT         ),     
            /*output  reg [31 : 0]*/   .OS_I_RESULT  (OS0_I_RESULT         )     
        );
        CW_PW_R_JX_OS CW_PW_R_JX_OS1(  //为了拿到稳定值 做延时
            /*input               */   .clk          (clk_50m                ),     
            /*input       [31 : 0]*/   .I_R_AVG      (OUPUT_SENSOR1_R_AVG    ),     
            /*input       [31 : 0]*/   .I_JX_AVG     (OUPUT_SENSOR1_JX_AVG   ),     
            /*input               */   .pulse_pwm_on (pulse3_pwm_on          ),     
            /*input               */   .CW_MODE      (CW_MODE3               ),     
            /*input               */   .PW_MODE      (PW_MODE3               ),     
            /*input               */   .power_fall   (OS1_I_fall             ),     
            /*input               */   .open_status  (open_status3           ),     
            /*input       [15 : 0]*/   .power_pwm_dly(w_OS1_pwm_dly          ),     
            /*input       [15 : 0]*/   .pulse_gap    (w_pulse_gap3           ),     
            /*output  reg         */   .O_Z_pulse_pwm(w_Z_pulse3_pwm         ),     
            /*output  reg [31 : 0]*/   .O_R          (R3_result	             ),     
            /*output  reg [31 : 0]*/   .O_JX         (JX3_result             ),     
            /*input       [31 : 0]*/   .OS_V_AVG     (OS1_V_AVG              ),     
            /*input       [31 : 0]*/   .OS_I_AVG     (OS1_I_AVG              ),     
            /*output  reg [31 : 0]*/   .OS_V_RESULT  (OS1_V_RESULT           ),     
            /*output  reg [31 : 0]*/   .OS_I_RESULT  (OS1_I_RESULT           )     
        );
        CW_PW_R_JX_OS CW_PW_R_JX_OS1_400K(  //为了拿到稳定值 做延时
            /*input               */   .clk          (clk_50m                  ),     
            /*input       [31 : 0]*/   .I_R_AVG      (OUPUT_SENSOR1_400K_R_AVG ),     
            /*input       [31 : 0]*/   .I_JX_AVG     (OUPUT_SENSOR1_400K_JX_AVG),     
            /*input               */   .pulse_pwm_on (pulse3_400k_pwm_on       ),     
            /*input               */   .CW_MODE      (CW_MODE3_400K            ),     
            /*input               */   .PW_MODE      (PW_MODE3_400K            ),     
            /*input               */   .power_fall   (OS1_400k_I_fall          ),     
            /*input               */   .open_status  (open_status3_400k        ),     
            /*input       [15 : 0]*/   .power_pwm_dly(w_OS1_pwm_dly_400k       ),     
            /*input       [15 : 0]*/   .pulse_gap    (w_pulse_gap3_400k        ),     
            /*output  reg         */   .O_Z_pulse_pwm(w_Z_pulse3_pwm_400k      ),     
            /*output  reg [31 : 0]*/   .O_R          (R3_400k_result	       ),     
            /*output  reg [31 : 0]*/   .O_JX         (JX3_400k_result          ),     
            /*input       [31 : 0]*/   .OS_V_AVG     (OS1_400K_V_AVG           ),     
            /*input       [31 : 0]*/   .OS_I_AVG     (OS1_400K_I_AVG           ),     
            /*output  reg [31 : 0]*/   .OS_V_RESULT  (OS1_400K_V_RESULT        ),     
            /*output  reg [31 : 0]*/   .OS_I_RESULT  (OS1_400K_I_RESULT        )     
        );
        CW_PW_R_JX_OS CW_PW_R_JX_OS2(  //为了拿到稳定值 做延时
            /*input               */   .clk          (clk_50m                ),     
            /*input       [31 : 0]*/   .I_R_AVG      (OUPUT_SENSOR2_R_AVG    ),     
            /*input       [31 : 0]*/   .I_JX_AVG     (OUPUT_SENSOR2_JX_AVG   ),     
            /*input               */   .pulse_pwm_on (pulse4_pwm_on          ),     
            /*input               */   .CW_MODE      (CW_MODE4               ),     
            /*input               */   .PW_MODE      (PW_MODE4               ),     
            /*input               */   .power_fall   (OS2_I_fall             ),     
            /*input               */   .open_status  (open_status4           ),     
            /*input       [15 : 0]*/   .power_pwm_dly(w_OS2_pwm_dly            ),     
            /*input       [15 : 0]*/   .pulse_gap    (w_pulse_gap4             ),     
            /*output  reg         */   .O_Z_pulse_pwm(w_Z_pulse4_pwm           ),     
            /*output  reg [31 : 0]*/   .O_R          (R4_result	             ),     
            /*output  reg [31 : 0]*/   .O_JX         (JX4_result             ),     
            /*input       [31 : 0]*/   .OS_V_AVG     (OS2_V_AVG              ),     
            /*input       [31 : 0]*/   .OS_I_AVG     (OS2_I_AVG              ),     
            /*output  reg [31 : 0]*/   .OS_V_RESULT  (OS2_V_RESULT           ),     
            /*output  reg [31 : 0]*/   .OS_I_RESULT  (OS2_I_RESULT           )     
        );
        CW_PW_R_JX_OS CW_PW_R_JX_OS2_400K(  //为了拿到稳定值 做延时
            /*input               */   .clk          (clk_50m                  ),     
            /*input       [31 : 0]*/   .I_R_AVG      (OUPUT_SENSOR2_400K_R_AVG ),     
            /*input       [31 : 0]*/   .I_JX_AVG     (OUPUT_SENSOR2_400K_JX_AVG),     
            /*input               */   .pulse_pwm_on (pulse4_400k_pwm_on       ),     
            /*input               */   .CW_MODE      (CW_MODE4_400K            ),     
            /*input               */   .PW_MODE      (PW_MODE4_400K            ),     
            /*input               */   .power_fall   (OS2_400k_I_fall          ),     
            /*input               */   .open_status  (open_status4_400k        ),     
            /*input       [15 : 0]*/   .power_pwm_dly(w_OS2_pwm_dly_400k       ),     
            /*input       [15 : 0]*/   .pulse_gap    (w_pulse_gap4_400k        ),     
            /*output  reg         */   .O_Z_pulse_pwm(w_Z_pulse4_pwm_400k      ),     
            /*output  reg [31 : 0]*/   .O_R          (R4_400k_result	       ),     
            /*output  reg [31 : 0]*/   .O_JX         (JX4_400k_result          ),     
            /*input       [31 : 0]*/   .OS_V_AVG     (OS2_400K_V_AVG           ),     
            /*input       [31 : 0]*/   .OS_I_AVG     (OS2_400K_I_AVG           ),     
            /*output  reg [31 : 0]*/   .OS_V_RESULT  (OS2_400K_V_RESULT        ),     
            /*output  reg [31 : 0]*/   .OS_I_RESULT  (OS2_400K_I_RESULT        )     
        );
    `else
        CW_PW_R_JX_RESULT  u_CW_PW_R_JX_RESULT(                         //PW/CW时候的R+ jx筛选
            /*input*/				    .clk                  (clk_50m             ),	 
            /**/						
            /*input       [31 : 0]*/	.R0_AVG               (INPUT_SENSOR0_R_AVG ), //HF
            /*input       [31 : 0]*/	.JX0_AVG              (INPUT_SENSOR0_JX_AVG),
            /**/					
            /*input       [31 : 0]*/	.R1_AVG               (OUPUT_SENSOR0_R_AVG ), //OS0
            /*input       [31 : 0]*/	.JX1_AVG              (OUPUT_SENSOR0_JX_AVG),										
            /*input       [31 : 0]*/	.R2_AVG               (INPUT_SENSOR1_R_AVG ), //LF ；或者OS3
            /*input       [31 : 0]*/	.JX2_AVG              (INPUT_SENSOR1_JX_AVG),
            /**/					
            /*input       [31 : 0]*/	.R3_AVG               (OUPUT_SENSOR1_R_AVG ), //OS1
            /*input       [31 : 0]*/	.JX3_AVG              (OUPUT_SENSOR1_JX_AVG),
            /*input       [31 : 0]*/	.R3_400K_AVG          (OUPUT_SENSOR1_400K_R_AVG ), //OS1
            /*input       [31 : 0]*/	.JX3_400K_AVG         (OUPUT_SENSOR1_400K_JX_AVG),
            /**/					
            /*input       [31 : 0]*/	.R4_AVG               (OUPUT_SENSOR2_R_AVG ), //OS2
            /*input       [31 : 0]*/	.JX4_AVG              (OUPUT_SENSOR2_JX_AVG),
            /*input       [31 : 0]*/	.R4_400K_AVG          (OUPUT_SENSOR2_400K_R_AVG ), //OS2
            /*input       [31 : 0]*/	.JX4_400K_AVG         (OUPUT_SENSOR2_400K_JX_AVG),
            /**/                                                                      
            /*input       [31 : 0]*/    .OS0_V_AVG            (OS0_V_AVG           ), //计算电压电流的波形取pw稳定的段;Cw则持续输出;
            /*input       [31 : 0]*/    .OS0_I_AVG            (OS0_I_AVG           ),
            /*input       [31 : 0]*/    .OS1_V_AVG            (OS1_V_AVG           ),
            /*input       [31 : 0]*/    .OS1_I_AVG            (OS1_I_AVG           ),
            /*input       [31 : 0]*/    .OS1_400K_V_AVG       (OS1_400K_V_AVG      ),
            /*input       [31 : 0]*/    .OS1_400K_I_AVG       (OS1_400K_I_AVG      ),
            /*input       [31 : 0]*/    .OS2_V_AVG            (OS2_V_AVG           ),
            /*input       [31 : 0]*/    .OS2_I_AVG            (OS2_I_AVG           ),						
            /*input       [31 : 0]*/    .OS2_400K_V_AVG       (OS2_400K_V_AVG      ),
            /*input       [31 : 0]*/    .OS2_400K_I_AVG       (OS2_400K_I_AVG      ),
            /**/
            /*input                */   .pulse0_pwm_on        (pulse0_pwm_on       ),	
            /*input                */   .pulse1_pwm_on        (pulse1_pwm_on       ),	
            /*input                */   .pulse2_pwm_on        (pulse2_pwm_on       ),	//no use :LF
            /*input                */   .pulse3_pwm_on        (pulse3_pwm_on       ),	
            /*input                */   .pulse3_400k_pwm_on   (pulse3_400k_pwm_on  ),	
            /*input                */   .pulse4_400k_pwm_on   (pulse4_400k_pwm_on  ),						
            /*input                */	.pulse4_pwm_on        (pulse4_pwm_on       ),	
            /**/						
            /*input                */   .CW_MODE0             (CW_MODE0            ),
            /*input                */   .PW_MODE0             (PW_MODE0            ), 
            /**/						
            /*input                */    .CW_MODE1             (CW_MODE1            ),
            /*input                */    .PW_MODE1             (PW_MODE1            ), 
            /**/						
            /*input                */   .CW_MODE2             (CW_MODE2            ),//no use :LF
            /*input                */   .PW_MODE2             (PW_MODE2            ), 	
            /**/
            /*input                */  .CW_MODE3             (CW_MODE3            ),
            /*input                */  .PW_MODE3             (PW_MODE3            ), 	
            /*input                */  .CW_MODE3_400K        (CW_MODE3_400K       ),
            /*input                */  .PW_MODE3_400K        (PW_MODE3_400K       ), 	
            /**/						
            /*input                */  .CW_MODE4             (CW_MODE4            ),
            /*input                */  .PW_MODE4             (PW_MODE4            ), 							
            /*input                */  .CW_MODE4_400K        (CW_MODE4_400K       ),
            /*input                */  .PW_MODE4_400K        (PW_MODE4_400K       ), 	
            /**/												
            /*input                */   .power_fall0          (IS0_power_fall  ),
            /*input                */	.open_status0         (open_status0        ), 
            /**/
            /*input                */   .power_fall1          (OS0_I_fall          ),
            /*input                */	.open_status1         (open_status1        ), 
            /**/                    
            /*input*/     		   // .power_fall2          (IS1_power_fall  ),
            /*input*/			   // .open_status2         (open_status2        ), 	
            /**/						
            /*input                */    .power_fall3          (OS1_I_fall          ),
            /*input                */	 .open_status3         (open_status3        ), 						
            /*input                */    .power_fall3_400k     (OS1_400k_I_fall     ),
            /*input                */	 .open_status3_400k    (open_status3_400k   ), 						
            /**/
            /*input                */    .power_fall4          (OS2_I_fall          ),
            /*input                */	 .open_status4         (open_status4        ), 
            /*input                */    .power_fall4_400k     (OS2_400k_I_fall     ),
            /*input                */	 .open_status4_400k    (open_status4_400k   ), 	
            /**/																   
            /*input       [15 : 0]*/	.power_pwm_dly0       (w_IS0_power_pwm_dly0    ),															   
            /*input       [15 : 0]*/	.power_pwm_dly2       (w_IS1_power_pwm_dly2    ),	
            /*input       [15 : 0]*/	.i_pwm_dly0           (w_OS0_pwm_dly        ),
            /*input       [15 : 0]*/	.i_pwm_dly1           (w_OS1_pwm_dly        ),
            /*input       [15 : 0]*/	.i_pwm_dly1_400k      (w_OS1_pwm_dly_400k   ),						
            /*input       [15 : 0]*/	.i_pwm_dly2           (w_OS2_pwm_dly        ),						
            /*input       [15 : 0]*/	.i_pwm_dly2_400k      (w_OS2_pwm_dly_400k   ),
            /**/					
            /*input       [15 : 0]*/   .pulse_gap0           (w_pulse_gap0        ),
            /*input       [15 : 0]*/   .pulse_gap1           (w_pulse_gap1        ),
            /*input       [15 : 0]*/   .pulse_gap2           (w_pulse_gap2        ),		
            /*input       [15 : 0]*/   .pulse_gap3           (w_pulse_gap3        ),	
            /*input       [15 : 0]*/   .pulse_gap3_400k      (w_pulse_gap3_400k   ),		
            /*input       [15 : 0]*/   .pulse_gap4           (w_pulse_gap4        ),
            /*input       [15 : 0]*/   .pulse_gap4_400k      (w_pulse_gap4_400k   ),		
            /**/						
            /*output  reg         */	.Z_pulse0_pwm         (w_Z_pulse0_pwm      ),
            /*output  reg         */	.Z_pulse1_pwm         (w_Z_pulse1_pwm      ),
            /*output  reg         */	.Z_pulse2_pwm         (w_Z_pulse2_pwm      ), //
            /*output  reg         */	.Z_pulse3_pwm         (w_Z_pulse3_pwm      ), //OS1
            /*output  reg         */	.Z_pulse3_pwm_400k    (w_Z_pulse3_pwm_400k ), //OS1_400k
            /*output  reg         */	.Z_pulse4_pwm         (w_Z_pulse4_pwm      ), //OS2						
            /*output  reg         */	.Z_pulse4_pwm_400k    (w_Z_pulse4_pwm_400k ), //OS2_400k
            /**/
            /**/						
            /*output  reg [31 : 0]*/	.R0                   (R0_result	       ),//CW_PW_R_JX_RESULT 脉冲?
            /*output  reg [31 : 0]*/	.JX0                  (JX0_result	       ),
            /*output  reg [31 : 0]*/	.R1                   (R1_result	       ),
            /*output  reg [31 : 0]*/	.JX1                  (JX1_result          ),
            /*output  reg [31 : 0]*/	.R2                   (R2_result	       ),
            /*output  reg [31 : 0]*/	.JX2                  (JX2_result          ),
            /**/					
            /*output  reg [31 : 0]*/	.R3                   (R3_result	       ),
            /*output  reg [31 : 0]*/	.JX3                  (JX3_result          ),
            /*output  reg [31 : 0]*/	.R3_400K              (R3_400k_result	   ),
            /*output  reg [31 : 0]*/	.JX3_400K             (JX3_400k_result     ),
            /**/						
            /*output  reg [31 : 0]*/	.R4                   (R4_result	       ),
            /*output  reg [31 : 0]*/	.JX4                  (JX4_result          ), 
            /*output  reg [31 : 0]*/	.R4_400K              (R4_400k_result	   ),//CW_PW_R_JX_RESULT
            /*output  reg [31 : 0]*/	.JX4_400K             (JX4_400k_result     ), 
            //PW电压电流选择�??
            /*output  reg [31 : 0]*/    .OS0_V_RESULT         (OS0_V_RESULT        ),
            /*output  reg [31 : 0]*/    .OS0_I_RESULT         (OS0_I_RESULT        ),
            /**/
            /*output  reg [31 : 0]*/    .OS1_V_RESULT         (OS1_V_RESULT        ),
            /*output  reg [31 : 0]*/    .OS1_I_RESULT         (OS1_I_RESULT        ),
            /*output  reg [31 : 0]*/    .OS1_400K_V_RESULT    (OS1_400K_V_RESULT   ),
            /*output  reg [31 : 0]*/    .OS1_400K_I_RESULT    (OS1_400K_I_RESULT   ),
            /**/					  
            /*output  reg [31 : 0]*/    .OS2_V_RESULT         (OS2_V_RESULT        ),
            /*output  reg [31 : 0]*/    .OS2_I_RESULT         (OS2_I_RESULT        ),						
            /*output  reg [31 : 0]*/    .OS2_400K_V_RESULT    (OS2_400K_V_RESULT   ),
            /*output  reg [31 : 0]*/    .OS2_400K_I_RESULT    (OS2_400K_I_RESULT   )
        );
    `endif
    //精度处理，精确到百分位；
    AVG_IIR_signed  HF_AVG_IIR_R0 (
        /*input            */    .clk_i               (clk_50m           ),
        /*input            */    .rst_i               (rst_125           ),
        /*input [31:0]     */    .din                 (R0_result         ),
        /*input            */    .din_en              (power_status0     ),
        /*output reg [31:0]*/    .dout                (AVG_IIR_R0        ),//CH0 返回上位机的值
        /*output reg       */    .dout_en             (                  )
    );

    AVG_IIR_signed  HF_AVG_IIR_JX0 (
        /*input            */    .clk_i               (clk_50m           ),
        /*input            */    .rst_i               (rst_125           ),
        /*input [31:0]     */    .din                 (JX0_result        ),
        /*input            */    .din_en              (power_status0     ),
        /*output reg [31:0]*/    .dout                (AVG_IIR_JX0       ),//CH0 返回上位机的值
        /*output reg       */    .dout_en             (                  )
    );

    // AVG_IIR_signed  OS0_AVG_IIR_R1 (
                            // .clk_i               (clk_50m           ),
                            // .rst_i               (rst_125           ),
                            // .din                 (R1_result         ),
                            // .din_en              (power_status1     ),
                            // .dout                (AVG_IIR_R1        ),
                            // .dout_en             (                  )
    // );
    // AVG_IIR_signed  OS0_AVG_IIR_JX1 (
                            // .clk_i               (clk_50m           ),
                            // .rst_i               (rst_125           ),
                            // .din                 (JX1_result        ),
                            // .din_en              (power_status1     ),
                            // .dout                (AVG_IIR_JX1       ),
                            // .dout_en             (                  )
    // );

    AVG_IIR_signed  LF_AVG_IIR_R2 (
        /*input            */     .clk_i               (clk_50m           ),
        /*input            */     .rst_i               (rst_125           ),
        /*input [31:0]     */     .din                 (R2_result         ),
        /*input            */     .din_en              (power_status2     ),
        /*output reg [31:0]*/     .dout                (AVG_IIR_R2        ),
        /*output reg       */     .dout_en             (                  )
    );

    AVG_IIR_signed  LF_AVG_IIR_JX2 (
        /*input            */     .clk_i               (clk_50m           ),
        /*input            */     .rst_i               (rst_125           ),
        /*input [31:0]     */     .din                 (JX2_result        ),
        /*input            */     .din_en              (power_status2     ),
        /*output reg [31:0]*/     .dout                (AVG_IIR_JX2       ),
        /*output reg       */     .dout_en             (                  )
    );

    // AVG_IIR_signed  OS1_AVG_IIR_R3 (
                            // .clk_i               (clk_50m           ),
                            // .rst_i               (rst_125           ),
                            // .din                 (R3_result         ),
                            // .din_en              (power_status3     ),
                            // .dout                (AVG_IIR_R3        ),
                            // .dout_en             (                  )
    // );
    // AVG_IIR_signed  OS1_AVG_IIR_JX3 (
                            // .clk_i               (clk_50m           ),
                            // .rst_i               (rst_125           ),
                            // .din                 (JX3_result        ),
                            // .din_en              (power_status3     ),
                            // .dout                (AVG_IIR_JX3       ),
                            // .dout_en             (                  )
    // );
    // AVG_IIR_signed  OS1_400K_AVG_IIR_R3 (
                            // .clk_i               (clk_50m           ),
                            // .rst_i               (rst_125           ),
                            // .din                 (R3_400k_result    ),
                            // .din_en              (power_status3_400k),
                            // .dout                (AVG_IIR_400K_R3   ),
                            // .dout_en             (                  )
    // );
    // AVG_IIR_signed  OS1_400K_AVG_IIR_JX3 (
                            // .clk_i               (clk_50m           ),
                            // .rst_i               (rst_125           ),
                            // .din                 (JX3_400k_result   ),
                            // .din_en              (power_status3_400k),
                            // .dout                (AVG_IIR_400K_JX3  ),
                            // .dout_en             (                  )
    // );

    AVG_IIR_signed  OS2_AVG_IIR_R4 (
        /*input            */             .clk_i               (clk_50m           ),
        /*input            */             .rst_i               (rst_125           ),
        /*input [31:0]     */             .din                 (R4_result         ),
        /*input            */             .din_en              (power_status4     ),
        /*output reg [31:0]*/             .dout                (AVG_IIR_R4        ),
        /*output reg       */             .dout_en             (                  )
    );

    AVG_IIR_signed  OS2_AVG_IIR_JX4 (
        /*input            */             .clk_i               (clk_50m           ),
        /*input            */             .rst_i               (rst_125           ),
        /*input [31:0]     */             .din                 (JX4_result        ),
        /*input            */             .din_en              (power_status4     ),
        /*output reg [31:0]*/             .dout                (AVG_IIR_JX4       ),
        /*output reg       */             .dout_en             (                  )
    );
    AVG_IIR_signed  OS2_400K_AVG_IIR_R4 (
        /*input            */                 .clk_i               (clk_50m           ),
        /*input            */                 .rst_i               (rst_125           ),
        /*input [31:0]     */                 .din                 (R4_400k_result    ),
        /*input            */                 .din_en              (power_status4_400k),
        /*output reg [31:0]*/                 .dout                (AVG_IIR_400K_R4   ),
        /*output reg       */                 .dout_en             (                  )
    );

    AVG_IIR_signed  OS2_400K_AVG_IIR_JX4 (
        /*input            */           .clk_i               (clk_50m           ),
        /*input            */           .rst_i               (rst_125           ),
        /*input [31:0]     */           .din                 (JX4_400k_result   ),
        /*input            */           .din_en              (power_status4_400k),
        /*output reg [31:0]*/           .dout                (AVG_IIR_400K_JX4  ),//返回上位机的值
        /*output reg       */           .dout_en             (                  )
    );

`endif 
 
/***********************************************pwm_detect**************************************************/
`ifdef IS0_POWER0_EDGE_DETECT 
    AVG_POWER_FILTER AVG_POWER_FILTER_HF(  //去掉异常功率�??
        /*input             */  .clk_i             (clk_50m                ),
        /*input             */  .rst_i             (rst_125                ),
        /*input             */  .power_calib_vld   (1'b1                   ),
        /*input [15:0]      */  .power_calib       (VF_POWER0_K_AVG         ),//进来的值
        /*input [15:0]      */  .filtering_value   (FILTER_THRESHOLD       ),  //异常功率点滤波
        /*input [23:0]      */  .detect_rise_dly   (DETECT_RISE_DLY        ), //窗口大小
        /*input [23:0]      */  .detect_fall_dly   (DETECT_FALL_DLY        ), //窗口大小
        /*output reg [15:0] */  .power_filter      (VF_POWER0_FILTER       ),//去掉异常点的入射功率值
        /*output reg        */  .power_filter_vld  (1'b1                   ),
                                                                    
        /*output reg        */  .power_buf0_vld    (IS0_power_buf0_vld ),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是上升
        /*output reg        */  .power_buf1_vld    (IS0_power_buf1_vld ),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是上升
        /*output reg        */  .power_buf2_vld    (IS0_power_buf2_vld ),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是上升
        /*output reg        */	.power_buf3_vld    (IS0_power_buf3_vld ),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是上升
        /*output reg        */  .power_sub_vld     (IS0_power_sub_vld  ),//移动窗口,最后的计数点，用于四个点的作差运算
                                                                    
        /*output reg        */  .power0_buf0_vld   (IS0_power0_buf0_vld),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是下降
        /*output reg        */  .power0_buf1_vld   (IS0_power0_buf1_vld),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是下降
        /*output reg        */  .power0_buf2_vld   (IS0_power0_buf2_vld),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是下降
        /*output reg        */	.power0_buf3_vld   (IS0_power0_buf3_vld),//移动窗口,窗口内有四个点,用于标记值,根据四个点的值,判断是否是下降
        /*output reg        */  .power0_sub_vld    (IS0_power0_sub_vld )	
    );                                                             
    //wire neg_avg_fall;
    power_edge_detect power_edge_detect_HF(
        /*input            */    .clk_i            (clk_50m              ),
        /*input            */    .rst_i            (rst_125              ),
        /*input            */    .power_filter_vld (1'b1                 ), 		         
        /*input   [15: 0]  */    .vf_power_filter  (VF_POWER0_FILTER     ), //入射功率值

        /*input   [ 9: 0]*/      .rise_jump        (RISE_JUMP            ),//10'd19  上位机配置的上升和下降的判定值 
        /*input   [ 9: 0]*/	     .fall_jump        (FALL_JUMP            ),//10'd15  上位机配置的上升和下降的判定值 //max:1023;
        /*input            */    .power_buf0_vld   (IS0_power_buf0_vld   ),//移动窗口 上升	
        /*input            */    .power_buf1_vld   (IS0_power_buf1_vld   ),//移动窗口 上升
        /*input            */    .power_buf2_vld   (IS0_power_buf2_vld   ),//移动窗口 上升
        /*input            */	 .power_buf3_vld   (IS0_power_buf3_vld   ),//移动窗口 上升
        /*input            */    .power_sub_vld    (IS0_power_sub_vld    ),//移动窗口 上升

        /*input            */    .power0_buf0_vld  (IS0_power0_buf0_vld  ),//移动窗口 下降	
        /*input            */    .power0_buf1_vld  (IS0_power0_buf1_vld  ),//移动窗口 下降
        /*input            */    .power0_buf2_vld  (IS0_power0_buf2_vld  ),//移动窗口 下降
        /*input            */	 .power0_buf3_vld  (IS0_power0_buf3_vld  ),//移动窗口 下降
        /*input            */    .power0_sub_vld   (IS0_power0_sub_vld   ),//移动窗口 下降
                                
        /*input   [15:0]*/		 .pulse_start      (w_IS0_PULSE_START0   ),//16'd100 上位机配置的
        /*input   [15:0]*/       .pulse_end        (w_IS0_PULSE_END0     ),//16'd700 上位机配置的
        /*output  reg   */		 .power_keep       (pulse0_pwm_on        ),
        /*output        */	     .power_fall       (IS0_power_fall       ),
        /*output        */	     .power_rise       (IS0_power_rise       ),

        /*output  reg   */		 .avg_keep         (sensor0_avg_keep     ),//NO USED                                                                        
        /*output reg [35:0] */   .keep_dly         (sensor0_keep_dly     ),//NO USED
        /*output reg [35:0] */   .pulse_on_cnt     (sensor0_pulse_on_cnt ) //NO USED						 
                                // .neg_avg_fall     (neg_avg_fall     ),
    );

    RF_MODE_SENSOR   RF_MODE_SENSOR_HF(
        /*input           */ .clk                 (clk_50m                   ),
        /*input           */ .rst                 (rst_125                   ),
        /*input [31:0]    */ .vf_power            (VF_POWER0_FILTER          ),
        /*input           */ .calib_vf_vld        (1'b1                      ),
        /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD           ),//32'd30  
        /*input           */ .power_rise          (IS0_power_rise            ),
        /*input           */ .power_fall          (IS0_power_fall            ),
        /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY              ),//32'd1000000  //20ms Ttotal=N×Tclk=1000000×20ns=20000000ns
        /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH        ),//32'd10000000,//200ms;
        /*input [31:0]    */ .OFF_NUM             (OFF_NUM                   ),//32'd3000000, //60ms;
        /*output          */ .open_status         (open_status0              ),
        /*output          */ .CW_MODE             (CW_MODE0                  ), 
        /*output          */ .PW_MODE             (PW_MODE0                  ), 
        /*output reg      */ .power_status        (power_status0             )
    );
`endif 
`ifdef IS1_POWER2_EDGE_DETECT  
    AVG_POWER_FILTER AVG_POWER_FILTER_LF(
        /*input             */  .clk_i             (clk_50m                ),
        /*input             */  .rst_i             (rst_125                ),
        /*input             */  .power_calib_vld   (1'b1                   ),
        /*input [15:0]      */  .power_calib       (VF_POWER2_K_AVG        ),
        /*input [15:0]      */  .filtering_value   (FILTER_THRESHOLD       ),		//异常功率点滤�?
        /*input [23:0]      */  .detect_rise_dly   (DETECT_RISE_DLY2       ),
        /*input [23:0]      */  .detect_fall_dly   (DETECT_FALL_DLY2       ),
        /*output reg [15:0] */  .power_filter      (VF_POWER2_FILTER       ),
        /*output reg        */  .power_filter_vld  (1'b1                   ),
                                                                    
        /*output reg        */  .power_buf0_vld    (IS1_power_buf0_vld ),
        /*output reg        */  .power_buf1_vld    (IS1_power_buf1_vld ),
        /*output reg        */  .power_buf2_vld    (IS1_power_buf2_vld ),
        /*output reg        */ 	.power_buf3_vld    (IS1_power_buf3_vld ),
        /*output reg        */  .power_sub_vld     (IS1_power_sub_vld  ),
                                                                    
        /*output reg        */  .power0_buf0_vld   (IS1_power0_buf0_vld),
        /*output reg        */  .power0_buf1_vld   (IS1_power0_buf1_vld),
        /*output reg        */  .power0_buf2_vld   (IS1_power0_buf2_vld),
        /*output reg        */ 	.power0_buf3_vld   (IS1_power0_buf3_vld),
        /*output reg        */  .power0_sub_vld    (IS1_power0_sub_vld )	
    );     
    //wire neg_avg_fall;
    power_edge_detect power_edge_detect_LF(
        /*input            */    .clk_i            (clk_50m                  ),
        /*input            */    .rst_i            (rst_125                  ),
        /*input            */    .power_filter_vld (1'b1 ), 		         
        /*input   [15: 0]  */    .vf_power_filter  (VF_POWER2_FILTER         ), 

        /*input   [ 9: 0] */     .rise_jump        (RISE_JUMP2               ),
        /*input   [ 9: 0] */	 .fall_jump        (FALL_JUMP2               ),//max:1023;
        /*input            */    .power_buf0_vld   (IS1_power_buf0_vld   ),	
        /*input            */    .power_buf1_vld   (IS1_power_buf1_vld   ),
        /*input            */    .power_buf2_vld   (IS1_power_buf2_vld   ),
        /*input            */	 .power_buf3_vld   (IS1_power_buf3_vld   ),
        /*input            */    .power_sub_vld    (IS1_power_sub_vld    ),

        /*input            */    .power0_buf0_vld  (IS1_power0_buf0_vld  ),	
        /*input            */    .power0_buf1_vld  (IS1_power0_buf1_vld  ),
        /*input            */    .power0_buf2_vld  (IS1_power0_buf2_vld  ),
        /*input            */	 .power0_buf3_vld  (IS1_power0_buf3_vld  ),
        /*input            */    .power0_sub_vld   (IS1_power0_sub_vld   ),
                                
        /*input   [15:0]*/		 .pulse_start      (w_IS1_PULSE_START2           ),
        /*input   [15:0]*/       .pulse_end        (w_IS1_PULSE_END2             ),
                                
        /* output  reg  */       // .power_keep       (pulse2_pwm_on            ),
        /* output  reg  */	     .power_fall       (IS1_power_fall       ),
        /* output  reg  */	     .power_rise       (IS1_power_rise       ),
        /* output  reg  */       .avg_keep         (sensor2_avg_keep         ),//NO USED 

        /*output reg [35:0] */   .keep_dly         (sensor2_keep_dly         ),//NO USED 
        /*output reg [35:0] */   .pulse_on_cnt     (sensor2_pulse_on_cnt     )	//NO USED 						 
                                // .neg_avg_fall     (neg_avg_fall     ),
    );
    RF_MODE_SENOR_400K   RF_MODE_SENOR_LF(
        /*input           */ .clk                 (clk_50m                  ),
        /*input           */ .rst                 (rst_125                  ),
        /*input [31:0]    */ .vf_power            (VF_POWER2_FILTER         ),
        /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
        /*input [31:0]    */ .OFF_NUM             (OFF_NUM2                 ),
        /*input [31:0]    */ .ON_KEEP_NUM         (ON_KEEP_NUM              ),      
        /*input [31:0]    */ .OFF_KEEP_NUM        (OFF_KEEP_NUM             ),      
        /*output reg      */ .pwm_on              (pulse2_pwm_on            ),
        /*output reg      */ .CW_MODE             (CW_MODE2                 ), 
        /*output reg      */ .PW_MODE             (PW_MODE2                 ), 
        /*output reg      */ .power_status        (power_status2            )
    );
    // RF_MODE_SENSOR   RF_MODE_SENSOR_LF(
        // /*input           */ .clk                 (clk_50m                  ),
        // /*input           */ .rst                 (rst_125                  ),
        // /*input [31:0]    */ .vf_power            (VF_POWER2_FILTER         ),
        // /*input           */ .calib_vf_vld        (1'b1                     ),
        // /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
        // /*input           */ .power_rise          (IS1_power_rise       ),
        // /*input           */ .power_fall          (IS1_power_fall       ),
        // /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY2            ),
        // /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH2      ),
                            // .OFF_NUM             (OFF_NUM2                 ),
                            // .open_status         (open_status2             ),
                            // .CW_MODE             (CW_MODE2                 ), 
                            // .PW_MODE             (PW_MODE2                 ), 
                            // .power_status        (power_status2            )
    // );

`endif

// //--------------------------TDM_pulse_on------------------------------------//
`ifdef NO_OS0_POWER_EDGE_DETECT 
    AVG_POWER_FILTER AVG_POWER_FILTER_OS0(
        /*input             */  .clk_i             (clk_50m                 ),
        /*input             */  .rst_i             (rst_125                 ),
        /*input             */  .power_calib_vld   (1'b1                    ),
        /*input [15:0]      */  .power_calib       (OS0_I_AVG>>11           ),
        /*input [15:0]      */  .filtering_value   (OS0_FILTER_THRESHOLD    ),	//异常功率点滤�?
        /*input [23:0]      */  .detect_rise_dly   (OS0_DETECT_RISE_DLY     ),
        /*input [23:0]      */  .detect_fall_dly   (OS0_DETECT_FALL_DLY     ),
        /*output reg [15:0] */  .power_filter      (w_OS0_filter_I       ),
        /*output reg        */  .power_filter_vld  (1'b1                    ),
                                                                        
        /*output reg        */  .power_buf0_vld    (OS0_I_buf0_vld          ),
                                .power_buf1_vld    (OS0_I_buf1_vld          ),
                                .power_buf2_vld    (OS0_I_buf2_vld          ),
                                .power_buf3_vld    (OS0_I_buf3_vld          ),
                                .power_sub_vld     (OS0_I_sub_vld           ),
                                                                                
        /*output reg        */  .power0_buf0_vld   (OS0_I1_buf0_vld         ),
                                .power0_buf1_vld   (OS0_I1_buf1_vld         ),
                                .power0_buf2_vld   (OS0_I1_buf2_vld         ),
                                .power0_buf3_vld   (OS0_I1_buf3_vld         ),
                                .power0_sub_vld    (OS0_I1_sub_vld          )	
                                                                                    
    );                                                             

    power_edge_detect power_edge_detect_OS0(
        /*input            */    .clk_i            (clk_50m                 ),
        /*input            */    .rst_i            (rst_125                 ),
        /*input            */    .power_filter_vld (1'b1                    ), 		     
        /*input   [15: 0]  */    .vf_power_filter  (w_OS0_filter_I       ), 
                                                                        
                                .rise_jump        (OS0_RISE_JUMP           ),
                                .fall_jump        (OS0_FALL_JUMP           ),//max:1023;
        /*input            */    .power_buf0_vld   (OS0_I_buf0_vld          ),	
        /*input            */    .power_buf1_vld   (OS0_I_buf1_vld          ),
                                .power_buf2_vld   (OS0_I_buf2_vld          ),
                                .power_buf3_vld   (OS0_I_buf3_vld          ),
        /*input            */    .power_sub_vld    (OS0_I_sub_vld           ),
                                                                            
        /*input            */    .power0_buf0_vld  (OS0_I1_buf0_vld         ),	
        /*input            */    .power0_buf1_vld  (OS0_I1_buf1_vld         ),
                                .power0_buf2_vld  (OS0_I1_buf2_vld         ),
                                .power0_buf3_vld  (OS0_I1_buf3_vld         ),
        /*input            */    .power0_sub_vld   (OS0_I1_sub_vld          ),
                                                                            
                                .pulse_start      (w_OS0_PULSE_START1       ),
                                .pulse_end        (w_OS0_PULSE_END1         ),
                                                                        
                                .power_keep       (pulse1_pwm_on           ),
                                .power_fall       (OS0_I_fall              ),
                                .power_rise       (OS0_I_rise              ),
                                .avg_keep         (OS0_avg_keep            ),//NO USED 
                                                                            
        /*output reg [35:0] */   .keep_dly         (OS0_keep_dly            ),//NO USED 
        /*output reg [35:0] */   .pulse_on_cnt     (OS0_pulse_on_cnt        )//NO USED 							 
                                // .neg_avg_fall     (neg_avg_fall     ),
    );

    RF_MODE_SENSOR   RF_MODE_SENSOR_OS0(
        /*input           */ .clk                 (clk_50m                  ),
        /*input           */ .rst                 (rst_125                  ),
        /*input [31:0]    */ .vf_power            (w_OS0_filter_I        ),
        /*input           */ .calib_vf_vld        (1'b1                     ),
        /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
        /*input           */ .power_rise          (OS0_I_rise               ),
        /*input           */ .power_fall          (OS0_I_fall               ),
        /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY1            ),
        /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH1      ),
                            .OFF_NUM             (OFF_NUM1                 ),
                            .open_status         (open_status1             ),
                            .CW_MODE             (CW_MODE1                 ), 
                            .PW_MODE             (PW_MODE1                 ), 
                            .power_status        (power_status1            )
    );
`endif 

`ifdef NO_OS1_POWER_EDGE_DETECT 
    AVG_POWER_FILTER AVG_POWER_FILTER_OS1(
        /*input             */  .clk_i             (clk_50m                 ),
        /*input             */  .rst_i             (rst_125                 ),
        /*input             */  .power_calib_vld   (1'b1                    ),
        /*input [15:0]      */  .power_calib       (OS1_I_AVG>>9            ),
        /*input [15:0]      */  .filtering_value   (OS1_FILTER_THRESHOLD    ),		//异常功率点滤波
        /*input [23:0]      */  .detect_rise_dly   (OS1_DETECT_RISE_DLY     ),
        /*input [23:0]      */  .detect_fall_dly   (OS1_DETECT_FALL_DLY     ),
        /*output reg [15:0] */  .power_filter      (w_OS1_filter_I       ),
        /*output reg        */  .power_filter_vld  (1'b1                    ),
                                                                        
        /*output reg        */  .power_buf0_vld    (OS1_I_buf0_vld          ),
                                .power_buf1_vld    (OS1_I_buf1_vld          ),
                                .power_buf2_vld    (OS1_I_buf2_vld          ),
                                .power_buf3_vld    (OS1_I_buf3_vld          ),
                                .power_sub_vld     (OS1_I_sub_vld           ),
                                                                                
        /*output reg        */  .power0_buf0_vld   (OS1_I1_buf0_vld         ),
                                .power0_buf1_vld   (OS1_I1_buf1_vld         ),
                                .power0_buf2_vld   (OS1_I1_buf2_vld         ),
                                .power0_buf3_vld   (OS1_I1_buf3_vld         ),
                                .power0_sub_vld    (OS1_I1_sub_vld          )	
                                                                                    
    );                                                             
    AVG_POWER_FILTER AVG_POWER_FILTER_400K_OS1(
        /*input             */  .clk_i             (clk_50m                 ),
        /*input             */  .rst_i             (rst_125                 ),
        /*input             */  .power_calib_vld   (1'b1                    ),
        /*input [15:0]      */  .power_calib       (OS1_400K_I_AVG>>9   ),
        /*input [15:0]      */  .filtering_value   (OS1_400K_FILTER_THRESHOLD),	//异常功率点滤波
        /*input [23:0]      */  .detect_rise_dly   (OS1_400K_DETECT_RISE_DLY ),
        /*input [23:0]      */  .detect_fall_dly   (OS1_400K_DETECT_FALL_DLY ),
        /*output reg [15:0] */  .power_filter      (w_OS1_400k_filter_I  ),
        /*output reg        */  .power_filter_vld  (1'b1                   ),
                                                                        
        /*output reg        */  .power_buf0_vld    (OS1_400K_I_buf0_vld    ),
                                .power_buf1_vld    (OS1_400K_I_buf1_vld    ),
                                .power_buf2_vld    (OS1_400K_I_buf2_vld    ),
                                .power_buf3_vld    (OS1_400K_I_buf3_vld    ),
                                .power_sub_vld     (OS1_400K_I_sub_vld     ),
                                                                        
        /*output reg        */  .power0_buf0_vld   (OS1_400K_I1_buf0_vld   ),
                                .power0_buf1_vld   (OS1_400K_I1_buf1_vld   ),
                                .power0_buf2_vld   (OS1_400K_I1_buf2_vld   ),
                                .power0_buf3_vld   (OS1_400K_I1_buf3_vld   ),
                                .power0_sub_vld    (OS1_400K_I1_sub_vld    )										   					
    );  
    power_edge_detect power_edge_detect_OS1(
        /*input            */    .clk_i            (clk_50m                 ),
        /*input            */    .rst_i            (rst_125                 ),
        /*input            */    .power_filter_vld (1'b1                    ), 		     
        /*input   [15: 0]  */    .vf_power_filter  (w_OS1_filter_I       ), 
                                                                        
                                .rise_jump        (OS1_RISE_JUMP           ),
                                .fall_jump        (OS1_FALL_JUMP           ),//max:1023;
        /*input            */    .power_buf0_vld   (OS1_I_buf0_vld          ),	
        /*input            */    .power_buf1_vld   (OS1_I_buf1_vld          ),
                                .power_buf2_vld   (OS1_I_buf2_vld          ),
                                .power_buf3_vld   (OS1_I_buf3_vld          ),
        /*input            */    .power_sub_vld    (OS1_I_sub_vld           ),
                                                                            
        /*input            */    .power0_buf0_vld  (OS1_I1_buf0_vld         ),	
        /*input            */    .power0_buf1_vld  (OS1_I1_buf1_vld         ),
                                .power0_buf2_vld  (OS1_I1_buf2_vld         ),
                                .power0_buf3_vld  (OS1_I1_buf3_vld         ),
        /*input            */    .power0_sub_vld   (OS1_I1_sub_vld          ),
                                                                            
                                .pulse_start      (w_OS1_PULSE_START       ),
                                .pulse_end        (w_OS1_PULSE_END         ),
                                                                        
                                .power_keep       (pulse3_pwm_on           ),
                                .power_fall       (OS1_I_fall              ),
                                .power_rise       (OS1_I_rise              ),
                                .avg_keep         (OS1_avg_keep            ),
                                                                            
        /*output reg [35:0] */   .keep_dly         (OS1_keep_dly            ),
        /*output reg [35:0] */   .pulse_on_cnt     (OS1_pulse_on_cnt        )							 
                                // .neg_avg_fall     (neg_avg_fall     ),
    );
    power_edge_detect power_edge_detect_400k_OS1(
        /*input            */    .clk_i            (clk_50m                 ),
        /*input            */    .rst_i            (rst_125                 ),
        /*input            */    .power_filter_vld (1'b1                    ), 		     
        /*input   [15: 0]  */    .vf_power_filter  (w_OS1_400k_filter_I ), 
                                                                        
                                .rise_jump        (OS1_400K_RISE_JUMP      ),
                                .fall_jump        (OS1_400K_FALL_JUMP      ),//max:1023;
        /*input            */    .power_buf0_vld   (OS1_400K_I_buf0_vld     ),	
        /*input            */    .power_buf1_vld   (OS1_400K_I_buf1_vld     ),
                                .power_buf2_vld   (OS1_400K_I_buf2_vld     ),
                                .power_buf3_vld   (OS1_400K_I_buf3_vld     ),
        /*input            */    .power_sub_vld    (OS1_400K_I_sub_vld      ),
                                                                            
        /*input            */    .power0_buf0_vld  (OS1_400K_I1_buf0_vld    ),	
        /*input            */    .power0_buf1_vld  (OS1_400K_I1_buf1_vld    ),
                                .power0_buf2_vld  (OS1_400K_I1_buf2_vld    ),
                                .power0_buf3_vld  (OS1_400K_I1_buf3_vld    ),
        /*input            */    .power0_sub_vld   (OS1_400K_I1_sub_vld     ),
                                                                            
                                .pulse_start      (w_OS1_400K_PULSE_START  ),
                                .pulse_end        (w_OS1_400K_PULSE_END    ),
                                                                        
                                .power_keep       (pulse3_400k_pwm_on      ),
                                .power_fall       (OS1_400k_I_fall         ),
                                .power_rise       (OS1_400k_I_rise         ),
                                .avg_keep         (OS1_400k_avg_keep       ),
                                                                            
        /*output reg [35:0] */   .keep_dly         (OS1_400k_keep_dly       ),
        /*output reg [35:0] */   .pulse_on_cnt     (OS1_400k_pulse_on_cnt   )							 
    );

    RF_MODE_SENSOR   RF_MODE_SENSOR_OS1(
        /*input           */ .clk                 (clk_50m                  ),
        /*input           */ .rst                 (rst_125                  ),
        /*input [31:0]    */ .vf_power            (w_OS1_filter_I       ),
        /*input           */ .calib_vf_vld        (1'b1                     ),
        /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
        /*input           */ .power_rise          (OS1_I_rise               ),
        /*input           */ .power_fall          (OS1_I_fall               ),
        /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY3            ),
        /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH3      ),
                            .OFF_NUM             (OFF_NUM3                 ),
                            .open_status         (open_status3             ),
                            .CW_MODE             (CW_MODE3                 ), 
                            .PW_MODE             (PW_MODE3                 ), 
                            .power_status        (power_status3            )
        );

    RF_MODE_SENSOR   RF_MODE_SENSOR_400K_OS1(
        /*input           */ .clk                 (clk_50m                  ),
        /*input           */ .rst                 (rst_125                  ),
        /*input [31:0]    */ .vf_power            (w_OS1_400k_filter_I  ),
        /*input           */ .calib_vf_vld        (1'b1                     ),
        /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
        /*input           */ .power_rise          (OS1_400k_I_rise          ),
        /*input           */ .power_fall          (OS1_400k_I_fall          ),
        /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY3_400K       ),
        /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH3_400K ),
                            .OFF_NUM             (OFF_NUM3_400K            ),
                            .open_status         (open_status3_400k        ),
                            .CW_MODE             (CW_MODE3_400K            ), 
                            .PW_MODE             (PW_MODE3_400K            ), 
                            .power_status        (power_status3_400k       )
    );
`endif     

`ifdef OS2_POWER_EDGE_DETECT 
    //OS IS都要�??�??
    AVG_POWER_FILTER AVG_POWER_FILTER_OS2(
        /*input             */  .clk_i             (clk_50m                 ),
        /*input             */  .rst_i             (rst_125                 ),
        /*input             */  .power_calib_vld   (1'b1                    ),
        /*input [15:0]      */  .power_calib       (OS2_I_AVG>>9            ),
        /*input [15:0]      */  .filtering_value   (OS2_FILTER_THRESHOLD    ),		//异常功率点滤波
        /*input [23:0]      */  .detect_rise_dly   (OS2_DETECT_RISE_DLY     ),
        /*input [23:0]      */  .detect_fall_dly   (OS2_DETECT_FALL_DLY     ),
        /*output reg [15:0] */  .power_filter      (w_OS2_filter_I       ),
        /*output reg        */  .power_filter_vld  (1'b1                    ),
                                                                        
        /*output reg        */  .power_buf0_vld    (OS2_I_buf0_vld          ),
                                .power_buf1_vld    (OS2_I_buf1_vld          ),
                                .power_buf2_vld    (OS2_I_buf2_vld          ),
                                .power_buf3_vld    (OS2_I_buf3_vld          ),
                                .power_sub_vld     (OS2_I_sub_vld           ),
                                                                                
        /*output reg        */  .power0_buf0_vld   (OS2_I1_buf0_vld         ),
                                .power0_buf1_vld   (OS2_I1_buf1_vld         ),
                                .power0_buf2_vld   (OS2_I1_buf2_vld         ),
                                .power0_buf3_vld   (OS2_I1_buf3_vld         ),
                                .power0_sub_vld    (OS2_I1_sub_vld          )	
                                                                                    
    );                                                             
    AVG_POWER_FILTER AVG_POWER_FILTER_400K_OS2
    (
        /*input             */  .clk_i             (clk_50m                 ),
        /*input             */  .rst_i             (rst_125                 ),
        /*input             */  .power_calib_vld   (1'b1                    ),
        /*input [15:0]      */  .power_calib       (OS2_400K_I_AVG>>9       ),
        /*input [15:0]      */  .filtering_value   (OS2_FILTER_THRESHOLD    ),		//异常功率点滤波
        /*input [23:0]      */  .detect_rise_dly   (OS2_400K_DETECT_RISE_DLY),
        /*input [23:0]      */  .detect_fall_dly   (OS2_400K_DETECT_FALL_DLY),
        /*output reg [15:0] */  .power_filter      (w_OS2_400k_filter_I ),
        /*output reg        */  .power_filter_vld  (1'b1                    ),
                                                                        
        /*output reg        */  .power_buf0_vld    (OS2_400K_I_buf0_vld     ),
                                .power_buf1_vld    (OS2_400K_I_buf1_vld     ),
                                .power_buf2_vld    (OS2_400K_I_buf2_vld     ),
                                .power_buf3_vld    (OS2_400K_I_buf3_vld     ),
                                .power_sub_vld     (OS2_400K_I_sub_vld      ),
                                                                                
        /*output reg        */  .power0_buf0_vld   (OS2_400K_I1_buf0_vld    ),
                                .power0_buf1_vld   (OS2_400K_I1_buf1_vld    ),
                                .power0_buf2_vld   (OS2_400K_I1_buf2_vld    ),
                                .power0_buf3_vld   (OS2_400K_I1_buf3_vld    ),
                                .power0_sub_vld    (OS2_400K_I1_sub_vld     )	
                                                                                    
    );  
    power_edge_detect power_edge_detect_OS2(
        /*input            */    .clk_i            (clk_50m                 ),
        /*input            */    .rst_i            (rst_125                 ),
        /*input            */    .power_filter_vld (1'b1                    ), 		     
        /*input   [15: 0]  */    .vf_power_filter  (w_OS2_filter_I      ), 
                                                                        
                                .rise_jump        (OS2_RISE_JUMP           ),
                                .fall_jump        (OS2_FALL_JUMP           ),//max:1023;
        /*input            */    .power_buf0_vld   (OS2_I_buf0_vld          ),	
        /*input            */    .power_buf1_vld   (OS2_I_buf1_vld          ),
                                .power_buf2_vld   (OS2_I_buf2_vld          ),
                                .power_buf3_vld   (OS2_I_buf3_vld          ),
        /*input            */    .power_sub_vld    (OS2_I_sub_vld           ),
                                                                        
        /*input            */    .power0_buf0_vld  (OS2_I1_buf0_vld         ),	
        /*input            */    .power0_buf1_vld  (OS2_I1_buf1_vld         ),
                                .power0_buf2_vld  (OS2_I1_buf2_vld         ),
                                .power0_buf3_vld  (OS2_I1_buf3_vld         ),
        /*input            */    .power0_sub_vld   (OS2_I1_sub_vld          ),
                                                                            
                                .pulse_start      (w_OS2_PULSE_START       ),
                                .pulse_end        (w_OS2_PULSE_END         ),
                                                                        
                                .power_keep       (pulse4_pwm_on           ),
                                .power_fall       (OS2_I_fall              ),
                                .power_rise       (OS2_I_rise              ),
                                .avg_keep         (OS2_avg_keep            ),
                                                                            
        /*output reg [35:0] */   .keep_dly         (OS2_keep_dly            ),
        /*output reg [35:0] */   .pulse_on_cnt     (OS2_pulse_on_cnt        )							 
                                // .neg_avg_fall     (neg_avg_fall     ),
    );

    power_edge_detect power_edge_detect_400k_OS2(
        /*input            */    .clk_i            (clk_50m                 ),
        /*input            */    .rst_i            (rst_125                 ),
        /*input            */    .power_filter_vld (1'b1                    ), 		     
        /*input   [15: 0]  */    .vf_power_filter  (w_OS2_400k_filter_I ), 
                                                                        
                                .rise_jump        (OS2_400K_RISE_JUMP      ),
                                .fall_jump        (OS2_400K_FALL_JUMP      ),//max:1023;
        /*input            */    .power_buf0_vld   (OS2_400K_I_buf0_vld     ),	
        /*input            */    .power_buf1_vld   (OS2_400K_I_buf1_vld     ),
                                .power_buf2_vld   (OS2_400K_I_buf2_vld     ),
                                .power_buf3_vld   (OS2_400K_I_buf3_vld     ),
        /*input            */    .power_sub_vld    (OS2_400K_I_sub_vld      ),
                                                                        
        /*input            */    .power0_buf0_vld  (OS2_400K_I1_buf0_vld    ),	
        /*input            */    .power0_buf1_vld  (OS2_400K_I1_buf1_vld    ),
                                .power0_buf2_vld  (OS2_400K_I1_buf2_vld    ),
                                .power0_buf3_vld  (OS2_400K_I1_buf3_vld    ),
        /*input            */    .power0_sub_vld   (OS2_400K_I1_sub_vld     ),
                                                                            
                                .pulse_start      (w_OS2_400K_PULSE_START  ),
                                .pulse_end        (w_OS2_400K_PULSE_END    ),
                                                                        
                                .power_keep       (pulse4_400k_pwm_on      ),
                                .power_fall       (OS2_400k_I_fall         ),
                                .power_rise       (OS2_400k_I_rise         ),
                                .avg_keep         (OS2_400k_avg_keep       ),
                                                                            
        /*output reg [35:0] */   .keep_dly         (OS2_400k_keep_dly       ),
        /*output reg [35:0] */   .pulse_on_cnt     (OS2_400k_pulse_on_cnt   )	
    );

    RF_MODE_SENSOR   RF_MODE_SENSOR_OS2(
        /*input           */ .clk                 (clk_50m                  ),
        /*input           */ .rst                 (rst_125                  ),
        /*input [31:0]    */ .vf_power            (w_OS2_filter_I       ),
        /*input           */ .calib_vf_vld        (1'b1                     ),
        /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
        /*input           */ .power_rise          (OS2_I_rise               ),
        /*input           */ .power_fall          (OS2_I_fall               ),
        /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY4            ),
        /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH4      ),
        /*input [31:0]    */ .OFF_NUM             (OFF_NUM4                 ),
        /*output          */ .open_status         (open_status4             ),
        /*output          */ .CW_MODE             (CW_MODE4                 ), 
        /*output          */ .PW_MODE             (PW_MODE4                 ), 
        /*output reg      */ .power_status        (power_status4            )
    );

    RF_MODE_SENSOR   RF_MODE_SENSOR_400K_OS2(  //脉冲或�?�连续波
        /*input           */ .clk                 (clk_50m                  ),
        /*input           */ .rst                 (rst_125                  ),
        /*input [31:0]    */ .vf_power            (w_OS2_400k_filter_I  ),
        /*input           */ .calib_vf_vld        (1'b1                     ),
        /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
        /*input           */ .power_rise          (OS2_400k_I_rise          ),
        /*input           */ .power_fall          (OS2_400k_I_fall          ),
        /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY4_400K       ),
        /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH4_400K ),
        /*input [31:0]    */ .OFF_NUM             (OFF_NUM4_400K            ),
        /*output          */ .open_status         (open_status4_400k        ),
        /*output          */ .CW_MODE             (CW_MODE4_400K            ), 
        /*output          */ .PW_MODE             (PW_MODE4_400K            ), 
        /*output reg      */ .power_status        (power_status4_400k       )
    );
`endif 
                                                        
core	core(
	.i_clk				         (clk_50m	               ),
	.i_rst				         (rst_125	               ),
														   
	.DEBUG_LED		             (debug_led[4:0]	       ),
	.dco_dly     		         (dco_dly      	           ),
	.BIAS_SET		             (BIAS_SET	               ),
	.RF_FREQ0			         (RF_FREQ0			       ),
	.RF_FREQ1			         (RF_FREQ1			       ),	
	.RF_FREQ2			         (RF_FREQ2			       ),	
	.RF_FREQ3			         (RF_FREQ3			       ),	
	.RF_FREQ4			         (RF_FREQ4			       ),	
	
	.freq_out0     		         (freq_out0     	       ),
    .freq_out1     		         (freq_out1     	       ),
	.freq_out2     		         (freq_out2     	       ),
    .freq_out3     		         (freq_out3     	       ),
	.freq_out4     		         (freq_out4     	       ),
	
	.RF_EN				         (RF_EN			           ),//射频功率开关
	.VR_ADC				         (AD9643_CHA		       ),			
	.VF_ADC				         (AD9643_CHB		       ),	
    //原始iq组合�??                  
	.ADC0_FILTER0_I              (r2_SENSOR1_ADC0_I        ),  //V
	.ADC0_FILTER0_Q              (r2_SENSOR1_ADC0_Q        ),  //V
	.ADC1_FILTER0_I              (r2_SENSOR1_ADC1_I        ),  //I
	.ADC1_FILTER0_Q              (r2_SENSOR1_ADC1_Q        ),  //I
	.ADC0_FILTER1_I              (r2_SENSOR3_ADC0_I        ),  //V
	.ADC0_FILTER1_Q              (r2_SENSOR3_ADC0_Q        ),  //V
	.ADC1_FILTER1_I              (r2_SENSOR3_ADC1_I        ),  //I
	.ADC1_FILTER1_Q              (r2_SENSOR3_ADC1_Q        ),  //I
	.ADC0_FILTER2_I              (r2_SENSOR4_ADC0_I        ),  //V
	.ADC0_FILTER2_Q              (r2_SENSOR4_ADC0_Q        ),  //V
	.ADC1_FILTER2_I              (r2_SENSOR4_ADC1_I        ),  //I
	.ADC1_FILTER2_Q              (r2_SENSOR4_ADC1_Q        ),  //I	
	
	.ADC0_FILTER1_400K_I         (r2_SENSOR3_ADC0_400K_I   ),  //V
	.ADC0_FILTER1_400K_Q         (r2_SENSOR3_ADC0_400K_Q   ),  //V
	.ADC1_FILTER1_400K_I         (r2_SENSOR3_ADC1_400K_I   ),  //I
	.ADC1_FILTER1_400K_Q         (r2_SENSOR3_ADC1_400K_Q   ),  //I
	.ADC0_FILTER2_400K_I         (r2_SENSOR4_ADC0_400K_I   ),  //V
	.ADC0_FILTER2_400K_Q         (r2_SENSOR4_ADC0_400K_Q   ),  //V
	.ADC1_FILTER2_400K_I         (r2_SENSOR4_ADC1_400K_I   ),  //I
	.ADC1_FILTER2_400K_Q         (r2_SENSOR4_ADC1_400K_Q   ),  //I		
	
	
	
    //经过decor后的原始iq组合�??     
    .I_DECOR_I                   (SENSOR2_V_DECOR_I       ),  //no use;
    .I_DECOR_Q                   (SENSOR2_V_DECOR_Q       ),  //no use;
    .V_DECOR_I                   (SENSOR2_I_DECOR_I       ),  //no use;
    .V_DECOR_Q                   (SENSOR2_I_DECOR_Q       ),  //no use;
														  
	.VR_CAL_I			         (ch0_calib_vr_i	      ),
	.VR_CAL_Q			         (ch0_calib_vr_q	      ),
	.VF_CAL_I			         (ch0_calib_vf_i	      ),
	.VF_CAL_Q			         (ch0_calib_vf_q	      ),	
	.refl_i				         (refl_i			      ),	//15位定点数
	.refl_q				         (refl_q			      ),	//15位定点数
	.r_jx_i				         (r_jx_i			      ),			
	.r_jx_q				         (r_jx_q			      ),	
														  
	.VR_POWER0			         (VR_POWER0		          ), //IQ 计算到的初始功率值 用于比对计算校准K
	.VF_POWER0			         (VF_POWER0		          ), //IQ 计算到的初始功率值 用于比对计算校准K
	.VR_POWER2			         (VR_POWER2		          ), //IQ 计算到的初始功率值 用于比对计算校准K
	.VF_POWER2			         (VF_POWER2		          ),


	.VR_POWER_CALIB		         (VR_POWER_CALIB	      ), //(无用)总的 经过K校正 的入射路（复用出来就是 sensor1的入射功率和 sensor1 路的I
	.VF_POWER_CALIB		         (VF_POWER_CALIB	      ), //(无用)总的 经过K校正 的反射路（复用出来就是 sensor2的反射功率和 sensor2 路的V
														  
														  
	.VF_POWER_CALIB_K0           (VF_POWER_CALIB_K0       ), //sensor1的校正K 且经过decor 复用
    .VR_POWER_CALIB_K0           (VR_POWER_CALIB_K0       ), 

	.VF_POWER_CALIB_K1           (VF_POWER_CALIB_K1       ),  //sensor2的校正K 且经过decor  复用

	.VF_POWER_CALIB_K2           (VF_POWER_CALIB_K2       ), 
	.VR_POWER_CALIB_K2           (VR_POWER_CALIB_K2       ), 	
	
	.VF_SENSOR0_K_AVG 	         (AVG_IIR_pf0             ),
	.VR_SENSOR0_K_AVG 	         (AVG_IIR_pr0             ),	
													     
	.VF_SENSOR2_K2_AVG           (AVG_IIR_pf2             ),//sensor2的vf；且平均 复用
	.VR_SENSOR2_K2_AVG 	         (AVG_IIR_pr2             ),	
	
	.ADC_RAM_EN			         (ADC_RAM_EN		      ),	
						         
	.ADC_RAM_RD_ADDR	         (ADC_RAM_RD_ADDR         ),	
	.ADC_RAM_RD_DATA	         (ADC_RAM_RD_DATA         ),
    //	.ADC_RAM_RD_DATA1	         (ADC_RAM_RD_DATA1        ),	
	.ADC_RAM_RD_DATA2	         (ADC_RAM_RD_DATA2        ),	
    //	.ADC_RAM_RD_DATA3	         (ADC_RAM_RD_DATA3        ),	
    //	.ADC_RAM_RD_DATA4	         (ADC_RAM_RD_DATA4        ),	
	
	.adc0_mean0			         (adc0_mean0		      ),    	
	.adc1_mean0			         (adc1_mean0		      ), 
 	.adc0_mean1			         (adc0_mean1		      ),    	
	.adc1_mean1			         (adc1_mean1		      ),   	
 	.adc0_mean2			         (adc0_mean2		      ),    	
	.adc1_mean2			         (adc1_mean2		      ),
	
 	.adc0_mean3			         (adc0_mean3		      ),    	
	.adc1_mean3			         (adc1_mean3		      ), 
 	.adc0_mean3_400k			 (adc0_mean3_400k		  ),    	
	.adc1_mean3_400k			 (adc1_mean3_400k		  ), 


  	
 	.adc0_mean4			         (adc0_mean4		      ),    	
	.adc1_mean4			         (adc1_mean4		      ),
 	.adc0_mean4_400k			 (adc0_mean4_400k		  ),    	
	.adc1_mean4_400k			 (adc1_mean4_400k		  ), 


	
	.m1a00_ch0    		         (m1a00_ch0    		      ),    	
	.m1a01_ch0    		         (m1a01_ch0    		      ),    	
	.m1a10_ch0    		         (m1a10_ch0    		      ),    	
	.m1a11_ch0    		         (m1a11_ch0    		      ),  
	.m1a00_ch1    		         (m1a00_ch1   		      ), 
	.m1a01_ch1    		         (m1a01_ch1   		      ), 
	.m1a10_ch1    		         (m1a10_ch1   		      ), 
	.m1a11_ch1    		         (m1a11_ch1   		      ), 	
	.m1a00_ch2    		         (m1a00_ch2  		      ), 
	.m1a01_ch2    		         (m1a01_ch2  		      ), 
	.m1a10_ch2    		         (m1a10_ch2  		      ), 
	.m1a11_ch2    		         (m1a11_ch2  		      ), 
	.m1a00_ch3    		         (m1a00_ch3  		      ), 
	.m1a01_ch3    		         (m1a01_ch3  		      ), 
	.m1a10_ch3    		         (m1a10_ch3  		      ), 
	.m1a11_ch3    		         (m1a11_ch3  		      ), 
	.m1a00_ch4    		         (m1a00_ch4  		      ), 
	.m1a01_ch4    		         (m1a01_ch4  		      ), 
	.m1a10_ch4    		         (m1a10_ch4  		      ), 
	.m1a11_ch4    		         (m1a11_ch4  		      ), 	


	.m1a00_ch3_400k   		     (m1a00_ch3_400k          ), 
	.m1a01_ch3_400k   		     (m1a01_ch3_400k          ), 
	.m1a10_ch3_400k   		     (m1a10_ch3_400k          ), 
	.m1a11_ch3_400k   		     (m1a11_ch3_400k          ), 
	.m1a00_ch4_400k   		     (m1a00_ch4_400k          ), 
	.m1a01_ch4_400k   		     (m1a01_ch4_400k          ), 
	.m1a10_ch4_400k   		     (m1a10_ch4_400k          ), 
	.m1a11_ch4_400k   		     (m1a11_ch4_400k          ), 	


						         
	.CALIB_R 			         (CALIB_R0 	              ), //0
	.CALIB_JX			         (CALIB_JX0	              ),
												          
	.R_DOUT				         (R0_result		          ),
	.JX_DOUT   			         (JX0_result	          ),
	.R1_DOUT			         (R1_result		          ),
	.JX1_DOUT   		         (JX1_result	          ),
	.R2_DOUT				     (R2_result		          ),
	.JX2_DOUT   			     (JX2_result	          ),
	.R3_DOUT			         (R3_result		          ),
	.JX3_DOUT   		         (JX3_result	          ),
	.R4_DOUT			         (R4_result		          ),
	.JX4_DOUT   		         (JX4_result	          ),
	.R3_400K_DOUT			     (R3_400k_result		  ),
	.JX3_400K_DOUT   		     (JX3_400k_result	      ),
	.R4_400K_DOUT			     (R4_400k_result		  ),
	.JX4_400K_DOUT   		     (JX4_400k_result	      ),

    .FREQ0_CALIB_MODE	         (FREQ0_CALIB_MODE        ),	
    .FREQ2_CALIB_MODE	         (FREQ2_CALIB_MODE        ),
	
	.ORIG_K0				     (ORIG_K0		          ),	
	.ORIG_K2			         (ORIG_K2		          ),	
	
	.SET_POINT_VAL		         (SET_POINT_VAL	          ),
    //**********************************************************************************************************
	
	.POWER_THRESHOLD             (POWER_THRESHOLD         ),
													      
	.FILTER_THRESHOLD            (FILTER_THRESHOLD        ),	
	.DETECT_RISE_DLY             (DETECT_RISE_DLY         ),
	.DETECT_FALL_DLY             (DETECT_FALL_DLY         ),
    .RISE_JUMP                   (RISE_JUMP               ),
	.FALL_JUMP                   (FALL_JUMP               ),

	.DETECT_RISE_DLY2            (DETECT_RISE_DLY2        ),
	.DETECT_FALL_DLY2            (DETECT_FALL_DLY2        ),
    .RISE_JUMP2                  (RISE_JUMP2              ),
	.FALL_JUMP2                  (FALL_JUMP2              ),
	
	
    .PULSE_START                 (w_IS0_PULSE_START0           ),//调节脉冲拟合占空比起点; 功率拟合占空比;
    .PULSE_END                   (w_IS0_PULSE_END0             ),//调节脉冲拟合占空比终点; 功率拟合占空比;	

    .PULSE_START2                (w_IS1_PULSE_START2          ),//调节脉冲拟合占空比起点; 功率拟合占空比;	
    .PULSE_END2                  (w_IS1_PULSE_END2            ),//调节脉冲拟合占空比终点; 功率拟合占空比;	
	
    .POWER_PWM_DLY0               (w_IS0_power_pwm_dly0       ), 	
    .POWER_PWM_DLY2               (w_IS1_power_pwm_dly2       ), 	


	.OS0_FILTER_THRESHOLD        (OS0_FILTER_THRESHOLD    ),	
	.OS0_DETECT_RISE_DLY         (OS0_DETECT_RISE_DLY     ),
	.OS0_DETECT_FALL_DLY         (OS0_DETECT_FALL_DLY     ),
    .OS0_RISE_JUMP               (OS0_RISE_JUMP           ),
	.OS0_FALL_JUMP               (OS0_FALL_JUMP           ),
    .OS0_PULSE_START             (w_OS0_PULSE_START1       ),//调节脉冲拟合占空比起点; 功率拟合占空比;
    .OS0_PULSE_END               (w_OS0_PULSE_END1         ),//调节脉冲拟合占空比终点; 功率拟合占空比;	

	.OS1_FILTER_THRESHOLD        (OS1_FILTER_THRESHOLD    ),
	.OS1_DETECT_RISE_DLY         (OS1_DETECT_RISE_DLY     ),
	.OS1_DETECT_FALL_DLY         (OS1_DETECT_FALL_DLY     ),
    .OS1_RISE_JUMP               (OS1_RISE_JUMP           ),
	.OS1_FALL_JUMP               (OS1_FALL_JUMP           ),
    .OS1_PULSE_START             (w_OS1_PULSE_START       ),
    .OS1_PULSE_END               (w_OS1_PULSE_END         ),

	.OS2_FILTER_THRESHOLD        (OS2_FILTER_THRESHOLD    ),
	.OS2_DETECT_RISE_DLY         (OS2_DETECT_RISE_DLY     ),
	.OS2_DETECT_FALL_DLY         (OS2_DETECT_FALL_DLY     ),
    .OS2_RISE_JUMP               (OS2_RISE_JUMP           ),
	.OS2_FALL_JUMP               (OS2_FALL_JUMP           ),
    .OS2_PULSE_START             (w_OS2_PULSE_START       ),
    .OS2_PULSE_END               (w_OS2_PULSE_END         ),


	.OS1_400K_DETECT_RISE_DLY    (OS1_400K_DETECT_RISE_DLY ),
	.OS1_400K_DETECT_FALL_DLY    (OS1_400K_DETECT_FALL_DLY ),
    .OS1_400K_RISE_JUMP          (OS1_400K_RISE_JUMP       ),
	.OS1_400K_FALL_JUMP          (OS1_400K_FALL_JUMP       ),
    .OS1_400K_PULSE_START        (w_OS1_400K_PULSE_START   ),
    .OS1_400K_PULSE_END          (w_OS1_400K_PULSE_END     ),


	.OS2_400K_DETECT_RISE_DLY    (OS2_400K_DETECT_RISE_DLY ),
	.OS2_400K_DETECT_FALL_DLY    (OS2_400K_DETECT_FALL_DLY ),
    .OS2_400K_RISE_JUMP          (OS2_400K_RISE_JUMP       ),
	.OS2_400K_FALL_JUMP          (OS2_400K_FALL_JUMP       ),
    .OS2_400K_PULSE_START        (w_OS2_400K_PULSE_START   ),
    .OS2_400K_PULSE_END          (w_OS2_400K_PULSE_END     ),

    .I_PWM_DLY                   (w_OS0_pwm_dly            ), 		
    .I1_PWM_DLY                  (w_OS1_pwm_dly            ), 														  
    .I2_PWM_DLY                  (w_OS2_pwm_dly            ), 	

    .I1_PWM_DLY_400K             (w_OS1_pwm_dly_400k       ), 														  
    .I2_PWM_DLY_400K             (w_OS2_pwm_dly_400k       ), 	

    .KEEP_DLY                    (KEEP_DLY                ), 
	
    .FFT_PERIOD                  (FFT_PERIOD              ),	
    .FD_R_OUT                    (FD_R_OUT                ),
    .FD_JX_OUT 	                 (FD_JX_OUT               ),
    .TDM_DIV_COEF                (TDM_DIV_COEF            ),
	
	.MATCH_DETECT                (MATCH_DETECT            ),//NO USE;
	
	.DETECT_PULSE_WIDTH          (DETECT_PULSE_WIDTH      ),
	.MATCH_ON_DLY                (MATCH_ON_DLY            ),
    .OFF_NUM                     (OFF_NUM                 ),

	.DETECT_PULSE_WIDTH1         (DETECT_PULSE_WIDTH1     ),
	.MATCH_ON_DLY1               (MATCH_ON_DLY1           ),		
    .OFF_NUM1                    (OFF_NUM1                ),
	
	.DETECT_PULSE_WIDTH2         (DETECT_PULSE_WIDTH2     ),
	.MATCH_ON_DLY2               (MATCH_ON_DLY2           ),		
    .OFF_NUM2                    (OFF_NUM2                ),

	.DETECT_PULSE_WIDTH3         (DETECT_PULSE_WIDTH3     ),
	.MATCH_ON_DLY3               (MATCH_ON_DLY3           ),		
    .OFF_NUM3                    (OFF_NUM3                ),
	
	.DETECT_PULSE_WIDTH4         (DETECT_PULSE_WIDTH4     ),
	.MATCH_ON_DLY4               (MATCH_ON_DLY4           ),		
    .OFF_NUM4                    (OFF_NUM4                ),

	.DETECT_PULSE_WIDTH3_400K    (DETECT_PULSE_WIDTH3_400K),
	.MATCH_ON_DLY3_400K          (MATCH_ON_DLY3_400K      ),		
    .OFF_NUM3_400K               (OFF_NUM3_400K           ),
	
	.DETECT_PULSE_WIDTH4_400K    (DETECT_PULSE_WIDTH4_400K),
	.MATCH_ON_DLY4_400K          (MATCH_ON_DLY4_400K      ),		
    .OFF_NUM4_400K               (OFF_NUM4_400K           ),

    .ON_KEEP_NUM                 (ON_KEEP_NUM             ),      
    .OFF_KEEP_NUM                (OFF_KEEP_NUM            ),     

	.TDM_PERIOD                  (TDM_PERIOD              ),
    .POWER_CALLAPSE              (POWER_CALLAPSE          ),	
    .R_JX_CALLAPSE               (R_JX_CALLAPSE           ),	
													      
    .AVG_IIR_R0                  (AVG_IIR_R0              ), //hf
    .AVG_IIR_JX0                 (AVG_IIR_JX0             ),
    .AVG_IIR_R1                  (AVG_IIR_R1              ), //os
    .AVG_IIR_JX1                 (AVG_IIR_JX1             ),
    .AVG_IIR_R2                  (AVG_IIR_R2              ), //lf
    .AVG_IIR_JX2                 (AVG_IIR_JX2             ),
	
    .AVG_IIR_R3                  (AVG_IIR_R3              ), 
    .AVG_IIR_JX3                 (AVG_IIR_JX3             ),
	.AVG_IIR_R4                  (AVG_IIR_R4              ), 
    .AVG_IIR_JX4                 (AVG_IIR_JX4             ),

    .AVG_IIR_400K_R3             (AVG_IIR_400K_R3         ), 
    .AVG_IIR_400K_JX3            (AVG_IIR_400K_JX3        ),
	.AVG_IIR_400K_R4             (AVG_IIR_400K_R4         ), 
    .AVG_IIR_400K_JX4            (AVG_IIR_400K_JX4        ),

	
    //.OS0_V_AVG                   (OS0_V_RESULT            ),
	//.OS0_I_AVG		           (OS0_I_RESULT            ), 
    .OS1_V_AVG                   (OS1_V_RESULT            ),
	.OS1_I_AVG		             (OS1_I_RESULT            ), 
    .OS2_V_AVG                   (OS2_V_RESULT            ),
	.OS2_I_AVG		             (OS2_I_RESULT            ), 	
    .OS1_400K_V_AVG              (OS1_400K_V_RESULT       ),
	.OS1_400K_I_AVG		         (OS1_400K_I_RESULT       ), 
    .OS2_400K_V_AVG              (OS2_400K_V_RESULT       ),
	.OS2_400K_I_AVG		         (OS2_400K_I_RESULT       ), 

													     	
    .POWER_FREQ_COEF0            (demod_freq_coef0        ),  //HF
    .POWER_FREQ_COEF1            (demod_freq_coef1        ),  //OS0
    .POWER_FREQ_COEF2            (demod_freq_coef2        ),  //LF
    .POWER_FREQ_COEF3            (demod_freq_coef3        ),  //OS1
    .POWER_FREQ_COEF4            (demod_freq_coef4        ),  //0S2	
	
    .HF_PERIOD_NUM               (HF_period_cnt           ),	
	.HF_PERIOD_TOTAL             (HF_period_total         ),
    .LF_PERIOD_NUM               (LF_period_cnt           ),	
	.LF_PERIOD_TOTAL             (LF_period_total         ),

    .HF_THRESHOLD2ON             (HF_threshold2on         ), 
    .HF_MEASURE_PERIOD           (HF_measure_period       ), 
    .LF_THRESHOLD2ON             (LF_threshold2on         ), 
    .LF_MEASURE_PERIOD           (LF_measure_period       ), 

 
    .PL_STATE                    (PL_STATE                ),
    .MOTO1_PARA1                 (MOTO1_PARA1             ),
    .MOTO1_PARA2                 (MOTO1_PARA2             ),
    .MOTO2_PARA1                 (MOTO2_PARA1             ),
    .MOTO2_PARA2                 (MOTO2_PARA2             ),
    .MOTO3_PARA1                 (MOTO3_PARA1             ),
    .MOTO3_PARA2                 (MOTO3_PARA2             ),
    .MOTO4_PARA1                 (MOTO4_PARA1             ),
    .MOTO4_PARA2                 (MOTO4_PARA2             ),
    .MOTO5_PARA1                 (MOTO5_PARA1             ),
    .MOTO5_PARA2                 (MOTO5_PARA2             ),
    .MOTO6_PARA1                 (MOTO6_PARA1             ),
    .MOTO6_PARA2                 (MOTO6_PARA2             ),
    .MOTO7_PARA1                 (MOTO7_PARA1             ),
    .MOTO7_PARA2                 (MOTO7_PARA2             ),
    .MOTO8_PARA1                 (MOTO8_PARA1             ),
    .MOTO8_PARA2                 (MOTO8_PARA2             ),	
	.DECOR_PULSE                 (decor_pulse             ),

	
	
    .POWER0_CALIB_K0	         (POWER0_CALIB_K0	      ),
    .POWER0_CALIB_K1	         (POWER0_CALIB_K1	      ),
    .POWER0_CALIB_K2	         (POWER0_CALIB_K2	      ),
    .POWER0_CALIB_K3	         (POWER0_CALIB_K3	      ),
    .POWER0_CALIB_K4	         (POWER0_CALIB_K4	      ),
    .POWER0_CALIB_K5	         (POWER0_CALIB_K5	      ),
    .POWER0_CALIB_K6	         (POWER0_CALIB_K6	      ),
    .POWER0_CALIB_K7	         (POWER0_CALIB_K7	      ),
    .POWER0_CALIB_K8	         (POWER0_CALIB_K8	      ),
    .POWER0_CALIB_K9	         (POWER0_CALIB_K9	      ),
    .POWER0_CALIB_K10	         (POWER0_CALIB_K10        ),      
    .POWER0_CALIB_K11	         (POWER0_CALIB_K11        ),      
    .POWER0_CALIB_K12	         (POWER0_CALIB_K12        ),      
    .POWER0_CALIB_K13	         (POWER0_CALIB_K13        ),      
    .POWER0_CALIB_K14	         (POWER0_CALIB_K14        ),      
    .POWER0_CALIB_K15	         (POWER0_CALIB_K15        ),      
    .POWER0_CALIB_K16	         (POWER0_CALIB_K16        ),      
    .POWER0_CALIB_K17	         (POWER0_CALIB_K17        ),      
    .POWER0_CALIB_K18	         (POWER0_CALIB_K18        ),      
    .POWER0_CALIB_K19	         (POWER0_CALIB_K19        ),      
    .POWER0_CALIB_K20	         (POWER0_CALIB_K20        ),      
    .POWER0_CALIB_K21	         (POWER0_CALIB_K21        ),      
    .POWER0_CALIB_K22	         (POWER0_CALIB_K22        ),      
    .POWER0_CALIB_K23	         (POWER0_CALIB_K23        ),      
    .POWER0_CALIB_K24	         (POWER0_CALIB_K24        ),      
    .POWER0_CALIB_K25	         (POWER0_CALIB_K25        ),      
    .POWER0_CALIB_K26	         (POWER0_CALIB_K26        ),      
    .POWER0_CALIB_K27	         (POWER0_CALIB_K27        ),      
    .POWER0_CALIB_K28	         (POWER0_CALIB_K28        ),      
    .POWER0_CALIB_K29	         (POWER0_CALIB_K29        ),      

    .FREQ0_THR0                  (FREQ0_THR0              ),		
    .FREQ0_THR1                  (FREQ0_THR1              ),		
    .FREQ0_THR2                  (FREQ0_THR2              ),		
    .FREQ0_THR3                  (FREQ0_THR3              ),		
    .FREQ0_THR4                  (FREQ0_THR4              ),		
    .FREQ0_THR5                  (FREQ0_THR5              ),		
    .FREQ0_THR6                  (FREQ0_THR6              ),		
    .FREQ0_THR7                  (FREQ0_THR7              ),		
    .FREQ0_THR8                  (FREQ0_THR8              ),		
    .FREQ0_THR9                  (FREQ0_THR9              ),		
    .FREQ0_THR10                 (FREQ0_THR10             ),		
    .FREQ0_THR11                 (FREQ0_THR11             ),		
    .FREQ0_THR12                 (FREQ0_THR12             ),		
    .FREQ0_THR13                 (FREQ0_THR13             ),		
    .FREQ0_THR14                 (FREQ0_THR14             ),		
    .FREQ0_THR15                 (FREQ0_THR15             ),		
    .FREQ0_THR16                 (FREQ0_THR16             ),		
    .FREQ0_THR17                 (FREQ0_THR17             ),		
    .FREQ0_THR18                 (FREQ0_THR18             ),		
    .FREQ0_THR19                 (FREQ0_THR19             ),		
    .FREQ0_THR20                 (FREQ0_THR20             ),		
    .FREQ0_THR21                 (FREQ0_THR21             ),		
    .FREQ0_THR22                 (FREQ0_THR22             ),		
    .FREQ0_THR23                 (FREQ0_THR23             ),		
    .FREQ0_THR24                 (FREQ0_THR24             ),		
    .FREQ0_THR25                 (FREQ0_THR25             ),		
    .FREQ0_THR26                 (FREQ0_THR26             ),		
    .FREQ0_THR27                 (FREQ0_THR27             ),		
    .FREQ0_THR28                 (FREQ0_THR28             ),		
    .FREQ0_THR29                 (FREQ0_THR29             ),		
    .FREQ0_THR30                 (FREQ0_THR30             ),		
														  
    .K0_THR0 			         (K0_THR0 		          ),
    .K0_THR1 			         (K0_THR1 		          ),
    .K0_THR2 			         (K0_THR2 		          ),
    .K0_THR3 			         (K0_THR3 		          ),
    .K0_THR4 			         (K0_THR4 		          ),
    .K0_THR5 			         (K0_THR5 		          ),
    .K0_THR6 			         (K0_THR6 		          ),
    .K0_THR7 			         (K0_THR7 		          ),
    .K0_THR8 			         (K0_THR8 		          ),
    .K0_THR9 			         (K0_THR9 		          ),
    .K0_THR10			         (K0_THR10		          ),
    .K0_THR11			         (K0_THR11		          ),
    .K0_THR12			         (K0_THR12		          ),
    .K0_THR13			         (K0_THR13		          ),
    .K0_THR14			         (K0_THR14		          ),
    .K0_THR15			         (K0_THR15		          ),
    .K0_THR16			         (K0_THR16		          ),
    .K0_THR17			         (K0_THR17		          ),
    .K0_THR18			         (K0_THR18		          ),
    .K0_THR19			         (K0_THR19		          ),
    .K0_THR20			         (K0_THR20		          ),
    .K0_THR21			         (K0_THR21		          ),
    .K0_THR22			         (K0_THR22		          ),
    .K0_THR23			         (K0_THR23		          ),
    .K0_THR24			         (K0_THR24		          ),
    .K0_THR25			         (K0_THR25		          ),
    .K0_THR26			         (K0_THR26		          ),
    .K0_THR27			         (K0_THR27		          ),
    .K0_THR28			         (K0_THR28		          ),
    .K0_THR29			         (K0_THR29		          ),

    .POWER2_CALIB_K0	         (POWER2_CALIB_K0	      ),
    .POWER2_CALIB_K1	         (POWER2_CALIB_K1	      ),
    .POWER2_CALIB_K2	         (POWER2_CALIB_K2	      ),
    .POWER2_CALIB_K3	         (POWER2_CALIB_K3	      ),
    .POWER2_CALIB_K4	         (POWER2_CALIB_K4	      ),
    .POWER2_CALIB_K5	         (POWER2_CALIB_K5	      ),
    .POWER2_CALIB_K6	         (POWER2_CALIB_K6	      ),
    .POWER2_CALIB_K7	         (POWER2_CALIB_K7	      ),
    .POWER2_CALIB_K8	         (POWER2_CALIB_K8	      ),
    .POWER2_CALIB_K9	         (POWER2_CALIB_K9	      ),
    .POWER2_CALIB_K10	         (POWER2_CALIB_K10        ),      
    .POWER2_CALIB_K11	         (POWER2_CALIB_K11        ),      
    .POWER2_CALIB_K12	         (POWER2_CALIB_K12        ),      
    .POWER2_CALIB_K13	         (POWER2_CALIB_K13        ),      
    .POWER2_CALIB_K14	         (POWER2_CALIB_K14        ),      
    .POWER2_CALIB_K15	         (POWER2_CALIB_K15        ),      
    .POWER2_CALIB_K16	         (POWER2_CALIB_K16        ),      
    .POWER2_CALIB_K17	         (POWER2_CALIB_K17        ),      
    .POWER2_CALIB_K18	         (POWER2_CALIB_K18        ),      
    .POWER2_CALIB_K19	         (POWER2_CALIB_K19        ),      
    .POWER2_CALIB_K20	         (POWER2_CALIB_K20        ),      
    .POWER2_CALIB_K21	         (POWER2_CALIB_K21        ),      
    .POWER2_CALIB_K22	         (POWER2_CALIB_K22        ),      
    .POWER2_CALIB_K23	         (POWER2_CALIB_K23        ),      
    .POWER2_CALIB_K24	         (POWER2_CALIB_K24        ),      
    .POWER2_CALIB_K25	         (POWER2_CALIB_K25        ),      
    .POWER2_CALIB_K26	         (POWER2_CALIB_K26        ),      
    .POWER2_CALIB_K27	         (POWER2_CALIB_K27        ),      
    .POWER2_CALIB_K28	         (POWER2_CALIB_K28        ),      
    .POWER2_CALIB_K29	         (POWER2_CALIB_K29        ),      

    .FREQ2_THR0                  (FREQ2_THR0              ),		
    .FREQ2_THR1                  (FREQ2_THR1              ),		
    .FREQ2_THR2                  (FREQ2_THR2              ),		
    .FREQ2_THR3                  (FREQ2_THR3              ),		
    .FREQ2_THR4                  (FREQ2_THR4              ),		
    .FREQ2_THR5                  (FREQ2_THR5              ),		
    .FREQ2_THR6                  (FREQ2_THR6              ),		
    .FREQ2_THR7                  (FREQ2_THR7              ),		
    .FREQ2_THR8                  (FREQ2_THR8              ),		
    .FREQ2_THR9                  (FREQ2_THR9              ),		
    .FREQ2_THR10                 (FREQ2_THR10             ),		
    .FREQ2_THR11                 (FREQ2_THR11             ),		
    .FREQ2_THR12                 (FREQ2_THR12             ),		
    .FREQ2_THR13                 (FREQ2_THR13             ),		
    .FREQ2_THR14                 (FREQ2_THR14             ),		
    .FREQ2_THR15                 (FREQ2_THR15             ),		
    .FREQ2_THR16                 (FREQ2_THR16             ),		
    .FREQ2_THR17                 (FREQ2_THR17             ),		
    .FREQ2_THR18                 (FREQ2_THR18             ),		
    .FREQ2_THR19                 (FREQ2_THR19             ),		
    .FREQ2_THR20                 (FREQ2_THR20             ),		
    .FREQ2_THR21                 (FREQ2_THR21             ),		
    .FREQ2_THR22                 (FREQ2_THR22             ),		
    .FREQ2_THR23                 (FREQ2_THR23             ),		
    .FREQ2_THR24                 (FREQ2_THR24             ),		
    .FREQ2_THR25                 (FREQ2_THR25             ),		
    .FREQ2_THR26                 (FREQ2_THR26             ),		
    .FREQ2_THR27                 (FREQ2_THR27             ),		
    .FREQ2_THR28                 (FREQ2_THR28             ),		
    .FREQ2_THR29                 (FREQ2_THR29             ),		
    .FREQ2_THR30                 (FREQ2_THR30             ),		
														  
    .K2_THR0 			         (K2_THR0 		          ),
    .K2_THR1 			         (K2_THR1 		          ),
    .K2_THR2 			         (K2_THR2 		          ),
    .K2_THR3 			         (K2_THR3 		          ),
    .K2_THR4 			         (K2_THR4 		          ),
    .K2_THR5 			         (K2_THR5 		          ),
    .K2_THR6 			         (K2_THR6 		          ),
    .K2_THR7 			         (K2_THR7 		          ),
    .K2_THR8 			         (K2_THR8 		          ),
    .K2_THR9 			         (K2_THR9 		          ),
    .K2_THR10			         (K2_THR10		          ),
    .K2_THR11			         (K2_THR11		          ),
    .K2_THR12			         (K2_THR12		          ),
    .K2_THR13			         (K2_THR13		          ),
    .K2_THR14			         (K2_THR14		          ),
    .K2_THR15			         (K2_THR15		          ),
    .K2_THR16			         (K2_THR16		          ),
    .K2_THR17			         (K2_THR17		          ),
    .K2_THR18			         (K2_THR18		          ),
    .K2_THR19			         (K2_THR19		          ),
    .K2_THR20			         (K2_THR20		          ),
    .K2_THR21			         (K2_THR21		          ),
    .K2_THR22			         (K2_THR22		          ),
    .K2_THR23			         (K2_THR23		          ),
    .K2_THR24			         (K2_THR24		          ),
    .K2_THR25			         (K2_THR25		          ),
    .K2_THR26			         (K2_THR26		          ),
    .K2_THR27			         (K2_THR27		          ),
    .K2_THR28			         (K2_THR28		          ),
    .K2_THR29			         (K2_THR29		          ),
														  
    .w_RDAddr                    (RDAddr                  ),
	.RD                          (RD                      ),
	//.PULSE_FREQ         (PULSE_FREQ         ),
    //spi                                       
	.SPI_CS				         (SPI_CS		          ),
	.SPI_SDI			         (SPI_SDI	              ),
	.SPI_SCLK			         (SPI_SCLK	              ),
	.SPI_SDO			         (SPI_SDO	              )
);
//others;
feed_dog	feed_dog( 
	.i_clk			(clk_50m      ),	//10m 
	.i_rstn			(~rst_125     ),
	.dout			(FPGA_DOG_WAVE)
);

led	led(
	.clk_i		    (clk_50m	  ),	//10m
	.rstn_i		    (~rst_125     ),
	.led		    (debug_led[7] )
);
/***************************************Frequency Domain****************************************************/
    // FD_power_handle FD_power_handle(
    // `ifdef FREQ_DOMAIN_ON 
    // /*input             */  .clk		          (i_sysclk         ), //100M drive clock;
    // /*input      [15:0]	*/  .AD9643_CHA           ({AD9238_CH0_CHA[13],AD9238_CH0_CHA[13],AD9238_CH0_CHA}),
    // /*input      [15:0]	*/  .AD9643_CHB           ({AD9238_CH0_CHB[13],AD9238_CH0_CHB[13],AD9238_CH0_CHB}),
                            // .fd_clk_50m           (FD_CLK_50M          ),
                            // .VF_POWER_CALIB       (VF_POWER_CALIB      ),
                            // .fft_start            (fft_start           ),
                            // .fft_period           (FFT_PERIOD          ),
    // /*output     [31:0] */  .fd_jx_out 	          (FD_JX_OUT           ),						
    // /*output     [31:0] */  .fd_r_out             (FD_R_OUT            )
    // `endif
    // ); 
/***********************MOTO_CTRL******************************/
`ifdef MOTO_CTRL_FUNCTION 
    moto_ctrl moto_ctrl_ch1_inst(
        /*input           */.clk            (clk_50m               ),
        /*input           */.rst_n          (~rst_125              ),
        /*input   [31:0]  */.pwm_param1     (MOTO1_PARA1[31: 0]    ),   
        /*input   [31:0]  */.pwm_param2     (MOTO1_PARA2[31: 0]    ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO1_PARA2[47:32]    ),  
        /*output  reg     */.O_PWM          (MOTO_PWM[0]           ),
        /*output          */.MOTO_DIR       (MOTO_DIR[0]           ),
        /*input           */.MOTO_ALM       (MOTO_ALM[0]           ),
        /*output          */.MOTO_EN        (MOTO_EN[0]            ),
        /*output     [1:0]*/.moto_work_state(moto_state[1:0]       )// 电机工作状
    );
    moto_ctrl moto_ctrl_ch2_inst(
        /*input           */.clk            (clk_50m               ),
        /*input           */.rst_n          (~rst_125              ),
        /*input   [31:0]  */.pwm_param1     (MOTO2_PARA1[31: 0]    ),   
        /*input   [31:0]  */.pwm_param2     (MOTO2_PARA2[31: 0]    ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO2_PARA2[47:32]    ),  
        /*output  reg     */.O_PWM          (MOTO_PWM[1]           ),
        /*output          */.MOTO_DIR       (MOTO_DIR[1]           ),
        /*input           */.MOTO_ALM       (MOTO_ALM[1]           ),
        /*output          */.MOTO_EN        (MOTO_EN[1]            ),
        /*output     [1:0]*/.moto_work_state(moto_state[3:2]       )// 电机工作状  
    );   
    moto_ctrl moto_ctrl_ch3_inst(   
        /*input           */.clk            (clk_50m                ),
        /*input           */.rst_n          (~rst_125               ),
        /*input   [31:0]  */.pwm_param1     (MOTO3_PARA1[31: 0]     ),   
        /*input   [31:0]  */.pwm_param2     (MOTO3_PARA2[31: 0]     ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO3_PARA2[47:32]     ),
        /*output  reg     */.O_PWM          (MOTO_PWM[2]            ),
        /*output          */.MOTO_DIR       (MOTO_DIR[2]            ),
        /*input           */.MOTO_ALM       (MOTO_ALM[2]            ),
        /*output          */.MOTO_EN        (MOTO_EN[2]             ),
        /*output     [1:0]*/.moto_work_state(moto_state[5:4]        )// 电机工作   
    );   
    moto_ctrl moto_ctrl_ch4_inst(   
        /*input           */.clk            (clk_50m                ),
        /*input           */.rst_n          (~rst_125               ),
        /*input   [31:0]  */.pwm_param1     (MOTO4_PARA1[31: 0]     ),   
        /*input   [31:0]  */.pwm_param2     (MOTO4_PARA2[31: 0]     ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO4_PARA2[47:32]     ), 
        /*output  reg     */.O_PWM          (MOTO_PWM[3]            ),
        /*output          */.MOTO_DIR       (MOTO_DIR[3]            ),
        /*input           */.MOTO_ALM       (MOTO_ALM[3]            ), 
        /*output          */.MOTO_EN        (MOTO_EN[3]             ),
        /*output     [1:0]*/.moto_work_state(moto_state[7:6]        )// 电机工作状     
    );
    moto_ctrl moto_ctrl_ch5_inst(   
        /*input           */.clk            (clk_50m                ),
        /*input           */.rst_n          (~rst_125               ),
        /*input   [31:0]  */.pwm_param1     (MOTO5_PARA1[31: 0]     ),   
        /*input   [31:0]  */.pwm_param2     (MOTO5_PARA2[31: 0]     ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO5_PARA2[47:32]     ),
        /*output  reg     */.O_PWM          (MOTO_PWM[4]            ),
        /*output          */.MOTO_DIR       (MOTO_DIR[4]            ),
        /*input           */.MOTO_ALM       (MOTO_ALM[4]            ),
        /*output          */.MOTO_EN        (MOTO_EN[4]             ),
        /*output     [1:0]*/.moto_work_state(moto_state[9:8]        )// 电机工作状
    );   
    moto_ctrl moto_ctrl_ch6_inst(   
        /*input           */.clk            (clk_50m                ),
        /*input           */.rst_n          (~rst_125               ),
        /*input   [31:0]  */.pwm_param1     (MOTO6_PARA1[31: 0]     ),   
        /*input   [31:0]  */.pwm_param2     (MOTO6_PARA2[31: 0]     ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO6_PARA2[47:32]     ), 
        /*output  reg     */.O_PWM          (MOTO_PWM[5]            ),
        /*output          */.MOTO_DIR       (MOTO_DIR[5]            ),
        /*input           */.MOTO_ALM       (MOTO_ALM[5]            ), 
        /*output          */.MOTO_EN        (MOTO_EN[5]             ),
        /*output     [1:0]*/.moto_work_state(moto_state[11:10]      )// 电机工作状  
    );

    moto_ctrl moto_ctrl_ch7_inst(   
        /*input           */.clk            (clk_50m                ),
        /*input           */.rst_n          (~rst_125               ),
        /*input   [31:0]  */.pwm_param1     (MOTO7_PARA1[31: 0]     ),   
        /*input   [31:0]  */.pwm_param2     (MOTO7_PARA2[31: 0]     ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO7_PARA2[47:32]     ),
        /*output  reg     */.O_PWM          (MOTO_PWM[6]            ),
        /*output          */.MOTO_DIR       (MOTO_DIR[6]            ),
        /*input           */.MOTO_ALM       (MOTO_ALM[6]            ),
        /*output          */.MOTO_EN        (MOTO_EN[6]             ),
        /*output     [1:0]*/.moto_work_state(moto_state[13:12]        )// 电机工作状   
    );   
    moto_ctrl moto_ctrl_ch8_inst(   
        /*input           */.clk            (clk_50m                ),
        /*input           */.rst_n          (~rst_125               ),
        /*input   [31:0]  */.pwm_param1     (MOTO8_PARA1[31: 0]     ),   
        /*input   [31:0]  */.pwm_param2     (MOTO8_PARA2[31: 0]     ),  
        /*input   [7:0]   */.moto_en_ctrl   (MOTO8_PARA2[47:32]     ), 
        /*output  reg     */.O_PWM          (MOTO_PWM[7]            ),
        /*output          */.MOTO_DIR       (MOTO_DIR[7]            ),
        /*input           */.MOTO_ALM       (MOTO_ALM[7]            ), 
        /*output          */.MOTO_EN        (MOTO_EN[7]             ),
        /*output     [1:0]*/.moto_work_state(moto_state[15:14]      )// 电机工作状  
    );

`endif     

endmodule
