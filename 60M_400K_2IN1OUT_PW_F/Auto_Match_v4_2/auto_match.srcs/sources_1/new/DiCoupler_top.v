`timescale 1ns / 1ps



`define INPUT_SENSOR_CH0
`define INPUT_SENSOR_CH1
//`define OUTPUT_SENSOR_CH0
`define OUTPUT_SENSOR_CH1_CH2

`define CW_PW_POWER_FUNCTION
`define CW_PW_R_JX_FUNCTION


`define POWER0_EDGE_DETECT
//`define OS0_POWER_EDGE_DETECT
`define OS1_OS2_POWER_EDGE_DETECT
`define POWER2_EDGE_DETECT
`define MOTO_CTRL_FUNCTION


//////////////////////////////////////////////////////////////////////////////////
module DiCoupler_top(
    input                       i_sys_reset      ,
    input                       i_clk_64m        ,
    input                       i_clk_128m       ,
    input                       i_clk_50m        ,	

											     
	//  HF/LF/OS_AD9238  12bit;                             
	input                       i_adc_clk        ,   //ADC 参考时钟，三路都用 同一个16M参考；
											     
	input  [11:0]               i_adc0_data0     ,   //HF   
	input  [11:0]               i_adc0_data1     ,			
	
	input  [11:0]               i_adc1_data0     ,   //OS0   
	input  [11:0]               i_adc1_data1     ,		    
								     
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
	output reg			        RF_ON_MCU        ,	//开关信号给MCU，需要取反,1开0关
	output 				        FPGA_DOG_WAVE    ,	//输出100 kHz
	output [5:0]		        debug_led        ,
    output                      FPGA_T25          ,  // pin：B17；
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
assign  FPGA_T24 = power_status2; //此处记得更改LF的开关给mcu；（待确定）；


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


wire                    open_status0    ;
wire                    open_status1    ;
wire                    open_status2     ;
wire                    open_status3     ;
wire                    open_status3_400k;
wire                    open_status4     ;
wire                    open_status4_400k;

wire                    power_status0   ;
wire                    power_status1   ;
wire                    power_status2    ;
wire                    power_status3    ;
wire                    power_status3_400k;
wire                    power_status4    ;
wire                    power_status4_400k;


wire                    sys0_start_demod    ;
wire                    sys0_start_lpf      ;

wire                    sys1_start_demod    ;
wire                    sys1_start_lpf      ;

wire                    sys2_start_demod    ;
wire                    sys2_start_lpf      ;

wire                    sys3_start_demod    ;
wire                    sys3_start_lpf      ;

wire                    sys3_start_400k_demod ;
wire                    sys3_start_400k_lpf   ;

wire                    sys4_start_demod    ;
wire                    sys4_start_lpf      ;

wire                    sys4_start_400k_demod ;
wire                    sys4_start_400k_lpf   ;


wire                    adc0_ch0_calib_vld  ;
wire  [63:0]            adc0_ch0_calib_data ;
wire                    adc1_ch0_calib_vld  ; //hf
wire  [63:0]            adc1_ch0_calib_data ;

// wire                    adc0_ch1_calib_vld  ;
// wire  [63:0]            adc0_ch1_calib_data ;
// wire                    adc1_ch1_calib_vld  ;
// wire  [63:0]            adc1_ch1_calib_data ;

wire                    adc0_ch2_calib_vld  ;
wire  [63:0]            adc0_ch2_calib_data ;
wire                    adc1_ch2_calib_vld  ;
wire  [63:0]            adc1_ch2_calib_data ;//lf




//OUTPUT sensor2 :Vt;It;
wire                    OS0_V_calib_vld ;
wire  [63:0]            OS0_V_calib_data;
wire                    OS0_I_calib_vld ;
wire  [63:0]            OS0_I_calib_data;


wire                    OS1_V_calib_vld ;
wire  [63:0]            OS1_V_calib_data;
wire                    OS1_I_calib_vld ;
wire  [63:0]            OS1_I_calib_data;


wire                    OS1_V_calib_400k_vld ;
wire  [63:0]            OS1_V_calib_400k_data;
wire                    OS1_I_calib_400k_vld ;
wire  [63:0]            OS1_I_calib_400k_data;


wire                    OS2_V_calib_vld ;
wire  [63:0]            OS2_V_calib_data;
wire                    OS2_I_calib_vld ;
wire  [63:0]            OS2_I_calib_data;

wire                    OS2_V_calib_400k_vld ;
wire  [63:0]            OS2_V_calib_400k_data;
wire                    OS2_I_calib_400k_vld ;
wire  [63:0]            OS2_I_calib_400k_data;



wire                    adc0_ch0_lpf_vld    ;
wire  [63:0]            adc0_ch0_lpf_data   ;
wire                    adc1_ch0_lpf_vld    ;
wire  [63:0]            adc1_ch0_lpf_data   ;


wire                    adc0_ch1_lpf0_vld    ;
wire  [63:0]            adc0_ch1_lpf0_data   ;
wire                    adc1_ch1_lpf0_vld    ;
wire  [63:0]            adc1_ch1_lpf0_data   ;

wire                    adc0_ch1_lpf_vld    ;
wire  [63:0]            adc0_ch1_lpf_data   ;
wire                    adc1_ch1_lpf_vld    ;
wire  [63:0]            adc1_ch1_lpf_data   ;

wire                    adc0_ch1_lpfx_vld    ;
wire  [63:0]            adc0_ch1_lpfx_data   ;
wire                    adc1_ch1_lpfx_vld    ;
wire  [63:0]            adc1_ch1_lpfx_data   ;

wire                    adc0_ch2_lpf_vld    ;
wire  [63:0]            adc0_ch2_lpf_data   ;
wire                    adc1_ch2_lpf_vld    ;
wire  [63:0]            adc1_ch2_lpf_data   ;


wire                    adc0_ch3_lpf_vld    ;
wire  [63:0]            adc0_ch3_lpf_data   ;
wire                    adc1_ch3_lpf_vld    ;
wire  [63:0]            adc1_ch3_lpf_data   ;

wire                    adc0_ch3_lpf_400k_vld    ;
wire  [63:0]            adc0_ch3_lpf_400k_data   ;
wire                    adc1_ch3_lpf_400k_vld    ;
wire  [63:0]            adc1_ch3_lpf_400k_data   ;


// wire                    adc0_ch3_lpf_vld    ;
// wire  [63:0]            adc0_ch3_lpf_data   ;
// wire                    adc1_ch3_lpf_vld    ;
// wire  [63:0]            adc1_ch3_lpf_data   ;
																    // ;
																    ;
wire                    adc0_ch4_lpf_vld     ;
wire  [63:0]            adc0_ch4_lpf_data    ;
wire                    adc1_ch4_lpf_vld     ;
wire  [63:0]            adc1_ch4_lpf_data    ;
										    ;
wire                    adc0_ch4_lpf_400k_vld    ;
wire  [63:0]            adc0_ch4_lpf_400k_data   ;
wire                    adc1_ch4_lpf_400k_vld    ;
wire  [63:0]            adc1_ch4_lpf_400k_data   ;


// wire                    adc0_ch4_lpf_vld   ;
// wire  [63:0]            adc0_ch4_lpf_data  ;
// wire                    adc1_ch4_lpf_vld   ;
// wire  [63:0]            adc1_ch4_lpf_data  ;




// wire  [31:0]            o_adc0_mean           ;
// wire  [31:0]            o_adc1_mean           ;
//---------------------------------------------
reg 			        RF_ON_FPGA		      ;

wire 			        ERR				      ;
wire [31:0]		        freq_out0     	      ;
wire [31:0]		        freq_out1     	      ;
wire [31:0]		        freq_out2     	      ;
wire [31:0]		        freq_out3     	      ;
wire [31:0]		        freq_out4     	      ;


wire                    FREQ0_CALIB_MODE       ;  
wire                    FREQ2_CALIB_MODE       ;  

wire [3:0]              RF_FREQ0              ;
wire [3:0]		        RF_FREQ1              ; 
wire [3:0]              RF_FREQ2              ; 
wire [3:0]		        RF_FREQ3              ; 
wire [3:0]		        RF_FREQ4              ; 


wire 			        RF_EN			      ;//射频功率开关,1开0关 
wire [15:0]		        SET_POINT_VAL	      ;//PID功率设置     	
wire [31:0]		        VR_CAL			      ;			
wire [31:0]		        VF_CAL			      ;	
		
wire [31:0]		        ch0_r_jx_i			  ;			
wire [31:0]		        ch0_r_jx_q			  ;	
wire [31:0]		        ch2_r_jx_i			  ;			
wire [31:0]		        ch2_r_jx_q			  ;	

wire [31:0]		        ch0_refl_i			  ;
wire [31:0]		        ch0_refl_q			  ;
wire [31:0]		        ch2_refl_i			  ;
wire [31:0]		        ch2_refl_q			  ;

// wire [31:0]		        sensor2_r			  ;
// wire [31:0]		        sensor2_jx			  ;

wire [31:0]		        VR_POWER0		      ;
wire [31:0]		        VF_POWER0		      ;
wire [31:0]		        VR_POWER2		      ;
wire [31:0]		        VF_POWER2		      ;

wire [31:0]		        OS0_V	              ;
wire [31:0]		        OS0_I	              ; 

wire [31:0]		        OS1_V	              ;
wire [31:0]		        OS1_I	              ; 
wire [31:0]		        OS1_400K_V	          ;
wire [31:0]		        OS1_400K_I	          ; 

wire [31:0]		        OS2_V	              ;
wire [31:0]		        OS2_I	              ; 
wire [31:0]		        OS2_400K_V	          ;
wire [31:0]		        OS2_400K_I	          ; 


wire [15:0]		        VR_POWER_CALIB	      ;  //NO USE;
wire [15:0]		        VF_POWER_CALIB	      ;  //NO USE;

wire [15:0]             VF_POWER_CALIB_K0     ; 
wire [15:0]             VR_POWER_CALIB_K0     ; 
wire [15:0]             VF_POWER_CALIB_K2     ; 
wire [15:0]             VR_POWER_CALIB_K2     ; 


wire [15:0]             VF_POWER0_K_AVG       ; //SENSOR1 VF
wire [15:0]             VF_POWER2_K_AVG       ; //SENSOR1 VR

wire [31:0]             OS0_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
wire [31:0]             OS0_I_AVG             ;
wire [31:0]             OS0_V_RESULT          ;
wire [31:0]             OS0_I_RESULT          ;


wire [31:0]             OS1_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
wire [31:0]             OS1_I_AVG             ;
wire [31:0]             OS1_400K_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
wire [31:0]             OS1_400K_I_AVG             ;


wire [31:0]             OS1_V_RESULT          ;
wire [31:0]             OS1_I_RESULT          ;

wire [31:0]             OS1_400K_V_RESULT          ;
wire [31:0]             OS1_400K_I_RESULT          ;

wire [31:0]             OS2_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
wire [31:0]             OS2_I_AVG             ;

wire [31:0]             OS2_400K_V_AVG             ; //SENSOR2 Vt i2+q2 AVG;
wire [31:0]             OS2_400K_I_AVG             ;

wire [31:0]             OS2_V_RESULT          ;
wire [31:0]             OS2_I_RESULT          ;
wire [31:0]             OS2_400K_V_RESULT          ;
wire [31:0]             OS2_400K_I_RESULT          ;
	
wire 			        ADC_RAM_EN		      ;	
wire [11:0]		        ADC_RAM_RD_ADDR	      ;	
wire [31:0]		        ADC_RAM_RD_DATA	      ;
//wire [31:0]		        ADC_RAM_RD_DATA1	  ;
wire [31:0]		        ADC_RAM_RD_DATA2	  ;
// wire [31:0]		        ADC_RAM_RD_DATA3	  ;
// wire [31:0]		        ADC_RAM_RD_DATA4	  ;


wire [31:0]		        CALIB_R0 		      ;
wire [31:0]		        CALIB_JX0		      ;
wire [31:0]		        CALIB_R2 		      ;
wire [31:0]		        CALIB_JX2		      ;

wire [31:0]		        R_DOUT0			      ;
wire [31:0]		        JX_DOUT0			  ;
wire [31:0]		        OS0_R			      ;
wire [31:0]		        OS0_JX			      ;

(* mark_debug="true" *)wire [31:0]		        R_DOUT2			      ;
(* mark_debug="true" *)wire [31:0]		        JX_DOUT2			  ;
wire [31:0]		        OS1_R			      ;
wire [31:0]		        OS1_JX			      ;

wire [31:0]		        OS1_400K_R			  ;
wire [31:0]		        OS1_400K_JX			  ;

wire [31:0]		        OS2_R			      ;
wire [31:0]		        OS2_JX			      ;

wire [31:0]		        OS2_400K_R			      ;
wire [31:0]		        OS2_400K_JX			      ;


wire [31:0]		        INPUT_SENSOR0_R_AVG	  ;
wire [31:0]		        INPUT_SENSOR0_JX_AVG  ;
(* mark_debug="true" *)wire [31:0]		        INPUT_SENSOR1_R_AVG	  ;
(* mark_debug="true" *)wire [31:0]		        INPUT_SENSOR1_JX_AVG  ;

wire [31:0]		        OUPUT_SENSOR0_R_AVG	  ;
wire [31:0]		        OUPUT_SENSOR0_JX_AVG  ;

wire [31:0]		        OUPUT_SENSOR1_R_AVG	  ;
wire [31:0]		        OUPUT_SENSOR1_JX_AVG  ;
wire [31:0]		        OUPUT_SENSOR1_400K_R_AVG ;
wire [31:0]		        OUPUT_SENSOR1_400K_JX_AVG;

wire [31:0]		        OUPUT_SENSOR2_R_AVG	  ;
wire [31:0]		        OUPUT_SENSOR2_JX_AVG  ;
wire [31:0]		        OUPUT_SENSOR2_400K_R_AVG ;
wire [31:0]		        OUPUT_SENSOR2_400K_JX_AVG;


wire [23:0]		        ORIG_K0			      ; 
wire [23:0]		        ORIG_K2			      ; 



wire 		            BIAS_SET              ;
wire [31:0]             POWER_THRESHOLD       ;
wire [15:0]             FFT_PERIOD            ;
//wire                    power_status_dly          ;

//====================================================
wire                     sysclk_bufg          ;

wire                     CW_MODE0             ;
wire                     CW_MODE1             ;
wire                     CW_MODE2             ;
wire                     CW_MODE3             ;
wire                     CW_MODE3_400K        ;
wire                     CW_MODE4             ;
wire                     CW_MODE4_400K        ;

wire                     PW_MODE0             ;
wire                     PW_MODE1             ;
wire                     PW_MODE2             ;
wire                     PW_MODE3             ;
wire                     PW_MODE4             ;

wire                     sensor0_power_rise   ;
wire                     sensor0_power_fall   ;
wire                     sensor0_avg_keep     ;

wire                     sensor2_power_rise   ;
wire                     sensor2_power_fall   ;
wire                     sensor2_avg_keep     ;

wire                     OS0_I_rise           ;
wire                     OS0_I_fall           ;
wire                     OS0_avg_keep         ;
		
wire                     OS1_I_rise           ;
wire                     OS1_I_fall           ;
wire                     OS1_avg_keep         ;

wire                     OS1_400k_I_rise      ;
wire                     OS1_400k_I_fall      ;
wire                     OS1_400k_avg_keep    ;


wire                     OS2_I_rise           ;
wire                     OS2_I_fall           ;
wire                     OS2_avg_keep         ;
wire                     OS2_400k_I_rise      ;
wire                     OS2_400k_I_fall      ;
wire                     OS2_400k_avg_keep    ;



		
wire [35:0]              sensor0_keep_dly     ;
wire [35:0]              sensor0_pulse_on_cnt ;

wire [35:0]              sensor2_keep_dly     ;
wire [35:0]              sensor2_pulse_on_cnt ;

wire [35:0]              OS0_keep_dly         ;
wire [35:0]              OS0_pulse_on_cnt     ;
	

	
wire [35:0]              OS1_keep_dly         ;
wire [35:0]              OS1_pulse_on_cnt     ;
wire [35:0]              OS1_400k_keep_dly    ;
wire [35:0]              OS1_400k_pulse_on_cnt;

wire [35:0]              OS2_keep_dly         ;
wire [35:0]              OS2_pulse_on_cnt     ;	
wire [35:0]              OS2_400k_keep_dly    ;
wire [35:0]              OS2_400k_pulse_on_cnt;	

wire 	                 O_ch0_start_9643     ;
wire 	                 O_ch1_start_9643     ;
											  
wire [5:0]	             dco_dly              ;
wire [5:0]	             dco_dly_ch0	      ;
wire [5:0]	             dco_dly_ch1	      ;
wire [5:0]	             dco_dly_ch2	      ;
wire [5:0]	             dco_dly_ch3	      ;
											  
(* mark_debug="true" *)wire 		             AD9238_CH0_vld	      ;
(* mark_debug="true" *)wire [11:0]	             AD9238_CH0_CHA	      ;  //vr
(* mark_debug="true" *)wire [11:0]	             AD9238_CH0_CHB	      ;  //vf
wire 		             AD9238_CH1_vld	      ;
wire [11:0]	             AD9238_CH1_CHA	      ;
wire [11:0]	             AD9238_CH1_CHB	      ;
(* mark_debug="true" *)wire 		             AD9238_CH2_vld	      ;
(* mark_debug="true" *)wire [11:0]	             AD9238_CH2_CHA	      ;
(* mark_debug="true" *)wire [11:0]	             AD9238_CH2_CHB	      ;			
wire 		             AD9238_CH3_vld	      ;
wire [11:0]	             AD9238_CH3_CHA	      ;
wire [11:0]	             AD9238_CH3_CHB	      ;											  
wire 		             AD9238_CH4_vld	      ;
wire [11:0]	             AD9238_CH4_CHA	      ;
wire [11:0]	             AD9238_CH4_CHB	      ;											  
											  
wire                     fft_start            ;
wire                     FD_CLK_50M           ;
wire  [31:0]             FD_R_OUT             ;
wire  [31:0]             FD_JX_OUT            ;
											  
											  
wire                     ch0_start_adc      ;
wire                     ad9238_da0_vld     ;
wire [31:0]              ad9238_da0         ;
wire                     ad9238_db0_vld     ;
wire [31:0]              ad9238_db0         ;
wire                     adc0_ch0_bpf_vld   ;
wire [63:0]              adc0_ch0_bpf_data  ;
wire                     adc1_ch0_bpf_vld   ;
wire [63:0]              adc1_ch0_bpf_data  ;
wire                     ch0_start_bpf      ;

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
											  
											  
wire                     ch2_start_adc      ;
wire                     ad9238_da2_vld     ;
wire [31:0]              ad9238_da2         ;
wire                     ad9238_db2_vld     ;
wire [31:0]              ad9238_db2         ;
wire                     adc0_ch2_bpf_vld   ;
wire [63:0]              adc0_ch2_bpf_data  ;
wire                     adc1_ch2_bpf_vld   ;
wire [63:0]              adc1_ch2_bpf_data  ;
wire                     ch2_start_bpf      ;
	

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





wire                     ch4_start_adc      ;
wire                     ad9238_da4_vld     ;
wire [31:0]              ad9238_da4         ;
wire                     ad9238_db4_vld     ;
wire [31:0]              ad9238_db4         ;
wire                     adc0_ch4_bpf_vld   ;
wire [63:0]              adc0_ch4_bpf_data  ;
wire                     adc1_ch4_bpf_vld   ;
wire [63:0]              adc1_ch4_bpf_data  ;
wire                     ch4_start_bpf      ;	
	


wire                     ch4_start_adc_400k      ;
wire                     ad9238_400k_da4_vld     ;
wire [31:0]              ad9238_400k_da4         ;
wire                     ad9238_400k_db4_vld     ;
wire [31:0]              ad9238_400k_db4         ;
wire                     adc0_ch4_bpf_400k_vld   ;
wire [63:0]              adc0_ch4_bpf_400k_data  ;
wire                     adc1_ch4_bpf_400k_vld   ;
wire [63:0]              adc1_ch4_bpf_400k_data  ;
wire                     ch4_start_bpf_400k      ;



	
wire [31:0]		         adc0_mean0		      ;    	
wire [31:0]		         adc1_mean0		      ;   
wire [31:0]		         adc0_mean1		      ;    	
wire [31:0]		         adc1_mean1		      ;  
wire [31:0]		         adc0_mean2		      ;    	
wire [31:0]		         adc1_mean2		      ;  

wire [31:0]		         adc0_mean3		      ;    	
wire [31:0]		         adc1_mean3		      ;  
wire [31:0]		         adc0_mean3_400k	  ;    	
wire [31:0]		         adc1_mean3_400k	  ;  


wire [31:0]		         adc0_mean4		      ;    	
wire [31:0]		         adc1_mean4		      ;  
wire [31:0]		         adc0_mean4_400k	  ;    	
wire [31:0]		         adc1_mean4_400k	  ;  
											  
											  
wire  [31:0]             TDM_DIV_COEF         ; //1250 10ms;
wire  [31:0]             TDM_PERIOD           ;
										      
				           				
wire                     adc0_ch0_demod_vld  ;
wire  [63:0]             adc0_ch0_demod_data ;
wire                     adc1_ch0_demod_vld  ;
wire  [63:0]             adc1_ch0_demod_data ;

wire                     adc0_ch1_demod_vld  ;
wire  [63:0]             adc0_ch1_demod_data ;
wire                     adc1_ch1_demod_vld  ;
wire  [63:0]             adc1_ch1_demod_data ;

wire                     adc0_ch2_demod_vld  ;
wire  [63:0]             adc0_ch2_demod_data ;
wire                     adc1_ch2_demod_vld  ;
wire  [63:0]             adc1_ch2_demod_data ;


wire                     adc0_ch3_demod_vld  ;
wire  [63:0]             adc0_ch3_demod_data ;
wire                     adc1_ch3_demod_vld  ;
wire  [63:0]             adc1_ch3_demod_data ;

wire                     adc0_ch3_demod_400k_vld  ;
wire  [63:0]             adc0_ch3_demod_400k_data ;
wire                     adc1_ch3_demod_400k_vld  ;
wire  [63:0]             adc1_ch3_demod_400k_data ;



wire                     adc0_ch4_demod_vld  ;
wire  [63:0]             adc0_ch4_demod_data ;
wire                     adc1_ch4_demod_vld  ;
wire  [63:0]             adc1_ch4_demod_data ;

wire                     adc0_ch4_demod_400k_vld  ;
wire  [63:0]             adc0_ch4_demod_400k_data ;
wire                     adc1_ch4_demod_400k_vld  ;
wire  [63:0]             adc1_ch4_demod_400k_data ;



wire  [13:0]             demod_rd_addr0	;
wire  [13:0]             demod_rd_addr1	;
wire  [13:0]             demod_rd_addr2	;

wire  [13:0]             demod_rd_addr3	;
wire  [13:0]             demod_rd_400k_addr3 ;

wire  [13:0]             demod_rd_addr4	;    
wire  [13:0]             demod_rd_400k_addr4 ;
			         
//sensor1;		         	    
wire  [31:0]             m1a00_ch0 ;    	
wire  [31:0]             m1a01_ch0 ;    	
wire  [31:0]             m1a10_ch0 ;    	
wire  [31:0]             m1a11_ch0 ; 
				         
wire  [31:0]             m1a00_ch1 ;    	
wire  [31:0]             m1a01_ch1 ;    	
wire  [31:0]             m1a10_ch1 ;    	
wire  [31:0]             m1a11_ch1 ; 	
   				         
wire  [31:0]             m1a00_ch2 ;    	
wire  [31:0]             m1a01_ch2 ;    	
wire  [31:0]             m1a10_ch2 ;    	
wire  [31:0]             m1a11_ch2 ; 

wire  [31:0]             m1a00_ch3 ;    	
wire  [31:0]             m1a01_ch3 ;    	
wire  [31:0]             m1a10_ch3 ;    	
wire  [31:0]             m1a11_ch3 ; 	
								  
wire  [31:0]             m1a00_ch4 ;    	
wire  [31:0]             m1a01_ch4 ;    	
wire  [31:0]             m1a10_ch4 ;    	
wire  [31:0]             m1a11_ch4 ; 	   
			

wire  [31:0]            m1a00_ch3_400k;
wire  [31:0]            m1a01_ch3_400k;
wire  [31:0]            m1a10_ch3_400k;
wire  [31:0]            m1a11_ch3_400k;
															   
wire  [31:0]            m1a00_ch4_400k;
wire  [31:0]            m1a01_ch4_400k;
wire  [31:0]            m1a10_ch4_400k;
wire  [31:0]            m1a11_ch4_400k;


			
wire [15:0]              MATCH_DETECT; //NO USE
wire [31:0]              DETECT_PULSE_WIDTH;
wire [31:0]              MATCH_ON_DLY;

wire [31:0]              DETECT_PULSE_WIDTH1;
wire [31:0]              MATCH_ON_DLY1;

wire [31:0]              DETECT_PULSE_WIDTH2;
wire [31:0]              MATCH_ON_DLY2;

wire [31:0]              DETECT_PULSE_WIDTH3;
wire [31:0]              MATCH_ON_DLY3;

wire [31:0]              DETECT_PULSE_WIDTH3_400K;
wire [31:0]              MATCH_ON_DLY3_400K;

wire [31:0]              DETECT_PULSE_WIDTH4;
wire [31:0]              MATCH_ON_DLY4;

wire [31:0]              DETECT_PULSE_WIDTH4_400K;
wire [31:0]              MATCH_ON_DLY4_400K;


wire [31:0]              demod_freq_coef0;	
wire [31:0]              demod_freq_coef1;	
(* mark_debug="true" *)wire [31:0]              demod_freq_coef2;		   
wire [31:0]              demod_freq_coef3;	
wire [31:0]              demod_freq_coef4;	
	


//sensor1 波形拟合检测；
wire [9:0]               RISE_JUMP          ;
wire [9:0]               FALL_JUMP          ;
wire [23:0]              DETECT_RISE_DLY    ;
wire [23:0]              DETECT_FALL_DLY    ;



wire [9:0]               RISE_JUMP2         ;
wire [9:0]               FALL_JUMP2         ;
wire [23:0]              DETECT_RISE_DLY2   ;
wire [23:0]              DETECT_FALL_DLY2   ;
wire [15:0]              FILTER_THRESHOLD   ;


//sensor2 波形拟合检测；
wire [9:0]               OS0_RISE_JUMP          ;
wire [9:0]               OS0_FALL_JUMP          ;
wire [23:0]              OS0_DETECT_RISE_DLY    ;
wire [23:0]              OS0_DETECT_FALL_DLY    ;
wire [15:0]              OS0_FILTER_THRESHOLD   ;

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



wire [9:0]               OS2_RISE_JUMP          ;
wire [9:0]               OS2_FALL_JUMP          ;
wire [23:0]              OS2_DETECT_RISE_DLY    ;
wire [23:0]              OS2_DETECT_FALL_DLY    ;
wire [15:0]              OS2_FILTER_THRESHOLD   ;

wire [9:0]               OS2_400K_RISE_JUMP          ;
wire [9:0]               OS2_400K_FALL_JUMP          ;
wire [23:0]              OS2_400K_DETECT_RISE_DLY    ;
wire [23:0]              OS2_400K_DETECT_FALL_DLY    ;
wire [15:0]              OS2_400K_FILTER_THRESHOLD   ;


wire [15:0]              VF_POWER0_FILTER        ;
(* mark_debug="true" *)wire [15:0]              VF_POWER2_FILTER        ;

wire [15:0]              w_sensor0_filter_I       ;
wire [15:0]              w_sensor1_filter_I       ;
wire [15:0]              w_sensor1_400k_filter_I  ;

wire [15:0]              w_sensor2_filter_I       ;			
wire [15:0]              w_sensor2_400k_filter_I  ;		

								     
wire [35:0]              KEEP_DLY                ;//NO USE;

wire [31:0]              OFF_NUM                 ;//检测功率关闭的计数器；
wire [31:0]              OFF_NUM1                 ;//检测功率关闭的计数器；

(* mark_debug="true" *)wire [31:0]              OFF_NUM2                ;
wire [31:0]              OFF_NUM3                ;
wire [31:0]              OFF_NUM3_400K           ;
wire [31:0]              OFF_NUM4                ;
wire [31:0]              OFF_NUM4_400K           ;

(* mark_debug="true" *)wire [31:0]              ON_KEEP_NUM             ;
(* mark_debug="true" *)wire [31:0]              OFF_KEEP_NUM            ;

wire [31:0]              PULSE_FREQ              ;

                           

wire                     sensor0_power_buf0_vld  ;
wire                     sensor0_power_buf1_vld  ;
wire                     sensor0_power_buf2_vld  ;
wire                     sensor0_power_buf3_vld  ;
wire                     sensor0_power_sub_vld   ;
                            
wire                     sensor0_power0_buf0_vld ;
wire                     sensor0_power0_buf1_vld ;
wire                     sensor0_power0_buf2_vld ;
wire                     sensor0_power0_buf3_vld ;
wire                     sensor0_power0_sub_vld  ;





                           

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



wire                     OS2_400K_I_buf0_vld     ;
wire                     OS2_400K_I_buf1_vld     ;
wire                     OS2_400K_I_buf2_vld     ;
wire                     OS2_400K_I_buf3_vld     ;
wire                     OS2_400K_I_sub_vld      ;
                    
wire                     OS2_400K_I1_buf0_vld    ;
wire                     OS2_400K_I1_buf1_vld    ;
wire                     OS2_400K_I1_buf2_vld    ;
wire                     OS2_400K_I1_buf3_vld    ;
wire                     OS2_400K_I1_sub_vld     ;

                        

wire                     sensor2_power_buf0_vld  ;
wire                     sensor2_power_buf1_vld  ;
wire                     sensor2_power_buf2_vld  ;
wire                     sensor2_power_buf3_vld  ;
wire                     sensor2_power_sub_vld   ;
                         
wire                     sensor2_power0_buf0_vld ;
wire                     sensor2_power0_buf1_vld ;
wire                     sensor2_power0_buf2_vld ;
wire                     sensor2_power0_buf3_vld ;
wire                     sensor2_power0_sub_vld  ;



wire                     pulse0_pwm_on       ;
wire                     pulse1_pwm_on      ; 
wire                     pulse2_pwm_on      ;
wire                     pulse3_pwm_on      ;
wire                     pulse3_400k_pwm_on ;

wire                     pulse4_pwm_on      ;
wire                     pulse4_400k_pwm_on ;

wire [31:0]	             ch0_calib_vr_i     ;	
wire [31:0]	             ch0_calib_vr_q     ;	
wire 		             calib_vr_vld0      ;
wire [31:0]	             ch0_calib_vf_i     ;	
wire [31:0]	             ch0_calib_vf_q     ;	
wire 		             calib_vf_vld0      ;

wire [31:0]	             ch2_calib_vr_i     ;	
wire [31:0]	             ch2_calib_vr_q     ;	
wire 		             calib_vr_vld2      ;
wire [31:0]	             ch2_calib_vf_i     ;	
wire [31:0]	             ch2_calib_vf_q     ;	
wire 		             calib_vf_vld2      ;

wire [31:0]	             OS0_calib_I_i  ;	
wire [31:0]	             OS0_calib_I_q  ;	
wire 		             OS0_calib_I_vld;
wire [31:0]	             OS0_calib_V_i  ;	
wire [31:0]	             OS0_calib_V_q  ;	
wire 		             OS0_calib_V_vld;

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

wire [31:0]	             OS2_calib_I_i  ;	
wire [31:0]	             OS2_calib_I_q  ;	
wire 		             OS2_calib_I_vld;
wire [31:0]	             OS2_calib_V_i  ;	
wire [31:0]	             OS2_calib_V_q  ;	
wire 		             OS2_calib_V_vld;

wire [31:0]	             OS2_calib_I_400k_i  ;	
wire [31:0]	             OS2_calib_I_400k_q  ;	
wire 		             OS2_calib_I_400k_vld;
wire [31:0]	             OS2_calib_V_400k_i  ;	
wire [31:0]	             OS2_calib_V_400k_q  ;	
wire 		             OS2_calib_V_400k_vld;

wire [31:0]              tdm_period_cnt     ;

wire [31:0]              R0_result          ;
wire [31:0]              JX0_result         ;

wire [31:0]              R1_result          ;
wire [31:0]              JX1_result         ;

(* mark_debug="true" *)wire [31:0]              R2_result          ;
(* mark_debug="true" *)wire [31:0]              JX2_result         ;

wire [31:0]              R3_result          ;
wire [31:0]              JX3_result         ;
wire [31:0]              R3_400k_result     ;
wire [31:0]              JX3_400k_result    ;

wire [31:0]              R4_result          ;
wire [31:0]              JX4_result         ;
wire [31:0]              R4_400k_result     ;
wire [31:0]              JX4_400k_result    ;


wire [31:0]              POWER_CALLAPSE     ; 
wire [31:0]              R_JX_CALLAPSE      ; 

wire [31:0]              AVG_IIR_R0         ; //hf
wire [31:0]              AVG_IIR_JX0        ;

wire [31:0]              AVG_IIR_R1         ; //os;
wire [31:0]              AVG_IIR_JX1        ;

wire [31:0]              AVG_IIR_R2         ; //lf
wire [31:0]              AVG_IIR_JX2        ;

wire [31:0]              AVG_IIR_R3         ; //os;
wire [31:0]              AVG_IIR_JX3        ;

wire [31:0]              AVG_IIR_400K_R3    ; 
wire [31:0]              AVG_IIR_400K_JX3   ;

wire [31:0]              AVG_IIR_R4         ; 
wire [31:0]              AVG_IIR_JX4        ;

wire [31:0]              AVG_IIR_400K_R4    ; 
wire [31:0]              AVG_IIR_400K_JX4   ;

// wire                     r_jx_vld0          ;
// wire                     r_jx_vld1          ;

wire [31:0]              AVG_IIR_pf0        ;
wire [31:0]              AVG_IIR_pr0        ;

wire [31:0]              AVG_IIR_pf2        ;
wire [31:0]              AVG_IIR_pr2        ;


wire [31:0]             SENSOR1_ADC0_I      ;
wire [31:0]             SENSOR1_ADC0_Q      ;
wire [31:0]             SENSOR1_ADC1_I      ;
wire [31:0]             SENSOR1_ADC1_Q      ;

reg [31:0]              r_SENSOR1_ADC0_I    ;
reg [31:0]              r_SENSOR1_ADC0_Q    ;
reg [31:0]              r_SENSOR1_ADC1_I    ;
reg [31:0]              r_SENSOR1_ADC1_Q    ;
				    
reg [31:0]              r2_SENSOR1_ADC0_I   ;
reg [31:0]              r2_SENSOR1_ADC0_Q   ;
reg [31:0]              r2_SENSOR1_ADC1_I   ;
reg [31:0]              r2_SENSOR1_ADC1_Q   ;

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



//13.56m
wire [31:0]             SENSOR4_ADC0_I      ;    
wire [31:0]             SENSOR4_ADC0_Q      ;
wire [31:0]             SENSOR4_ADC1_I      ;
wire [31:0]             SENSOR4_ADC1_Q      ;

reg [31:0]              r_SENSOR4_ADC0_I    ;
reg [31:0]              r_SENSOR4_ADC0_Q    ;
reg [31:0]              r_SENSOR4_ADC1_I    ;
reg [31:0]              r_SENSOR4_ADC1_Q    ;
				    
reg [31:0]              r2_SENSOR4_ADC0_I   ;
reg [31:0]              r2_SENSOR4_ADC0_Q   ;
reg [31:0]              r2_SENSOR4_ADC1_I   ;
reg [31:0]              r2_SENSOR4_ADC1_Q   ;

							    
reg [31:0]              SENSOR2_I_DECOR_I   ;
reg [31:0]              SENSOR2_I_DECOR_Q   ;
reg [31:0]              SENSOR2_V_DECOR_I   ;
reg [31:0]              SENSOR2_V_DECOR_Q   ;

//400k
wire [31:0]             SENSOR4_ADC0_400K_I    ;    
wire [31:0]             SENSOR4_ADC0_400K_Q    ;
wire [31:0]             SENSOR4_ADC1_400K_I    ;
wire [31:0]             SENSOR4_ADC1_400K_Q    ;

reg [31:0]              r_SENSOR4_ADC0_400K_I  ;
reg [31:0]              r_SENSOR4_ADC0_400K_Q  ;
reg [31:0]              r_SENSOR4_ADC1_400K_I  ;
reg [31:0]              r_SENSOR4_ADC1_400K_Q  ;
				    
reg [31:0]              r2_SENSOR4_ADC0_400K_I ;
reg [31:0]              r2_SENSOR4_ADC0_400K_Q ;
reg [31:0]              r2_SENSOR4_ADC1_400K_I ;
reg [31:0]              r2_SENSOR4_ADC1_400K_Q ;





//wire                    sensor2_power_vld;
wire                    OS0_demod_vld0       ;
wire                    OS0_demod_vld1       ;

wire                    OS1_demod_vld0       ;
wire                    OS1_demod_vld1       ;

wire                    OS1_demod_400k_vld0       ;
wire                    OS1_demod_400k_vld1       ;


wire                    OS2_demod_vld0       ;
wire                    OS2_demod_vld1       ;

wire                    OS2_demod_400k_vld0       ;
wire                    OS2_demod_400k_vld1       ;	

	
wire [15:0]             HF_threshold2on      ;
wire [31:0]             HF_measure_period    ;
wire [31:0]             HF_period_cnt        ;
wire [31:0]             HF_period_total      ;

wire [15:0]             LF_threshold2on      ;
wire [31:0]             LF_measure_period    ;
wire [31:0]             LF_period_cnt        ;
wire [31:0]             LF_period_total      ;

wire [15:0]             OS0_threshold2on     ;
wire [31:0]             OS0_measure_period   ;
wire [31:0]             OS0_period_cnt       ;
wire [31:0]             OS0_period_total     ;

wire [15:0]             OS1_threshold2on     ;
wire [31:0]             OS1_measure_period   ;
wire [31:0]             OS1_period_cnt       ;
wire [31:0]             OS1_period_total     ;

wire [15:0]             OS2_threshold2on     ;
wire [31:0]             OS2_measure_period   ;
wire [31:0]             OS2_period_cnt       ;
wire [31:0]             OS2_period_total     ;										     

									     
wire [15:0]             w_PULSE_START        ;
wire [15:0]             w_PULSE_END          ;
										     
wire [15:0]             w_PULSE_START2       ;
wire [15:0]             w_PULSE_END2         ;
										     
wire [15:0]             w_OS0_PULSE_START    ;
wire [15:0]             w_OS0_PULSE_END      ;

wire [15:0]             w_OS1_PULSE_START;
wire [15:0]             w_OS1_PULSE_END  ;

wire [15:0]             w_OS1_400K_PULSE_START;
wire [15:0]             w_OS1_400K_PULSE_END  ;


wire [15:0]             w_OS2_PULSE_START;
wire [15:0]             w_OS2_PULSE_END  ;

wire [15:0]             w_OS2_400K_PULSE_START;
wire [15:0]             w_OS2_400K_PULSE_END  ;

wire [15:0]             w_pulse_gap0         ;
wire [15:0]             w_pulse_gap1         ;
wire [15:0]             w_pulse_gap2         ;
wire [15:0]             w_pulse_gap3     ;
wire [15:0]             w_pulse_gap3_400k     ;
wire [15:0]             w_pulse_gap4     ;
wire [15:0]             w_pulse_gap4_400k     ;


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
			             
wire [23:0]             AUTO_POWER_CALIB_K0       ;
wire [23:0]             AUTO_POWER_CALIB_K2       ;
wire [14:0]             RDAddr                    ;
										          
wire [15:0]             vf_power0_calib_disp      ;
wire [15:0]             vr_power0_calib_disp      ;
wire [15:0]             vf_power0_disp_avg        ;
wire [15:0]             vr_power0_disp_avg        ;
 
wire [15:0]             vf_power2_calib_disp      ;
wire [15:0]             vr_power2_calib_disp      ;
wire [15:0]             vf_power2_disp_avg        ;
wire [15:0]             vr_power2_disp_avg        ;

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

wire                    w_Z_pulse0_pwm; //HF
wire [15:0]             w_power_pwm_dly0;		
           			   	            
wire                    w_Z_pulse2_pwm;  //LF
wire [15:0]             w_power_pwm_dly2;	
	            
wire                    w_Z_pulse1_pwm; //os0
wire [15:0]             w_i0_pwm_dly;	 



wire                    w_Z_pulse3_pwm; //OS1
wire [15:0]             w_i1_pwm_dly;
wire                    w_Z_pulse3_pwm_400k; //OS1
wire [15:0]             w_i1_pwm_dly_400k;


wire                    w_Z_pulse4_pwm; //OS2
wire [15:0]             w_i2_pwm_dly;

wire                    w_Z_pulse4_pwm_400k; //OS2
wire [15:0]             w_i2_pwm_dly_400k;

assign INTLOCK_OUT = INTLOCK_IN;


assign w_pulse_gap0  = w_PULSE_END - w_PULSE_START;
assign w_pulse_gap1 = w_OS0_PULSE_END - w_OS0_PULSE_START;
assign w_pulse_gap2 = w_PULSE_END2 - w_PULSE_START2;
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
		RF_ON_FPGA = 1;	//0开1关  // set point为0时关闭rf on
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


`ifdef INPUT_SENSOR_CH0 
ADC_DATA_RAM	ADC0_DATA_RAM(                        
	.i_clk_64m				(clk_64m              ),
	.i_clk					(clk_50m              ),		
	.i_rstn					(~rst_125             ),
	.vld					(AD9238_CH0_vld       ),	
	.CHA					({AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA}),	// V
	.CHB					({AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB}),	//vf
	.ADC_RAM_EN				(ADC_RAM_EN		      ),		//拉高1个周期
    .ADC_RAM_RD_ADDR		(ADC_RAM_RD_ADDR      ),
    .ADC_RAM_RD_DATA		(ADC_RAM_RD_DATA      )	
);
`endif



`ifdef INPUT_SENSOR_CH1  
ADC_DATA_RAM	ADC2_DATA_RAM(                    
	.i_clk_64m				(clk_64m              ),
	.i_clk					(clk_50m              ),		
	.i_rstn					(~rst_125             ),
	.vld					(AD9238_CH2_vld       ),	
	.CHA					({AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA}),	
	.CHB					({AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB}),	
	.ADC_RAM_EN				(ADC_RAM_EN		      ),		//拉高1个周期
    .ADC_RAM_RD_ADDR		(ADC_RAM_RD_ADDR      ),
    .ADC_RAM_RD_DATA		(ADC_RAM_RD_DATA2     )	
);
`endif


`ifdef INPUT_SENSOR_CH0  // 13.56M / 60M
// FREQ_RTK_1356M  FREQ_RTK_MEASURE_HF  //13.56M
// (
    // .i_clk                     (clk_64m             ), //64M == 15.628ns;
    // .i_rst                     (rst_125             ),
    // .i_adc_vld                 (AD9238_CH0_vld      ), 
    // .i_adc_data                ({AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB} ), //input sensor VF;
	

    // .i_threshold2on            (HF_threshold2on     ),
    // .i_measure_period          (HF_measure_period   ),
    // .o_period_total            (HF_period_total     ),
    // .o_period_pos_cnt          (HF_period_cnt       )  //测量周期个数；           
// );
//The first pcs adc;  

FREQ_RTK_60M  FREQ_RTK_MEASURE_HF
(
    .i_clk                     (clk_64m             ), //64M == 15.628ns;
    .i_rst                     (rst_125             ),
    .i_adc_vld                 (AD9238_CH0_vld      ), 
    .i_adc_data                ({AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB} ), //input sensor VF;
    .i_threshold2on            (HF_threshold2on     ),
    .i_measure_period          (HF_measure_period   ),
    .o_period_total            (HF_period_total     ),
    .o_period_pos_cnt          (HF_period_cnt       )  //测量周期个数；        
);

AD9238_drive   AD9238_HF(
     .i_clk                    (clk_64m             ),
     .i_adc_clk                (i_adc_clk           ),
     .i_rst                    (rst_125             ),
     .i_adc_data0              (i_adc0_data0        ),
     .i_adc_data1              (i_adc0_data1        ),
     .vld	                   (AD9238_CH0_vld      ),
     .o_CHA                    (AD9238_CH0_CHA      ),
     .o_CHB                    (AD9238_CH0_CHB      )  //VF
);

`endif


`ifdef INPUT_SENSOR_CH1  

FREQ_RTK_400K  FREQ_RTK_MEASURE_LF
(
    .i_clk                     (clk_64m             ), //64M == 15.628ns;
    .i_rst                     (rst_125             ),
    .i_adc_vld                 (AD9238_CH2_vld      ), 
    .i_adc_data                ({AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB}  ), //input sensor LF;
	
	
    .i_threshold2on            (LF_threshold2on     ),
    .i_measure_period          (LF_measure_period   ),
    .o_period_total            (LF_period_total     ),
    .o_period_pos_cnt          (LF_period_cnt       )  //测量周期个数；        
);


AD9238_drive   AD9238_LF(
    .i_clk                    (clk_64m              ),
    .i_adc_clk                (i_adc_clk            ),
    .i_rst                    (rst_125              ),
    .i_adc_data0              (i_adc2_data0         ),
    .i_adc_data1              (i_adc2_data1         ),
	.vld	                  (AD9238_CH2_vld       ),
    .o_CHA                    (AD9238_CH2_CHA       ),
    .o_CHB                    (AD9238_CH2_CHB       )   //VF
);

`endif



`ifdef OUTPUT_SENSOR_CH1_CH2    
//The second pc;adc;Near dut;
AD9238_drive   AD9238_OS1(
    .i_clk                   (clk_64m               ),
    .i_adc_clk               (i_adc_clk             ),
    .i_rst                   (rst_125               ),
    .i_adc_data0             (i_adc3_data0          ),
    .i_adc_data1             (i_adc3_data1          ),
    .vld	                 (AD9238_CH3_vld        ),
    .o_CHA                   (AD9238_CH3_CHA        ),
    .o_CHB                   (AD9238_CH3_CHB        )  //VF
);

//The second pc;adc;Near dut;
AD9238_drive   AD9238_OS2(
     .i_clk                  (clk_64m               ),
     .i_adc_clk              (i_adc_clk             ),
     .i_rst                  (rst_125               ),
     .i_adc_data0            (i_adc4_data0          ),
     .i_adc_data1            (i_adc4_data1          ),
     .vld	                 (AD9238_CH4_vld        ),
     .o_CHA                  (AD9238_CH4_CHA        ),
     .o_CHB                  (AD9238_CH4_CHB        )  //VF
);



`endif


//`ifdef OUTPUT_SENSOR_CH0 
//The second pc;adc;Near dut;
// AD9238_drive   AD9238_OS0(
// /*input          */           .i_clk           (clk_64m           ),
// /*input          */           .i_adc_clk       (i_adc_clk         ),
// /*input          */           .i_rst           (rst_125           ),
// /*input  [11:0]  */           .i_adc_data0     (i_adc1_data0      ),
// /*input  [11:0]  */           .i_adc_data1     (i_adc1_data1      ),
// /*output reg 	 */		      .vld	           (AD9238_CH1_vld    ),
// /*output [11:0]  */           .o_CHA           (AD9238_CH1_CHA    ),
// /*output [11:0]  */           .o_CHB           (AD9238_CH1_CHB    )  //VF
// );

// FREQ_RTK_MEASURE  FREQ_RTK_MEASURE_OS0
// (
    // .i_clk                     (clk_64m             ), //64M == 15.628ns;
    // .i_rst                     (rst_125             ),
    // .i_adc_vld                 (AD9238_CH1_vld      ), 
    // .i_adc_data                ({AD9238_CH1_CHB[11],AD9238_CH1_CHB[11],AD9238_CH1_CHB}  ), //input sensor LF;
	
    // .i_power_status0           (power_status0       ),
    // .i_power_status2           (power_status2       ),
	
    // .i_threshold2on            (OS0_threshold2on     ),
    // .i_measure_period          (OS0_measure_period   ),
    // .o_period_total            (OS0_period_total     ),
    // .o_period_pos_cnt          (OS0_period_cnt       )  //测量周期个数；        
// );

//`endif


`ifdef INPUT_SENSOR_CH0 
daq9248 daq9248_adc0(
    .i_clk_62p5             ( clk_64m             ),
    .i_clk_250              ( clk_128m            ),
    .i_rst_62p5             ( rst_125             ),

    .i_adc0_mean            ( adc0_mean0          ),	//输入 入射mean
    .i_adc1_mean            ( adc1_mean0          ),	//输入 反射mean

    .o_sys_start            ( ch0_start_adc       ),

	.vld					( AD9238_CH0_vld      ),
    .i_ad9248_da            ( {AD9238_CH0_CHB[11],AD9238_CH0_CHB[11],AD9238_CH0_CHB}  ),	//AD9643数据,入射
    .i_ad9248_db            ( {AD9238_CH0_CHA[11],AD9238_CH0_CHA[11],AD9238_CH0_CHA}  ),//AD9643数据，反射

    .o_ad9248_da_vld        ( ad9238_da0_vld      ),
    .o_ad9248_da            ( ad9238_da0          ), //2个14bit补齐到32bit signed；
    .o_ad9248_db_vld        ( ad9238_db0_vld      ),
    .o_ad9248_db            ( ad9238_db0          )  //2个14bit补齐到32bit signed；
);                                             
`endif


`ifdef INPUT_SENSOR_CH1  
daq9248 daq9248_adc2(
    .i_clk_62p5             ( clk_64m             ),
    .i_clk_250              ( clk_128m            ),
    .i_rst_62p5             ( rst_125             ),

    .i_adc0_mean            ( adc0_mean2          ),	//输入 入射mean
    .i_adc1_mean            ( adc1_mean2          ),	//输入 反射mean

    .o_sys_start            ( ch2_start_adc       ),
                                     
	.vld					( AD9238_CH2_vld      ),
    .i_ad9248_da            ( {AD9238_CH2_CHB[11],AD9238_CH2_CHB[11],AD9238_CH2_CHB }  ),	//AD9643数据,入射
    .i_ad9248_db            ( {AD9238_CH2_CHA[11],AD9238_CH2_CHA[11],AD9238_CH2_CHA }  ),//AD9643数据，反射
                                  
    .o_ad9248_da_vld        ( ad9238_da2_vld      ),
    .o_ad9248_da            ( ad9238_da2          ), //2个14bit补齐到32bit signed；
    .o_ad9248_db_vld        ( ad9238_db2_vld      ),
    .o_ad9248_db            ( ad9238_db2          )  //2个14bit补齐到32bit signed；
);  
`endif

// `ifdef OUTPUT_SENSOR_CH0 
// daq9248 daq9248_adc1(
    // .i_clk_62p5             ( clk_64m             ),
    // .i_clk_250              ( clk_128m            ),
    // .i_rst_62p5             ( rst_125             ),

    // .i_adc0_mean            ( adc0_mean1          ),	//输入 入射mean
    // .i_adc1_mean            ( adc1_mean1          ),	//输入 反射mean

    // .o_sys_start            ( ch1_start_adc       ),
                                     
	// .vld					( AD9238_CH1_vld      ),
    // .i_ad9248_da            ( {AD9238_CH1_CHB[11],AD9238_CH1_CHB[11],AD9238_CH1_CHB }    ),	//AD9643数据,入射
    // .i_ad9248_db            ( {AD9238_CH1_CHA[11],AD9238_CH1_CHA[11],AD9238_CH1_CHA }    ), //AD9643数据，反射
                                       
    // .o_ad9248_da_vld        ( ad9238_da1_vld      ),
    // .o_ad9248_da            ( ad9238_da1          ), //2个14bit补齐到32bit signed；
    // .o_ad9248_db_vld        ( ad9238_db1_vld      ),
    // .o_ad9248_db            ( ad9238_db1          )  //2个14bit补齐到32bit signed；
// );                                             
// `endif             
   
`ifdef OUTPUT_SENSOR_CH1_CH2 
daq9248 daq9248_adc3(                               //13.56M
    .i_clk_62p5             ( clk_64m             ),
    .i_clk_250              ( clk_128m            ),
    .i_rst_62p5             ( rst_125             ),

    .i_adc0_mean            ( adc0_mean3          ),	//输入 入射mean
    .i_adc1_mean            ( adc1_mean3          ),	//输入 反射mean

    .o_sys_start            ( ch3_start_adc       ),
                                     
	.vld					( AD9238_CH3_vld      ),
    .i_ad9248_da            ( {AD9238_CH3_CHB[11],AD9238_CH3_CHB[11],AD9238_CH3_CHB }    ),	//AD9643数据,入射   V
    .i_ad9248_db            ( {AD9238_CH3_CHA[11],AD9238_CH3_CHA[11],AD9238_CH3_CHA }    ), //AD9643数据，反射
                                       
    .o_ad9248_da_vld        ( ad9238_da3_vld      ),
    .o_ad9248_da            ( ad9238_da3          ), //2个14bit补齐到32bit signed；
    .o_ad9248_db_vld        ( ad9238_db3_vld      ),
    .o_ad9248_db            ( ad9238_db3          )  //2个14bit补齐到32bit signed；
);      



daq9248 daq9248_adc3_400k(
    .i_clk_62p5             ( clk_64m             ),
    .i_clk_250              ( clk_128m            ),
    .i_rst_62p5             ( rst_125             ),

    .i_adc0_mean            ( adc0_mean3_400k     ),	//输入 入射mean
    .i_adc1_mean            ( adc1_mean3_400k     ),	//输入 反射mean

    .o_sys_start            ( ch3_start_adc_400k  ),
                                     
	.vld					( AD9238_CH3_vld      ),
    .i_ad9248_da            ( {AD9238_CH3_CHB[11],AD9238_CH3_CHB[11],AD9238_CH3_CHB }    ),	//AD9643数据,入射   V
    .i_ad9248_db            ( {AD9238_CH3_CHA[11],AD9238_CH3_CHA[11],AD9238_CH3_CHA }    ), //AD9643数据，反射
                                       
    .o_ad9248_da_vld        ( ad9238_400k_da3_vld ),
    .o_ad9248_da            ( ad9238_400k_da3     ), //2个14bit补齐到32bit signed；
    .o_ad9248_db_vld        ( ad9238_400k_db3_vld ),
    .o_ad9248_db            ( ad9238_400k_db3     )  //2个14bit补齐到32bit signed；
);      



daq9248 daq9248_adc4(                                     //13.56M
    .i_clk_62p5             ( clk_64m             ),
    .i_clk_250              ( clk_128m            ),
    .i_rst_62p5             ( rst_125             ),

    .i_adc0_mean            ( adc0_mean4          ),	//输入 入射mean
    .i_adc1_mean            ( adc1_mean4          ),	//输入 反射mean

    .o_sys_start            ( ch4_start_adc       ),
                                     
	.vld					( AD9238_CH4_vld      ),
    .i_ad9248_da            ( {AD9238_CH4_CHB[11],AD9238_CH4_CHB[11],AD9238_CH4_CHB }    ),	//AD9643数据,入射
    .i_ad9248_db            ( {AD9238_CH4_CHA[11],AD9238_CH4_CHA[11],AD9238_CH4_CHA }    ), //AD9643数据，反射
                                       
    .o_ad9248_da_vld        ( ad9238_da4_vld      ),
    .o_ad9248_da            ( ad9238_da4          ), //2个14bit补齐到32bit signed；
    .o_ad9248_db_vld        ( ad9238_db4_vld      ),
    .o_ad9248_db            ( ad9238_db4          )  //2个14bit补齐到32bit signed；
);    


daq9248 daq9248_adc4_400k(
    .i_clk_62p5             ( clk_64m             ),
    .i_clk_250              ( clk_128m            ),
    .i_rst_62p5             ( rst_125             ),

    .i_adc0_mean            ( adc0_mean4_400k     ),	//输入 入射mean
    .i_adc1_mean            ( adc1_mean4_400k     ),	//输入 反射mean

    .o_sys_start            ( ch4_start_adc_400k  ),
                                     
	.vld					( AD9238_CH4_vld      ),
    .i_ad9248_da            ( {AD9238_CH4_CHB[11],AD9238_CH4_CHB[11],AD9238_CH4_CHB }    ),	//AD9643数据,入射
    .i_ad9248_db            ( {AD9238_CH4_CHA[11],AD9238_CH4_CHA[11],AD9238_CH4_CHA }    ), //AD9643数据，反射
                                       
    .o_ad9248_da_vld        ( ad9238_400k_da4_vld      ),
    .o_ad9248_da            ( ad9238_400k_da4          ), //2个14bit补齐到32bit signed；
    .o_ad9248_db_vld        ( ad9238_400k_db4_vld      ),
    .o_ad9248_db            ( ad9238_400k_db4          )  //2个14bit补齐到32bit signed；
);  

                                    
`endif   

   

`ifdef INPUT_SENSOR_CH0 
adc_demod adc_demod_HF(
    .i_clk                     ( clk_128m               ),
    .i_rst                     ( rst_125                ),
													   
    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数据
													   
    .i_sys_start               ( ch0_start_bpf          ),	
    .o_sys_start               ( sys0_start_demod       ),
    .RF_FREQ				   ( RF_FREQ0			    ),
	//.freq_data				   ( freq_out0			    ),
    // adc bpf data           
    .i_adc0_vld                ( adc0_ch0_bpf_vld      ),
    .i_adc0_data               ( adc0_ch0_bpf_data     ),
    .i_adc1_vld                ( adc1_ch0_bpf_vld      ),
    .i_adc1_data               ( adc1_ch0_bpf_data     ),
						              
    // adc lpf data           
    .o_adc0_demod_vld          ( adc0_ch0_demod_vld    ),  
    .o_adc0_demod_data         ( adc0_ch0_demod_data   ),  // {Vmi ,Vmq}					      
    .o_adc1_demod_vld          ( adc1_ch0_demod_vld    ),
    .o_adc1_demod_data         ( adc1_ch0_demod_data   ),  // {Imi ,Imq}
													   
	.r_demod_rd_addr		   ( demod_rd_addr0	       ),
    .i_demod_freq_coef         ( demod_freq_coef0      )
);

`endif


`ifdef INPUT_SENSOR_CH1  
adc_demod adc_demod_LF(
    .i_clk                     ( clk_128m               ),
    .i_rst                     ( rst_125                ),
													    
    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数据
													    
    .i_sys_start               ( ch2_start_bpf          ),	
    .o_sys_start               ( sys2_start_demod       ),
    .RF_FREQ				   ( RF_FREQ2			    ),
	//.freq_data				   ( freq_out2			    ),
    // adc bpf data                                     
    .i_adc0_vld                ( adc0_ch2_bpf_vld       ),
    .i_adc0_data               ( adc0_ch2_bpf_data      ),
    .i_adc1_vld                ( adc1_ch2_bpf_vld       ),
    .i_adc1_data               ( adc1_ch2_bpf_data      ),
						      
    // adc lpf data           
    .o_adc0_demod_vld          ( adc0_ch2_demod_vld     ),  
    .o_adc0_demod_data         ( adc0_ch2_demod_data    ),  // {Vmi ,Vmq}												    
    .o_adc1_demod_vld          ( adc1_ch2_demod_vld     ),
    .o_adc1_demod_data         ( adc1_ch2_demod_data    ),  // {Imi ,Imq}
	
	.r_demod_rd_addr		   ( demod_rd_addr2	        ),												    
    .i_demod_freq_coef         ( demod_freq_coef2       )
);
`endif



// `ifdef OUTPUT_SENSOR_CH0 
// adc_demod adc_demod_OS0(
    // .i_clk                     ( clk_128m               ),
    // .i_rst                     ( rst_125                ),
													    
    // .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数据
													    
    // .i_sys_start               ( ch1_start_bpf          ),	
    // .o_sys_start               ( sys1_start_demod       ),
    // .RF_FREQ				   ( RF_FREQ1			    ),
	// .freq_data				   ( freq_out1			    ),
    // // adc bpf data                                     
    // .i_adc0_vld                ( adc0_ch1_bpf_vld       ),
    // .i_adc0_data               ( adc0_ch1_bpf_data      ),
    // .i_adc1_vld                ( adc1_ch1_bpf_vld       ),
    // .i_adc1_data               ( adc1_ch1_bpf_data      ),
													    
    // // adc lpf data                                     
    // .o_adc0_demod_vld          ( adc0_ch1_demod_vld     ),  
    // .o_adc0_demod_data         ( adc0_ch1_demod_data    ),  // {Vmi ,Vmq}				      
    // .o_adc1_demod_vld          ( adc1_ch1_demod_vld     ),
    // .o_adc1_demod_data         ( adc1_ch1_demod_data    ),  // {Imi ,Imq}
													     
	// .r_demod_rd_addr		   ( demod_rd_addr1	        ),
    // .i_demod_freq_coef         ( demod_freq_coef1       )
// );

// `endif

`ifdef OUTPUT_SENSOR_CH1_CH2    //HF;
adc_demod adc_demod_OS1(
    .i_clk                     ( clk_128m               ),
    .i_rst                     ( rst_125                ),
													    
    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数据
													    
    .i_sys_start               ( ch3_start_bpf          ),	
    .o_sys_start               ( sys3_start_demod       ),
    //.RF_FREQ				   ( RF_FREQ3			    ),
	//.freq_data				   ( freq_out3			    ),
    // adc bpf data                                     
    .i_adc0_vld                ( adc0_ch3_bpf_vld       ),
    .i_adc0_data               ( adc0_ch3_bpf_data      ),
    .i_adc1_vld                ( adc1_ch3_bpf_vld       ),
    .i_adc1_data               ( adc1_ch3_bpf_data      ),
													    
    // adc lpf data                                     
    .o_adc0_demod_vld          ( adc0_ch3_demod_vld     ),  
    .o_adc0_demod_data         ( adc0_ch3_demod_data    ),  // {Vmi ,Vmq}				      
    .o_adc1_demod_vld          ( adc1_ch3_demod_vld     ),
    .o_adc1_demod_data         ( adc1_ch3_demod_data    ),  // {Imi ,Imq}
													     
	.r_demod_rd_addr		   ( demod_rd_addr3         ),
    .i_demod_freq_coef         ( demod_freq_coef0       )
);

adc_demod adc_demod_400k_OS1(
    .i_clk                     ( clk_128m               ),
    .i_rst                     ( rst_125                ),
													    
    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数据
													    
    .i_sys_start               ( ch3_start_bpf_400k     ),	
    .o_sys_start               ( sys3_start_400k_demod  ),
   // .RF_FREQ				   ( RF_FREQ3			    ),
	//.freq_data				   ( freq_out3			    ),
    // adc bpf data                                     
    .i_adc0_vld                ( adc0_ch3_bpf_400k_vld   ),
    .i_adc0_data               ( adc0_ch3_bpf_400k_data  ),
    .i_adc1_vld                ( adc1_ch3_bpf_400k_vld   ),
    .i_adc1_data               ( adc1_ch3_bpf_400k_data  ),
													    
    // adc lpf data                                     
    .o_adc0_demod_vld          ( adc0_ch3_demod_400k_vld ),  
    .o_adc0_demod_data         ( adc0_ch3_demod_400k_data),  // {Vmi ,Vmq}				      
    .o_adc1_demod_vld          ( adc1_ch3_demod_400k_vld ),
    .o_adc1_demod_data         ( adc1_ch3_demod_400k_data),  // {Imi ,Imq}
													     
	.r_demod_rd_addr		   ( demod_rd_400k_addr3     ),
    .i_demod_freq_coef         ( demod_freq_coef2        )
);



adc_demod adc_demod_OS2(
    .i_clk                     ( clk_128m               ),
    .i_rst                     ( rst_125                ),
													    
    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数据
													    
    .i_sys_start               ( ch4_start_bpf          ),	
    .o_sys_start               ( sys4_start_demod       ),
    //.RF_FREQ				   ( RF_FREQ4			    ),
	//.freq_data				   ( freq_out4			    ),
    // adc bpf data                                     
    .i_adc0_vld                ( adc0_ch4_bpf_vld       ),
    .i_adc0_data               ( adc0_ch4_bpf_data      ),
    .i_adc1_vld                ( adc1_ch4_bpf_vld       ),
    .i_adc1_data               ( adc1_ch4_bpf_data      ),
													    
    // adc lpf data                                     
    .o_adc0_demod_vld          ( adc0_ch4_demod_vld     ),  
    .o_adc0_demod_data         ( adc0_ch4_demod_data    ),  // {Vmi ,Vmq}				      
    .o_adc1_demod_vld          ( adc1_ch4_demod_vld     ),
    .o_adc1_demod_data         ( adc1_ch4_demod_data    ),  // {Imi ,Imq}
													     
	.r_demod_rd_addr		   ( demod_rd_addr4	        ),
    .i_demod_freq_coef         ( demod_freq_coef0       )
);

adc_demod adc_demod_400k_OS2(
    .i_clk                     ( clk_128m               ),
    .i_rst                     ( rst_125                ),
													    
    .i_coef_len                ( 'd3125                 ),//( O_dac1_wave_len           ), //固定3125个数据
													    
    .i_sys_start               ( ch4_start_bpf_400k     ),	
    .o_sys_start               ( sys4_start_400k_demod  ),
    //.RF_FREQ				   ( RF_FREQ4			    ),
	//.freq_data				   ( freq_out4			    ),
    // adc bpf data                                     
    .i_adc0_vld                ( adc0_ch4_bpf_400k_vld  ),
    .i_adc0_data               ( adc0_ch4_bpf_400k_data ),
    .i_adc1_vld                ( adc1_ch4_bpf_400k_vld  ),
    .i_adc1_data               ( adc1_ch4_bpf_400k_data ),
													    
    // adc lpf data                                     
    .o_adc0_demod_vld          ( adc0_ch4_demod_400k_vld ),  
    .o_adc0_demod_data         ( adc0_ch4_demod_400k_data),  // {Vmi ,Vmq}				      
    .o_adc1_demod_vld          ( adc1_ch4_demod_400k_vld ),
    .o_adc1_demod_data         ( adc1_ch4_demod_400k_data),  // {Imi ,Imq}
													     
	.r_demod_rd_addr		   ( demod_rd_400k_addr4	),
    .i_demod_freq_coef         ( demod_freq_coef2       )
);



`endif



`ifdef INPUT_SENSOR_CH0   
adc_lpf adc_lpf_HF(
    .i_clk_250                 ( clk_128m              ),
    .i_rst                     ( rst_125               ),
						      
    .i_sys_start               ( sys0_start_demod      ),
    .o_sys_start               ( sys0_start_lpf        ),
													   
    .i_adc0_demod_vld          ( adc0_ch0_demod_vld    ),
    .i_adc0_demod_data         ( adc0_ch0_demod_data   ),						      
    .i_adc1_demod_vld          ( adc1_ch0_demod_vld    ),
    .i_adc1_demod_data         ( adc1_ch0_demod_data   ),
						                
    .o_adc0_lpf_vld            ( adc0_ch0_lpf_vld     ), //V
    .o_adc0_lpf_data           ( adc0_ch0_lpf_data    ),						      
    .o_adc1_lpf_vld            ( adc1_ch0_lpf_vld     ), //I
    .o_adc1_lpf_data           ( adc1_ch0_lpf_data    )
); 
`endif


`ifdef INPUT_SENSOR_CH1  
adc_lpf_400k adc_lpf_400k_LF(
    .i_clk_250                 ( clk_128m              ),
    .i_rst                     ( rst_125               ),
						      
    .i_sys_start               ( sys2_start_demod      ),
    .o_sys_start               ( sys2_start_lpf        ),
													   
    .i_adc0_demod_vld          ( adc0_ch2_demod_vld    ),
    .i_adc0_demod_data         ( adc0_ch2_demod_data   ),						      
    .i_adc1_demod_vld          ( adc1_ch2_demod_vld    ),
    .i_adc1_demod_data         ( adc1_ch2_demod_data   ),
													   
    .o_adc0_lpf_vld            ( adc0_ch2_lpf_vld      ), //V
    .o_adc0_lpf_data           ( adc0_ch2_lpf_data     ),						      
    .o_adc1_lpf_vld            ( adc1_ch2_lpf_vld      ), //I
    .o_adc1_lpf_data           ( adc1_ch2_lpf_data     )

); 
`endif

// `ifdef OUTPUT_SENSOR_CH0
// adc_lpf adc_lpf_OS0(
    // .i_clk_250                 ( clk_128m              ),
    // .i_rst                     ( rst_125               ),
						      
    // .i_sys_start               ( sys1_start_demod      ),
    // .o_sys_start               ( sys1_start_lpf        ),
	        
    // .i_adc0_demod_vld          ( adc0_ch1_demod_vld    ),
    // .i_adc0_demod_data         ( adc0_ch1_demod_data   ),						      
    // .i_adc1_demod_vld          ( adc1_ch1_demod_vld    ),
    // .i_adc1_demod_data         ( adc1_ch1_demod_data   ),
						              
    // .o_adc0_lpf_vld            ( adc0_ch1_lpfx_vld      ), //V
    // .o_adc0_lpf_data           ( adc0_ch1_lpfx_data     ),						      
    // .o_adc1_lpf_vld            ( adc1_ch1_lpfx_vld      ), //I
    // .o_adc1_lpf_data           ( adc1_ch1_lpfx_data     )
// ); 

// `endif


`ifdef OUTPUT_SENSOR_CH1_CH2

// adc_lpf adc_lpf_OS1(                                      //13.56m
    // .i_clk_250                 ( clk_128m              ),
    // .i_rst                     ( rst_125               ),
						      
    // .i_sys_start               ( sys3_start_demod      ),
    // .o_sys_start               ( sys3_start_lpf        ),
	        
    // .i_adc0_demod_vld          ( adc0_ch3_demod_vld    ),
    // .i_adc0_demod_data         ( adc0_ch3_demod_data   ),						      
    // .i_adc1_demod_vld          ( adc1_ch3_demod_vld    ),
    // .i_adc1_demod_data         ( adc1_ch3_demod_data   ),
						              
    // .o_adc0_lpf_vld            ( adc0_ch3_lpf_vld      ), //V
    // .o_adc0_lpf_data           ( adc0_ch3_lpf_data     ),						      
    // .o_adc1_lpf_vld            ( adc1_ch3_lpf_vld      ), //I
    // .o_adc1_lpf_data           ( adc1_ch3_lpf_data     )

// ); 

// adc_lpf_400k adc_lpf_400k_OS1(
    // .i_clk_250                 ( clk_128m              ),
    // .i_rst                     ( rst_125               ),
						      
    // .i_sys_start               ( sys3_start_400k_demod   ),
    // .o_sys_start               ( sys3_start_400k_lpf     ),
	                             
    // .i_adc0_demod_vld          ( adc0_ch3_demod_400k_vld ),
    // .i_adc0_demod_data         ( adc0_ch3_demod_400k_data),						      
    // .i_adc1_demod_vld          ( adc1_ch3_demod_400k_vld ),
    // .i_adc1_demod_data         ( adc1_ch3_demod_400k_data),
						              
    // .o_adc0_lpf_vld            ( adc0_ch3_lpf_400k_vld   ), //V
    // .o_adc0_lpf_data           ( adc0_ch3_lpf_400k_data  ),						      
    // .o_adc1_lpf_vld            ( adc1_ch3_lpf_400k_vld   ), //I
    // .o_adc1_lpf_data           ( adc1_ch3_lpf_400k_data  )
// ); 



adc_lpf adc_lpf_OS2(                                            //13.56m
    .i_clk_250                 ( clk_128m                 ),
    .i_rst                     ( rst_125                  ),
													     
    .i_sys_start               ( sys4_start_demod         ),
    .o_sys_start               ( sys4_start_lpf           ),
													     
    .i_adc0_demod_vld          ( adc0_ch4_demod_vld       ),
    .i_adc0_demod_data         ( adc0_ch4_demod_data      ),						      
    .i_adc1_demod_vld          ( adc1_ch4_demod_vld       ),
    .i_adc1_demod_data         ( adc1_ch4_demod_data      ),
													     
    .o_adc0_lpf_vld            ( adc0_ch4_lpf_vld         ), //V
    .o_adc0_lpf_data           ( adc0_ch4_lpf_data        ),						      
    .o_adc1_lpf_vld            ( adc1_ch4_lpf_vld         ), //I
    .o_adc1_lpf_data           ( adc1_ch4_lpf_data        )

);


adc_lpf_400k adc_lpf_400k_OS2(                                            //13.56m
    .i_clk_250                 ( clk_128m                 ),
    .i_rst                     ( rst_125                  ),
						      
    .i_sys_start               ( sys4_start_400k_demod    ),
    .o_sys_start               ( sys4_start_400k_lpf      ),
	        
    .i_adc0_demod_vld          ( adc0_ch4_demod_400k_vld  ),
    .i_adc0_demod_data         ( adc0_ch4_demod_400k_data ),						      
    .i_adc1_demod_vld          ( adc1_ch4_demod_400k_vld  ),
    .i_adc1_demod_data         ( adc1_ch4_demod_400k_data ),
						              
    .o_adc0_lpf_vld            ( adc0_ch4_lpf_400k_vld    ), //V
    .o_adc0_lpf_data           ( adc0_ch4_lpf_400k_data   ),						      
    .o_adc1_lpf_vld            ( adc1_ch4_lpf_400k_vld    ), //I
    .o_adc1_lpf_data           ( adc1_ch4_lpf_400k_data   )

);

`endif



//-----------------------------------分流出原始滤波iq计算A B C D Dicao参数---------------------------------//
// `ifdef OUTPUT_SENSOR_CH0 
// data_ext	OS0_data_ext_Vm(                          
	// .i_clk				        (clk_128m              ),
	// .clk_50m			        (clk_50m               ),
	// .i_data				        (adc0_ch1_lpfx_data     ),	//V
	// .i_valid			        (adc0_ch1_lpfx_vld      ), 
	// .r_demod_rd_addr	        (demod_rd_addr1        ),
	// .o_data_i			        (SENSOR1_ADC0_I        ),
	// .o_data_q			        (SENSOR1_ADC0_Q        ),
	// .o_valid			        (OS0_demod_vld0        )
// );   

// data_ext	OS0_data_ext_Im(
	// .i_clk				        (clk_128m 		       ),
	// .clk_50m			        (clk_50m		       ),
	// .i_data				        (adc1_ch1_lpfx_data     ),	//I
	// .i_valid			        (adc1_ch1_lpfx_vld      ),   
	// .r_demod_rd_addr	        (demod_rd_addr1        ),
	// .o_data_i			        (SENSOR1_ADC1_I        ),
	// .o_data_q			        (SENSOR1_ADC1_Q        ),
	// .o_valid			        (OS0_demod_vld1        )
// ); 


// //复用在power稳定时候的iq 为有效值；提取出来；此时时钟域为50M；
// always@(clk_50m)begin
	// if(OS0_demod_vld0)begin
          // r_SENSOR1_ADC0_I <= SENSOR1_ADC0_I ;		
          // r_SENSOR1_ADC0_Q <= SENSOR1_ADC0_Q ;		
	// end
// end

// always@(clk_50m)begin
	// if(OS0_demod_vld1)begin
          // r_SENSOR1_ADC1_I <= SENSOR1_ADC1_I ;	
          // r_SENSOR1_ADC1_Q <= SENSOR1_ADC1_Q ;		
	// end
// end

// // always@(clk_50m)begin
         // // r2_SENSOR1_ADC0_I <= r_SENSOR1_ADC0_I ;		//V
// // end 

// // syn i && q; lock ; 


// always@(clk_50m)begin
	// if(decor_pulse) begin          
         // r2_SENSOR1_ADC0_I <= r_SENSOR1_ADC0_I ;	
	     // r2_SENSOR1_ADC0_Q <= r_SENSOR1_ADC0_Q ;
         // r2_SENSOR1_ADC1_I <= r_SENSOR1_ADC1_I ;		
		 // r2_SENSOR1_ADC1_Q <= r_SENSOR1_ADC1_Q ;	
	// end
	// else begin
	
         // r2_SENSOR1_ADC0_I <= r2_SENSOR1_ADC0_I ;	
	     // r2_SENSOR1_ADC0_Q <= r2_SENSOR1_ADC0_Q ;
         // r2_SENSOR1_ADC1_I <= r2_SENSOR1_ADC1_I ;		
		 // r2_SENSOR1_ADC1_Q <= r2_SENSOR1_ADC1_Q ;	
    // end
// end 
// `endif
// // syn i && q; lock ; 去除avg_seial结果直接发出去；所以注释掉；


`ifdef OUTPUT_SENSOR_CH1_CH2 
// data_ext	OS1_data_ext_Vm(                          
	// .i_clk				        (clk_128m              ),
	// .clk_50m			        (clk_50m               ),
	// .i_data				        (adc0_ch3_lpf_data     ),	//V
	// .i_valid			        (adc0_ch3_lpf_vld      ), 
	// .r_demod_rd_addr	        (demod_rd_addr3        ),
	// .o_data_i			        (SENSOR3_ADC0_I        ),
	// .o_data_q			        (SENSOR3_ADC0_Q        ),
	// .o_valid			        (OS1_demod_vld0        )
// );   

// data_ext	OS1_data_ext_Im(
	// .i_clk				        (clk_128m 		       ),
	// .clk_50m			        (clk_50m		       ),
	// .i_data				        (adc1_ch3_lpf_data     ),	//I
	// .i_valid			        (adc1_ch3_lpf_vld      ),   
	// .r_demod_rd_addr	        (demod_rd_addr3        ),
	// .o_data_i			        (SENSOR3_ADC1_I        ),
	// .o_data_q			        (SENSOR3_ADC1_Q        ),
	// .o_valid			        (OS1_demod_vld1        )
// ); 


// data_ext	OS1_400k_data_ext_Vm(                          
	// .i_clk				        (clk_128m              ),
	// .clk_50m			        (clk_50m               ),
	// .i_data				        (adc0_ch3_lpf_400k_data),	//V
	// .i_valid			        (adc0_ch3_lpf_400k_vld ), 
	// .r_demod_rd_addr	        (demod_rd_400k_addr3   ),
	// .o_data_i			        (SENSOR3_ADC0_400K_I   ),
	// .o_data_q			        (SENSOR3_ADC0_400K_Q   ),
	// .o_valid			        (OS1_demod_400k_vld0   )
// );   

// data_ext	OS1_400k_data_ext_Im(
	// .i_clk				        (clk_128m 		       ),
	// .clk_50m			        (clk_50m		       ),
	// .i_data				        (adc1_ch3_lpf_400k_data),	//I
	// .i_valid			        (adc1_ch3_lpf_400k_vld ),   
	// .r_demod_rd_addr	        (demod_rd_400k_addr3   ),
	// .o_data_i			        (SENSOR3_ADC1_400K_I   ),
	// .o_data_q			        (SENSOR3_ADC1_400K_Q   ),
	// .o_valid			        (OS1_demod_400k_vld1   )
// ); 




//复用在power稳定时候的iq 为有效值；提取出来；此时时钟域为50M；
// always@(clk_50m)begin
	// if(OS1_demod_vld0)begin
          // r_SENSOR3_ADC0_I <= SENSOR3_ADC0_I ;		
          // r_SENSOR3_ADC0_Q <= SENSOR3_ADC0_Q ;	
	// end
// end

// always@(clk_50m)begin
	// if(OS1_demod_vld1)begin
          // r_SENSOR3_ADC1_I <= SENSOR3_ADC1_I ;	
          // r_SENSOR3_ADC1_Q <= SENSOR3_ADC1_Q ;		
	// end
// end


// always@(clk_50m)begin
	// if(OS1_demod_400k_vld0)begin
          // r_SENSOR3_ADC0_400K_I <= SENSOR3_ADC0_400K_I ;		
          // r_SENSOR3_ADC0_400K_Q <= SENSOR3_ADC0_400K_Q ;	
	// end
// end

// always@(clk_50m)begin
	// if(OS1_demod_400k_vld1)begin
          // r_SENSOR3_ADC1_400K_I <= SENSOR3_ADC1_400K_I ;	
          // r_SENSOR3_ADC1_400K_Q <= SENSOR3_ADC1_400K_Q ;		
	// end
// end



// syn i && q; lock ; 
// always@(clk_50m)begin
	// if(r_decor_pulse_pos) begin   
         // r2_SENSOR3_ADC0_I <= r_SENSOR3_ADC0_I ;
	     // r2_SENSOR3_ADC0_Q <= r_SENSOR3_ADC0_Q ;
         // r2_SENSOR3_ADC1_I <= r_SENSOR3_ADC1_I ;		
		 // r2_SENSOR3_ADC1_Q <= r_SENSOR3_ADC1_Q ;	
		 
         // r2_SENSOR3_ADC0_400K_I <= r_SENSOR3_ADC0_400K_I ;
	     // r2_SENSOR3_ADC0_400K_Q <= r_SENSOR3_ADC0_400K_Q ;
         // r2_SENSOR3_ADC1_400K_I <= r_SENSOR3_ADC1_400K_I ;		
		 // r2_SENSOR3_ADC1_400K_Q <= r_SENSOR3_ADC1_400K_Q ;			 
		 
	// end
	// else begin
	     // r2_SENSOR3_ADC0_I <= r2_SENSOR3_ADC0_I ;
	     // r2_SENSOR3_ADC0_Q <= r2_SENSOR3_ADC0_Q ;
         // r2_SENSOR3_ADC1_I <= r2_SENSOR3_ADC1_I ;		
		 // r2_SENSOR3_ADC1_Q <= r2_SENSOR3_ADC1_Q ;	
		 
	     // r2_SENSOR3_ADC0_400K_I <= r2_SENSOR3_ADC0_400K_I ;
	     // r2_SENSOR3_ADC0_400K_Q <= r2_SENSOR3_ADC0_400K_Q ;
         // r2_SENSOR3_ADC1_400K_I <= r2_SENSOR3_ADC1_400K_I ;		
		 // r2_SENSOR3_ADC1_400K_Q <= r2_SENSOR3_ADC1_400K_Q ;			 
 
    // end
// end 


data_ext	OS2_data_ext_Vm(                          
	.i_clk				        (clk_128m              ),
	.clk_50m			        (clk_50m               ),
	.i_data				        (adc0_ch4_lpf_data     ),	//V
	.i_valid			        (adc0_ch4_lpf_vld      ), 
	.r_demod_rd_addr	        (demod_rd_addr4        ),
	.o_data_i			        (SENSOR4_ADC0_I        ),
	.o_data_q			        (SENSOR4_ADC0_Q        ),
	.o_valid			        (OS2_demod_vld0        )
);   

data_ext	OS2_data_ext_Im(
	.i_clk				        (clk_128m 		       ),
	.clk_50m			        (clk_50m		       ),
	.i_data				        (adc1_ch4_lpf_data     ),	//I
	.i_valid			        (adc1_ch4_lpf_vld      ),   
	.r_demod_rd_addr	        (demod_rd_addr4        ),
	.o_data_i			        (SENSOR4_ADC1_I        ),
	.o_data_q			        (SENSOR4_ADC1_Q        ),
	.o_valid			        (OS2_demod_vld1        )
); 


data_ext	OS2_400k_data_ext_Vm(                          
	.i_clk				        (clk_128m              ),
	.clk_50m			        (clk_50m               ),
	.i_data				        (adc0_ch4_lpf_400k_data),	//V
	.i_valid			        (adc0_ch4_lpf_400k_vld ), 
	.r_demod_rd_addr	        (demod_rd_400k_addr4   ),
	.o_data_i			        (SENSOR4_ADC0_400K_I   ),
	.o_data_q			        (SENSOR4_ADC0_400K_Q   ),
	.o_valid			        (OS2_demod_400k_vld0   )
);   

data_ext	OS2_400k_data_ext_Im(
	.i_clk				        (clk_128m 		       ),
	.clk_50m			        (clk_50m		       ),
	.i_data				        (adc1_ch4_lpf_400k_data),	//I
	.i_valid			        (adc1_ch4_lpf_400k_vld ),   
	.r_demod_rd_addr	        (demod_rd_400k_addr4   ),
	.o_data_i			        (SENSOR4_ADC1_400K_I   ),
	.o_data_q			        (SENSOR4_ADC1_400K_Q   ),
	.o_valid			        (OS2_demod_400k_vld1   )
); 




//复用在power稳定时候的iq 为有效值；提取出来；此时时钟域为50M；
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

`endif



`ifdef INPUT_SENSOR_CH0  
Decor_Calib Decor_Calib_HF(
    .i_clk                   ( clk_128m              ),
    .i_rst                   ( rst_125               ),
												    
    .i_sys_start             ( sys0_start_lpf        ),
    .o_sys_start             ( sys0_start_calib      ),
												    
    .i_calib_en              ( 1'b1                  ),
    
    // .o_adc0_mean             ( adc0_mean0            ),//从SPI发来
    // .o_adc1_mean             ( adc1_mean0            ),
 
    .i_adc0_lpf_vld          ( adc0_ch0_lpf_vld      ), //Vf
    .i_adc0_lpf_data         ( adc0_ch0_lpf_data     ),
    .i_adc1_lpf_vld          ( adc1_ch0_lpf_vld      ), //Vr
    .i_adc1_lpf_data         ( adc1_ch0_lpf_data     ),
												     
    .o_adc0_calib_vld        ( adc0_ch0_calib_vld    ), 
    .o_adc0_calib_data       ( adc0_ch0_calib_data   ),	   
    .o_adc1_calib_vld        ( adc1_ch0_calib_vld    ),	
    .o_adc1_calib_data       ( adc1_ch0_calib_data   ),	

	.m1a00					 ( m1a00_ch0		     ),
	.m1a01					 ( m1a01_ch0		     ),
	.m1a10					 ( m1a10_ch0		     ),
	.m1a11					 ( m1a11_ch0		     )

);
`endif

`ifdef INPUT_SENSOR_CH1  
Decor_Calib Decor_Calib_LF(
    .i_clk                   ( clk_128m             ),
    .i_rst                   ( rst_125              ),
    
    .i_sys_start             ( sys2_start_lpf       ),
    .o_sys_start             ( sys2_start_calib     ),
    
    .i_calib_en              ( 1'b1                 ),
    
    // .o_adc0_mean             ( adc0_mean1           ),//从SPI发来
    // .o_adc1_mean             ( adc1_mean1           ),

    .i_adc0_lpf_vld          ( adc0_ch2_lpf_vld     ), //V
    .i_adc0_lpf_data         ( adc0_ch2_lpf_data    ),
    .i_adc1_lpf_vld          ( adc1_ch2_lpf_vld     ), //I
    .i_adc1_lpf_data         ( adc1_ch2_lpf_data    ),
												    
    .o_adc0_calib_vld        ( adc0_ch2_calib_vld   ),  //V
    .o_adc0_calib_data       ( adc0_ch2_calib_data  ),	   
    .o_adc1_calib_vld        ( adc1_ch2_calib_vld   ),	
    .o_adc1_calib_data       ( adc1_ch2_calib_data  ),	//I

	.m1a00					 ( m1a00_ch2		    ),
	.m1a01					 ( m1a01_ch2		    ),
	.m1a10					 ( m1a10_ch2		    ),
	.m1a11					 ( m1a11_ch2		    )
);
`endif

// ila_1 ila_demod (
    // .clk    (clk_128m),
    // .probe0 ({
			// AD9238_CH0_CHB,
			// adc0_ch0_bpf_data[63:32],
			// adc0_ch0_bpf_vld,
			
			// adc0_ch0_demod_data[63:32],
			// adc0_ch0_demod_vld,
			// adc0_ch0_demod_data[31:0],
			
			// adc0_ch0_lpf_data[63:32],
			// adc0_ch0_lpf_vld,
			// adc0_ch0_lpf_data[31:0],
			
			// adc0_ch0_calib_data[63:32],
			// adc0_ch0_calib_vld,
			// adc0_ch0_calib_data[31:0],
			// demod_rd_addr0,
			// ch0_calib_vf_i,
			// ch0_calib_vf_q,
			// VF_POWER0
			
			
			// })
// );	


/*----------------------------------->Input sensor 功率+阻抗业务 ------------------------------------*/

                /*-------------> HF 的 INPUT SENSOR 计算功率  -------------------*/
`ifdef INPUT_SENSOR_CH0                                        
data_ext	data_ext_HF_vf(                            
	.i_clk				     (clk_128m             ),
	.clk_50m			     (clk_50m              ),
	.i_data				     (adc0_ch0_calib_data  ),	
	.i_valid			     (adc0_ch0_calib_vld   ), 
	.r_demod_rd_addr	     (demod_rd_addr0       ),
	.o_data_i			     (ch0_calib_vf_i       ), 
	.o_data_q			     (ch0_calib_vf_q       ),
	.o_valid			     (calib_vf_vld0        )
);                                                 
												   
data_ext	data_ext_HF_vr(                              
	.i_clk				     (clk_128m 		       ),
	.clk_50m			     (clk_50m		       ),
	.i_data				     (adc1_ch0_calib_data  ),	
	.i_valid			     (adc1_ch0_calib_vld   ),
	.r_demod_rd_addr	     (demod_rd_addr0       ),
	.o_data_i			     (ch0_calib_vr_i       ),
	.o_data_q			     (ch0_calib_vr_q       ),
	.o_valid			     (calib_vr_vld0        )
);                                                 
												   
power_cal	power_HF_pf(    //INPUT SENSOR vf;          
	.i_clk				     (clk_50m              ),	//125m 
	.i_rstn				     (~rst_125		       ),
	.data_i				     (ch0_calib_vf_i       ),	//16位定点数 
	.data_q				     (ch0_calib_vf_q       ),
	.dout				     (VF_POWER0            )	//p = q^2 + i^2  
);                                                 
												   
power_cal	power_HF_pr(                                
	.i_clk				     (clk_50m              ),	//125m 
	.i_rstn				     (~rst_125             ),
	.data_i				     (ch0_calib_vr_i       ),	//16位定点数
	.data_q				     (ch0_calib_vr_q       ),
	.dout				     (VR_POWER0            )	//p = q^2 + i^2
);                                                 
`endif	
												  												   
/************************HF power cailb**********************************/
`ifdef INPUT_SENSOR_CH1  
data_ext	data_ext_LF_vf(                            
	.i_clk				     (clk_128m             ),
	.clk_50m			     (clk_50m              ),//time domain cross；
	.i_data				     (adc0_ch2_calib_data  ),	
	.i_valid			     (adc0_ch2_calib_vld   ), 
	.r_demod_rd_addr	     (demod_rd_addr2       ),
	.o_data_i			     (ch2_calib_vf_i       ), //V
	.o_data_q			     (ch2_calib_vf_q       ),
	.o_valid			     (calib_vf_vld2        )
);                                                 
												   
data_ext	data_ext_LF_vr(                              
	.i_clk				     (clk_128m 		       ),
	.clk_50m			     (clk_50m		       ),//time domain cross；
	.i_data				     (adc1_ch2_calib_data  ),	
	.i_valid			     (adc1_ch2_calib_vld   ),  //I 
	.r_demod_rd_addr	     (demod_rd_addr2       ),
	.o_data_i			     (ch2_calib_vr_i       ),
	.o_data_q			     (ch2_calib_vr_q       ),
	.o_valid			     (calib_vr_vld2        )
);                                                 
												   
power_cal	power_LF_pf(    //INPUT SENSOR vf;          
	.i_clk				     (clk_50m              ),	//125m 
	.i_rstn				     (~rst_125		       ),
	.data_i				     (ch2_calib_vf_i       ),	//16位定点数 
	.data_q				     (ch2_calib_vf_q       ),
	.dout				     (VF_POWER2            )	//p = q^2 + i^2  
);                                                 
												   
power_cal	power_LF_pr(                                
	.i_clk				     (clk_50m              ),	//125m 
	.i_rstn				     (~rst_125             ),
	.data_i				     (ch2_calib_vr_i       ),	//16位定点数
	.data_q				     (ch2_calib_vr_q       ),
	.dout				     (VR_POWER2            )	//p = q^2 + i^2
);   

`endif

`ifdef INPUT_SENSOR_CH0  
power_k_sel   power_k_sel_HF(
    .clk_i                  (clk_50m             ),
    .rst_i                  (rst_125             ),
											     
    .freq_in                (demod_freq_coef0    ),
											     
	.FREQ_CALIB_MODE        (FREQ0_CALIB_MODE    ),
    .ORIG_K	                (ORIG_K0             ),	
				    
    .POWER_CALIB_K0	        (POWER0_CALIB_K0	 ),
    .POWER_CALIB_K1	        (POWER0_CALIB_K1	 ),
    .POWER_CALIB_K2	        (POWER0_CALIB_K2	 ),
    .POWER_CALIB_K3	        (POWER0_CALIB_K3	 ),
    .POWER_CALIB_K4	        (POWER0_CALIB_K4	 ),
    .POWER_CALIB_K5	        (POWER0_CALIB_K5	 ),
    .POWER_CALIB_K6	        (POWER0_CALIB_K6	 ),
    .POWER_CALIB_K7	        (POWER0_CALIB_K7	 ),
    .POWER_CALIB_K8	        (POWER0_CALIB_K8	 ),
    .POWER_CALIB_K9	        (POWER0_CALIB_K9	 ),
    .POWER_CALIB_K10	    (POWER0_CALIB_K10    ),      
    .POWER_CALIB_K11	    (POWER0_CALIB_K11    ),      
    .POWER_CALIB_K12	    (POWER0_CALIB_K12    ),      
    .POWER_CALIB_K13	    (POWER0_CALIB_K13    ),      
    .POWER_CALIB_K14	    (POWER0_CALIB_K14    ),      
    .POWER_CALIB_K15	    (POWER0_CALIB_K15    ),      
    .POWER_CALIB_K16	    (POWER0_CALIB_K16    ),      
    .POWER_CALIB_K17	    (POWER0_CALIB_K17    ),      
    .POWER_CALIB_K18	    (POWER0_CALIB_K18    ),      
    .POWER_CALIB_K19	    (POWER0_CALIB_K19    ),      
    .POWER_CALIB_K20	    (POWER0_CALIB_K20    ),      
    .POWER_CALIB_K21	    (POWER0_CALIB_K21    ),      
    .POWER_CALIB_K22	    (POWER0_CALIB_K22    ),      
    .POWER_CALIB_K23	    (POWER0_CALIB_K23    ),      
    .POWER_CALIB_K24	    (POWER0_CALIB_K24    ),      
    .POWER_CALIB_K25	    (POWER0_CALIB_K25    ),      
    .POWER_CALIB_K26	    (POWER0_CALIB_K26    ),      
    .POWER_CALIB_K27	    (POWER0_CALIB_K27    ),      
    .POWER_CALIB_K28	    (POWER0_CALIB_K28    ),      
    .POWER_CALIB_K29	    (POWER0_CALIB_K29    ),      

    .FREQ_THR0              (FREQ0_THR0          ),		
    .FREQ_THR1              (FREQ0_THR1          ),		
    .FREQ_THR2              (FREQ0_THR2          ),		
    .FREQ_THR3              (FREQ0_THR3          ),		
    .FREQ_THR4              (FREQ0_THR4          ),		
    .FREQ_THR5              (FREQ0_THR5          ),		
    .FREQ_THR6              (FREQ0_THR6          ),		
    .FREQ_THR7              (FREQ0_THR7          ),		
    .FREQ_THR8              (FREQ0_THR8          ),		
    .FREQ_THR9              (FREQ0_THR9          ),		
    .FREQ_THR10             (FREQ0_THR10         ),		
    .FREQ_THR11             (FREQ0_THR11         ),		
    .FREQ_THR12             (FREQ0_THR12         ),		
    .FREQ_THR13             (FREQ0_THR13         ),		
    .FREQ_THR14             (FREQ0_THR14         ),		
    .FREQ_THR15             (FREQ0_THR15         ),		
    .FREQ_THR16             (FREQ0_THR16         ),		
    .FREQ_THR17             (FREQ0_THR17         ),		
    .FREQ_THR18             (FREQ0_THR18         ),		
    .FREQ_THR19             (FREQ0_THR19         ),		
    .FREQ_THR20             (FREQ0_THR20         ),		
    .FREQ_THR21             (FREQ0_THR21         ),		
    .FREQ_THR22             (FREQ0_THR22         ),		
    .FREQ_THR23             (FREQ0_THR23         ),		
    .FREQ_THR24             (FREQ0_THR24         ),		
    .FREQ_THR25             (FREQ0_THR25         ),		
    .FREQ_THR26             (FREQ0_THR26         ),		
    .FREQ_THR27             (FREQ0_THR27         ),		
    .FREQ_THR28             (FREQ0_THR28         ),		
    .FREQ_THR29             (FREQ0_THR29         ),		
    .FREQ_THR30             (FREQ0_THR30         ),		
											    
    .K_THR0 			    (K0_THR0 		     ),
    .K_THR1 			    (K0_THR1 		     ),
    .K_THR2 			    (K0_THR2 		     ),
    .K_THR3 			    (K0_THR3 		     ),
    .K_THR4 			    (K0_THR4 		     ),
    .K_THR5 			    (K0_THR5 		     ),
    .K_THR6 			    (K0_THR6 		     ),
    .K_THR7 			    (K0_THR7 		     ),
    .K_THR8 			    (K0_THR8 		     ),
    .K_THR9 			    (K0_THR9 		     ),
    .K_THR10			    (K0_THR10		     ),
    .K_THR11			    (K0_THR11		     ),
    .K_THR12			    (K0_THR12		     ),
    .K_THR13			    (K0_THR13		     ),
    .K_THR14			    (K0_THR14		     ),
    .K_THR15			    (K0_THR15		     ),
    .K_THR16			    (K0_THR16		     ),
    .K_THR17			    (K0_THR17		     ),
    .K_THR18			    (K0_THR18		     ),
    .K_THR19			    (K0_THR19		     ),
    .K_THR20			    (K0_THR20		     ),
    .K_THR21			    (K0_THR21		     ),
    .K_THR22			    (K0_THR22		     ),
    .K_THR23			    (K0_THR23		     ),
    .K_THR24			    (K0_THR24		     ),
    .K_THR25			    (K0_THR25		     ),
    .K_THR26			    (K0_THR26		     ),
    .K_THR27			    (K0_THR27		     ),
    .K_THR28			    (K0_THR28		     ),
    .K_THR29			    (K0_THR29		     ),
						    
	.K_out                  (AUTO_POWER_CALIB_K0 )	//默认 orig_k =69300;
);

power_calib	calib_pf_k_HF(                      
	.i_clk				    (clk_50m             ),
	.i_rst				    (rst_125             ),
	.power_in			    (VF_POWER0           ),
	.POWER_CALIB_K		    (AUTO_POWER_CALIB_K0 ),	
	.dout				    (VF_POWER_CALIB_K0   )	 //16bit
);                         
						   
power_calib	calib_pr_k_HF(                         
	.i_clk				    (clk_50m             ),
	.i_rst				    (rst_125             ),
	.power_in			    (VR_POWER0           ),
	.POWER_CALIB_K		    (AUTO_POWER_CALIB_K0 ),	
	.dout				    (VR_POWER_CALIB_K0   )	 //16bit
);  

//用于 edge_detect ;Input sensor 功率波形拟合；
AVG_FIFO_32	AVG32_pf_k_HF(                         
    .clk_i			       (clk_50m              ),
    .rst_i			       (rst_125              ),
    .data_in		       (VF_POWER_CALIB_K0    ),
    .den_in			       (calib_vf_vld0        ),
    .data_out		       (VF_POWER0_K_AVG      ),
    .den_out		       ()
);
`endif
   
		 /*-------------> HF 的 INPUT SENSOR 计算功率  -------------------*/
`ifdef INPUT_SENSOR_CH1  
power_k_sel   power_k_sel_LF(
    .clk_i                 (clk_50m             ),
    .rst_i                 (rst_125             ),
												 
    .freq_in               (demod_freq_coef2    ),										 
	.FREQ_CALIB_MODE       (FREQ2_CALIB_MODE    ),
    .ORIG_K	               (ORIG_K2             ),	
				    
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
	.i_clk				    (clk_50m             ),
	.i_rst				    (rst_125             ),
	.power_in			    (VF_POWER2           ),
	.POWER_CALIB_K		    (AUTO_POWER_CALIB_K2 ),	
	.dout				    (VF_POWER_CALIB_K2   )	 //16bit
);                         
						   
power_calib	calib_pr_k(                         
	.i_clk				    (clk_50m             ),
	.i_rst				    (rst_125             ),
	.power_in			    (VR_POWER2           ),
	.POWER_CALIB_K		    (AUTO_POWER_CALIB_K2 ),	
	.dout				    (VR_POWER_CALIB_K2   )	 //16bit
);  

//用于 edge_detect ;Input sensor 功率波形拟合；
AVG_FIFO_32	AVG32_pf_k(                         
    .clk_i			       (clk_50m             ),
    .rst_i			       (rst_125             ),
    .data_in		       (VF_POWER_CALIB_K2   ),
    .den_in			       (calib_vf_vld2       ),
    .data_out		       (VF_POWER2_K_AVG     ),
    .den_out		       ()
);

`endif


`ifdef  CW_PW_POWER_FUNCTION
CW_PW_POWER_DISPLAY  u_CW_PW_POWER_DISPLAY(
/*input            */  .i_clk                  (clk_50m             ),
/*input            */  .i_rst                  (rst_125             ), 
/*input   [15:0]   */  .i_vf_power_calib       (VF_POWER_CALIB_K0   ), //复用出的Input sensor vf 功率波形;
/*input   [15:0]   */  .i_vr_power_calib       (VR_POWER_CALIB_K0   ), //复用出的Input sensor vr 功率波形;
																   
/*input   [15:0]   */  .i_vf_power2_calib      (VF_POWER_CALIB_K2   ), //复用出的Input sensor vf 功率波形;
/*input   [15:0]   */  .i_vr_power2_calib      (VR_POWER_CALIB_K2   ), //复用出的Input sensor vr 功率波形;
																   
/*input            */  .i_pulse0_on            (pulse0_pwm_on       ), //VF 原始波形的拟合占空比；
                       .i_pulse2_on            (pulse2_pwm_on       ),
																   
/*input            */  .i_pw_mode0             (PW_MODE0            ), 
/*input            */  .i_pw_mode2             (PW_MODE2            ), 
/*output reg [15:0]*/  .o_vf_power_calib       (vf_power0_calib_disp), //进行PW mode 下的功率数据滤波显示；
/*output reg [15:0]*/  .o_vr_power_calib       (vr_power0_calib_disp), //进行PW mode 下的功率数据滤波显示；

/*output reg [15:0]*/  .o_vf_power2_calib      (vf_power2_calib_disp), //进行PW mode 下的功率数据滤波显示；
/*output reg [15:0]*/  .o_vr_power2_calib      (vr_power2_calib_disp) 
);

/*********************  HF power disp*************************/

AVG_FIFO_32	AVG32_HF_pf_disp(                      //显示后平均；
    .clk_i			     (clk_50m              ),
    .rst_i			     (rst_125              ),
    .data_in		     (vf_power0_calib_disp ),
    .den_in			     (calib_vf_vld0        ),
    .data_out		     (vf_power0_disp_avg   ),
    .den_out		     ()
);

AVG_FIFO_32	AVG32_HF_pr_disp(
    .clk_i			     (clk_50m              ),
    .rst_i			     (rst_125              ),
    .data_in		     (vr_power0_calib_disp ),
    .den_in			     (calib_vr_vld0        ),
    .data_out		     (vr_power0_disp_avg   ),
    .den_out		     ()
);

//对功率进行小数点后两位稳定的滤波
AVG_IIR_signed  AVG_IIR_HF_pf_avg (                //平均后小数点后两位精度提升；
     .clk_i               (clk_50m            ),
     .rst_i               (rst_125            ),
     .din                 (vf_power0_disp_avg ),
     .din_en              (calib_vf_vld0      ),
     .dout                (AVG_IIR_pf0        ),
     .dout_en             (                   )
);

AVG_IIR_signed  AVG_IIR_HF_pr_avg (
    .clk_i               (clk_50m             ),
    .rst_i               (rst_125             ),
    .din                 (vr_power0_disp_avg  ),
    .din_en              (calib_vr_vld0       ),
    .dout                (AVG_IIR_pr0         ),
    .dout_en             (                    )
);	

/*********************  LF power disp*************************/

AVG_FIFO_32	AVG32_LF_pf_disp(                      //显示后平均；
    .clk_i			     (clk_50m              ),
    .rst_i			     (rst_125              ),
    .data_in		     (vf_power2_calib_disp ),
    .den_in			     (calib_vf_vld2        ),
    .data_out		     (vf_power2_disp_avg   ),
    .den_out		     ()
);

AVG_FIFO_32	AVG32_LF_pr_disp(
    .clk_i			     (clk_50m              ),
    .rst_i			     (rst_125              ),
    .data_in		     (vr_power2_calib_disp ),
    .den_in			     (calib_vr_vld2        ),
    .data_out		     (vr_power2_disp_avg   ),
    .den_out		     ()
);

//对功率进行小数点后两位稳定的滤波
AVG_IIR_signed  AVG_IIR_LF_pf_avg (                //平均后小数点后两位精度提升；
     .clk_i               (clk_50m             ),
     .rst_i               (rst_125             ),
     .din                 (vf_power2_disp_avg  ),
     .din_en              (calib_vf_vld2       ),
     .dout                (AVG_IIR_pf2         ),
     .dout_en             (                    )
);

AVG_IIR_signed  AVG_IIR_LF_pr_avg (
    .clk_i               (clk_50m              ),
    .rst_i               (rst_125              ),
    .din                 (vr_power2_disp_avg   ),
    .din_en              (calib_vr_vld2        ),
    .dout                (AVG_IIR_pr2          ),
    .dout_en             (                     )
);	
`endif

                     /*-------------> HF INPUT SENSOR 计算阻抗业务   -------------------*/
`ifdef INPUT_SENSOR_CH0
refl_cal_16bit	refl_cal_16bit_HF(
	.i_clk				 (clk_50m               ),	//125m 
	
	.vr_i				 (ch0_calib_vr_i[31:16] ),	//A 
	.vr_q				 (ch0_calib_vr_q[31:16] ),	//B
	.vf_i				 (ch0_calib_vf_i[31:16] ),	//C
	.vf_q				 (ch0_calib_vf_q[31:16] ),	//D
	.refl_i				 (ch0_refl_i            ),
	.refl_q				 (ch0_refl_q	        )
);	//反射/入射   
       						 
r_jx	r_jx_HF(            
	.i_clk				 (clk_50m           ),	//125m 
	.refl_i				 (ch0_refl_i        ),	//31位定点数
	.refl_q				 (ch0_refl_q        ),	//31位定点数
						 		           
	.r_jx_i				 (ch0_r_jx_i        ),	//31位定点数
	.r_jx_q				 (ch0_r_jx_q        )    //15位定点数
);	//R+jX = Z0*(1+r)/(1-r) , Z0 = 50

//校准阻抗
r_jx_calib	r_jx_calib_HF(	//射频开启后才输出R+JX
	.clk_i				 (clk_50m           ),	
	.rst_i				 (rst_125           ),
	.RF_ON_FPGA			 (0),//(RF_ON_FPGA  ,	//0开1关 
	.bias_on			 (0),//(bias_on),      //0开1关
	.R_IN				 (ch0_r_jx_i        ),	
	.JX_IN				 (ch0_r_jx_q        ),	
	.K1					 (CALIB_R0          ), //给0，没影响的参数
	.K2					 (),                	

	.R_OUT				 (R_DOUT0            ),	//15位定点数
	.JX_OUT				 (JX_DOUT0           )
);	//Z = (a + j(50k+b)) / ((50-bk) + jak)  

		//HF--INPUT SENSOR;					    
average_signed	R0_AVG256_HF(                       
	.clk_i			     (clk_50m             ),
	.rst_i			     (rst_125             ),
	.din			     (R_DOUT0             ),
	.en_in			     (1                   ),
	.dout			     (INPUT_SENSOR0_R_AVG ),
	.en_out			     ()                 
);

average_signed	JX0_AVG256_HF(
	.clk_i			     (clk_50m             ),
	.rst_i			     (rst_125             ),
	.din			     (JX_DOUT0            ),
	.en_in			     (1                   ),
	.dout			     (INPUT_SENSOR0_JX_AVG),
	.en_out			     ()
);


`endif
                     /*-------------> lF INPUT SENSOR 计算阻抗业务   -------------------*/
`ifdef INPUT_SENSOR_CH1  
refl_cal_16bit	refl_cal_16bit_LF(
	.i_clk				 (clk_50m               ),	//125m 
	
	.vr_i				 (ch2_calib_vr_i[31:16] ),	//A 
	.vr_q				 (ch2_calib_vr_q[31:16] ),	//B
	.vf_i				 (ch2_calib_vf_i[31:16] ),	//C
	.vf_q				 (ch2_calib_vf_q[31:16] ),	//D
	.refl_i				 (ch2_refl_i            ),
	.refl_q				 (ch2_refl_q	        )
);	//反射/入射   
       						 
r_jx	r_jx_LF(            
	.i_clk				 (clk_50m              ),	//125m 
	.refl_i				 (ch2_refl_i           ),	//31位定点数
	.refl_q				 (ch2_refl_q           ),	//31位定点数
						 		              
	.r_jx_i				 (ch2_r_jx_i           ),	//31位定点数
	.r_jx_q				 (ch2_r_jx_q           )    //15位定点数
);	//R+jX = Z0*(1+r)/(1-r) , Z0 = 50

//校准阻抗
r_jx_calib	r_jx_calib_LF(	//射频开启后才输出R+JX
	.clk_i				 (clk_50m             ),	
	.rst_i				 (rst_125             ),
	.RF_ON_FPGA			 (0),//(RF_ON_FPGA    ,	//0开1关 
	.bias_on			 (0),//(bias_on),        //0开1关
	.R_IN				 (ch2_r_jx_i          ),	
	.JX_IN				 (ch2_r_jx_q          ),	
	.K1					 (CALIB_R2            ),
	.K2					 (),                  	

	.R_OUT				 (R_DOUT2             ),	//15位定点数
	.JX_OUT				 (JX_DOUT2            )
);	//Z = (a + j(50k+b)) / ((50-bk) + jak)  

//HF--INPUT SENSOR;					    
average_signed	R0_AVG256_LF(                       
	.clk_i			     (clk_50m             ),
	.rst_i			     (rst_125             ),
	.din			     (R_DOUT2             ),
	.en_in			     (1                   ),
	.dout			     (INPUT_SENSOR1_R_AVG ),
	.en_out			     ()                 
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

                     /*-------------> LF INPUT SENSOR 计算阻抗业务   -------------------*/

`ifdef  CW_PW_R_JX_FUNCTION
CW_PW_R_JX_RESULT  u_CW_PW_R_JX_RESULT(                         //PW/CW时候的R+ jx筛选；
						.clk                  (clk_50m             ),	 
						
						.R0_AVG               (INPUT_SENSOR0_R_AVG ), //HF
						.JX0_AVG              (INPUT_SENSOR0_JX_AVG),
						
						.R1_AVG               (OUPUT_SENSOR0_R_AVG ), //OS0
						.JX1_AVG              (OUPUT_SENSOR0_JX_AVG),
						
						
						.R2_AVG               (INPUT_SENSOR1_R_AVG ), //LF ；或者OS3
						.JX2_AVG              (INPUT_SENSOR1_JX_AVG),
						
						.R3_AVG               (OUPUT_SENSOR1_R_AVG ), //OS1
						.JX3_AVG              (OUPUT_SENSOR1_JX_AVG),
						.R3_400K_AVG          (OUPUT_SENSOR1_400K_R_AVG ), //OS1
						.JX3_400K_AVG         (OUPUT_SENSOR1_400K_JX_AVG),
						
						.R4_AVG               (OUPUT_SENSOR2_R_AVG ), //OS2
						.JX4_AVG              (OUPUT_SENSOR2_JX_AVG),
						.R4_400K_AVG          (OUPUT_SENSOR2_400K_R_AVG ), //OS2
						.JX4_400K_AVG         (OUPUT_SENSOR2_400K_JX_AVG),

                                                                       //计算电压电流的波形取pw稳定的段；Cw则持续输出；
                        .OS0_V_AVG            (OS0_V_AVG           ),
                        .OS0_I_AVG            (OS0_I_AVG           ),
                        .OS1_V_AVG            (OS1_V_AVG           ),
                        .OS1_I_AVG            (OS1_I_AVG           ),
                        .OS1_400K_V_AVG       (OS1_400K_V_AVG      ),
                        .OS1_400K_I_AVG       (OS1_400K_I_AVG      ),
                        .OS2_V_AVG            (OS2_V_AVG           ),
                        .OS2_I_AVG            (OS2_I_AVG           ),						
                        .OS2_400K_V_AVG       (OS2_400K_V_AVG      ),
                        .OS2_400K_I_AVG       (OS2_400K_I_AVG      ),


	                    
	                    .pulse0_pwm_on        (pulse0_pwm_on       ),	
	                    .pulse1_pwm_on        (pulse1_pwm_on       ),	
		                .pulse2_pwm_on        (pulse2_pwm_on       ),	//no use ：LF；
		                .pulse3_pwm_on        (pulse3_pwm_on       ),	
		                .pulse3_400k_pwm_on   (pulse3_400k_pwm_on  ),	
		                .pulse4_400k_pwm_on   (pulse4_400k_pwm_on  ),
						
		                .pulse4_pwm_on        (pulse4_pwm_on       ),	
						
                        .CW_MODE0             (CW_MODE0            ),
                        .PW_MODE0             (PW_MODE0            ), 
						
                        .CW_MODE1             (CW_MODE1            ),
                        .PW_MODE1             (PW_MODE1            ), 
						
                        .CW_MODE2             (CW_MODE2            ),
                        .PW_MODE2             (PW_MODE2            ), 	

                        .CW_MODE3             (CW_MODE3            ),
                        .PW_MODE3             (PW_MODE3            ), 	
                        .CW_MODE3_400K        (CW_MODE3_400K       ),
                        .PW_MODE3_400K        (PW_MODE3_400K       ), 	
						
                        .CW_MODE4             (CW_MODE4            ),
                        .PW_MODE4             (PW_MODE4            ), 							
                        .CW_MODE4_400K        (CW_MODE4_400K       ),
                        .PW_MODE4_400K        (PW_MODE4_400K       ), 	
												
					    .power_fall0          (sensor0_power_fall  ),
						.open_status0         (open_status0        ), 

					    .power_fall1          (OS0_I_fall          ),
						.open_status1         (open_status1        ), 
                    
     					// .power_fall2          (sensor2_power_fall  ),
						// .open_status2         (open_status2        ), 	
						
					    .power_fall3          (OS1_I_fall          ),
						.open_status3         (open_status3        ), 						
					    .power_fall3_400k     (OS1_400k_I_fall     ),
						.open_status3_400k    (open_status3_400k   ), 						

					    .power_fall4          (OS2_I_fall          ),
						.open_status4         (open_status4        ), 
					    .power_fall4_400k     (OS2_400k_I_fall     ),
						.open_status4_400k    (open_status4_400k   ), 	

																   
						.power_pwm_dly0       (w_power_pwm_dly0    ),															   
						.power_pwm_dly2       (w_power_pwm_dly2    ),	
						.i_pwm_dly0           (w_i0_pwm_dly        ),
						.i_pwm_dly1           (w_i1_pwm_dly        ),
						.i_pwm_dly1_400k      (w_i1_pwm_dly_400k   ),						
						.i_pwm_dly2           (w_i2_pwm_dly        ),						
						.i_pwm_dly2_400k      (w_i2_pwm_dly_400k   ),
					
                        .pulse_gap0           (w_pulse_gap0        ),
					    .pulse_gap1           (w_pulse_gap1        ),
					    .pulse_gap2           (w_pulse_gap2        ),		
					    .pulse_gap3           (w_pulse_gap3        ),	
					    .pulse_gap3_400k      (w_pulse_gap3_400k   ),		
					    .pulse_gap4           (w_pulse_gap4        ),
					    .pulse_gap4_400k      (w_pulse_gap4_400k   ),		
						
						.Z_pulse0_pwm         (w_Z_pulse0_pwm      ),
						.Z_pulse1_pwm         (w_Z_pulse1_pwm      ),
						.Z_pulse2_pwm         (w_Z_pulse2_pwm      ), //OS0
						.Z_pulse3_pwm         (w_Z_pulse3_pwm      ), //OS1
						.Z_pulse3_pwm_400k    (w_Z_pulse3_pwm_400k ), //OS1_400k
						.Z_pulse4_pwm         (w_Z_pulse4_pwm      ), //OS2						
						.Z_pulse4_pwm_400k    (w_Z_pulse4_pwm_400k ), //OS2_400k

						
						.R0                   (R0_result	       ),
						.JX0                  (JX0_result	       ),
						.R1                   (R1_result	       ),
						.JX1                  (JX1_result          ),
						.R2                   (R2_result	       ),
						.JX2                  (JX2_result          ),
						
						.R3                   (R3_result	       ),
						.JX3                  (JX3_result          ),
						.R3_400K              (R3_400k_result	   ),
						.JX3_400K             (JX3_400k_result     ),
						
						.R4                   (R4_result	       ),
						.JX4                  (JX4_result          ), 
						.R4_400K              (R4_400k_result	   ),
						.JX4_400K             (JX4_400k_result     ), 

 //PW电压电流选择；
                        .OS0_V_RESULT         (OS0_V_RESULT        ),
                        .OS0_I_RESULT         (OS0_I_RESULT        ),

                        .OS1_V_RESULT         (OS1_V_RESULT        ),
                        .OS1_I_RESULT         (OS1_I_RESULT        ),
                        .OS1_400K_V_RESULT    (OS1_400K_V_RESULT   ),
                        .OS1_400K_I_RESULT    (OS1_400K_I_RESULT   ),
						
                        .OS2_V_RESULT         (OS2_V_RESULT        ),
                        .OS2_I_RESULT         (OS2_I_RESULT        ),						
                        .OS2_400K_V_RESULT    (OS2_400K_V_RESULT   ),
                        .OS2_400K_I_RESULT    (OS2_400K_I_RESULT   )
);



//精度处理，精确到百分位；
AVG_IIR_signed  HF_AVG_IIR_R0 (
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (R0_result         ),
                        .din_en              (power_status0     ),
                        .dout                (AVG_IIR_R0        ),
                        .dout_en             (                  )
);

AVG_IIR_signed  HF_AVG_IIR_JX0 (
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (JX0_result        ),
                        .din_en              (power_status0     ),
                        .dout                (AVG_IIR_JX0       ),
                        .dout_en             (                  )
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
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (R2_result         ),
                        .din_en              (power_status2     ),
                        .dout                (AVG_IIR_R2        ),
                        .dout_en             (                  )
);

AVG_IIR_signed  LF_AVG_IIR_JX2 (
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (JX2_result        ),
                        .din_en              (power_status2     ),
                        .dout                (AVG_IIR_JX2       ),
                        .dout_en             (                  )
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

AVG_IIR_signed  OS2_AVG_IIR_R4 (
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (R4_result         ),
                        .din_en              (power_status4     ),
                        .dout                (AVG_IIR_R4        ),
                        .dout_en             (                  )
);

AVG_IIR_signed  OS2_AVG_IIR_JX4 (
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (JX4_result        ),
                        .din_en              (power_status4     ),
                        .dout                (AVG_IIR_JX4       ),
                        .dout_en             (                  )
);



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

AVG_IIR_signed  OS2_400K_AVG_IIR_R4 (
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (R4_400k_result    ),
                        .din_en              (power_status4_400k),
                        .dout                (AVG_IIR_400K_R4   ),
                        .dout_en             (                  )
);

AVG_IIR_signed  OS2_400K_AVG_IIR_JX4 (
                        .clk_i               (clk_50m           ),
                        .rst_i               (rst_125           ),
                        .din                 (JX4_400k_result   ),
                        .din_en              (power_status4_400k),
                        .dout                (AVG_IIR_400K_JX4  ),
                        .dout_en             (                  )
);



 `endif 
 
 
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>OUTPUT SENSOR ------------------------------------------------------------------//
// `ifdef OUTPUT_SENSOR_CH0 
// Decor_matrix  Decor_matrix_OS0(
// /*input               */ .i_clk                ( clk_128m               ),
// /*input               */ .i_rst                ( rst_125                ),	
				  
// /*input               */ .i_adc0_lpf_vld       (adc0_ch1_lpfx_vld        ), //ADC0---V；
// /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch1_lpfx_data       ),
// /*input               */ .i_adc1_lpf_vld       (adc1_ch1_lpfx_vld        ), //ADC1---I；
// /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch1_lpfx_data       ),

// /*input [31:0] 	    */   .m1a00				   (m1a00_ch1               ), //a
// /*input [31:0] 	    */   .m1a01				   (m1a01_ch1               ), //b
// /*input [31:0] 	    */   .m1a10				   (m1a10_ch1               ), //c
// /*input [31:0] 	    */   .m1a11				   (m1a11_ch1               ), //d

// /*output              */ .o_adc0_calib_vld     (OS0_V_calib_vld         ),   //Vt;
// /*output  [99:0]      */ .o_adc0_calib_data    (OS0_V_calib_data        ),
// /*output              */ .o_adc1_calib_vld     (OS0_I_calib_vld         ),   //It;
// /*output  [99:0]      */ .o_adc1_calib_data    (OS0_I_calib_data        )
// );   

// //Vm经过decor出来的 adc_calib_data 是经过单独特定的decor cali 通过IQ滤波的

// data_ext	data_ext0_Vt(                                         
	// .i_clk				     (clk_128m                 ),
	// .clk_50m			     (clk_50m                  ),//time domain cross；
	// .i_data				     (OS0_V_calib_data         ),	//100bit
	// .i_valid			     (OS0_V_calib_vld          ), 
	// .r_demod_rd_addr	     (demod_rd_addr1           ),
	// .o_data_i			     (OS0_calib_V_i            ), //V  50b
	// .o_data_q			     (OS0_calib_V_q            ),
	// .o_valid			     (OS0_calib_V_vld          )
// );   
 
// data_ext	data_ext0_It(                           
	// .i_clk				     (clk_128m 		           ),
	// .clk_50m			     (clk_50m		           ),//time domain cross；
	// .i_data				     (OS0_I_calib_data         ),	
	// .i_valid			     (OS0_I_calib_vld          ),  //I 
	// .r_demod_rd_addr	     (demod_rd_addr1           ),
	// .o_data_i			     (OS0_calib_I_i            ),
	// .o_data_q			     (OS0_calib_I_q            ),
	// .o_valid			     (OS0_calib_I_vld          )
// );
                                            
										// /*----------------------Output sensor0 计算阻抗-----------------------*/

// //求分流出的sensor2 的i q 		  V（I + Qj） / I（I + Qj）   ； Vt/It;
// complex_div	   DIV_OS0(                          //V/I
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (rst_125            ),
	// .vr_i				     (OS0_calib_V_i      ),	//V
	// .vr_q				     (OS0_calib_V_q      ),	//V
	// .vf_i				     (OS0_calib_I_i      ),	//I
	// .vf_q				     (OS0_calib_I_q      ),	//I
	// .R				         (OS0_R              ),
	// .JX				         (OS0_JX             )
// );	//反射/入射   

// average_signed	R1_AVG256_OS0(                       
	// .clk_i			        (clk_50m             ),
	// .rst_i			        (rst_125             ),
	// .din			        (OS0_R               ),
	// .en_in			        (1                   ),
	// .dout			        (OUPUT_SENSOR0_R_AVG ),
	// .en_out			        ()                 
// );


// average_signed	JX1_AVG256_OS0(
	// .clk_i			        (clk_50m             ),
	// .rst_i			        (rst_125             ),
	// .din			        (OS0_JX              ),
	// .en_in			        (1                   ),
	// .dout			        (OUPUT_SENSOR0_JX_AVG),
	// .en_out			        ()
// );
  
                                    // /*----------------------Output sensor0 电压电流 功率-----------------------*/

// power_cal	mod_Vt_OS0(                         
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (~rst_125		     ),
	// .data_i				     (OS0_calib_V_i      ),	//16位定点数
	// .data_q				     (OS0_calib_V_q      ),
	// .dout				     (OS0_V              )	//p = q^2 + i^2
// );                                               
												 
// power_cal	mod_It_OS0(                              
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (~rst_125		     ),
	// .data_i				     (OS0_calib_I_i      ),	//16位定点数
	// .data_q				     (OS0_calib_I_q      ),
	// .dout				     (OS0_I              )	//p = q^2 + i^2
// );   

// //平均处理
// AVG_FIFO_32	AVG32_V_OS0(
    // .clk_i			        (clk_50m             ),
    // .rst_i			        (rst_125             ),
    // .data_in		        (OS0_V               ),
    // .den_in			        (1                   ),
    // .data_out		        (OS0_V_AVG           ),
    // .den_out		        ()
// );
// AVG_FIFO_32	AVG32_I_OS0(
    // .clk_i			        (clk_50m             ),
    // .rst_i			        (rst_125             ),
    // .data_in		        (OS0_I               ),
    // .den_in			        (1                   ),
    // .data_out		        (OS0_I_AVG           ),
    // .den_out		        ()
// );
// `endif     

`ifdef OUTPUT_SENSOR_CH1_CH2 
// Decor_matrix  Decor_matrix_OS1(
// /*input               */ .i_clk                ( clk_128m                    ),
// /*input               */ .i_rst                ( rst_125                     ),	
																		     
// /*input               */ .i_adc0_lpf_vld       (adc0_ch3_lpf_vld             ), //ADC0---V；
// /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch3_lpf_data            ),
// /*input               */ .i_adc1_lpf_vld       (adc1_ch3_lpf_vld             ), //ADC1---I；
// /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch3_lpf_data            ),
																		     
// /*input [31:0] 	    */   .m1a00				   (m1a00_ch3                    ), //a
// /*input [31:0] 	    */   .m1a01				   (m1a01_ch3                    ), //b
// /*input [31:0] 	    */   .m1a10				   (m1a10_ch3                    ), //c
// /*input [31:0] 	    */   .m1a11				   (m1a11_ch3                    ), //d
																		     
// /*output              */ .o_adc0_calib_vld     (OS1_V_calib_vld              ),   //Vt;
// /*output  [99:0]      */ .o_adc0_calib_data    (OS1_V_calib_data             ),
// /*output              */ .o_adc1_calib_vld     (OS1_I_calib_vld              ),   //It;
// /*output  [99:0]      */ .o_adc1_calib_data    (OS1_I_calib_data             )
// );                                                                           
																		     
// Decor_matrix  Decor_matrix_400k_OS1(                                         
// /*input               */ .i_clk                ( clk_128m                    ),
// /*input               */ .i_rst                ( rst_125                     ),	
				  
// /*input               */ .i_adc0_lpf_vld       (adc0_ch3_lpf_400k_vld        ), //ADC0---V；
// /*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch3_lpf_400k_data       ),
// /*input               */ .i_adc1_lpf_vld       (adc1_ch3_lpf_400k_vld        ), //ADC1---I；
// /*input   [63:0]      */ .i_adc1_lpf_data      (adc1_ch3_lpf_400k_data       ),

// /*input [31:0] 	    */   .m1a00				   (m1a00_ch3_400k               ), //a
// /*input [31:0] 	    */   .m1a01				   (m1a01_ch3_400k               ), //b
// /*input [31:0] 	    */   .m1a10				   (m1a10_ch3_400k               ), //c
// /*input [31:0] 	    */   .m1a11				   (m1a11_ch3_400k               ), //d

// /*output              */ .o_adc0_calib_vld     (OS1_V_calib_400k_vld         ),   //Vt;
// /*output  [99:0]      */ .o_adc0_calib_data    (OS1_V_calib_400k_data        ),
// /*output              */ .o_adc1_calib_vld     (OS1_I_calib_400k_vld         ),   //It;
// /*output  [99:0]      */ .o_adc1_calib_data    (OS1_I_calib_400k_data        )
// );   








// //Vm经过decor出来的 adc_calib_data 是经过单独特定的decor cali 通过IQ滤波的
// //13.56m;
// data_ext	data_ext1_Vt(                                         
	// .i_clk				     (clk_128m                 ),
	// .clk_50m			     (clk_50m                  ),//time domain cross；
	// .i_data				     (OS1_V_calib_data         ),	//100bit
	// .i_valid			     (OS1_V_calib_vld          ), 
	// .r_demod_rd_addr	     (demod_rd_addr3           ),
	// .o_data_i			     (OS1_calib_V_i            ), //V  50b
	// .o_data_q			     (OS1_calib_V_q            ),
	// .o_valid			     (OS1_calib_V_vld          )
// );   
 
// data_ext	data_ext1_It(                           
	// .i_clk				     (clk_128m 		           ),
	// .clk_50m			     (clk_50m		           ),//time domain cross；
	// .i_data				     (OS1_I_calib_data         ),	
	// .i_valid			     (OS1_I_calib_vld          ),  //I 
	// .r_demod_rd_addr	     (demod_rd_addr3           ),
	// .o_data_i			     (OS1_calib_I_i            ),
	// .o_data_q			     (OS1_calib_I_q            ),
	// .o_valid			     (OS1_calib_I_vld          )
// );
     
// //400k

// data_ext	data_ext1_400k_Vt(                                         
	// .i_clk				     (clk_128m                 ),
	// .clk_50m			     (clk_50m                  ),//time domain cross；
	// .i_data				     (OS1_V_calib_400k_data    ),	//100bit
	// .i_valid			     (OS1_V_calib_400k_vld     ), 
	// .r_demod_rd_addr	     (demod_rd_400k_addr3      ),
	// .o_data_i			     (OS1_calib_V_400k_i       ), //V  50b
	// .o_data_q			     (OS1_calib_V_400k_q       ),
	// .o_valid			     (OS1_calib_V_400k_vld     )
// );   
 
// data_ext	data_ext1_400k_It(                           
	// .i_clk				     (clk_128m 		           ),
	// .clk_50m			     (clk_50m		           ),//time domain cross；
	// .i_data				     (OS1_I_calib_400k_data    ),	
	// .i_valid			     (OS1_I_calib_400k_vld     ),  //I 
	// .r_demod_rd_addr	     (demod_rd_400k_addr3      ),
	// .o_data_i			     (OS1_calib_I_400k_i       ),
	// .o_data_q			     (OS1_calib_I_400k_q       ),
	// .o_valid			     (OS1_calib_I_400k_vld     )
// );

	 
										// /*----------------------Output sensor0 计算阻抗-----------------------*/

// //求分流出的sensor2 的i q 		  V（I + Qj） / I（I + Qj）   ； Vt/It;
// complex_div	   DIV_OS1(                          //V/I
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (rst_125            ),
	// .vr_i				     (OS1_calib_V_i      ),	//V
	// .vr_q				     (OS1_calib_V_q      ),	//V
	// .vf_i				     (OS1_calib_I_i      ),	//I
	// .vf_q				     (OS1_calib_I_q      ),	//I
	// .R				         (OS1_R              ),
	// .JX				         (OS1_JX             )
// );	//反射/入射   


// complex_div	   DIV_OS1_400k(                          //V/I
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (rst_125            ),
	// .vr_i				     (OS1_calib_V_400k_i ),	//V
	// .vr_q				     (OS1_calib_V_400k_q ),	//V
	// .vf_i				     (OS1_calib_I_400k_i ),	//I
	// .vf_q				     (OS1_calib_I_400k_q ),	//I
	// .R				         (OS1_400K_R         ),
	// .JX				         (OS1_400K_JX        )
// );	//反射/入射   


// average_signed	R1_AVG256_OS1(                       
	// .clk_i			        (clk_50m             ),
	// .rst_i			        (rst_125             ),
	// .din			        (OS1_R               ),
	// .en_in			        (1                   ),
	// .dout			        (OUPUT_SENSOR1_R_AVG ),
	// .en_out			        ()                 
// );


// average_signed	JX1_AVG256_OS1(
	// .clk_i			        (clk_50m             ),
	// .rst_i			        (rst_125             ),
	// .din			        (OS1_JX              ),
	// .en_in			        (1                   ),
	// .dout			        (OUPUT_SENSOR1_JX_AVG),
	// .en_out			        ()
// );
 
// average_signed	R1_AVG256_400k_OS1(                       
	// .clk_i			        (clk_50m             ),
	// .rst_i			        (rst_125             ),
	// .din			        (OS1_400K_R          ),
	// .en_in			        (1                   ),
	// .dout			        (OUPUT_SENSOR1_400K_R_AVG ),
	// .en_out			        ()                 
// );


// average_signed	JX1_AVG256_400K_OS1(
	// .clk_i			        (clk_50m             ),
	// .rst_i			        (rst_125             ),
	// .din			        (OS1_400K_JX         ),
	// .en_in			        (1                   ),
	// .dout			        (OUPUT_SENSOR1_400K_JX_AVG),
	// .en_out			        ()
// );


 
                                    // /*----------------------Output sensor0 电压电流 功率-----------------------*/

// power_cal	mod_Vt_OS1(                         
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (~rst_125		     ),
	// .data_i				     (OS1_calib_V_i      ),	//16位定点数
	// .data_q				     (OS1_calib_V_q      ),
	// .dout				     (OS1_V              )	//p = q^2 + i^2
// );                                               
												 
// power_cal	mod_It_OS1(                              
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (~rst_125		     ),
	// .data_i				     (OS1_calib_I_i      ),	//16位定点数
	// .data_q				     (OS1_calib_I_q      ),
	// .dout				     (OS1_I              )	//p = q^2 + i^2
// );   

// power_cal	mod_Vt_400K_OS1(                         
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (~rst_125		     ),
	// .data_i				     (OS1_calib_V_400k_i ),	//16位定点数
	// .data_q				     (OS1_calib_V_400k_q ),
	// .dout				     (OS1_400K_V         )	//p = q^2 + i^2
// );                                               
												 
// power_cal	mod_It_400K_OS1(                              
	// .i_clk				     (clk_50m            ),	//125m 
	// .i_rstn				     (~rst_125		     ),
	// .data_i				     (OS1_calib_I_400k_i ),	//16位定点数
	// .data_q				     (OS1_calib_I_400k_q ),
	// .dout				     (OS1_400K_I         )	//p = q^2 + i^2
// );   



// //平均处理
// AVG_FIFO_32	AVG32_V_OS1(
    // .clk_i			        (clk_50m             ),
    // .rst_i			        (rst_125             ),
    // .data_in		        (OS1_V               ),
    // .den_in			        (1                   ),
    // .data_out		        (OS1_V_AVG           ),
    // .den_out		        ()
// );
// AVG_FIFO_32	AVG32_I_OS1(
    // .clk_i			        (clk_50m             ),
    // .rst_i			        (rst_125             ),
    // .data_in		        (OS1_I               ),
    // .den_in			        (1                   ),
    // .data_out		        (OS1_I_AVG           ),
    // .den_out		        ()
// );

// AVG_FIFO_32	AVG32_V_400K_OS1(
    // .clk_i			        (clk_50m             ),
    // .rst_i			        (rst_125             ),
    // .data_in		        (OS1_400K_V          ),
    // .den_in			        (1                   ),
    // .data_out		        (OS1_400K_V_AVG      ),
    // .den_out		        ()
// );
// AVG_FIFO_32	AVG32_I_400K_OS1(
    // .clk_i			        (clk_50m             ),
    // .rst_i			        (rst_125             ),
    // .data_in		        (OS1_400K_I          ),
    // .den_in			        (1                   ),
    // .data_out		        (OS1_400K_I_AVG      ),
    // .den_out		        ()
// );




Decor_matrix  Decor_matrix_OS2(
/*input               */ .i_clk                ( clk_128m               ),
/*input               */ .i_rst                ( rst_125                ),	
				  
/*input               */ .i_adc0_lpf_vld       (adc0_ch4_lpf_vld        ), //ADC0---V；
/*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch4_lpf_data       ),
/*input               */ .i_adc1_lpf_vld       (adc1_ch4_lpf_vld        ), //ADC1---I；
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
				  
/*input               */ .i_adc0_lpf_vld       (adc0_ch4_lpf_400k_vld   ), //ADC0---V；
/*input   [63:0]      */ .i_adc0_lpf_data      (adc0_ch4_lpf_400k_data  ),
/*input               */ .i_adc1_lpf_vld       (adc1_ch4_lpf_400k_vld   ), //ADC1---I；
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


//Vm经过decor出来的 adc_calib_data 是经过单独特定的decor cali 通过IQ滤波的

data_ext	data_ext2_Vt(                                         
	.i_clk				     (clk_128m                 ),
	.clk_50m			     (clk_50m                  ),//time domain cross；
	.i_data				     (OS2_V_calib_data         ),	//100bit
	.i_valid			     (OS2_V_calib_vld          ), 
	.r_demod_rd_addr	     (demod_rd_addr4           ),
	.o_data_i			     (OS2_calib_V_i            ), //V  50b
	.o_data_q			     (OS2_calib_V_q            ),
	.o_valid			     (OS2_calib_V_vld          )
);   
 
data_ext	data_ext2_It(                           
	.i_clk				     (clk_128m 		           ),
	.clk_50m			     (clk_50m		           ),//time domain cross；
	.i_data				     (OS2_I_calib_data         ),	
	.i_valid			     (OS2_I_calib_vld          ),  //I 
	.r_demod_rd_addr	     (demod_rd_addr4           ),
	.o_data_i			     (OS2_calib_I_i            ),
	.o_data_q			     (OS2_calib_I_q            ),
	.o_valid			     (OS2_calib_I_vld          )
);
      
data_ext	data_ext2_400k_Vt(                                         
	.i_clk				     (clk_128m                 ),
	.clk_50m			     (clk_50m                  ),//time domain cross；
	.i_data				     (OS2_V_calib_400k_data    ),	//100bit
	.i_valid			     (OS2_V_calib_400k_vld     ), 
	.r_demod_rd_addr	     (demod_rd_400k_addr4      ),
	.o_data_i			     (OS2_calib_V_400k_i       ), //V  50b
	.o_data_q			     (OS2_calib_V_400k_q       ),
	.o_valid			     (OS2_calib_V_400k_vld     )
);   
 
data_ext	data_ext2_400k_It(                           
	.i_clk				     (clk_128m 		           ),
	.clk_50m			     (clk_50m		           ),//time domain cross；
	.i_data				     (OS2_I_calib_400k_data    ),	
	.i_valid			     (OS2_I_calib_400k_vld     ),  //I 
	.r_demod_rd_addr	     (demod_rd_400k_addr4      ),
	.o_data_i			     (OS2_calib_I_400k_i       ),
	.o_data_q			     (OS2_calib_I_400k_q       ),
	.o_valid			     (OS2_calib_I_400k_vld     )
);
	  
										/*----------------------Output sensor0 计算阻抗-----------------------*/

//求分流出的sensor2 的i q 		  V（I + Qj） / I（I + Qj）   ； Vt/It;
complex_div	   DIV_OS2(                          //V/I
	.i_clk				     (clk_50m            ),	//125m 
	.i_rstn				     (rst_125            ),
	.vr_i				     (OS2_calib_V_i      ),	//V
	.vr_q				     (OS2_calib_V_q      ),	//V
	.vf_i				     (OS2_calib_I_i      ),	//I
	.vf_q				     (OS2_calib_I_q      ),	//I
	.R				         (OS2_R              ),
	.JX				         (OS2_JX             )
);	//反射/入射   


complex_div	   DIV_400K_OS2(                          //V/I
	.i_clk				     (clk_50m            ),	//125m 
	.i_rstn				     (rst_125            ),
	.vr_i				     (OS2_calib_V_400k_i ),	//V
	.vr_q				     (OS2_calib_V_400k_q ),	//V
	.vf_i				     (OS2_calib_I_400k_i ),	//I
	.vf_q				     (OS2_calib_I_400k_q ),	//I
	.R				         (OS2_400K_R         ),
	.JX				         (OS2_400K_JX        )
);	//反射/入射  


average_signed	R1_AVG256_OS2(                       
	.clk_i			        (clk_50m             ),
	.rst_i			        (rst_125             ),
	.din			        (OS2_R               ),
	.en_in			        (1                   ),
	.dout			        (OUPUT_SENSOR2_R_AVG ),
	.en_out			        ()                 
);


average_signed	JX1_AVG256_OS2(
	.clk_i			        (clk_50m             ),
	.rst_i			        (rst_125             ),
	.din			        (OS2_JX              ),
	.en_in			        (1                   ),
	.dout			        (OUPUT_SENSOR2_JX_AVG),
	.en_out			        ()
);
  
average_signed	R1_AVG256_400K_OS2(                       
	.clk_i			        (clk_50m             ),
	.rst_i			        (rst_125             ),
	.din			        (OS2_400K_R          ),
	.en_in			        (1                   ),
	.dout			        (OUPUT_SENSOR2_400K_R_AVG ),
	.en_out			        ()                 
);


average_signed	JX1_AVG256_400K_OS2(
	.clk_i			        (clk_50m             ),
	.rst_i			        (rst_125             ),
	.din			        (OS2_400K_JX         ),
	.en_in			        (1                   ),
	.dout			        (OUPUT_SENSOR2_400K_JX_AVG),
	.en_out			        ()
);  
  
  
                                    /*----------------------Output sensor0 电压电流 功率-----------------------*/

power_cal	mod_Vt_OS2(                         
	.i_clk				     (clk_50m            ),	//125m 
	.i_rstn				     (~rst_125		     ),
	.data_i				     (OS2_calib_V_i      ),	//16位定点数
	.data_q				     (OS2_calib_V_q      ),
	.dout				     (OS2_V              )	//p = q^2 + i^2
);                                               
												 
power_cal	mod_It_OS2(                              
	.i_clk				     (clk_50m            ),	//125m 
	.i_rstn				     (~rst_125		     ),
	.data_i				     (OS2_calib_I_i      ),	//16位定点数
	.data_q				     (OS2_calib_I_q      ),
	.dout				     (OS2_I              )	//p = q^2 + i^2
);   


power_cal	mod_Vt_400k_OS2(                         
	.i_clk				     (clk_50m            ),	//125m 
	.i_rstn				     (~rst_125		     ),
	.data_i				     (OS2_calib_V_400k_i ),	//16位定点数
	.data_q				     (OS2_calib_V_400k_q ),
	.dout				     (OS2_400K_V         )	//p = q^2 + i^2
);                                               
												 
power_cal	mod_It_400k_OS2(                              
	.i_clk				     (clk_50m            ),	//125m 
	.i_rstn				     (~rst_125		     ),
	.data_i				     (OS2_calib_I_400k_i ),	//16位定点数
	.data_q				     (OS2_calib_I_400k_q ),
	.dout				     (OS2_400K_I         )	//p = q^2 + i^2
);   



//平均处理
AVG_FIFO_32	AVG32_V_OS2(
    .clk_i			        (clk_50m             ),
    .rst_i			        (rst_125             ),
    .data_in		        (OS2_V               ),
    .den_in			        (1                   ),
    .data_out		        (OS2_V_AVG           ),
    .den_out		        ()
);
AVG_FIFO_32	AVG32_I_OS2(
    .clk_i			        (clk_50m             ),
    .rst_i			        (rst_125             ),
    .data_in		        (OS2_I               ),
    .den_in			        (1                   ),
    .data_out		        (OS2_I_AVG           ),
    .den_out		        ()
);


//平均处理
AVG_FIFO_32	AVG32_V_400K_OS2(
    .clk_i			        (clk_50m             ),
    .rst_i			        (rst_125             ),
    .data_in		        (OS2_400K_V          ),
    .den_in			        (1                   ),
    .data_out		        (OS2_400K_V_AVG      ),
    .den_out		        ()
);
AVG_FIFO_32	AVG32_I_400K_OS2(
    .clk_i			        (clk_50m             ),
    .rst_i			        (rst_125             ),
    .data_in		        (OS2_400K_I          ),
    .den_in			        (1                   ),
    .data_out		        (OS2_400K_I_AVG      ),
    .den_out		        ()
);


`endif   



/***********************************************pwm_detect**************************************************/


`ifdef POWER0_EDGE_DETECT 

AVG_POWER_FILTER AVG_POWER_FILTER_HF(
/*input             */  .clk_i             (clk_50m                ),
/*input             */  .rst_i             (rst_125                ),
/*input             */  .power_calib_vld   (1'b1                   ),
/*input [15:0]      */  .power_calib       (VF_POWER0_K_AVG         ),
/*input [15:0]      */  .filtering_value   (FILTER_THRESHOLD       ),	//异常功率点滤波
/*input [23:0]      */  .detect_rise_dly   (DETECT_RISE_DLY        ),
/*input [23:0]      */  .detect_fall_dly   (DETECT_FALL_DLY        ),
/*output reg [15:0] */  .power_filter      (VF_POWER0_FILTER       ),
/*output reg        */  .power_filter_vld  (1'b1                   ),
															   
/*output reg        */  .power_buf0_vld    (sensor0_power_buf0_vld ),
                        .power_buf1_vld    (sensor0_power_buf1_vld ),
                        .power_buf2_vld    (sensor0_power_buf2_vld ),
						.power_buf3_vld    (sensor0_power_buf3_vld ),
                        .power_sub_vld     (sensor0_power_sub_vld  ),
															   
/*output reg        */  .power0_buf0_vld   (sensor0_power0_buf0_vld),
                        .power0_buf1_vld   (sensor0_power0_buf1_vld),
                        .power0_buf2_vld   (sensor0_power0_buf2_vld),
						.power0_buf3_vld   (sensor0_power0_buf3_vld),
                        .power0_sub_vld    (sensor0_power0_sub_vld )	
															   					
);                                                             


//wire neg_avg_fall;
power_edge_detect power_edge_detect_HF(
/*input            */    .clk_i            (clk_50m                  ),
/*input            */    .rst_i            (rst_125                  ),
/*input            */    .power_filter_vld (1'b1 ), 		         
/*input   [15: 0]  */    .vf_power_filter  (VF_POWER0_FILTER         ), 

                         .rise_jump        (RISE_JUMP                ),
	                     .fall_jump        (FALL_JUMP                ),//max:1023;
/*input            */    .power_buf0_vld   (sensor0_power_buf0_vld   ),	
/*input            */    .power_buf1_vld   (sensor0_power_buf1_vld   ),
                         .power_buf2_vld   (sensor0_power_buf2_vld   ),
						 .power_buf3_vld   (sensor0_power_buf3_vld   ),
/*input            */    .power_sub_vld    (sensor0_power_sub_vld    ),

/*input            */    .power0_buf0_vld  (sensor0_power0_buf0_vld  ),	
/*input            */    .power0_buf1_vld  (sensor0_power0_buf1_vld  ),
                         .power0_buf2_vld  (sensor0_power0_buf2_vld  ),
						 .power0_buf3_vld  (sensor0_power0_buf3_vld  ),
/*input            */    .power0_sub_vld   (sensor0_power0_sub_vld   ),
                         
						 .pulse_start      (w_PULSE_START            ),
                         .pulse_end        (w_PULSE_END              ),
						 .power_keep       (pulse0_pwm_on            ),
	                     .power_fall       (sensor0_power_fall       ),
	                     .power_rise       (sensor0_power_rise       ),
						 .avg_keep         (sensor0_avg_keep         ),
																     
/*output reg [35:0] */   .keep_dly         (sensor0_keep_dly         ),
/*output reg [35:0] */   .pulse_on_cnt     (sensor0_pulse_on_cnt     )							 
                        // .neg_avg_fall     (neg_avg_fall     ),
);

RF_MODE_SENSOR   RF_MODE_SENSOR_HF(
/*input           */ .clk                 (clk_50m                   ),
/*input           */ .rst                 (rst_125                   ),
/*input [31:0]    */ .vf_power            (VF_POWER0_FILTER          ),
/*input           */ .calib_vf_vld        (1'b1                      ),
/*input [31:0]    */ .power_threshold     (POWER_THRESHOLD           ),
/*input           */ .power_rise          (sensor0_power_rise        ),
/*input           */ .power_fall          (sensor0_power_fall        ),
/*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY              ),
/*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH        ),
                     .OFF_NUM             (OFF_NUM                   ),
                     .open_status         (open_status0              ),
                     .CW_MODE             (CW_MODE0                  ), 
					 .PW_MODE             (PW_MODE0                  ), 
                     .power_status        (power_status0             )
);

`endif 


// //--------------------------TDM_pulse_on------------------------------------//

// `ifdef OS0_POWER_EDGE_DETECT 
// AVG_POWER_FILTER AVG_POWER_FILTER_OS0(
// /*input             */  .clk_i             (clk_50m                 ),
// /*input             */  .rst_i             (rst_125                 ),
// /*input             */  .power_calib_vld   (1'b1                    ),
// /*input [15:0]      */  .power_calib       (OS0_I_AVG>>11           ),
// /*input [15:0]      */  .filtering_value   (OS0_FILTER_THRESHOLD    ),	//异常功率点滤波
// /*input [23:0]      */  .detect_rise_dly   (OS0_DETECT_RISE_DLY     ),
// /*input [23:0]      */  .detect_fall_dly   (OS0_DETECT_FALL_DLY     ),
// /*output reg [15:0] */  .power_filter      (w_sensor0_filter_I       ),
// /*output reg        */  .power_filter_vld  (1'b1                    ),
																   
// /*output reg        */  .power_buf0_vld    (OS0_I_buf0_vld          ),
                        // .power_buf1_vld    (OS0_I_buf1_vld          ),
                        // .power_buf2_vld    (OS0_I_buf2_vld          ),
						// .power_buf3_vld    (OS0_I_buf3_vld          ),
                        // .power_sub_vld     (OS0_I_sub_vld           ),
															            
// /*output reg        */  .power0_buf0_vld   (OS0_I1_buf0_vld         ),
                        // .power0_buf1_vld   (OS0_I1_buf1_vld         ),
                        // .power0_buf2_vld   (OS0_I1_buf2_vld         ),
						// .power0_buf3_vld   (OS0_I1_buf3_vld         ),
                        // .power0_sub_vld    (OS0_I1_sub_vld          )	
															   					
// );                                                             

// power_edge_detect power_edge_detect_OS0(
// /*input            */    .clk_i            (clk_50m                 ),
// /*input            */    .rst_i            (rst_125                 ),
// /*input            */    .power_filter_vld (1'b1                    ), 		     
// /*input   [15: 0]  */    .vf_power_filter  (w_sensor0_filter_I       ), 
															       
                         // .rise_jump        (OS0_RISE_JUMP           ),
	                     // .fall_jump        (OS0_FALL_JUMP           ),//max:1023;
// /*input            */    .power_buf0_vld   (OS0_I_buf0_vld          ),	
// /*input            */    .power_buf1_vld   (OS0_I_buf1_vld          ),
                         // .power_buf2_vld   (OS0_I_buf2_vld          ),
						 // .power_buf3_vld   (OS0_I_buf3_vld          ),
// /*input            */    .power_sub_vld    (OS0_I_sub_vld           ),
															        
// /*input            */    .power0_buf0_vld  (OS0_I1_buf0_vld         ),	
// /*input            */    .power0_buf1_vld  (OS0_I1_buf1_vld         ),
                         // .power0_buf2_vld  (OS0_I1_buf2_vld         ),
						 // .power0_buf3_vld  (OS0_I1_buf3_vld         ),
// /*input            */    .power0_sub_vld   (OS0_I1_sub_vld          ),
															        
						 // .pulse_start      (w_OS0_PULSE_START       ),
                         // .pulse_end        (w_OS0_PULSE_END         ),
															       
						 // .power_keep       (pulse1_pwm_on           ),
	                     // .power_fall       (OS0_I_fall              ),
	                     // .power_rise       (OS0_I_rise              ),
						 // .avg_keep         (OS0_avg_keep            ),
															         
// /*output reg [35:0] */   .keep_dly         (OS0_keep_dly            ),
// /*output reg [35:0] */   .pulse_on_cnt     (OS0_pulse_on_cnt        )							 
                        // // .neg_avg_fall     (neg_avg_fall     ),
// );

// RF_MODE_SENSOR   RF_MODE_SENSOR_OS0(
// /*input           */ .clk                 (clk_50m                  ),
// /*input           */ .rst                 (rst_125                  ),
// /*input [31:0]    */ .vf_power            (w_sensor0_filter_I        ),
// /*input           */ .calib_vf_vld        (1'b1                     ),
// /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
// /*input           */ .power_rise          (OS0_I_rise               ),
// /*input           */ .power_fall          (OS0_I_fall               ),
// /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY1            ),
// /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH1      ),
                     // .OFF_NUM             (OFF_NUM1                 ),
                     // .open_status         (open_status1             ),
                     // .CW_MODE             (CW_MODE1                 ), 
					 // .PW_MODE             (PW_MODE1                 ), 
                     // .power_status        (power_status1            )
// );

// `endif 


`ifdef OS1_OS2_POWER_EDGE_DETECT 
// AVG_POWER_FILTER AVG_POWER_FILTER_OS1(
// /*input             */  .clk_i             (clk_50m                 ),
// /*input             */  .rst_i             (rst_125                 ),
// /*input             */  .power_calib_vld   (1'b1                    ),
// /*input [15:0]      */  .power_calib       (OS1_I_AVG>>9            ),
// /*input [15:0]      */  .filtering_value   (OS1_FILTER_THRESHOLD    ),	//异常功率点滤波
// /*input [23:0]      */  .detect_rise_dly   (OS1_DETECT_RISE_DLY     ),
// /*input [23:0]      */  .detect_fall_dly   (OS1_DETECT_FALL_DLY     ),
// /*output reg [15:0] */  .power_filter      (w_sensor1_filter_I       ),
// /*output reg        */  .power_filter_vld  (1'b1                    ),
																   
// /*output reg        */  .power_buf0_vld    (OS1_I_buf0_vld          ),
                        // .power_buf1_vld    (OS1_I_buf1_vld          ),
                        // .power_buf2_vld    (OS1_I_buf2_vld          ),
						// .power_buf3_vld    (OS1_I_buf3_vld          ),
                        // .power_sub_vld     (OS1_I_sub_vld           ),
															            
// /*output reg        */  .power0_buf0_vld   (OS1_I1_buf0_vld         ),
                        // .power0_buf1_vld   (OS1_I1_buf1_vld         ),
                        // .power0_buf2_vld   (OS1_I1_buf2_vld         ),
						// .power0_buf3_vld   (OS1_I1_buf3_vld         ),
                        // .power0_sub_vld    (OS1_I1_sub_vld          )	
															   					
// );                                                             


// AVG_POWER_FILTER AVG_POWER_FILTER_400K_OS1(
// /*input             */  .clk_i             (clk_50m                 ),
// /*input             */  .rst_i             (rst_125                 ),
// /*input             */  .power_calib_vld   (1'b1                    ),
// /*input [15:0]      */  .power_calib       (OS1_400K_I_AVG>>9   ),
// /*input [15:0]      */  .filtering_value   (OS1_400K_FILTER_THRESHOLD),	//异常功率点滤波
// /*input [23:0]      */  .detect_rise_dly   (OS1_400K_DETECT_RISE_DLY ),
// /*input [23:0]      */  .detect_fall_dly   (OS1_400K_DETECT_FALL_DLY ),
// /*output reg [15:0] */  .power_filter      (w_sensor1_400k_filter_I  ),
// /*output reg        */  .power_filter_vld  (1'b1                   ),
																   
// /*output reg        */  .power_buf0_vld    (OS1_400K_I_buf0_vld    ),
                        // .power_buf1_vld    (OS1_400K_I_buf1_vld    ),
                        // .power_buf2_vld    (OS1_400K_I_buf2_vld    ),
						// .power_buf3_vld    (OS1_400K_I_buf3_vld    ),
                        // .power_sub_vld     (OS1_400K_I_sub_vld     ),
															       
// /*output reg        */  .power0_buf0_vld   (OS1_400K_I1_buf0_vld   ),
                        // .power0_buf1_vld   (OS1_400K_I1_buf1_vld   ),
                        // .power0_buf2_vld   (OS1_400K_I1_buf2_vld   ),
						// .power0_buf3_vld   (OS1_400K_I1_buf3_vld   ),
                        // .power0_sub_vld    (OS1_400K_I1_sub_vld    )	
															   					
// );  


// power_edge_detect power_edge_detect_OS1(
// /*input            */    .clk_i            (clk_50m                 ),
// /*input            */    .rst_i            (rst_125                 ),
// /*input            */    .power_filter_vld (1'b1                    ), 		     
// /*input   [15: 0]  */    .vf_power_filter  (w_sensor1_filter_I       ), 
															       
                         // .rise_jump        (OS1_RISE_JUMP           ),
	                     // .fall_jump        (OS1_FALL_JUMP           ),//max:1023;
// /*input            */    .power_buf0_vld   (OS1_I_buf0_vld          ),	
// /*input            */    .power_buf1_vld   (OS1_I_buf1_vld          ),
                         // .power_buf2_vld   (OS1_I_buf2_vld          ),
						 // .power_buf3_vld   (OS1_I_buf3_vld          ),
// /*input            */    .power_sub_vld    (OS1_I_sub_vld           ),
															        
// /*input            */    .power0_buf0_vld  (OS1_I1_buf0_vld         ),	
// /*input            */    .power0_buf1_vld  (OS1_I1_buf1_vld         ),
                         // .power0_buf2_vld  (OS1_I1_buf2_vld         ),
						 // .power0_buf3_vld  (OS1_I1_buf3_vld         ),
// /*input            */    .power0_sub_vld   (OS1_I1_sub_vld          ),
															        
						 // .pulse_start      (w_OS1_PULSE_START       ),
                         // .pulse_end        (w_OS1_PULSE_END         ),
															       
						 // .power_keep       (pulse3_pwm_on           ),
	                     // .power_fall       (OS1_I_fall              ),
	                     // .power_rise       (OS1_I_rise              ),
						 // .avg_keep         (OS1_avg_keep            ),
															         
// /*output reg [35:0] */   .keep_dly         (OS1_keep_dly            ),
// /*output reg [35:0] */   .pulse_on_cnt     (OS1_pulse_on_cnt        )							 
                        // // .neg_avg_fall     (neg_avg_fall     ),
// );


// power_edge_detect power_edge_detect_400k_OS1(
// /*input            */    .clk_i            (clk_50m                 ),
// /*input            */    .rst_i            (rst_125                 ),
// /*input            */    .power_filter_vld (1'b1                    ), 		     
// /*input   [15: 0]  */    .vf_power_filter  (w_sensor1_400k_filter_I ), 
															       
                         // .rise_jump        (OS1_400K_RISE_JUMP      ),
	                     // .fall_jump        (OS1_400K_FALL_JUMP      ),//max:1023;
// /*input            */    .power_buf0_vld   (OS1_400K_I_buf0_vld     ),	
// /*input            */    .power_buf1_vld   (OS1_400K_I_buf1_vld     ),
                         // .power_buf2_vld   (OS1_400K_I_buf2_vld     ),
						 // .power_buf3_vld   (OS1_400K_I_buf3_vld     ),
// /*input            */    .power_sub_vld    (OS1_400K_I_sub_vld      ),
															        
// /*input            */    .power0_buf0_vld  (OS1_400K_I1_buf0_vld    ),	
// /*input            */    .power0_buf1_vld  (OS1_400K_I1_buf1_vld    ),
                         // .power0_buf2_vld  (OS1_400K_I1_buf2_vld    ),
						 // .power0_buf3_vld  (OS1_400K_I1_buf3_vld    ),
// /*input            */    .power0_sub_vld   (OS1_400K_I1_sub_vld     ),
															        
						 // .pulse_start      (w_OS1_400K_PULSE_START  ),
                         // .pulse_end        (w_OS1_400K_PULSE_END    ),
															       
						 // .power_keep       (pulse3_400k_pwm_on      ),
	                     // .power_fall       (OS1_400k_I_fall         ),
	                     // .power_rise       (OS1_400k_I_rise         ),
						 // .avg_keep         (OS1_400k_avg_keep       ),
															         
// /*output reg [35:0] */   .keep_dly         (OS1_400k_keep_dly       ),
// /*output reg [35:0] */   .pulse_on_cnt     (OS1_400k_pulse_on_cnt   )							 

// );




// RF_MODE_SENSOR   RF_MODE_SENSOR_OS1(
// /*input           */ .clk                 (clk_50m                  ),
// /*input           */ .rst                 (rst_125                  ),
// /*input [31:0]    */ .vf_power            (w_sensor1_filter_I       ),
// /*input           */ .calib_vf_vld        (1'b1                     ),
// /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
// /*input           */ .power_rise          (OS1_I_rise               ),
// /*input           */ .power_fall          (OS1_I_fall               ),
// /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY3            ),
// /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH3      ),
                     // .OFF_NUM             (OFF_NUM3                 ),
                     // .open_status         (open_status3             ),
                     // .CW_MODE             (CW_MODE3                 ), 
					 // .PW_MODE             (PW_MODE3                 ), 
                     // .power_status        (power_status3            )
// );

// RF_MODE_SENSOR   RF_MODE_SENSOR_400K_OS1(
// /*input           */ .clk                 (clk_50m                  ),
// /*input           */ .rst                 (rst_125                  ),
// /*input [31:0]    */ .vf_power            (w_sensor1_400k_filter_I  ),
// /*input           */ .calib_vf_vld        (1'b1                     ),
// /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
// /*input           */ .power_rise          (OS1_400k_I_rise          ),
// /*input           */ .power_fall          (OS1_400k_I_fall          ),
// /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY3_400K       ),
// /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH3_400K ),
                     // .OFF_NUM             (OFF_NUM3_400K            ),
                     // .open_status         (open_status3_400k        ),
                     // .CW_MODE             (CW_MODE3_400K            ), 
					 // .PW_MODE             (PW_MODE3_400K            ), 
                     // .power_status        (power_status3_400k       )
// );




AVG_POWER_FILTER AVG_POWER_FILTER_OS2(
/*input             */  .clk_i             (clk_50m                 ),
/*input             */  .rst_i             (rst_125                 ),
/*input             */  .power_calib_vld   (1'b1                    ),
/*input [15:0]      */  .power_calib       (OS2_I_AVG>>9            ),
/*input [15:0]      */  .filtering_value   (OS2_FILTER_THRESHOLD    ),	//异常功率点滤波
/*input [23:0]      */  .detect_rise_dly   (OS2_DETECT_RISE_DLY     ),
/*input [23:0]      */  .detect_fall_dly   (OS2_DETECT_FALL_DLY     ),
/*output reg [15:0] */  .power_filter      (w_sensor2_filter_I       ),
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


AVG_POWER_FILTER AVG_POWER_FILTER_400K_OS2(
/*input             */  .clk_i             (clk_50m                 ),
/*input             */  .rst_i             (rst_125                 ),
/*input             */  .power_calib_vld   (1'b1                    ),
/*input [15:0]      */  .power_calib       (OS2_400K_I_AVG>>9       ),
/*input [15:0]      */  .filtering_value   (OS2_FILTER_THRESHOLD    ),	//异常功率点滤波
/*input [23:0]      */  .detect_rise_dly   (OS2_400K_DETECT_RISE_DLY),
/*input [23:0]      */  .detect_fall_dly   (OS2_400K_DETECT_FALL_DLY),
/*output reg [15:0] */  .power_filter      (w_sensor2_400k_filter_I ),
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
/*input   [15: 0]  */    .vf_power_filter  (w_sensor2_filter_I      ), 
															       
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
/*input   [15: 0]  */    .vf_power_filter  (w_sensor2_400k_filter_I ), 
															       
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
/*input [31:0]    */ .vf_power            (w_sensor2_filter_I       ),
/*input           */ .calib_vf_vld        (1'b1                     ),
/*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
/*input           */ .power_rise          (OS2_I_rise               ),
/*input           */ .power_fall          (OS2_I_fall               ),
/*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY4            ),
/*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH4      ),
                     .OFF_NUM             (OFF_NUM4                 ),
                     .open_status         (open_status4             ),
                     .CW_MODE             (CW_MODE4                 ), 
					 .PW_MODE             (PW_MODE4                 ), 
                     .power_status        (power_status4            )
);

RF_MODE_SENSOR   RF_MODE_SENSOR_400K_OS2(
/*input           */ .clk                 (clk_50m                  ),
/*input           */ .rst                 (rst_125                  ),
/*input [31:0]    */ .vf_power            (w_sensor2_400k_filter_I  ),
/*input           */ .calib_vf_vld        (1'b1                     ),
/*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
/*input           */ .power_rise          (OS2_400k_I_rise          ),
/*input           */ .power_fall          (OS2_400k_I_fall          ),
/*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY4_400K       ),
/*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH4_400K ),
                     .OFF_NUM             (OFF_NUM4_400K            ),
                     .open_status         (open_status4_400k        ),
                     .CW_MODE             (CW_MODE4_400K            ), 
					 .PW_MODE             (PW_MODE4_400K            ), 
                     .power_status        (power_status4_400k       )
);

`endif 
                                                        

`ifdef POWER2_EDGE_DETECT  

AVG_POWER_FILTER AVG_POWER_FILTER_LF(
/*input             */  .clk_i             (clk_50m                ),
/*input             */  .rst_i             (rst_125                ),
/*input             */  .power_calib_vld   (1'b1                   ),
/*input [15:0]      */  .power_calib       (VF_POWER2_K_AVG        ),
/*input [15:0]      */  .filtering_value   (FILTER_THRESHOLD       ),	//异常功率点滤波
/*input [23:0]      */  .detect_rise_dly   (DETECT_RISE_DLY2       ),
/*input [23:0]      */  .detect_fall_dly   (DETECT_FALL_DLY2       ),
/*output reg [15:0] */  .power_filter      (VF_POWER2_FILTER       ),
/*output reg        */  .power_filter_vld  (1'b1                   ),
															   
/*output reg        */  .power_buf0_vld    (sensor2_power_buf0_vld ),
                        .power_buf1_vld    (sensor2_power_buf1_vld ),
                        .power_buf2_vld    (sensor2_power_buf2_vld ),
						.power_buf3_vld    (sensor2_power_buf3_vld ),
                        .power_sub_vld     (sensor2_power_sub_vld  ),
															   
/*output reg        */  .power0_buf0_vld   (sensor2_power0_buf0_vld),
                        .power0_buf1_vld   (sensor2_power0_buf1_vld),
                        .power0_buf2_vld   (sensor2_power0_buf2_vld),
						.power0_buf3_vld   (sensor2_power0_buf3_vld),
                        .power0_sub_vld    (sensor2_power0_sub_vld )	
															   					
);     


//wire neg_avg_fall;
power_edge_detect power_edge_detect_LF(
/*input            */    .clk_i            (clk_50m                  ),
/*input            */    .rst_i            (rst_125                  ),
/*input            */    .power_filter_vld (1'b1 ), 		         
/*input   [15: 0]  */    .vf_power_filter  (VF_POWER2_FILTER         ), 

                         .rise_jump        (RISE_JUMP2               ),
	                     .fall_jump        (FALL_JUMP2               ),//max:1023;
/*input            */    .power_buf0_vld   (sensor2_power_buf0_vld   ),	
/*input            */    .power_buf1_vld   (sensor2_power_buf1_vld   ),
                         .power_buf2_vld   (sensor2_power_buf2_vld   ),
						 .power_buf3_vld   (sensor2_power_buf3_vld   ),
/*input            */    .power_sub_vld    (sensor2_power_sub_vld    ),

/*input            */    .power0_buf0_vld  (sensor2_power0_buf0_vld  ),	
/*input            */    .power0_buf1_vld  (sensor2_power0_buf1_vld  ),
                         .power0_buf2_vld  (sensor2_power0_buf2_vld  ),
						 .power0_buf3_vld  (sensor2_power0_buf3_vld  ),
/*input            */    .power0_sub_vld   (sensor2_power0_sub_vld   ),
                         
						 .pulse_start      (w_PULSE_START2           ),
                         .pulse_end        (w_PULSE_END2             ),
						 
						// .power_keep       (pulse2_pwm_on            ),
						
	                     .power_fall       (sensor2_power_fall       ),
	                     .power_rise       (sensor2_power_rise       ),
						 .avg_keep         (sensor2_avg_keep         ),
																     
/*output reg [35:0] */   .keep_dly         (sensor2_keep_dly         ),
/*output reg [35:0] */   .pulse_on_cnt     (sensor2_pulse_on_cnt     )							 
                        // .neg_avg_fall     (neg_avg_fall     ),
);


RF_MODE_SENOR_400K   RF_MODE_SENOR_LF(
/*input           */ .clk                 (clk_50m                  ),
/*input           */ .rst                 (rst_125                  ),
/*input [31:0]    */ .vf_power            (VF_POWER2_FILTER         ),

/*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),

                     .OFF_NUM             (OFF_NUM2                 ),

                     .ON_KEEP_NUM         (ON_KEEP_NUM              ),      
                     .OFF_KEEP_NUM        (OFF_KEEP_NUM             ),      
					 
                     .pwm_on              (pulse2_pwm_on            ),
					 
                     .CW_MODE             (CW_MODE2                 ), 
					 .PW_MODE             (PW_MODE2                 ), 
					 
                     .power_status        (power_status2            )
);


// RF_MODE_SENSOR   RF_MODE_SENSOR_LF(
// /*input           */ .clk                 (clk_50m                  ),
// /*input           */ .rst                 (rst_125                  ),
// /*input [31:0]    */ .vf_power            (VF_POWER2_FILTER         ),
// /*input           */ .calib_vf_vld        (1'b1                     ),
// /*input [31:0]    */ .power_threshold     (POWER_THRESHOLD          ),
// /*input           */ .power_rise          (sensor2_power_rise       ),
// /*input           */ .power_fall          (sensor2_power_fall       ),
// /*input [31:0]    */ .match_on_dly        (MATCH_ON_DLY2            ),
// /*input [31:0]    */ .detect_pulse_width  (DETECT_PULSE_WIDTH2      ),
                     // .OFF_NUM             (OFF_NUM2                 ),
                     // .open_status         (open_status2             ),
                     // .CW_MODE             (CW_MODE2                 ), 
					 // .PW_MODE             (PW_MODE2                 ), 
                     // .power_status        (power_status2            )
// );

`endif



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
/*output     [1:0]*/.moto_work_state(moto_state[1:0]       )// 电机工作状态   
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
/*output     [1:0]*/.moto_work_state(moto_state[3:2]       )// 电机工作状态   
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
/*output     [1:0]*/.moto_work_state(moto_state[5:4]        )// 电机工作状态   
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
/*output     [1:0]*/.moto_work_state(moto_state[7:6]        )// 电机工作状态   
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
/*output     [1:0]*/.moto_work_state(moto_state[9:8]        )// 电机工作状态   
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
/*output     [1:0]*/.moto_work_state(moto_state[11:10]      )// 电机工作状态   
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
/*output     [1:0]*/.moto_work_state(moto_state[13:12]        )// 电机工作状态   
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
/*output     [1:0]*/.moto_work_state(moto_state[15:14]      )// 电机工作状态   
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
//原始iq组合；                  
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
	
	
	
//经过decor后的原始iq组合；     
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
														  
	.VR_POWER0			         (VR_POWER0		          ), //IQ 计算到的初始功率值 用于比对计算校准K；
	.VF_POWER0			         (VF_POWER0		          ), //IQ 计算到的初始功率值 用于比对计算校准K；
	.VR_POWER2			         (VR_POWER2		          ), //IQ 计算到的初始功率值 用于比对计算校准K；
	.VF_POWER2			         (VF_POWER2		          ),


	.VR_POWER_CALIB		         (VR_POWER_CALIB	      ), //（无用）总的 经过K校正 的入射路（复用出来就是 sensor1的入射功率和 sensor1 路的 I）
	.VF_POWER_CALIB		         (VF_POWER_CALIB	      ), //（无用）总的 经过K校正 的反射路（复用出来就是 sensor2的反射功率和 sensor2 路的 V）
														  
														  
	.VF_POWER_CALIB_K0           (VF_POWER_CALIB_K0       ), //sensor1的校正K 且经过decor 复用；
    .VR_POWER_CALIB_K0           (VR_POWER_CALIB_K0       ), 

	.VF_POWER_CALIB_K1           (VF_POWER_CALIB_K1       ),  //sensor2的校正K 且经过decor  复用；

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
	
	
    .PULSE_START                 (w_PULSE_START           ),//调节脉冲拟合占空比起点； 功率拟合占空比；
    .PULSE_END                   (w_PULSE_END             ),//调节脉冲拟合占空比终点； 功率拟合占空比；	

    .PULSE_START2                (w_PULSE_START2          ),//调节脉冲拟合占空比起点； 功率拟合占空比；	
    .PULSE_END2                  (w_PULSE_END2            ),//调节脉冲拟合占空比终点； 功率拟合占空比；	
	
    .POWER_PWM_DLY0               (w_power_pwm_dly0       ), 	
    .POWER_PWM_DLY2               (w_power_pwm_dly2       ), 	


	.OS0_FILTER_THRESHOLD        (OS0_FILTER_THRESHOLD    ),	
	.OS0_DETECT_RISE_DLY         (OS0_DETECT_RISE_DLY     ),
	.OS0_DETECT_FALL_DLY         (OS0_DETECT_FALL_DLY     ),
    .OS0_RISE_JUMP               (OS0_RISE_JUMP           ),
	.OS0_FALL_JUMP               (OS0_FALL_JUMP           ),
    .OS0_PULSE_START             (w_OS0_PULSE_START       ),//调节脉冲拟合占空比起点； 功率拟合占空比；
    .OS0_PULSE_END               (w_OS0_PULSE_END         ),//调节脉冲拟合占空比终点； 功率拟合占空比；	

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



    .I_PWM_DLY                   (w_i0_pwm_dly            ), 		
    .I1_PWM_DLY                  (w_i1_pwm_dly            ), 														  
    .I2_PWM_DLY                  (w_i2_pwm_dly            ), 	

    .I1_PWM_DLY_400K             (w_i1_pwm_dly_400k       ), 														  
    .I2_PWM_DLY_400K             (w_i2_pwm_dly_400k       ), 	



	
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
     


//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
// ila_power ila_power (
	// .clk(clk_128m), // input wire clk
	
	// .probe0  (OS0_R   ), 
	// .probe1  (OS0_JX  ), 
	// .probe2  (VF_POWER0_K_AVG   ),
	// .probe3  (OS0_V_AVG     ), 
	// .probe4  (tdm_period_cnt         ),
	// .probe5  ( OS0_calib_V_i       ),
	// .probe6  (OS0_calib_V_q      ),
	// .probe7  (r_jx_vld1         ),
	// .probe8  (CW_MODE              ),
	// .probe9 (PW_MODE              ),
	// .probe10 (open_status0          ),
    // .probe11 (OUPUT_SENSOR0_R_AVG  ),	
	// .probe12 (OUPUT_SENSOR0_JX_AVG ), 
	// .probe13 (R1_result	           ), 
	// .probe14 (JX1_result	           ), 
	// .probe15 (w_pulse_gap1           ),
	// .probe16 (0        ),
	// .probe17 (0         ),
	// .probe18 (OS0_pulse_on_cnt     ),
	// .probe19 (power_status0          ),
	// .probe20 (w_Z_pulse1_pwm         ),
    // .probe21 (OS0_V),
	// .probe22 (w_sensor0_filter_I),
	// .probe23 (OS0_I_AVG),
	// .probe24 (OS0_V_RESULT),
	// .probe25 (OS0_I_RESULT)
// ); 	



// ila_multiplex_adc0_adc1 u_ila_multiplex_adc0_adc (
	// .clk(clk_128m), // input wire clk

	// .probe0(clk_64m), // input wire [0:0]  probe0  
	// .probe1(clk_50m), // input wire [0:0]  probe1 
	// .probe2(AD9238_CH0_vld	), // input wire [0:0]  probe2 
	// .probe3(AD9238_CH0_CHA	), // input wire [13:0]  probe3 
	// .probe4(AD9238_CH0_CHB	), // input wire [13:0]  probe4 
	// .probe5(AD9238_CH1_vld	), // input wire [0:0]  probe5 
	// .probe6(AD9238_CH1_CHA	), // input wire [13:0]  probe6 
	// .probe7(AD9238_CH1_CHB	), // input wire [13:0]  probe7 
	// .probe8 (adc0_ch0_bpf_vld ), // input wire [0:0]  probe8 
	// .probe9 (adc0_ch0_bpf_data), // input wire [63:0]  probe9 
	// .probe10(adc1_ch0_bpf_vld ), // input wire [0:0]  probe10 
	// .probe11(adc1_ch0_bpf_data), // input wire [63:0]  probe11 
	// .probe12(ch0_start_bpf    ), // input wire [0:0]  probe12 
	// .probe13(adc0_ch1_bpf_vld ), // input wire [0:0]  probe13 
	// .probe14(adc0_ch1_bpf_data), // input wire [63:0]  probe14 
	// .probe15(adc1_ch1_bpf_vld ), // input wire [0:0]  probe15 
	// .probe16(adc1_ch1_bpf_data), // input wire [63:0]  probe16 
	// .probe17(ch1_start_bpf    ), // input wire [0:0]  probe17 
	// .probe18(sel_multiplex_ch), // input wire [0:0]  probe18 
	// .probe19(adc0_mean0	), // input wire [31:0]  probe19 
	// .probe20(adc1_mean0	), // input wire [31:0]  probe20 
	// .probe21(adc0_mean1	), // input wire [31:0]  probe21 
	// .probe22(adc1_mean1	), // input wire [31:0]  probe22 
	// .probe23(chx_start_bpf    ), // input wire [0:0]  probe23 
	// .probe24(adc0_chx_bpf_vld ), // input wire [0:0]  probe24 
	// .probe25(adc0_chx_bpf_data), // input wire [63:0]  probe25 
	// .probe26(adc1_chx_bpf_vld ), // input wire [0:0]  probe26 
	// .probe27(adc1_chx_bpf_data), // input wire [63:0]  probe27 
	// .probe28(chx_start_bpf    ), // input wire [0:0]  probe28 
	// .probe29(r_demod_rd_addr), // input wire [13:0]  probe41 
	// .probe30(ch0_calib_vr_i      ), // input wire [31:0]  probe42 
	// .probe31(ch0_calib_vr_q      ), // input wire [31:0]  probe43 
	// .probe32(calib_vr_vld0    ), // input wire [0:0]  probe44 
	// .probe33(calib_vf_vld0    ), // input wire [0:0]  probe45
	// .probe34(ch0_calib_vf_q      ),
	// .probe35(ch0_calib_vf_i      ) ,
	// .probe36( m1a00_ch0           ),
	// .probe37( m1a01_ch0           ),
	// .probe38( m1a10_ch0           ),
	// .probe39( m1a11_ch0           ),
	// .probe40( m1a00_ch1           ),
	// .probe41( m1a01_ch1           ),
	// .probe42( m1a10_ch1           ),
	// .probe43( m1a11_ch1           ),
	// .probe44(m1a00_chx       ),
	// .probe45(m1a01_chx       ),
	// .probe46(m1a10_chx       ),
	// .probe47(m1a11_chx       )
// );




// ila_rf_mode_R_jx  u_ila_rf_mode_R_jx (
    // .clk     (clk_50m             ),
	
    // .probe0  (VF_POWER0            ),//32
    // .probe1  (VF_POWER_CALIB_K0    ),//16
    // .probe2  (VF_POWER_CALIB_K1   ),//16
    // .probe3  (pulse1_pwm_on       ),
    // .probe4  (CW_MODE             ),
    // .probe5  (PW_MODE             ),  
	// .probe6  (pulse0_pwm_on        ),
    // .probe7  (power_status0        ),
    // .probe8  (VF_POWER0_K_AVG      ),
    // .probe9  (VF_POWER_K1_AVG      ),
	// .probe10 (sensor0_avg_keep    ),
								  
	// .probe11 (VF_POWER0_FILTER     ),//15位定点数
	// .probe12 (w_sensor0_filter_I     ),
								  
    // .probe13 (VF_POWER_CALIB      ),
    // .probe14 (open_status0         ),
	// .probe15 (power_status0        ),
	// .probe16 (R0_result           ),//15位定点数
	// .probe17 (JX0_result          ),
	// .probe18 (R1_result           ),//15位定点数
	// .probe19 (JX1_result          ),
	// .probe20 (sel_multiplex_ch    ),
	// .probe21 (power_no_cali_vf0   ),
	// .probe22 (0   ),
	// .probe23 (tdm_period_cnt      ),
	// .probe24 (sensor0_keep_dly    ),
	// .probe25 (sensor0_pulse_on_cnt),
    // .probe26 (INPUT_SENSOR0_R_AVG	       ),
    // .probe27 (INPUT_SENSOR0_JX_AVG	       ),
    // .probe28 (OUPUT_SENSOR0_R_AVG	       ),
    // .probe29 (OUPUT_SENSOR0_JX_AVG       ),
    // // .probe26 (AVG_IIR_R0          ),
    // // .probe27 (AVG_IIR_JX0         ),
    // // .probe28 (AVG_IIR_R1          ),
    // // .probe29 (AVG_IIR_JX1         ),

	
    // .probe30 (pulse0_pwm_on       ),
	// .probe31 (AVG_IIR_pf0         ),
	// .probe32 (0         ),
    // .probe33 (OS0_I_rise  ),
    // .probe34 (OS0_I_fall  ),
	// .probe35 (OS0_avg_keep    ),
    // .probe36 (R_DOUT0              ),
    // .probe37 (JX_DOUT0             ),
    // .probe38 (TDM_PERIOD          )	
	
// );

// ila_disp_power  u_ila_disp_power (
    // .clk     (clk_50m             ),
	
    // .probe0  (VF_POWER_CALIB_K0        ),
    // .probe1  (w_sensor_avg_V          ),
    // .probe2  (power_no_cali_vf0       ),
    // .probe3  (CW_MODE            ),
    // .probe4  (PW_MODE                 ),
    // .probe5  (vf_power0_calib_disp     ),  
	// .probe6  (vr_power0_calib_disp     ),
    // .probe7  (R_DOUT0           ),
    // .probe8  (JX_DOUT0          ),
    // .probe9  (OS0_R        ),
	// .probe10 (OS0_JX       ), 
	// .probe11 (   0      ),
	// .probe12 (   0      ),
	// .probe13 (R1_DOUT          ),
	// .probe14 (JX1_DOUT         ),
	// .probe15 (pulse1_pwm_on    ),
	// .probe16 (pulse0_pwm_on     ),
    // .probe17 (sensor0_pulse_on_cnt),	
    // .probe18 (OS0_pulse_on_cnt)
// );



// ila_adc_data  ila_adc_demo (

    // .clk      (clk_64m           ),
    // .probe0   (rst_125           ),         
	// .probe1   (i_adc0_data0      ), //11
	// .probe2   (i_adc0_data1      ),
	// .probe3   (AD9238_CH0_vld    ),
	// .probe4   (AD9238_CH0_CHA    ),
	// .probe5   (AD9238_CH0_CHB    ),
	// .probe6   (i_adc1_data0      ),
	// .probe7   (i_adc1_data1      ),
	// .probe8   (AD9238_CH1_vld    ),
	// .probe9   (AD9238_CH1_CHA    ),
	// .probe10  (AD9238_CH1_CHB    ),
	// .probe11  (i_adc2_data0      ),
	// .probe12  (i_adc2_data1      ),	
	// .probe13  (AD9238_CH2_vld    ),	
	// .probe14  (AD9238_CH2_CHA    ),	
	// .probe15  (AD9238_CH2_CHB    )
// );

// ila_1 ila_power_wave (
    // .clk     (clk_50m  ),
    // .probe0  (~rst_125 ),         
	// .probe1  (VF_POWER0), //36
	// .probe2  (VR_POWER0),
	// .probe3  (VF_POWER2),
	// .probe4  (VR_POWER2),
	
	// .probe5  (VF_POWER_CALIB_K0),
	// .probe6  (VR_POWER_CALIB_K0),
	// .probe7  (VF_POWER0_K_AVG),
	// .probe8  (VF_POWER_CALIB_K2),
	// .probe9  (VR_POWER_CALIB_K2),
	// .probe10 (VF_POWER2_K_AVG)
// );

endmodule
